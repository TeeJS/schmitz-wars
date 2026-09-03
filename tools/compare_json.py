"""Field-level comparison of two canonical DTO dumps (HANDOFF step 1A gate).

    python tools/compare_json.py cs-dto.json gd-dto.json

Compares the PARSED structures, so formatting differences (indentation, 5 vs
5.0, key escaping) do not count; null vs 0, missing vs present, and every value
do. Prints every difference with its path, then a per-dataset summary. Exit 0
only on zero differences.
"""
import json
import sys


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def same_number(a, b):
    return isinstance(a, (int, float)) and isinstance(b, (int, float)) \
        and not isinstance(a, bool) and not isinstance(b, bool) and a == b


def diff(a, b, path, out):
    if isinstance(a, dict) and isinstance(b, dict):
        for k in sorted(set(a) | set(b)):
            if k not in a:
                out.append((path + "/" + k, "<missing in C#>", b[k]))
            elif k not in b:
                out.append((path + "/" + k, a[k], "<missing in GDScript>"))
            else:
                diff(a[k], b[k], path + "/" + k, out)
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            out.append((path, f"<{len(a)} items>", f"<{len(b)} items>"))
        for i, (x, y) in enumerate(zip(a, b)):
            diff(x, y, f"{path}[{i}]", out)
    else:
        if a is None and b is None:
            return
        # GDScript's String cannot be null: a C# string that deserialised as null
        # is "" on the port side. The port's translation rule is is_empty() where
        # C# says == null on a string (HANDOFF §4b).
        if a is None and b == "":
            return
        if same_number(a, b):
            return
        if type(a) is bool or type(b) is bool:
            if a is b:
                return
        elif a == b:
            return
        out.append((path, a, b))


def main():
    cs, gd = load(sys.argv[1]), load(sys.argv[2])
    out = []
    diff(cs, gd, "", out)
    by_dataset = {}
    for p, a, b in out:
        ds = p.split("/")[1].split("[")[0] if "/" in p else p
        by_dataset[ds] = by_dataset.get(ds, 0) + 1
    for p, a, b in out[:200]:
        print(f"  {p}: C#={a!r}  GD={b!r}")
    if len(out) > 200:
        print(f"  ... {len(out) - 200} more")
    print()
    for ds in sorted(set(cs) | set(gd)):
        n = by_dataset.get(ds, 0)
        size = len(cs.get(ds) or []) if isinstance(cs.get(ds), (list, dict)) else 1
        print(f"  {ds:24s} {size:5d} records  {n:5d} diffs  {'OK' if n == 0 else 'FAIL'}")
    print()
    print("PASS" if not out else f"FAIL: {len(out)} differences")
    sys.exit(0 if not out else 1)


if __name__ == "__main__":
    main()
