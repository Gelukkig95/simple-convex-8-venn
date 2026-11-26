import json, sys
from fractions import Fraction
from pathlib import Path
def orient2d(a, b, c): return (b[0]-a[0])*(c[1]-a[1]) - (b[1]-a[1])*(c[0]-a[0])
def on_seg(a, b, c): return min(a[0],b[0])<=c[0]<=max(a[0],b[0]) and min(a[1],b[1])<=c[1]<=max(a[1],b[1])
p = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("CERTIFIED_SIMPLE_8_VENN_k8_Z2.json")
d = json.loads(p.read_text(encoding="utf-8"))
polys = [[(int(x), int(y)) for x, y in poly] for poly in d["polygons_z2"]]
S_w = int(d["witness_integer_scale"])
wits = [(int(m), int(x), int(y)) for m, x, y in d["witnesses_z2_scaled"]]
assert len(polys) == 8 and all(len(poly) == 8 for poly in polys)
for poly in polys:
    for e in range(8):
        for j in range(8):
            if j not in (e, (e+1)%8): assert orient2d(poly[e], poly[(e+1)%8], poly[j]) > 0
seen, pc = set(), [[0]*8 for _ in range(8)]
for i in range(8):
    for j in range(i+1, 8):
        for e1 in range(8):
            a, b = polys[i][e1], polys[i][(e1+1)%8]
            for e2 in range(8):
                c, d_ = polys[j][e2], polys[j][(e2+1)%8]
                o1, o2, o3, o4 = orient2d(a,b,c), orient2d(a,b,d_), orient2d(c,d_,a), orient2d(c,d_,b)
                assert not (o1==0 and on_seg(a,b,c)) and not (o2==0 and on_seg(a,b,d_))
                assert not (o3==0 and on_seg(c,d_,a)) and not (o4==0 and on_seg(c,d_,b))
                if ((o1>0 and o2<0) or (o1<0 and o2>0)) and ((o3>0 and o4<0) or (o3<0 and o4>0)):
                    rx, ry = b[0]-a[0], b[1]-a[1]; sx, sy = d_[0]-c[0], d_[1]-c[1]
                    t = Fraction((c[0]-a[0])*sy - (c[1]-a[1])*sx, rx*sy - ry*sx)
                    pt = (Fraction(a[0])+t*rx, Fraction(a[1])+t*ry)
                    assert pt not in seen; seen.add(pt); pc[i][j] += 1
assert len(seen) == 254 and all(pc[i][j] >= 2 for i in range(8) for j in range(i+1, 8))
assert len(wits) == 256 and {m for m, _, _ in wits} == set(range(256))
for m, wx, wy in wits:
    for i in range(8):
        if (m >> i) & 1:
            assert all(orient2d((polys[i][e][0]*S_w, polys[i][e][1]*S_w), (polys[i][(e+1)%8][0]*S_w, polys[i][(e+1)%8][1]*S_w), (wx, wy)) > 0 for e in range(8))
        else:
            assert any(orient2d((polys[i][e][0]*S_w, polys[i][e][1]*S_w), (polys[i][(e+1)%8][0]*S_w, polys[i][(e+1)%8][1]*S_w), (wx, wy)) < 0 for e in range(8))
print("EXACT Z^2 VERIFICATION PASS: 8 strictly convex octagons | V=254 | E=508 | F=256 | 256/256 witnesses!")
