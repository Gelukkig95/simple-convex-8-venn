-- Standalone Zero-sorry Zero-Mathlib Pure-ASCII Lean 4 Certificate (D = 9, S_w = 2)
set_option maxRecDepth 2000000
set_option maxHeartbeats 0

namespace SimpleConvex8VennK8

structure Pt where
  x : Int
  y : Int

structure Wit where
  mask : Nat
  x : Int
  y : Int

structure Cr where
  i : Nat
  e1 : Nat
  j : Nat
  e2 : Nat

def orient2d (a b c : Pt) : Int :=
  (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

def onSeg (a b c : Pt) : Bool :=
  let lx := if a.x <= b.x then a.x else b.x
  let rx := if a.x <= b.x then b.x else a.x
  let ly := if a.y <= b.y then a.y else b.y
  let ry := if a.y <= b.y then b.y else a.y
  decide (lx <= c.x) && decide (c.x <= rx) && decide (ly <= c.y) && decide (c.y <= ry)

def polys : Array (Array Pt) := #[
  #[Pt.mk 497 (-152), Pt.mk 499 (-52), Pt.mk (-49) 245, Pt.mk (-178) 215, Pt.mk (-330) 64, Pt.mk (-332) (-144), Pt.mk (-208) (-302), Pt.mk (-74) (-348)],
  #[Pt.mk 386 273, Pt.mk 337 322, Pt.mk (-254) 155, Pt.mk (-334) 30, Pt.mk (-316) (-207), Pt.mk (-157) (-331), Pt.mk 99 (-300), Pt.mk 215 (-227)],
  #[Pt.mk 267 53, Pt.mk (-91) 404, Pt.mk (-141) 328, Pt.mk (-334) (-108), Pt.mk (-294) (-226), Pt.mk (-104) (-349), Pt.mk 135 (-287), Pt.mk 279 (-110)],
  #[Pt.mk 286 (-75), Pt.mk 212 132, Pt.mk 13 250, Pt.mk (-113) 234, Pt.mk (-412) 120, Pt.mk (-204) (-302), Pt.mk (-66) (-344), Pt.mk 199 (-253)],
  #[Pt.mk 288 63, Pt.mk 116 196, Pt.mk (-51) 246, Pt.mk (-179) 216, Pt.mk (-589) (-194), Pt.mk (-587) (-214), Pt.mk 97 (-299), Pt.mk 214 (-225)],
  #[Pt.mk 272 (-22), Pt.mk 226 91, Pt.mk 89 220, Pt.mk (-107) 250, Pt.mk (-256) 154, Pt.mk (-335) 30, Pt.mk (-289) (-568), Pt.mk 270 (-120)],
  #[Pt.mk 204 136, Pt.mk 40 229, Pt.mk (-43) 242, Pt.mk (-215) 195, Pt.mk (-301) 93, Pt.mk (-335) (-110), Pt.mk (-295) (-227), Pt.mk 253 (-583)],
  #[Pt.mk 273 (-1), Pt.mk 163 171, Pt.mk 45 229, Pt.mk (-213) 239, Pt.mk (-355) (-43), Pt.mk (-269) (-293), Pt.mk 33 (-339), Pt.mk 256 (-197)]
]

def getPt (i e : Nat) : Pt :=
  (polys.getD i #[]).getD (e % 8) (Pt.mk 0 0)

def checkPolyConvex (i : Nat) : Bool :=
  (List.range 8).all fun e =>
    let a := getPt i e
    let b := getPt i (e + 1)
    (List.range 8).all fun j =>
      if j == e || j == (e + 1) % 8 then true else decide (orient2d a b (getPt i j) > 0)

def checkAll8Convex : Bool :=
  (polys.size == 8) && (List.range 8).all fun i => ((polys.getD i #[]).size == 8) && checkPolyConvex i

def isProperCross (a b c d : Pt) : Bool :=
  let o1 := orient2d a b c
  let o2 := orient2d a b d
  let o3 := orient2d c d a
  let o4 := orient2d c d b
  ((decide (o1 > 0) && decide (o2 < 0)) || (decide (o1 < 0) && decide (o2 > 0))) &&
  ((decide (o3 > 0) && decide (o4 < 0)) || (decide (o3 < 0) && decide (o4 > 0)))

def isNonDeg (a b c d : Pt) : Bool :=
  let o1 := orient2d a b c
  let o2 := orient2d a b d
  let o3 := orient2d c d a
  let o4 := orient2d c d b
  !((o1 == 0) && onSeg a b c) && !((o2 == 0) && onSeg a b d) &&
  !((o3 == 0) && onSeg c d a) && !((o4 == 0) && onSeg c d b)

def pairStats (i j : Nat) : Prod Bool Nat :=
  (List.range 8).foldl (fun (acc : Prod Bool Nat) e1 =>
    (List.range 8).foldl (fun (acc2 : Prod Bool Nat) e2 =>
      let a := getPt i e1; let b := getPt i (e1 + 1);
      let c := getPt j e2; let d := getPt j (e2 + 1);
      (acc2.1 && isNonDeg a b c d, acc2.2 + (if isProperCross a b c d then 1 else 0))
    ) acc) (true, 0)

def checkSimple254 : Bool :=
  let r := (List.range 8).foldl (fun (acc : Prod Bool Nat) i =>
    (List.range 8).foldl (fun (acc2 : Prod Bool Nat) j =>
      if i < j then (let s := pairStats i j; (acc2.1 && s.1 && decide (s.2 >= 2), acc2.2 + s.2))
      else acc2) acc) (true, 0)
  r.1 && (r.2 == 254)

def projA : Int := 1
def projB : Int := 0
def sortedCr : List Cr := [
  Cr.mk 3 4 4 3, Cr.mk 3 4 7 3, Cr.mk 6 4 7 4, Cr.mk 2 2 7 4, Cr.mk 5 5 7 3, Cr.mk 1 3 7 3, Cr.mk 0 4 6 5, Cr.mk 0 4 2 3, Cr.mk 0 4 7 4, Cr.mk 0 4 2 2, Cr.mk 0 4 6 4, Cr.mk 0 4 3 4, Cr.mk 0 4 5 5, Cr.mk 0 4 1 3, Cr.mk 0 4 7 3, Cr.mk 0 4 1 2, Cr.mk 0 4 5 4, Cr.mk 3 4 5 5, Cr.mk 1 3 3 4, Cr.mk 5 5 6 4, Cr.mk 1 3 6 4, Cr.mk 2 2 5 5, Cr.mk 3 4 6 4, Cr.mk 1 3 2 2, Cr.mk 5 5 7 4, Cr.mk 2 3 5 5, Cr.mk 5 5 6 5, Cr.mk 1 3 7 4, Cr.mk 1 3 2 3, Cr.mk 0 5 5 5, Cr.mk 1 3 6 5, Cr.mk 0 5 1 3, Cr.mk 2 2 3 4, Cr.mk 0 5 6 5, Cr.mk 0 5 2 3, Cr.mk 4 5 5 5, Cr.mk 0 5 7 4, Cr.mk 6 4 7 3, Cr.mk 1 2 6 4, Cr.mk 5 4 6 4, Cr.mk 0 3 6 4, Cr.mk 1 4 6 5, Cr.mk 4 3 6 3, Cr.mk 1 4 2 3, Cr.mk 1 4 7 4, Cr.mk 2 4 7 4, Cr.mk 6 6 7 4, Cr.mk 0 3 5 4, Cr.mk 4 5 7 4, Cr.mk 4 3 5 4, Cr.mk 0 3 1 2, Cr.mk 1 4 2 4, Cr.mk 1 2 4 3, Cr.mk 5 4 6 3, Cr.mk 0 3 7 3, Cr.mk 4 3 7 3, Cr.mk 1 2 6 3, Cr.mk 1 4 6 6, Cr.mk 6 3 7 3, Cr.mk 1 2 7 3, Cr.mk 5 3 7 3, Cr.mk 1 4 4 5, Cr.mk 4 5 6 6, Cr.mk 2 4 4 5, Cr.mk 1 1 6 3, Cr.mk 0 5 4 5, Cr.mk 5 3 6 3, Cr.mk 0 5 2 4, Cr.mk 3 3 7 3, Cr.mk 0 5 6 6, Cr.mk 1 1 4 3, Cr.mk 0 3 1 1, Cr.mk 0 5 1 4, Cr.mk 3 4 4 5, Cr.mk 2 4 3 4, Cr.mk 3 4 6 6, Cr.mk 4 3 5 3, Cr.mk 1 1 2 2, Cr.mk 1 4 3 4, Cr.mk 0 3 5 3, Cr.mk 0 6 7 5, Cr.mk 2 2 5 3, Cr.mk 0 3 2 2, Cr.mk 2 2 4 3, Cr.mk 3 5 7 5, Cr.mk 2 2 6 2, Cr.mk 2 2 3 3, Cr.mk 4 3 6 2, Cr.mk 0 3 6 2, Cr.mk 3 3 4 3, Cr.mk 1 4 7 5, Cr.mk 1 4 3 5, Cr.mk 0 3 3 3, Cr.mk 0 6 1 4, Cr.mk 2 2 7 2, Cr.mk 5 3 6 2, Cr.mk 6 6 7 5, Cr.mk 2 4 7 5, Cr.mk 3 3 5 3, Cr.mk 3 5 6 6, Cr.mk 2 4 3 5, Cr.mk 0 2 5 3, Cr.mk 4 2 5 3, Cr.mk 0 6 6 6, Cr.mk 0 6 2 4, Cr.mk 0 2 3 3, Cr.mk 1 5 6 6, Cr.mk 1 5 2 4, Cr.mk 0 6 1 5, Cr.mk 3 3 4 2, Cr.mk 5 3 7 2, Cr.mk 1 5 3 5, Cr.mk 3 2 7 2, Cr.mk 4 2 7 2, Cr.mk 0 2 7 2, Cr.mk 3 2 4 2, Cr.mk 0 6 2 5, Cr.mk 1 5 7 5, Cr.mk 0 2 3 2, Cr.mk 2 5 3 5, Cr.mk 6 2 7 2, Cr.mk 4 2 5 2, Cr.mk 0 2 5 2, Cr.mk 5 6 6 6, Cr.mk 3 2 5 2, Cr.mk 5 2 6 2, Cr.mk 0 1 3 2, Cr.mk 0 1 6 2, Cr.mk 3 2 4 1, Cr.mk 0 1 5 2, Cr.mk 4 1 6 1, Cr.mk 2 5 7 5, Cr.mk 3 6 7 5, Cr.mk 0 1 7 2, Cr.mk 0 7 7 5, Cr.mk 4 1 5 2, Cr.mk 0 1 1 1, Cr.mk 2 5 3 6, Cr.mk 4 1 7 2, Cr.mk 5 6 7 5, Cr.mk 1 1 4 1, Cr.mk 0 7 2 5, Cr.mk 1 1 7 2, Cr.mk 1 1 5 2, Cr.mk 1 1 6 1, Cr.mk 5 2 7 2, Cr.mk 2 5 5 6, Cr.mk 0 7 5 6, Cr.mk 3 6 5 6, Cr.mk 1 1 3 1, Cr.mk 1 5 5 6, Cr.mk 6 1 7 2, Cr.mk 1 5 3 6, Cr.mk 5 2 6 0, Cr.mk 0 7 1 5, Cr.mk 5 2 7 1, Cr.mk 4 5 5 6, Cr.mk 3 1 5 2, Cr.mk 3 1 7 1, Cr.mk 1 1 2 0, Cr.mk 1 5 2 5, Cr.mk 3 6 4 5, Cr.mk 0 7 4 5, Cr.mk 4 1 6 0, Cr.mk 2 5 4 5, Cr.mk 3 1 4 1, Cr.mk 1 5 7 6, Cr.mk 4 5 7 6, Cr.mk 2 5 7 6, Cr.mk 2 5 4 6, Cr.mk 4 1 7 1, Cr.mk 1 6 2 5, Cr.mk 4 1 5 1, Cr.mk 5 1 7 1, Cr.mk 4 0 7 1, Cr.mk 0 7 7 6, Cr.mk 2 0 7 1, Cr.mk 0 7 4 6, Cr.mk 3 6 7 6, Cr.mk 3 1 5 1, Cr.mk 3 6 4 6, Cr.mk 0 7 1 6, Cr.mk 5 1 6 0, Cr.mk 2 0 4 0, Cr.mk 1 6 3 6, Cr.mk 0 7 2 6, Cr.mk 2 0 3 1, Cr.mk 2 6 3 6, Cr.mk 1 6 2 6, Cr.mk 2 0 6 0, Cr.mk 2 6 4 6, Cr.mk 3 1 4 0, Cr.mk 2 6 7 6, Cr.mk 4 0 6 0, Cr.mk 3 1 7 0, Cr.mk 6 0 7 0, Cr.mk 4 0 7 0, Cr.mk 2 0 7 0, Cr.mk 5 1 7 0, Cr.mk 0 1 7 0, Cr.mk 4 0 6 7, Cr.mk 2 0 6 7, Cr.mk 5 1 6 7, Cr.mk 0 1 6 7, Cr.mk 6 7 7 0, Cr.mk 1 6 3 7, Cr.mk 3 7 4 6, Cr.mk 3 7 7 6, Cr.mk 0 1 5 1, Cr.mk 4 7 7 6, Cr.mk 3 7 4 7, Cr.mk 1 7 7 6, Cr.mk 3 0 4 0, Cr.mk 0 1 2 0, Cr.mk 1 7 3 7, Cr.mk 5 6 6 7, Cr.mk 0 1 3 0, Cr.mk 2 6 6 7, Cr.mk 4 7 6 7, Cr.mk 2 0 3 0, Cr.mk 1 7 6 7, Cr.mk 3 7 6 7, Cr.mk 2 6 4 7, Cr.mk 6 7 7 6, Cr.mk 0 7 6 7, Cr.mk 3 0 5 0, Cr.mk 4 7 5 6, Cr.mk 1 7 2 6, Cr.mk 3 0 7 0, Cr.mk 1 7 5 6, Cr.mk 5 0 7 0, Cr.mk 2 6 3 7, Cr.mk 3 7 5 6, Cr.mk 2 6 7 7, Cr.mk 5 6 7 7, Cr.mk 3 7 7 7, Cr.mk 1 7 7 7, Cr.mk 3 0 4 7, Cr.mk 4 7 5 0, Cr.mk 3 7 5 7, Cr.mk 3 0 7 7, Cr.mk 2 7 7 0, Cr.mk 2 7 4 7, Cr.mk 1 7 5 7, Cr.mk 5 0 7 7, Cr.mk 3 0 5 7, Cr.mk 2 7 7 7, Cr.mk 4 7 7 0, Cr.mk 2 7 3 0, Cr.mk 1 7 2 7, Cr.mk 1 7 3 0, Cr.mk 2 7 3 7, Cr.mk 0 1 4 7, Cr.mk 0 1 1 7
]

def crProj (t : Cr) : Prod Bool (Prod Int Int) :=
  let a := getPt t.i t.e1; let b := getPt t.i (t.e1 + 1);
  let c := getPt t.j t.e2; let d := getPt t.j (t.e2 + 1);
  let ok := decide (t.i < t.j) && decide (t.j < 8) && decide (t.e1 < 8) && decide (t.e2 < 8) && isProperCross a b c d
  let rx := b.x - a.x; let ry := b.y - a.y;
  let sx := d.x - c.x; let sy := d.y - c.y;
  let den0 := rx * sy - ry * sx
  let nt0 := (c.x - a.x) * sy - (c.y - a.y) * sx
  let nt := if den0 < 0 then -nt0 else nt0
  let den := if den0 < 0 then -den0 else den0
  let pNum := projA * (den * a.x + nt * rx) + projB * (den * a.y + nt * ry)
  (ok && decide (den > 0), (pNum, den))

def checkSorted : List Cr -> Bool
  | [] => true
  | [x] => (crProj x).1
  | x :: y :: rest =>
      let r1 := crProj x; let r2 := crProj y;
      r1.1 && r2.1 && decide (r1.2.1 * r2.2.2 < r2.2.1 * r1.2.2) && checkSorted (y :: rest)

def checkAll254Distinct : Bool := (sortedCr.length == 254) && checkSorted sortedCr

def witScale : Int := 2

def witChunk0 : List Wit := [
  Wit.mk 0 1198 1198, Wit.mk 1 618 (-230), Wit.mk 2 468 324, Wit.mk 3 561 3, Wit.mk 4 (-125) 531, Wit.mk 5 540 (-241), Wit.mk 6 200 433, Wit.mk 7 544 (-53), Wit.mk 8 (-587) 204, Wit.mk 9 557 (-134), Wit.mk 10 385 287, Wit.mk 11 550 (-94), Wit.mk 12 (-2) 481, Wit.mk 13 547 (-157), Wit.mk 14 81 459, Wit.mk 15 546 (-96), Wit.mk 16 (-667) (-229), Wit.mk 17 (-653) (-270), Wit.mk 18 509 170, Wit.mk 19 512 159, Wit.mk 20 (-108) 488, Wit.mk 21 (-103) 486, Wit.mk 22 235 389, Wit.mk 23 516 103, Wit.mk 24 (-662) 127, Wit.mk 25 (-632) 137, Wit.mk 26 429 222, Wit.mk 27 447 193, Wit.mk 28 (-82) 484, Wit.mk 29 (-94) 484, Wit.mk 30 422 213, Wit.mk 31 440 194
]

def witChunk1 : List Wit := [
  Wit.mk 32 (-475) (-596), Wit.mk 33 (-388) (-612), Wit.mk 34 (-313) (-646), Wit.mk 35 (-338) (-628), Wit.mk 36 (-196) 472, Wit.mk 37 540 (-229), Wit.mk 38 183 425, Wit.mk 39 543 (-55), Wit.mk 40 (-531) 275, Wit.mk 41 (-384) (-610), Wit.mk 42 (-530) 273, Wit.mk 43 (-353) (-618), Wit.mk 44 (-197) 471, Wit.mk 45 535 (-185), Wit.mk 46 114 447, Wit.mk 47 540 (-103), Wit.mk 48 (-634) (-407), Wit.mk 49 (-641) (-311), Wit.mk 50 (-609) (-426), Wit.mk 51 (-638) (-318), Wit.mk 52 (-129) 483, Wit.mk 53 (-125) 482, Wit.mk 54 225 393, Wit.mk 55 480 110, Wit.mk 56 (-667) 31, Wit.mk 57 (-633) 117, Wit.mk 58 (-665) 46, Wit.mk 59 (-629) 115, Wit.mk 60 (-180) 472, Wit.mk 61 (-129) 480, Wit.mk 62 417 213, Wit.mk 63 447 186
]

def witChunk2 : List Wit := [
  Wit.mk 64 377 (-516), Wit.mk 65 376 (-514), Wit.mk 66 199 (-596), Wit.mk 67 427 (-451), Wit.mk 68 248 (-569), Wit.mk 69 289 (-545), Wit.mk 70 240 (-571), Wit.mk 71 274 (-550), Wit.mk 72 (-569) 223, Wit.mk 73 399 (-483), Wit.mk 74 395 274, Wit.mk 75 364 (-493), Wit.mk 76 (-8) 470, Wit.mk 77 295 (-540), Wit.mk 78 49 461, Wit.mk 79 278 (-547), Wit.mk 80 (-666) (-223), Wit.mk 81 (-653) (-265), Wit.mk 82 198 (-595), Wit.mk 83 427 (-450), Wit.mk 84 (-665) (-220), Wit.mk 85 (-653) (-255), Wit.mk 86 231 (-574), Wit.mk 87 262 (-554), Wit.mk 88 (-586) 203, Wit.mk 89 (-588) 192, Wit.mk 90 389 259, Wit.mk 91 369 (-486), Wit.mk 92 (-71) 480, Wit.mk 93 (-86) 482, Wit.mk 94 399 235, Wit.mk 95 290 (-537)
]

def witChunk3 : List Wit := [
  Wit.mk 96 (-195) (-710), Wit.mk 97 (-97) (-678), Wit.mk 98 (-281) (-652), Wit.mk 99 (-300) (-641), Wit.mk 100 (-229) (-675), Wit.mk 101 (-207) (-670), Wit.mk 102 (-273) (-654), Wit.mk 103 (-274) (-649), Wit.mk 104 (-550) 245, Wit.mk 105 (-116) (-679), Wit.mk 106 (-543) 252, Wit.mk 107 (-323) (-625), Wit.mk 108 (-13) 467, Wit.mk 109 (-197) (-668), Wit.mk 110 36 461, Wit.mk 111 (-261) (-637), Wit.mk 112 (-591) (-449), Wit.mk 113 (-642) (-298), Wit.mk 114 (-613) (-386), Wit.mk 115 (-636) (-316), Wit.mk 116 (-586) (-451), Wit.mk 117 (-642) (-287), Wit.mk 118 (-608) (-384), Wit.mk 119 (-633) (-314), Wit.mk 120 (-564) 225, Wit.mk 121 (-586) 189, Wit.mk 122 (-552) 237, Wit.mk 123 (-583) 181, Wit.mk 124 (-42) 469, Wit.mk 125 (-92) 473, Wit.mk 126 406 222, Wit.mk 127 410 212
]

def witChunk4 : List Wit := [
  Wit.mk 128 (-415) 432, Wit.mk 129 455 (-411), Wit.mk 130 296 343, Wit.mk 131 543 (-16), Wit.mk 132 (-342) 440, Wit.mk 133 519 (-263), Wit.mk 134 262 370, Wit.mk 135 541 (-25), Wit.mk 136 (-436) 387, Wit.mk 137 472 (-346), Wit.mk 138 334 316, Wit.mk 139 458 (-354), Wit.mk 140 (-390) 403, Wit.mk 141 498 (-285), Wit.mk 142 87 456, Wit.mk 143 471 (-312), Wit.mk 144 (-663) (-133), Wit.mk 145 (-660) (-124), Wit.mk 146 295 342, Wit.mk 147 543 0, Wit.mk 148 (-328) 439, Wit.mk 149 (-338) 429, Wit.mk 150 279 350, Wit.mk 151 528 13, Wit.mk 152 (-662) (-64), Wit.mk 153 (-661) (-78), Wit.mk 154 310 330, Wit.mk 155 452 (-353), Wit.mk 156 (-382) 406, Wit.mk 157 (-357) 415, Wit.mk 158 286 344, Wit.mk 159 455 (-328)
]

def witChunk5 : List Wit := [
  Wit.mk 160 (-484) (-530), Wit.mk 161 (-419) (-591), Wit.mk 162 (-486) (-525), Wit.mk 163 (-447) (-553), Wit.mk 164 (-279) 451, Wit.mk 165 523 (-252), Wit.mk 166 175 414, Wit.mk 167 538 (-43), Wit.mk 168 (-498) 317, Wit.mk 169 (-401) (-600), Wit.mk 170 (-513) 297, Wit.mk 171 (-393) (-591), Wit.mk 172 (-235) 463, Wit.mk 173 517 (-234), Wit.mk 174 132 433, Wit.mk 175 513 (-167), Wit.mk 176 (-530) (-494), Wit.mk 177 (-655) (-113), Wit.mk 178 (-515) (-504), Wit.mk 179 (-654) (-112), Wit.mk 180 (-285) 448, Wit.mk 181 (-300) 441, Wit.mk 182 221 386, Wit.mk 183 515 27, Wit.mk 184 (-663) (-7), Wit.mk 185 (-659) (-68), Wit.mk 186 (-662) (-3), Wit.mk 187 (-649) (-25), Wit.mk 188 (-232) 460, Wit.mk 189 (-257) 446, Wit.mk 190 221 381, Wit.mk 191 469 (-71)
]

def witChunk6 : List Wit := [
  Wit.mk 192 166 (-604), Wit.mk 193 447 (-419), Wit.mk 194 177 (-601), Wit.mk 195 435 (-435), Wit.mk 196 88 (-618), Wit.mk 197 76 (-618), Wit.mk 198 117 (-606), Wit.mk 199 120 (-603), Wit.mk 200 (-449) 367, Wit.mk 201 451 (-396), Wit.mk 202 345 306, Wit.mk 203 445 (-399), Wit.mk 204 (-395) 397, Wit.mk 205 74 (-616), Wit.mk 206 74 457, Wit.mk 207 102 (-602), Wit.mk 208 (-665) (-201), Wit.mk 209 (-658) (-173), Wit.mk 210 192 (-595), Wit.mk 211 429 (-445), Wit.mk 212 (-664) (-213), Wit.mk 213 (-656) (-221), Wit.mk 214 207 (-578), Wit.mk 215 205 (-574), Wit.mk 216 (-412) 376, Wit.mk 217 (-409) 376, Wit.mk 218 341 297, Wit.mk 219 358 (-491), Wit.mk 220 (-394) 395, Wit.mk 221 (-386) 394, Wit.mk 222 339 292, Wit.mk 223 205 (-572)
]

def witChunk7 : List Wit := [
  Wit.mk 224 (-16) (-651), Wit.mk 225 (-25) (-652), Wit.mk 226 (-488) (-517), Wit.mk 227 (-457) (-537), Wit.mk 228 42 (-632), Wit.mk 229 31 (-633), Wit.mk 230 (-488) (-516), Wit.mk 231 (-463) (-526), Wit.mk 232 (-443) 348, Wit.mk 233 (-42) (-656), Wit.mk 234 (-508) 287, Wit.mk 235 (-384) (-586), Wit.mk 236 13 460, Wit.mk 237 (-17) (-648), Wit.mk 238 38 460, Wit.mk 239 (-247) (-630), Wit.mk 240 (-573) (-462), Wit.mk 241 (-653) (-155), Wit.mk 242 (-523) (-496), Wit.mk 243 (-648) (-138), Wit.mk 244 (-576) (-459), Wit.mk 245 (-647) (-229), Wit.mk 246 (-603) (-388), Wit.mk 247 (-581) (-329), Wit.mk 248 (-441) 346, Wit.mk 249 (-428) 350, Wit.mk 250 (-505) 284, Wit.mk 251 (-556) 124, Wit.mk 252 (-14) 458, Wit.mk 253 (-233) 417, Wit.mk 254 204 353, Wit.mk 255 409 212
]

def checkWit (w : Wit) : Bool :=
  (List.range 8).all fun i =>
    if (w.mask / (2 ^ i)) % 2 == 1 then
      (List.range 8).all fun e =>
        let a := getPt i e; let b := getPt i (e + 1);
        decide (orient2d (Pt.mk (a.x * witScale) (a.y * witScale)) (Pt.mk (b.x * witScale) (b.y * witScale)) (Pt.mk w.x w.y) > 0)
    else
      (List.range 8).any fun e =>
        let a := getPt i e; let b := getPt i (e + 1);
        decide (orient2d (Pt.mk (a.x * witScale) (a.y * witScale)) (Pt.mk (b.x * witScale) (b.y * witScale)) (Pt.mk w.x w.y) < 0)

def checkChunk (idx : Nat) (xs : List Wit) : Bool :=
  (xs.length == 32) && (xs.zip (List.range 32)).all fun p => (p.1.mask == idx * 32 + p.2) && checkWit p.1

theorem t_convex : checkAll8Convex = true := by decide
theorem t_simple254 : checkSimple254 = true := by decide
theorem t_distinct254 : checkAll254Distinct = true := by decide
theorem t_w0 : checkChunk 0 witChunk0 = true := by decide
theorem t_w1 : checkChunk 1 witChunk1 = true := by decide
theorem t_w2 : checkChunk 2 witChunk2 = true := by decide
theorem t_w3 : checkChunk 3 witChunk3 = true := by decide
theorem t_w4 : checkChunk 4 witChunk4 = true := by decide
theorem t_w5 : checkChunk 5 witChunk5 = true := by decide
theorem t_w6 : checkChunk 6 witChunk6 = true := by decide
theorem t_w7 : checkChunk 7 witChunk7 = true := by decide

end SimpleConvex8VennK8
