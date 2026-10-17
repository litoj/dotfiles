#!/usr/bin/env python3
"""Generate the romaji compose table and the jprom kana overlay.

One table drives both outputs, so the private marker numbers in the
layout and in ~/.XCompose cannot drift:

    .XCompose                      (written whole)
    .config/xkb/symbols/jprom      (written whole)

Run it after a table change.  `--check` only reports drift.
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
XCOMPOSE = ROOT / ".XCompose"
JPROM = ROOT / ".config/xkb/symbols/jprom"

# the v gate is appended last, so the existing letter markers keep their numbers
LETTERS = "a i u e o k s š z ž t d n p h g m j y r w b c č f v".split()
PAUSE = "-"
STANDALONE = LETTERS + [PAUSE]          # keys with no romaji sequence
M = {ch: 0x01 + i for i, ch in enumerate(STANDALONE)}
KATA = len(STANDALONE)                  # katakana marker offset
GEM_CONS = set("ksšzžtdphgmrbcčf")      # doubled first letter -> っ
PUNCT_BASE = 0x01 + 2 * len(STANDALONE) # punctuation markers follow both blocks

# czech QWERTZ position of each letter, used for the xkb overlay
KEYS = {
    'a': 'AC01', 'i': 'AD08', 'u': 'AD07', 'e': 'AD03', 'o': 'AD09',
    'k': 'AC08', 's': 'AC02', 'š': 'AE03', 'z': 'AD06', 'ž': 'AE06',
    't': 'AD05', 'd': 'AC03', 'n': 'AB06', 'p': 'AD10', 'h': 'AC06',
    'g': 'AC05', 'm': 'AB07', 'j': 'AC07', 'y': 'AB01', 'r': 'AD04',
    'w': 'AD02', 'b': 'AB05', 'c': 'AB03', 'č': 'AE04', 'f': 'AC04', 'v': 'AB04',
}
PAUSE_KEYS = ['TLDE']                   # the pause moved here

# single-character keys: one marker, the same char on both NL6 levels
PUNCT = [
    ('AB09', '。'),      # the period key -> ideographic full stop
    ('AE11', 'ー'), ('AB10', 'ー'),     # the - positions
    ('AE12', 'ー'),                     # czech ´ / US =
    ('AB08', '、'),        # the comma key -> ideographic comma
]

# (section title, [(spelling, hiragana), ...])
ROWS = [
    # base rows, in gojuon order
    ("a", [
        ("a", "あ"), ("i", "い"), ("u", "う"), ("e", "え"), ("o", "お"),
    ]),
    ("k", [
        ("ka", "か"), ("ki", "き"), ("ku", "く"), ("ke", "け"), ("ko", "こ"),
    ]),
    ("g", [
        ("ga", "が"), ("gi", "ぎ"), ("gu", "ぐ"), ("ge", "げ"), ("go", "ご"),
    ]),
    ("s", [
        ("sa", "さ"), ("si", "し"), ("ši", "し"), ("su", "す"), ("se", "せ"), ("so", "そ"), ("s'", "す"),
    ]),
    ("z", [
        ("za", "ざ"), ("zi", "じ"), ("ži", "じ"), ("dži", "じ"), ("ji", "じ"), ("yi", "じ"), ("zu", "ず"), ("ze", "ぜ"), ("zo", "ぞ"),
    ]),
    ("t", [
        ("ta", "た"), ("či", "ち"), ("ci", "ち"), ("cu", "つ"), ("te", "て"), ("to", "と"),
    ]),
    ("dz", [
        ("da", "だ"), ("dzi", "ぢ"), ("dzu", "づ"), ("dyu", "づ"), ("de", "で"), ("do", "ど"),
    ]),
    ("n", [
        ("na", "な"), ("ni", "に"), ("nu", "ぬ"), ("ne", "ね"), ("no", "の"),
    ]),
    ("h", [
        ("ha", "は"), ("hi", "ひ"), ("hu", "ふ"), ("fu", "ふ"), ("he", "へ"), ("ho", "ほ"),
    ]),
    ("b", [
        ("ba", "ば"), ("bi", "び"), ("bu", "ぶ"), ("be", "べ"), ("bo", "ぼ"),
    ]),
    ("p", [
        ("pa", "ぱ"), ("pi", "ぴ"), ("pu", "ぷ"), ("pe", "ぺ"), ("po", "ぽ"),
    ]),
    ("m", [
        ("ma", "ま"), ("mi", "み"), ("mu", "む"), ("me", "め"), ("mo", "も"),
    ]),
    ("j", [
        ("ja", "や"), ("ju", "ゆ"), ("jo", "よ"), ("ya", "や"), ("yu", "ゆ"), ("yo", "よ"),
    ]),
    ("r", [
        ("ra", "ら"), ("ri", "り"), ("ru", "る"), ("re", "れ"), ("ro", "ろ"),
    ]),
    ("w", [
        ("wa", "わ"), ("wo", "を"),
    ]),
    ("nn", [
        ("nn", "ん"), ("n'", "ん"), ("nna", "んな"), ("nni", "んに"), ("nnu", "んぬ"), ("nne", "んね"), ("nno", "んの"),
    ]),
    # the small-kana contractions, by the small vowel
    ("small -a", [
        ("kja", "きゃ"), ("gja", "ぎゃ"), ("ša", "しゃ"), ("ža", "じゃ"), ("dža", "じゃ"), ("ča", "ちゃ"), ("nja", "にゃ"), ("chja", "ひゃ"), ("bja", "びゃ"), ("pja", "ぴゃ"), ("mja", "みゃ"), ("dja", "りゃ"),
    ]),
    ("small -u", [
        ("kju", "きゅ"), ("gju", "ぎゅ"), ("šu", "しゅ"), ("žu", "じゅ"), ("džu", "じゅ"), ("ču", "ちゅ"), ("nju", "にゅ"), ("chju", "ひゅ"), ("bju", "びゅ"), ("pju", "ぴゅ"), ("mju", "みゅ"), ("dju", "りゅ"),
    ]),
    ("small -o", [
        ("kjo", "きょ"), ("gjo", "ぎょ"), ("šo", "しょ"), ("žo", "じょ"), ("džo", "じょ"), ("čo", "ちょ"), ("njo", "にょ"), ("chjo", "ひょ"), ("bjo", "びょ"), ("pjo", "ぴょ"), ("mjo", "みょ"), ("djo", "りょ"),
    ]),
    # full-size や/ゆ/よ, kept where czech reads them right
    ("full -a", [
        ("kya", "きや"), ("gya", "ぎや"), ("nya", "にや"), ("chya", "ひや"), ("bya", "びや"), ("pya", "ぴや"), ("mya", "みや"), ("rya", "りや"),
    ]),
    ("full -u", [
        ("kyu", "きゆ"), ("gyu", "ぎゆ"), ("nyu", "にゆ"), ("chyu", "ひゆ"), ("byu", "びゆ"), ("pyu", "ぴゆ"), ("myu", "みゆ"), ("ryu", "りゆ"),
    ]),
    ("full -o", [
        ("kyo", "きよ"), ("gyo", "ぎよ"), ("nyo", "によ"), ("chyo", "ひよ"), ("byo", "びよ"), ("pyo", "ぴよ"), ("myo", "みよ"), ("ryo", "りよ"),
    ]),
    # foreign sounds; hiragana small forms, katakana comes from the usual offset
    ("foreign", [
        ("fa", "ふぁ"), ("fi", "ふぃ"), ("fe", "ふぇ"), ("fo", "ふぉ"),
        ("va", "ゔぁ"), ("vi", "ゔぃ"), ("vu", "ゔ"), ("ve", "ゔぇ"), ("vo", "ゔぉ"),
        ("če", "ちぇ"), ("še", "しぇ"), ("že", "じぇ"),
        ("tyi", "てぃ"), ("dyi", "でぃ"),
        ("wi", "うぃ"), ("we", "うぇ"), ("wu", "うぉ"),
        ("ye", "いぇ"),
        ("ca", "つぁ"), ("cyi", "つぃ"), ("ce", "つぇ"), ("co", "つぉ"),
    ]),
]


def kata(out):
    return "".join(chr(ord(ch) + 0x60) for ch in out)


def rule(spell, out, katakana=False):
    off = KATA if katakana else 0
    seq = []
    for ch in spell:
        seq.append("apostrophe" if ch == "'" else "UE%03X" % (M[ch] + off))
    return "%s : \"%s\"" % (" ".join("<%s>" % k for k in seq),
                            kata(out) if katakana else out)


# flatten, keeping section structure and detecting collisions early
rules = {}
table = []
for title, items in ROWS:
    for spell, out in items:
        assert spell not in rules, "duplicate spelling %r" % spell
        rules[spell] = out
        table.append((spell, out))

# geminates: double the first letter of the spelling. The full-size
# や/ゆ/よ of the english-style XyV forms never follow っ.
gems = []
for spell, out in table:
    c = spell[0]
    if c in GEM_CONS and "'" not in spell and not any(ch in "やゆよ" for ch in out):
        g = c + spell
        assert g not in rules, "geminate collision %r" % g
        rules[g] = "っ" + out
        gems.append((g, "っ" + out))

# bare doubled consonant -> っ
bare = []
for c in sorted(GEM_CONS):
    d = c + c
    assert d not in rules, "bare collision %r" % d
    rules[d] = "っ"
    bare.append((d, "っ"))

# base vowels must commit at once: no longer spelling may start with one
for spell in rules:
    assert len(spell) == 1 or spell[0] not in "aiueo", \
        "vowel-initial spelling %r" % spell


def emit(items, katakana):
    return "\n".join(rule(s, o, katakana) for s, o in items)


SPELLING_DOC = [
    "# Spelling follows czech pronunciation. The small ゃゅょ come from",
    "# j or from the czech palatal letter; a doubled first letter and",
    "# the - key both give っ; nn before a vowel joins the な row,",
    "# n' and s' commit ん and す anywhere.",
    "# Foreign sounds: f, v or c plus a vowel (ファ ヴァ ツァ and friends),",
    "# če še že (チェ シェ ジェ), tyi dyi (ティ ディ), wi we wu ye (ウィ ウェ ウォ イェ).",
    "# Base vowels never compose: they commit their kana at once.",
]


# ------------------------------------------------------------------ compose
def compose_text():
    out = []
    out.append("# Romaji sequences for the jprom(kana) NumLock-gated overlay.")
    out.append("# Generated by .config/xkb/gen_kana.py - edit the script, not this file.")
    out.append("# Markers: one hole-free block in this order from U+E001")
    out.append("# (hiragana); the katakana block mirrors it, punctuation follows.")
    out.append("#   a i u e o  k s š z ž t d n p h g m j y r w b  c č f v  -")
    out.append("# The same markers sit on the same czech QWERTZ positions")
    out.append("# on both the US romaji and the czech layout.")
    out.extend(SPELLING_DOC)
    out.append('include "%L"')

    out.append("\n# ---- hiragana ----")
    for title, items in ROWS:
        out.append("\n# %s" % title)
        out.append(emit(items, False))

    out.append("\n# no children: -ka commits っ, then starts a fresh か")
    out.append("<UE%03X> : \"っ\"" % M[PAUSE])
    out.append("\n# the bare rule must come first, or the engine commits っ early")
    out.append(emit(bare, False))
    out.append(emit(gems, False))

    out.append("\n# ---- katakana (same order, kana + 0x60) ----")
    for title, items in ROWS:
        out.append("\n# %s" % title)
        out.append(emit(items, True))

    out.append("<UE%03X> : \"ッ\"" % (M[PAUSE] + KATA))
    out.append(emit(bare, True))
    out.append(emit(gems, True))

    out.append("\n# ---- punctuation ----")
    for i, (key, ch) in enumerate(PUNCT):
        out.append("<UE%03X> : \"%s\"" % (PUNCT_BASE + i, ch))

    return "\n".join(out) + "\n"


# ------------------------------------------------------------------- jprom
JPROM_HEADER = "// generated by .config/xkb/gen_kana.py - edit the script, not this file."


def jprom_text():
    out = [JPROM_HEADER, "", "partial alphanumeric_keys", 'xkb_symbols "kana" {', ""]
    for ch in LETTERS:
        out.append('\tkey <%s>\t{ type[1]="NL6_GATE", [ any, any, any, any, UE%03X, UE%03X ]};'
                   % (KEYS[ch], M[ch], M[ch] + KATA))
    out.append("")
    for k in PAUSE_KEYS:
        out.append('\tkey <%s>\t{ type[1]="NL6_GATE", [ any, any, any, any, UE%03X, UE%03X ]};'
                   % (k, M[PAUSE], M[PAUSE] + KATA))
    out.append("")
    for i, (key, ch) in enumerate(PUNCT):
        out.append('\tkey <%s>\t{ type[1]="NL6_GATE", [ any, any, any, any, UE%03X, UE%03X ]};'
                   % (key, PUNCT_BASE + i, PUNCT_BASE + i))
    out.append("};")
    return "\n".join(out) + "\n"


def main(argv):
    check = "--check" in argv[1:]
    drift = False
    for path, want in ((XCOMPOSE, compose_text()), (JPROM, jprom_text())):
        have = path.read_text(encoding="utf-8") if path.exists() else ""
        if have == want:
            print("unchanged %s" % path.relative_to(ROOT))
        elif check:
            print("DRIFT     %s" % path.relative_to(ROOT))
            drift = True
        else:
            path.write_text(want, encoding="utf-8")
            print("wrote     %s" % path.relative_to(ROOT))

    per_script = len(table) + len(gems) + len(bare) + 1
    print("markers U+E001..U+E%03X + U+E%03X..U+E%03X, punctuation U+E%03X..U+E%03X, %d kana rules"
          % (M[PAUSE], M[LETTERS[0]] + KATA, M[PAUSE] + KATA,
             PUNCT_BASE, PUNCT_BASE + len(PUNCT) - 1, 2 * per_script))
    return 1 if drift else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
