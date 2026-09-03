"""Pinpoint where two replay-text dumps (C# --replay-text, GDScript --replay-text)
first differ, per day: which planet block (split on '|'), and the first differing
character with context.

    python tools/diff_replay_text.py cs-replay.txt gd-replay.txt [day]
"""
import sys


def load(path):
    out = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            if "\t" not in line:
                continue
            day, text = line.split("\t", 1)
            out[int(day)] = text
    return out


def main():
    a, b = load(sys.argv[1]), load(sys.argv[2])
    days = [int(sys.argv[3])] if len(sys.argv) > 3 else sorted(set(a) & set(b))
    for day in days:
        x, y = a.get(day), b.get(day)
        if x is None or y is None:
            print(f"day {day}: missing on one side")
            continue
        if x == y:
            print(f"day {day}: identical ({len(x)} chars)")
            continue
        xs, ys = x.split("|"), y.split("|")
        print(f"day {day}: DIFFER - C# {len(x)} chars / {len(xs)} blocks, GD {len(y)} chars / {len(ys)} blocks")
        shown = 0
        for i, (p, q) in enumerate(zip(xs, ys)):
            if p != q:
                k = next((j for j in range(min(len(p), len(q))) if p[j] != q[j]), min(len(p), len(q)))
                print(f"  block {i}: first diff at char {k}")
                print(f"    C#: {p[max(0, k - 60):k + 80]}")
                print(f"    GD: {q[max(0, k - 60):k + 80]}")
                shown += 1
                if shown >= 5:
                    break
        if len(xs) != len(ys):
            print(f"  block count differs: {len(xs)} vs {len(ys)}")
        if shown == 0:
            k = next((j for j in range(min(len(x), len(y))) if x[j] != y[j]), min(len(x), len(y)))
            print(f"  tail diff at char {k}: C# ...{x[max(0,k-80):k+80]} | GD ...{y[max(0,k-80):k+80]}")
        if len(sys.argv) <= 3:
            break   # the first differing day is enough


if __name__ == "__main__":
    main()
