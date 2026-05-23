#!/usr/bin/env python3
import re
import sys
import math
from collections import defaultdict

def parse_results(input_file):
    commits = defaultdict(lambda: defaultdict(list))
    current_commit = None
    
    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip()
            
            if line.startswith('# '):
                current_commit = line[2:].strip()
            elif line.startswith('Total:') or line.startswith('Took:'):
                match = re.match(r'(?:Total|Took):\s*cpu=([\d.]+)', line)
                if match and current_commit:
                    commits[current_commit]['total_times'].append(float(match.group(1)))
            elif ':' in line and '=' in line:
                # Match: method : X ms / Y = Z us
                match = re.match(r'(\S+)\s*:\s*([\d.]+)\s+ms\s*/\s*(\d+)\s*=\s*([\d.]+)\s+us', line)
                if match and current_commit:
                    method = match.group(1)
                    total_ms = float(match.group(2))
                    count = int(match.group(3))
                    us_per_call = float(match.group(4))
                    commits[current_commit][method].append({
                        'total_ms': total_ms,
                        'count': count,
                        'us_per_call': us_per_call
                    })
    
    return commits

def round_to_two_digits(n):
    """Round to first two significant digits using log10."""
    if n == 0:
        return 0
    exp = int(math.log10(abs(n)))
    scale = 10 ** (exp - 1)
    return round(n / scale) * scale

def format_value(n):
    """Format value with 3 significant digits using log10."""
    if n == 0:
        return "0"
    # Calculate the exponent for 3 significant digits
    exp = int(math.log10(abs(n)))
    # We want 3 sig digits, so scale by 10^(exp-2)
    scale = 10 ** (exp - 2)
    rounded = round(n / scale) * scale
    # Format without trailing zeros
    if rounded == int(rounded):
        return str(int(rounded))
    else:
        return f"{rounded:g}"

def compute_averages(commits):
    aggregated = {}
    
    # First, collect all counts per method across all commits to get global average
    all_method_counts = defaultdict(list)
    for commit_data in commits.values():
        for method, runs in commit_data.items():
            if method != 'total_times':
                for run in runs:
                    all_method_counts[method].append(run['count'])
    
    global_avg_counts = {m: sum(counts) / len(counts) for m, counts in all_method_counts.items()}
    # Round to two significant digits
    global_avg_counts_rounded = {m: round_to_two_digits(avg) for m, avg in global_avg_counts.items()}
    
    for commit, data in commits.items():
        agg = {}
        
        if 'total_times' in data:
            times = data['total_times']
            avg_time = sum(times) / len(times)
            sorted_times = sorted(times)
            n = len(sorted_times)
            low_idx = max(0, int(n * 0.01) - 1)
            high_idx = min(n - 1, int(n * 0.99))
            med_idx = n // 2
            agg['total'] = {
                'avg': avg_time,
                'best': sorted_times[low_idx],
                'worst': sorted_times[high_idx],
                'median': sorted_times[med_idx]
            }
        
        for method, runs in data.items():
            if method == 'total_times':
                continue
            
            total_ms_sum = sum(r['total_ms'] for r in runs)
            total_count = sum(r['count'] for r in runs)
            num_runs = len(runs)
            
            # Average ms per call across all runs
            avg_ms_per_call = total_ms_sum / total_count if total_count > 0 else 0
            
            # Normalized: what would this take with the global average number of calls?
            global_avg = global_avg_counts_rounded.get(method, 1)
            normalized_ms = avg_ms_per_call * global_avg
            
            agg[method] = {
                'total_ms': total_ms_sum,
                'num_runs': num_runs,
                'total_count': total_count,
                'global_avg_count': global_avg,
                'avg_ms': avg_ms_per_call,
                'normalized_ms': normalized_ms
            }
        
        aggregated[commit] = agg
    
    return aggregated

def extract_commit_info(commit_name):
    match = re.match(r'^([a-zA-Z0-9]+)\s+(.*)', commit_name)
    if match:
        return match.group(1), match.group(2).strip()
    match = re.match(r'^([a-zA-Z0-9]+)$', commit_name)
    if match:
        return match.group(1), ""
    return commit_name, ""

def print_table(lines, headers, rows, align='right'):
    """Print a markdown table with proper alignment."""
    if not rows:
        return
    
    # Calculate column widths as max of header and first data row
    col_widths = []
    for i, h in enumerate(headers):
        # Handle multi-line headers (with <br>)
        h_lines = h.split('<br>')
        max_h_len = max(len(line) for line in h_lines)
        width = max(max_h_len, len(str(rows[0][i])))
        col_widths.append(width)
    
    # Build header row - keep <br> as literal text in single line
    header_parts = []
    for i, h in enumerate(headers):
        if align == 'left':
            header_parts.append(h.ljust(col_widths[i]))
        else:
            header_parts.append(h.rjust(col_widths[i]))
    lines.append("| " + " | ".join(header_parts) + " |")
    
    # Build separator row
    sep_parts = ["-" * col_widths[0]]
    for w in col_widths[1:]:
        sep_parts.append("-" * w)
    lines.append("| " + " | ".join(sep_parts) + " |")
    
    # Build data rows
    for row in rows:
        row_parts = [row[0]]
        for i, val in enumerate(row[1:], 1):
            val_str = str(val)
            if align == 'left':
                row_parts.append(val_str.ljust(col_widths[i]))
            else:
                row_parts.append(val_str.rjust(col_widths[i]))
        lines.append("| " + " | ".join(row_parts) + " |")

def format_tables(aggregated):
    lines = []
    commits = list(aggregated.keys())
    
    # Legend
    lines.append("## Legend")
    lines.append("")
    for i, commit in enumerate(commits, 1):
        short_hash, desc = extract_commit_info(commit)
        lines.append(f"{i}. `{short_hash}` - {desc}")
    lines.append("")
    
    # Total Times table
    lines.append("## Total Cpu time (s)")
    lines.append("")
    total_headers = ["Commit", "Best", "Avg", "Median", "Worst"]
    total_rows = []
    for commit in commits:
        data = aggregated[commit]
        if 'total' in data:
            t = data['total']
            short_hash, _ = extract_commit_info(commit)
            total_rows.append([
                short_hash,
                f"{t['best']:.0f}",
                f"{t['avg']:.0f}",
                f"{t['median']:.0f}",
                f"{t['worst']:.0f}"
            ])
    print_table(lines, total_headers, total_rows)
    lines.append("")
    
    # Call Averages tables by prefix
    all_methods = set()
    for data in aggregated.values():
        for key in data.keys():
            if key != 'total':
                all_methods.add(key)
    
    lines.append("## Call avg (ms) per avg number of runs")
    lines.append("")
    
    # Group methods by prefix (auto-detect from data)
    prefixes = sorted(set(m.split(':')[0] for m in all_methods))
    for prefix in prefixes:
        methods = sorted([m for m in all_methods if m.startswith(prefix)])
        if not methods:
            continue
        
        lines.append(f"### {prefix.upper()}")
        lines.append("")
        
        method_names = [m.split(':')[1] for m in methods]
        headers = ["Commit"]
        for name, method in zip(method_names, methods):
            if method in aggregated[commits[0]]:
                global_avg = aggregated[commits[0]][method]['global_avg_count']
            else:
                global_avg = 0
            headers.append(f"{name}<br>{global_avg}")
        
        rows = []
        for commit in commits:
            data = aggregated[commit]
            short_hash, _ = extract_commit_info(commit)
            row = [short_hash]
            for method in methods:
                if method in data:
                    # Show normalized ms (per global average number of calls) formatted with 2 sig digits
                    row.append(format_value(data[method]['normalized_ms']))
                else:
                    row.append("-")
            rows.append(row)
        
        print_table(lines, headers, rows)
        lines.append("")
    
    return '\n'.join(lines)

if __name__ == '__main__':
    input_file = sys.argv[1] if len(sys.argv) > 1 else 'results_raw.md'
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'results.md'
    
    commits = parse_results(input_file)
    aggregated = compute_averages(commits)
    output = format_tables(aggregated)
    
    with open(output_file, 'w') as f:
        f.write(output)
    
    print(f"Wrote aggregated results to {output_file}")
