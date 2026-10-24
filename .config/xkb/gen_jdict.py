#!/usr/bin/env python3
"""Convert JMdict into a HeliBoard kanji-suggestion dictionary.

Typing hiragana suggests the kanji word: every reading becomes a
not_a_word entry of the combined wordlist, and its kanji forms become
the shortcuts the keyboard suggests.

    .config/xkb/main_ja.combined   (written whole)

`--locale th_TH` writes main_th.combined instead: the header language
decides which subtype's typing queries the wordlist. HeliBoard compiles
the file on import. JMdict by the EDRDG is CC BY-SA 4.0; the
attribution travels in the header. Run it after a JMdict update.
`--check` only reports drift.
"""
import gzip
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CACHE = Path.home() / ".cache/gen_jdict/JMdict_e.gz"
URL = "https://www.edrdg.org/pub/Nihongo/JMdict_e.gz"

# the user can type hiragana and ー; JMdict has a few latin readings
TYPEABLE = re.compile(r"[ぁ-ゖー]+")
# a shortcut must contain a kanji: JMdict also lists greek, kana and
# latin headwords
KANJI = re.compile("[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff\U00020000-\U0002a6df]")


# katakana converts to hiragana by codepoint; ー and ・ keep theirs
def hira(s):
    return "".join(chr(ord(c) - 0x60) if "ァ" <= c <= "ヺ" else c for c in s)


# nf01..nf48 rank the 48000 most frequent words of the Mainichi
# newspaper; ichi, news, spec and gai mark common words, 2 less common
def freq(pris):
    nf = [int(p[2:]) for p in pris if p[:2] == "nf"]
    if nf:
        return max(159, 255 - 2 * min(nf))
    if pris & {"ichi1", "news1", "spec1", "gai1"}:
        return 150
    if pris & {"ichi2", "news2", "spec2", "gai2"}:
        return 120
    return 60


def add(words, word, shortcut, f):
    sc = words.setdefault(word, {})
    if sc.get(shortcut, 0) < f:
        sc[shortcut] = f


def load():
    if not CACHE.exists():
        CACHE.parent.mkdir(parents=True, exist_ok=True)
        print("downloading %s" % URL)
        urllib.request.urlretrieve(URL, CACHE)
    words = {}
    with gzip.open(CACHE, "rb") as fh:
        for _, elem in ET.iterparse(fh, events=("end",)):
            if elem.tag != "entry":
                continue
            kanji = [(k.findtext("keb"), {p.text for p in k.findall("ke_pri")})
                     for k in elem.findall("k_ele")]
            kanji = [k for k in kanji if KANJI.search(k[0])]
            for r in elem.findall("r_ele"):
                if r.find("re_nokanji") is not None or not kanji:
                    continue
                reb = r.findtext("reb")
                rpri = {p.text for p in r.findall("re_pri")}
                restr = {x.text for x in r.findall("re_restr")}
                for keb, kpri in kanji:
                    if restr and keb not in restr:
                        continue
                    add(words, hira(reb), keb, freq(kpri | rpri))
            elem.clear()
    return {w: sc for w, sc in words.items() if TYPEABLE.fullmatch(w)}


def combined_text(words, locale):
    out = [
        "# Typing the hiragana suggests the kanji.",
        "# Data: JMdict by the EDRDG, CC BY-SA 4.0.",
        "dictionary=main:%s,locale=%s,description=JMdict kanji suggestions"
        " (EDRDG CC BY-SA 4.0),date=%d,version=54"
        % (locale.lower(), locale, int(CACHE.stat().st_mtime)),
    ]
    for word in sorted(words):
        sc = words[word]
        out.append(" word=%s,f=%d,not_a_word=true" % (word, max(sc.values())))
        for shortcut, f in sorted(sc.items(), key=lambda kv: (-kv[1], kv[0])):
            out.append("  shortcut=%s,f=%d" % (shortcut, f))
    return "\n".join(out) + "\n"


def main(argv):
    check = "--check" in argv[1:]
    locale = argv[argv.index("--locale") + 1] if "--locale" in argv else "ja_JP"
    out = ROOT / (".config/xkb/main_%s.combined" % locale.split("_")[0].lower())
    words = load()
    want = combined_text(words, locale)
    have = out.read_text(encoding="utf-8") if out.exists() else ""
    if have == want:
        print("unchanged %s" % out.relative_to(ROOT))
    elif check:
        print("DRIFT     %s" % out.relative_to(ROOT))
    else:
        out.write_text(want, encoding="utf-8")
        print("wrote     %s" % out.relative_to(ROOT))
    print("%d readings, %d suggestions" % (len(words), sum(len(s) for s in words.values())))
    return 1 if check and have != want else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
