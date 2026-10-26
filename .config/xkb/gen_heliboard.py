#!/usr/bin/env python3
"""Generate the HeliBoard custom layout for typing kana.

One table describes the keyboard.  The file written is a FlorisBoard-style
json layout, which HeliBoard can load from a file:

    .config/xkb/symbols/jprom.json

The keyboard keeps the czech QWERTZ shape, and every key shows the kana it
prints.  The kana sit where gen_kana.py puts the matching romaji gate: j carries
the や row with the small ゃゅょ, x し with the š palatals, v the č gate, c the cu
with the small っ, f ふ with the ファ フィ フェ フォ katakana popups, g the が row
and l the ん; the じ left the ž gate for the czech bottom row, which reads
じ し つ ち ば な ま on y x c v b n m.  The katakana ヴ letters sit on w.  A
blank key only holds the position of a letter without kana; q is blank.  A
long press opens the remaining forms; every popup starts with the key's own
form, so the -a variant is always the first choice.  A key with a single
variant holds only that variant as the default.  A contraction key already
starts with its -a form, so it needs no repeat.
Foreign sounds (ヴ, チェ, ファ, ティ, ディ, シェ, ジェ, ウィ ウェ ウォ, イェ,
ツァ ツィ ツェ ツォ) live in the katakana keyboard only: the shifted
popups carry them and the hiragana popups stay clean.  The last row holds exactly two
keys, so HeliBoard puts them in place of the comma and the period key
next to the spacebar.  The shift key switches hiragana to katakana
(manual shift and shift lock); automatic shift stays hiragana, so the
table holds two kana per entry.

Run it after a table change.  `--check` only reports drift.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / ".config/xkb/symbols/jprom.json"

# czech QWERTZ rows: (hiragana, katakana, [popup h...], [popup k...])
# None key = blank, it only holds the qwertz position
# hiragana None = foreign-only key, blank until shifted
ROWS = [
    [  # q w e r t z u i o p
        None,                                                                    # q
        ("わ", "ワ", ["を"], ["ヲ", "ヴ", "ヴァ", "ヴィ", "ヴェ", "ヴォ"]),                   # w
        ("え", "エ", ["ぇ"], ["ェ"]),                                              # e
        ("ら", "ラ", ["り", "る", "れ", "ろ"], ["リ", "ル", "レ", "ロ"]),                   # r
        ("た", "タ", ["て", "と"], ["テ", "ト", "ティ"]),                                 # t
        ("ざ", "ザ", ["ず", "ぜ", "ぞ"], ["ズ", "ゼ", "ゾ"]),                       # z
        ("う", "ウ", ["ぅ"], ["ゥ", "ウィ", "ウェ", "ウォ"]),                             # u
        ("い", "イ", ["ぃ"], ["ィ", "イェ"]),                                       # i
        ("お", "オ", ["ぉ"], ["ォ"]),                                              # o
        ("ぱ", "パ", ["ぴ", "ぷ", "ぺ", "ぽ"], ["ピ", "プ", "ペ", "ポ"]),                   # p
    ],
    [  # a s d f g h j k l
        ("あ", "ア", ["ぁ"], ["ァ"]),                                              # a
        ("さ", "サ", ["す", "せ", "そ"], ["ス", "セ", "ソ"]),                       # s
        ("だ", "ダ", ["ぢ", "づ", "で", "ど"], ["ヂ", "ヅ", "デ", "ド", "ディ"]),              # d
        ("ふ", "フ", [], ["ファ", "フィ", "フェ", "フォ"]),                                # f
        ("が", "ガ", ["ぎ", "ぐ", "げ", "ご"], ["ギ", "グ", "ゲ", "ゴ"]),                   # g
        ("は", "ハ", ["ひ", "へ", "ほ"], ["ヒ", "ヘ", "ホ"]),                               # h
        ("や", "ヤ", ["ゆ", "よ", "ゃ", "ゅ", "ょ"], ["ユ", "ヨ", "ャ", "ュ", "ョ"]),          # j
        ("か", "カ", ["き", "く", "け", "こ"], ["キ", "ク", "ケ", "コ"]),                   # k
        ("ん", "ン", [], []),                                                     # l
    ],
    [  # y x c v b n m — the czech bottom row
        ("じ", "ジ", ["じゃ", "じゅ", "じょ"], ["ジャ", "ジュ", "ジョ", "ジェ"]),                  # y
        ("し", "シ", ["しゃ", "しゅ", "しょ"], ["シャ", "シュ", "ショ", "シェ"]),                  # x
        ("つ", "ツ", ["っ"], ["ッ", "ツァ", "ツィ", "ツェ", "ツォ"]),                     # c
        ("ち", "チ", ["ちゃ", "ちゅ", "ちょ"], ["チャ", "チュ", "チョ", "チェ"]),          # v
        ("ば", "バ", ["び", "ぶ", "べ", "ぼ"], ["ビ", "ブ", "ベ", "ボ"]),                   # b
        ("な", "ナ", ["に", "ぬ", "ね", "の"], ["ニ", "ヌ", "ネ", "ノ"]),                   # n
        ("ま", "マ", ["み", "む", "め", "も"], ["ミ", "ム", "メ", "モ"]),                   # m
    ],
    [  # exactly two keys: HeliBoard moves them next to the spacebar
        ("、", "、", [], []),                                                     # comma slot
        ("。", "。", ["ー"], ["ー"]),                                              # period slot
    ],
]


CONTRACTIONS = ("ゃ", "ゅ", "ょ", "ャ", "ュ", "ョ")


def with_default(kana, popups):
    """Start a multi-variant kana popup with the key's own form."""
    if not popups:
        return popups
    if len(popups) == 1:
        return popups  # a lone variant is the default, the base would only block it
    if not ("\u3040" <= kana <= "\u309f" or "\u30a0" <= kana <= "\u30ff"):
        return popups
    if popups[0] == kana:
        return popups
    if popups[0].startswith(kana) and popups[0][len(kana):] in CONTRACTIONS:
        return popups  # an -a contraction needs no repeat
    return [kana] + popups


def branch(kana, popups):
    popups = with_default(kana, popups)
    key = {"label": kana}
    if popups:
        order = [{"label": "!fixedColumnOrder!%d" % len(popups)}] if len(popups) > 1 else []
        key["popup"] = {"relevant": order + [{"label": p} for p in popups]}
    return key


def key_data(entry):
    if entry is None:
        return {"type": "placeholder"}
    hira, kata, hira_popups, kata_popups = entry
    if hira is None:  # foreign-only key: blank until the shift switches the script
        return {"$": "shift_state_selector",
                "manualOrLocked": branch(kata, kata_popups),
                "default": {"type": "placeholder"}}
    if hira == kata and hira_popups == kata_popups:
        return branch(hira, hira_popups)
    return {"$": "shift_state_selector",
            "manualOrLocked": branch(kata, kata_popups),
            "default": branch(hira, hira_popups)}


def layout():
    return [[key_data(entry) for entry in row] for row in ROWS]


def text():
    body = json.dumps(layout(), ensure_ascii=False, indent=2)
    return "// generated by .config/xkb/gen_heliboard.py - edit the script, not this file.\n" + body + "\n"


def validate():
    """Every form lives on one key and a multi-kana form starts on its own key."""
    homes = {}
    for i, row in enumerate(ROWS):
        for j, entry in enumerate(row):
            if not entry:
                continue
            hira, kata, hp, kp = entry
            branches = [(kata, kp)] if hira is None else [(hira, hp), (kata, kp)]
            for label, popups in branches:
                forms = [label] + with_default(label, popups)
                for form in forms:
                    assert homes.setdefault(form, (i, j)) == (i, j), \
                        "form %r lives on two keys" % form
                    if len(form) > 1:
                        assert form[0] in forms, \
                            "form %r starts outside its key" % form


def main(argv):
    validate()
    check = "--check" in argv[1:]
    want = text()
    have = OUT.read_text(encoding="utf-8") if OUT.exists() else ""
    if have == want:
        print("unchanged %s" % OUT.relative_to(ROOT))
        return 0
    if check:
        print("DRIFT     %s" % OUT.relative_to(ROOT))
        return 1
    OUT.write_text(want, encoding="utf-8")
    print("wrote     %s" % OUT.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
