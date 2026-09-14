#pragma once
#include <atomic>
#include <chrono>
#include <map>
#include <mutex>
#include <unordered_map>

using system_clock = std::chrono::high_resolution_clock;
using time_point_t = system_clock::time_point;
using duration_t = std::chrono::nanoseconds;

struct ProfileStats {
    int64_t total_ns = 0;
    size_t count = 0;

    void add(int64_t ns)
    {
        total_ns += ns;
        ++count;
    }
};

namespace aprof {
inline std::atomic<int_fast8_t> threads { 0 };

// Global merged stats (one entry per region across all threads)
static std::map<std::string, ProfileStats> g_profile_stats;
static std::mutex g_profile_mutex;

// Per‑thread data that will be merged on thread exit
class ThreadProfile {
    int thr;

public:
    ThreadProfile()
        : thr(threads.fetch_add(1))
    {
        // printf("Started T%d\n", thr);
    }
    std::unordered_map<std::string, ProfileStats> stats;

    ~ThreadProfile()
    {
        std::lock_guard<std::mutex> lock(g_profile_mutex);
        for (const auto& [name, s] : stats) {
            auto& g = g_profile_stats[name];
            g.total_ns += s.total_ns;
            g.count += s.count;
        }

        int tcnt = threads.fetch_sub(1);
        // printf("Ended T%d of %d\n", thr, tcnt);
        if (tcnt <= 1) {
            // Only main thread prints; avoid multiple full prints
            for (const auto& [name, stats] : g_profile_stats) {
                double avg_ns = stats.count > 0
                    ? double(stats.total_ns) / stats.count
                    : 0.0;

                printf("%-16s: %7zu ms / %7zu = %6zu us\n", name.c_str(),
                       stats.total_ns / 1000000, stats.count,
                       int64_t(avg_ns) / 1000);
            }
        }
    }
};

// One per thread, destroyed when the thread exits
inline thread_local ThreadProfile tl_profile;

class ScopedProfile {
public:
    explicit ScopedProfile(const char* name)
        : name_(name)
        , start_(system_clock::now())
    {
    }

    ~ScopedProfile()
    {
        auto end = system_clock::now();
        auto delta_ns =
            std::chrono::duration_cast<duration_t>(end - start_).count();

        tl_profile.stats[name_].add(delta_ns);
    }

private:
    const char* name_;
    time_point_t start_;
};
} // namespace aprof

#define PROFILE_SCOPE(name) \
    aprof::ScopedProfile _scoped_profile_##__LINE__(name);
