import sys
import json
from collections import deque
from fractions import Fraction
from pathlib import Path


def sub(a, b):
    return (a[0] - b[0], a[1] - b[1])


def cross(u, v):
    return u[0] * v[1] - u[1] * v[0]


def dot(u, v):
    return u[0] * v[0] + u[1] * v[1]


def on_closed_segment(p, a, b):
    ab = sub(b, a)
    ap = sub(p, a)
    if cross(ab, ap) != 0:
        return False
    proj = dot(ap, ab)
    return 0 <= proj <= dot(ab, ab)


def independent_audit(json_path: Path) -> bool:
    data = json.loads(json_path.read_text(encoding="utf-8"))
    raw_polys = data["rational_polygons"]
    raw_wits = data["rational_witnesses"]

    polys = [[(Fraction(pt[0]), Fraction(pt[1])) for pt in poly] for poly in raw_polys]
    wits = [(Fraction(pt[0]), Fraction(pt[1])) for pt in raw_wits]

    N = len(polys)
    side_counts = [len(p) for p in polys]
    max_K = max(side_counts)
    is_uniform = (len(set(side_counts)) == 1)

    # 1. Exact Strict Convexity & Exact Winding Number W == 1
    convex_ok = (N == 8)
    for i, poly in enumerate(polys):
        K = len(poly)
        if K < 3:
            convex_ok = False
            break
        cx = sum((p[0] for p in poly), Fraction(0)) * Fraction(1, K)
        cy = sum((p[1] for p in poly), Fraction(0)) * Fraction(1, K)
        u = [sub(p, (cx, cy)) for p in poly]
        for m in range(K):
            if cross(u[m], u[(m + 1) % K]) <= 0:
                convex_ok = False
        in_h = [(um[1] > 0) or (um[1] == 0 and um[0] > 0) for um in u]
        winding = sum(1 for m in range(K) if (not in_h[m]) and in_h[(m + 1) % K])
        if winding != 1:
            convex_ok = False
        edges = [sub(poly[(m + 1) % K], poly[m]) for m in range(K)]
        for m in range(K):
            if dot(edges[m], edges[m]) <= 0 or cross(edges[m], edges[(m + 1) % K]) <= 0:
                convex_ok = False

    # 2. Exact Transversal Crossings (V == 254, zero degeneracy, zero triple crossings)
    degenerate = False
    crossing_pts = []
    # Store crossing events per polygon edge to build the exact 254-vertex primal graph!
    edge_events = [[[] for _ in range(len(polys[i]))] for i in range(N)]
    pair_matrix = [[0] * N for _ in range(N)]

    for i in range(N):
        pi, Ki = polys[i], len(polys[i])
        for j in range(i + 1, N):
            pj, Kj = polys[j], len(polys[j])
            for e1 in range(Ki):
                a, b = pi[e1], pi[(e1 + 1) % Ki]
                for e2 in range(Kj):
                    c, d = pj[e2], pj[(e2 + 1) % Kj]
                    if (
                        on_closed_segment(a, c, d)
                        or on_closed_segment(b, c, d)
                        or on_closed_segment(c, a, b)
                        or on_closed_segment(d, a, b)
                    ):
                        degenerate = True
                        continue
                    r = sub(b, a)
                    s = sub(d, c)
                    den = cross(r, s)
                    if den == 0:
                        continue
                    qp = sub(c, a)
                    t = cross(qp, s) / den
                    u_val = cross(qp, r) / den
                    if (0 < t < 1) and (0 < u_val < 1):
                        vid = len(crossing_pts)
                        pt = (a[0] + t * r[0], a[1] + t * r[1])
                        crossing_pts.append(pt)
                        edge_events[i][e1].append((t, vid))
                        edge_events[j][e2].append((u_val, vid))
                        pair_matrix[i][j] += 1
                        pair_matrix[j][i] += 1

    V = len(crossing_pts)
    all_distinct = (len(set(crossing_pts)) == V)
    if not all_distinct:
        degenerate = True

    # 3. Exact 4-Regular Planar Graph Connectivity (Explicit BFS over all V crossings!)
    adj = [[] for _ in range(V)]
    E_double = 0
    for i in range(N):
        cyc_vids = []
        for e in range(len(polys[i])):
            ev = sorted(edge_events[i][e], key=lambda x: x[0])
            for _, vid in ev:
                cyc_vids.append(vid)
        L = len(cyc_vids)
        for k in range(L):
            u_v = cyc_vids[k]
            w_v = cyc_vids[(k + 1) % L]
            adj[u_v].append(w_v)
            adj[w_v].append(u_v)
            E_double += 2

    E = E_double // 2
    all_deg4 = (V > 0 and all(len(adj[v]) == 4 for v in range(V)))
    visited = set()
    if V > 0:
        q = deque([0])
        visited.add(0)
        while q:
            cur = q.popleft()
            for nb in adj[cur]:
                if nb not in visited:
                    visited.add(nb)
                    q.append(nb)
    connected = (len(visited) == V and V > 0)
    euler_faces = (E - V + 2) if connected else -1

    # 4. Exact 256-Subset Strict Witness Verification
    verified_masks = 0
    if len(wits) == 256:
        for mask in range(256):
            wp = wits[mask]
            ok = True
            for i in range(N):
                poly = polys[i]
                K = len(poly)
                z_vals = [cross(sub(poly[(m + 1) % K], poly[m]), sub(wp, poly[m])) for m in range(K)]
                if (mask >> i) & 1:
                    if not all(z > 0 for z in z_vals):
                        ok = False
                        break
                else:
                    if not any(z < 0 for z in z_vals):
                        ok = False
                        break
            if ok:
                verified_masks += 1

    max_pair = max(pair_matrix[i][j] for i in range(N) for j in range(i + 1, N))
    min_pair = min(pair_matrix[i][j] for i in range(N) for j in range(i + 1, N))

    passed = (
        convex_ok
        and (not degenerate)
        and all_distinct
        and (V == 254)
        and (E == 508)
        and all_deg4
        and connected
        and (euler_faces == 256)
        and (verified_masks == 256)
    )

    print("=" * 88)
    print(f"[INDEPENDENT PURE-Q^2 VERIFIER] File: {json_path.name}")
    print("=" * 88)
    print(f"  1. Sides per polygon     : {side_counts} (max_K={max_K}, uniform={is_uniform})")
    print(f"  2. Strict Convex & W==1  : {convex_ok}")
    print(f"  3. Crossings & Non-Degen : V={V}/254 | distinct={all_distinct} | non_degenerate={not degenerate}")
    print(f"  4. Planar Graph BFS      : E={E}/508 | 4-regular={all_deg4} | BFS_connected={len(visited)}/{V} -> Euler F={euler_faces}")
    print(f"  5. Pairwise Crossings    : min={min_pair}, max={max_pair} (algebraic floor k>={(max_pair+1)//2})")
    print(f"  6. Exact 256 Witnesses   : {verified_masks}/256")
    print(f"  >>> FINAL INDEPENDENT VERDICT: {'*** CERTIFIED SIMPLE CONVEX 8-VENN (PASS) ***' if passed else 'FAILED'} <<<")
    print("=" * 88)
    return passed


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("CERTIFIED_SIMPLE_8_VENN_k22.json")
    ok = independent_audit(target)
    sys.exit(0 if ok else 1)
