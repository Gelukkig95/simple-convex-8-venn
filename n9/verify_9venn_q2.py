import argparse
import json
import time
from fractions import Fraction


def orient(a, b, c):
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def seg_cross_exact(p1, p2, q1, q2):
    if (
        max(p1[0], p2[0]) < min(q1[0], q2[0])
        or max(q1[0], q2[0]) < min(p1[0], p2[0])
        or max(p1[1], p2[1]) < min(q1[1], q2[1])
        or max(q1[1], q2[1]) < min(p1[1], p2[1])
    ):
        return (False, None)
    dx1, dy1 = p2[0] - p1[0], p2[1] - p1[1]
    dx2, dy2 = q2[0] - q1[0], q2[1] - q1[1]
    det = dx1 * dy2 - dy1 * dx2
    if det == 0:
        if orient(p1, p2, q1) == 0:
            raise RuntimeError("Collinear segment overlap detected!")
        return (False, None)
    rx, ry = q1[0] - p1[0], q1[1] - p1[1]
    t_num = rx * dy2 - ry * dx2
    u_num = rx * dy1 - ry * dx1
    if det > 0:
        if t_num < 0 or t_num > det or u_num < 0 or u_num > det:
            return (False, None)
        if t_num == 0 or t_num == det or u_num == 0 or u_num == det:
            raise RuntimeError("Degenerate vertex-on-edge or shared-vertex contact detected!")
    else:
        if t_num > 0 or t_num < det or u_num > 0 or u_num < det:
            return (False, None)
        if t_num == 0 or t_num == det or u_num == 0 or u_num == det:
            raise RuntimeError("Degenerate vertex-on-edge or shared-vertex contact detected!")
    t = Fraction(t_num, det)
    return (True, (Fraction(p1[0]) + t * dx1, Fraction(p1[1]) + t * dy1))


def main():
    parser = argparse.ArgumentParser(description="Independent pure-Z^2 / Q^2 verifier for simple convex 9-Venn")
    parser.add_argument("json_path", type=str)
    args = parser.parse_args()

    t0 = time.time()
    with open(args.json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    polys = data["polygons"]
    witnesses = data["witnesses"]
    S_w = int(data["witness_scale"])
    n = len(polys)
    assert n == 9, f"Expected 9 polygons, got {n}"
    assert len(witnesses) == 512, f"Expected 512 witnesses, got {len(witnesses)}"

    # 1. Strict CCW convexity
    ks = []
    bbox = 0
    for c, poly in enumerate(polys):
        k = len(poly)
        ks.append(k)
        assert k >= 3
        for x, y in poly:
            assert isinstance(x, int) and isinstance(y, int)
            bbox = max(bbox, abs(x), abs(y))
        for i in range(k):
            if orient(poly[i], poly[(i + 1) % k], poly[(i + 2) % k]) <= 0:
                raise RuntimeError(f"Polygon {c} failed strict CCW convexity at vertex {i}!")

    # 2. Exact Q^2 pairwise intersections
    all_pts = set()
    pair_mat = [[0] * n for _ in range(n)]
    total_x = 0
    for i in range(n):
        pi, ki = polys[i], len(polys[i])
        for j in range(i + 1, n):
            pj, kj = polys[j], len(polys[j])
            cnt = 0
            for ei in range(ki):
                for ej in range(kj):
                    hit, pt = seg_cross_exact(pi[ei], pi[(ei + 1) % ki], pj[ej], pj[(ej + 1) % kj])
                    if hit:
                        if pt in all_pts:
                            raise RuntimeError(f"Triple point detected at {pt}!")
                        all_pts.add(pt)
                        cnt += 1
                        total_x += 1
            if cnt < 2:
                raise RuntimeError(f"Pair ({i},{j}) crosses only {cnt} times (< 2)!")
            pair_mat[i][j] = pair_mat[j][i] = cnt

    if total_x != 510:
        raise RuntimeError(f"Expected V=510 crossings, got {total_x}")

    # 3. Exact integer witness separation for all 512 subsets
    seen_masks = set()
    for idx, (wx, wy) in enumerate(witnesses):
        assert isinstance(wx, int) and isinstance(wy, int)
        mask = 0
        for c, poly in enumerate(polys):
            k = len(poly)
            inside = True
            for i in range(k):
                x1, y1 = poly[i][0] * S_w, poly[i][1] * S_w
                x2, y2 = poly[(i + 1) % k][0] * S_w, poly[(i + 1) % k][1] * S_w
                o = (x2 - x1) * (wy - y1) - (y2 - y1) * (wx - x1)
                if o == 0:
                    raise RuntimeError(f"Witness {idx} lies on boundary of polygon {c}!")
                if o < 0:
                    inside = False
                    break
            if inside:
                mask |= (1 << c)
        seen_masks.add(mask)

    if len(seen_masks) != 512:
        raise RuntimeError(f"Expected 512 distinct masks, got {len(seen_masks)}")

    max_pair = max(max(row) for row in pair_mat)
    print("============================================================")
    print("  EXACT Z^2 / Q^2 CERTIFICATION PASSED: SIMPLE CONVEX 9-VENN")
    print("============================================================")
    print(f"  File           : {args.json_path}")
    print(f"  Sides per curve: {ks}  (K_max = {max(ks)}  vs. Grunbaum 128)")
    print(f"  Lattice box    : [-{bbox}, {bbox}]^2   (witness scale S_w = {S_w})")
    print(f"  Topology       : V = {total_x}, E = {2*total_x}, F = {total_x + 2} (0 triple, 0 degen)")
    print(f"  Max pairwise   : {max_pair}  |  All 512/512 subsets strictly witnessed")
    print(f"  Elapsed        : {time.time() - t0:.2f}s")


if __name__ == "__main__":
    main()
