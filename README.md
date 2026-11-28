# Simple Convex 8- and 9-Venn Diagrams

[![Verify](https://github.com/Gelukkig95/simple-convex-venn/actions/workflows/verify.yml/badge.svg)](https://github.com/Gelukkig95/simple-convex-venn/actions/workflows/verify.yml)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.24572392-blue.svg)](https://doi.org/10.5281/zenodo.24572392)

Formally verified integer-lattice ($\mathbb{Z}^2$) realizations of simple convex $n$-Venn diagrams establishing new explicit polygon-side upper bounds for $n = 8$ and $n = 9$:

$$
k^{\ast}(8) \le 8 \qquad \text{and} \qquad k^{\ast}(9) \le 25
$$

Both constructions improve upon Grünbaum's (1975) exponential upper bound $k^{\ast}(n) \le 2^{n-2}$ ($64$ for $n=8$, $128$ for $n=9$) and are independently certified by exact rational arithmetic and dependency-free **Lean 4 kernel proofs** (zero Mathlib, zero `native_decide`, zero `sorry`).

## Summary of Certified Results

| $n$ | Lower Bound (CRW 2007) | Previous Upper Bound (Grünbaum 1975) | Certified Upper Bound | Lattice Box | Topology ($V, E, F$) | Max Pairwise Crossings |
|---:|---:|---:|---:|---|---|---:|
| **8** | 6 | 64 | $\mathbf{k^{\ast}(8) \le 8}$ (8 octagons) | $[-589, 589]^2$ | $V=254,\; E=508,\; F=256$ | 14 |
| **9** | 8 | 128 | $\mathbf{k^{\ast}(9) \le 25}$ (9 uniform 25-gons) | $[-358651, 358651]^2$ | $V=510,\; E=1020,\; F=512$ | 22 |

## Repository Structure

- **Root (`n = 8`, $K = 8$):**
  - `CERTIFIED_SIMPLE_8_VENN_k8_Z2.json` — 8 strictly convex integer octagons and 256 strict subset witnesses.
  - `SimpleConvex8VennK8.lean` — standalone pure Lean 4 kernel certificate (`by decide`).
  - `verify_z2_certificate.py` / `verify_independent_q2.py` — independent exact integer / $\mathbb{Q}^2$ verifiers.
- **`n9/` (`n = 9`, $K = 25$):**
  - `n9/CERTIFIED_SIMPLE_9_VENN_k25_Z2.json` — 9 strictly convex integer 25-gons and 512 strict subset witnesses ($S_{w} = 1$).
  - `n9/SimpleConvex9VennK25.lean` — standalone pure Lean 4 kernel certificate (`by decide`).
  - `n9/verify_9venn_q2.py` — independent pure-$\mathbb{Q}^2$ Python verifier.
  - `n9/figures/` — color and B&W print-ready SVG renderings.

## Independent Verification

```bash
# n = 8 (K = 8)
python3 verify_z2_certificate.py CERTIFIED_SIMPLE_8_VENN_k8_Z2.json
lean SimpleConvex8VennK8.lean

# n = 9 (K = 25)
python3 n9/verify_9venn_q2.py n9/CERTIFIED_SIMPLE_9_VENN_k25_Z2.json
lean n9/SimpleConvex9VennK25.lean
```

Each Lean 4 certificate proves four finite predicates by definitional kernel reduction:
1. Simple strict convexity (winding number $1$): for every directed edge of all $n$ polygons, all $K-2$ non-incident vertices lie strictly to its left.
2. Zero degenerate contacts, $\ge 2$ crossings per curve pair, and exact total crossings $V = 2^n - 2$.
3. Strict rational lexicographical ordering of all $V$ crossings (proving 0 triple points).
4. Strict separation of all $2^n$ subset witness points.

By the Jordan Curve Theorem, Euler's formula ($F = E - V + 2 = 2^n$), and the Pigeonhole Principle, every Venn region is nonempty and connected.


