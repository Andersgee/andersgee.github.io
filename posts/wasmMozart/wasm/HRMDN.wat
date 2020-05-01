(module $arithmetic
  (func $consolelog (import "imports" "consolelog") (param f32))
  (func $exp (import "imports" "exp") (param f32) (result f32))
  (func $tanh (import "imports" "tanh") (param f32) (result f32))

  (memory (import "imports" "mem") 1)
  ;;(memory (export "memory") 1) ;;size in multiples of 64kB (aka pages)

  ;;(func $debugfunc (export "debugfunc") (param $y f32) (param $x f32) (result f32)
    ;;(set_local $y (call $sigm (get_local $x)))
    ;;(call $consolelog (get_local $y))
    ;;(get_local $y)
  ;;)

  (func $debugfunc (export "debugfunc") (param $x f32) (param $y f32) (result f32)
    (f32.div (f32.mul (f32.mul (get_local $x) (get_local $x) (get_local $x))) (get_local $y))
  )

  (func $mixture_m (export "mixture_m") (param $y i32) (param $z i32) (param $Wm i32) (param $bm i32) (param $bias f32) (param $L i32) (param $L2 i32)
    (call $matmuladd2 (get_local $y) (get_local $Wm) (get_local $z) (get_local $bm) (get_local $L) (get_local $L2))
    (call $softmaxbiased (get_local $y) (get_local $y) (get_local $bias) (get_local $L2))
  )

  (func $mixture_p (export "mixture_p") (param $y i32) (param $z i32) (param $Wp i32) (param $bp i32) (param $L i32)
    (call $matmuladd (get_local $y) (get_local $Wp) (get_local $z) (get_local $bp) (get_local $L))
    (call $vecsigm (get_local $y) (get_local $y) (get_local $L))
  )

  (func $fprop (export "fprop") (param $z i32) (param $h1 i32) (param $h2 i32) 
    (param $W i32) (param $b i32)
    (param $Wz1 i32) (param $Uz1 i32) (param $bz1 i32) (param $Wr1 i32) (param $Ur1 i32) (param $br1 i32) (param $Wh1 i32) (param $Uh1 i32) (param $bh1 i32)
    (param $Wz2 i32) (param $Uz2 i32) (param $bz2 i32) (param $Wr2 i32) (param $Ur2 i32) (param $br2 i32) (param $Wh2 i32) (param $Uh2 i32) (param $bh2 i32)
    (local $L i32)
    (local $x i32)
    (set_local $x (i32.const 0)) ;;always keep x at zero for easy read in js
    (set_local $L (i32.const 384))

    ;;function fprop!(x, z, h, b)
    ;;  z = leakyrelu.(W*x .+ b, 0.1)
    ;;  h1,z1 = gru(z , h1 , Wz , Uz , bz , Wr , Ur , br , Wh ], Uh , bh )
    ;;  h2,z2 = gru2(z1, h2, Wz2, Uz2, bz2, Wr2, Ur2, br2, Wh2], Uh2, bh2)
    ;;end
    (call $leakyrelumatmuladd (get_local $z)     (get_local $W) (get_local $x) (get_local $b) (get_local $L))
    (call $gru  (get_local $z) (get_local $h1)   (get_local $Wz1) (get_local $Uz1) (get_local $bz1) (get_local $Wr1) (get_local $Ur1) (get_local $br1) (get_local $Wh1) (get_local $Uh1) (get_local $bh1) (get_local $L))
    (call $gru2 (get_local $z) (get_local $h2)   (get_local $Wz2) (get_local $Uz2) (get_local $bz2) (get_local $Wr2) (get_local $Ur2) (get_local $br2) (get_local $Wh2) (get_local $Uh2) (get_local $bh2) (get_local $L))
  )  
    

  (func $gru (export "gru") (param $x i32) (param $h i32) 
    (param $Wz i32) (param $Uz i32) (param $bz i32) (param $Wr i32) (param $Ur i32) (param $br i32) (param $Wh i32) (param $Uh i32) (param $bh i32) (param $L i32)
    ;;#Gated Recurrent Unit. see (Cho et al., 2014) https://arxiv.org/pdf/1406.1078v3 (eqs 5-8)
    ;;function gru(x, hi, Wz, Uz, bz, Wr, Ur, br, Wh, Uh, bh)
    ;;  r = sigm.(Wr*x .+ Ur*hi .+ br)
    ;;  z = sigm.(Wz*x .+ Uz*hi .+ bz)
    ;;  hnew = tanh.(Wh*x .+ Uh*(r.*hi) .+ bh) 
    ;;  ho = hnew.*(1.0 .- z) .+ hi.*z
    ;;  return ho, ho
    ;;end
    (local $r i32)
    (local $z i32)
    (local $hnew i32)
    (set_local $r (i32.const 384)) ;;pointers to temp arrays of size 96*4
    (set_local $z (i32.const 768))
    (set_local $hnew (i32.const 1152))

    (call $sigmdoublematmuladd (get_local $r)                  (get_local $Wr) (get_local $x) (get_local $Ur) (get_local $h) (get_local $br) (get_local $L))
    (call $sigmdoublematmuladd (get_local $z)                  (get_local $Wz) (get_local $x) (get_local $Uz) (get_local $h) (get_local $bz) (get_local $L))
    (call $tanhdoublematmuladd (get_local $hnew)               (get_local $Wh) (get_local $x) (get_local $Uh) (get_local $h) (get_local $r) (get_local $bh) (get_local $L))
    (call $vecmix_doubleassign (get_local $h) (get_local $x)   (get_local $hnew) (get_local $h) (get_local $z) (get_local $L))
  )

  (func $gru2 (export "gru2") (param $x i32) (param $h i32)
    (param $Wz i32) (param $Uz i32) (param $bz i32) (param $Wr i32) (param $Ur i32) (param $br i32) (param $Wh i32) (param $Uh i32) (param $bh i32) (param $L i32)
    ;;same thing but with
    ;;h = tanh.(Wh*x .+ r.*(Uh*hi) .+ bh)
    ;;instead of
    ;;h = tanh.(Wh*x .+ Uh*(r.*hi) .+ bh)
    (local $r i32)
    (local $z i32)
    (local $hnew i32)
    (set_local $r (i32.const 384)) ;;pointers to temp arrays of size 96*4
    (set_local $z (i32.const 768))
    (set_local $hnew (i32.const 1152))

    (call $sigmdoublematmuladd (get_local $r)                  (get_local $Wr) (get_local $x) (get_local $Ur) (get_local $h) (get_local $br) (get_local $L))
    (call $sigmdoublematmuladd (get_local $z)                  (get_local $Wz) (get_local $x) (get_local $Uz) (get_local $h) (get_local $bz) (get_local $L))
    (call $tanhdoublematmuladd2 (get_local $hnew)              (get_local $Wh) (get_local $x) (get_local $Uh) (get_local $h) (get_local $r) (get_local $bh) (get_local $L))
    (call $vecmix_doubleassign (get_local $h) (get_local $x)   (get_local $hnew) (get_local $h) (get_local $z) (get_local $L))
  )



  ;; ------------------------- return functions -------------------------
  ;;$sigm(x): sigm(x)
  ;;$sum(x,L): sum(x)
  ;;$maximum(x,L): maximum(x)
  ;;$exp(x): exp(x)   (imported from js)
  ;;$tanh(x): tanh(x) (imported from js)

  ;; ------------------------- in-place functions -------------------------
  ;;$vecleakyrelu(y,x,L):  y=max.(0.1*x, x)
  ;;$vecsigm(y,x,L):  y=sigm.(x)
  ;;$vecmix(y,a,b,t,L): y = a*(1.-t) + b.*t
  ;;$vecexpbiased(y,x,b,L): y = exp.(x - b)
  ;;$vecexpmulbiased(y,x,b,L): y = exp.(x .* b)
  ;;$vecdivscalar(x): y = x ./ k

  ;;$vecadd(y,a,b,L): y = a.+b
  ;;$vecmul(y,a,b,L): y = a.*b
  ;;$matmul(y,w,x,L): y = w*x
  ;;$matmuladd(y,w,x,b,L): y = w*x .+ b
  ;;$doublematmuladd(y,w,x,w2,x2,b,L): y = w*x .+ w2*x2 .+ b
  ;;$sigmdoublematmuladd(y,w,x,w2,x2,b,L): y = sigm.(w*x .+ w2*x2 .+ b)
  ;;$tanhdoublematmuladd(y,w,x,w2,x2,b,L): y = tanh.(w*x .+ w2*x2 .+ b)

  (func $softmax (export "softmax") (param $y i32) (param $x i32) (param $L i32)
    (local $m f32)
    ;;softmax(x) = exp(x)/sum(exp(x))
    ;;
    ;;function softmax_overflowsafe(x)
    ;;    m = maximum(x)
    ;;    y = exp.(x - m)
    ;;    m = sum(y)
    ;;    y / m
    ;;end

    (set_local $m (call $maximum (get_local $x) (get_local $L)))
    (call $vecexpbiased (get_local $y) (get_local $x) (get_local $m) (get_local $L))
    (set_local $m (call $sum (get_local $y) (get_local $L)))
    (call $vecdivscalar (get_local $y) (get_local $y) (get_local $m) (get_local $L))
  )

  ;;tested
  (func $softmaxbiased (export "softmaxbiased") (param $y i32) (param $x i32) (param $b f32) (param $L i32)
    (local $m f32)
    ;;softmax(x.*b) (b>1 means bias toward more likely)

    (call $vecmulscalar (get_local $y) (get_local $x) (get_local $b) (get_local $L))
    (set_local $m (call $maximum (get_local $y) (get_local $L)))
    (call $vecexpbiased (get_local $y) (get_local $y) (get_local $m) (get_local $L))
    (set_local $m (call $sum (get_local $y) (get_local $L)))
    (call $vecdivscalar (get_local $y) (get_local $y) (get_local $m) (get_local $L))
  )

  (func $sigm (param $x f32) (result f32)
    ;;1/(1+exp(-x))
    (f32.div (f32.const 1) (f32.add (f32.const 1) (call $exp (f32.neg (get_local $x)))))
  )

  ;;(func $increment (param $i i32) (result i32) (i32.add (get_local $i) (i32.const 4)))
  ;;(func $idx2adr (param $i i32) (result i32) (i32.shl (get_local $i) (i32.const 2)))

  (func $vecsigm (export "vecsigm") (param $py i32) (param $px i32) (param $L i32)
    (local $N i32)
    ;;y=sigm(x)
    (set_local $N (i32.add (get_local $L) (get_local $py)))
    (loop $continue
      (f32.store (get_local $py) (call $sigm (f32.load (get_local $px))))
      (set_local $px (i32.add (get_local $px) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  
  (func $vecleakyrelu (export "vecleakyrelu") (param $py i32) (param $px i32) (param $L i32)
    (local $N i32)
    ;;max(0.1*x, x)
    (set_local $N (i32.add (get_local $L) (get_local $py)))
    (loop $continue
      (f32.store (get_local $py) (f32.max (f32.load (get_local $px)) (f32.mul (f32.load (get_local $px)) (f32.const 0.1))))
      (set_local $px (i32.add (get_local $px) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $vecmix_doubleassign (param $py i32) (param $py2 i32) (param $pa i32) (param $pb i32) (param $t i32) (param $L i32)
    (local $N i32)
    ;;y = a*(1-t) + b*t
    (set_local $N (i32.add (get_local $L) (get_local $py)))
    (loop $continue
      (f32.store (get_local $py) (f32.add 
        (f32.mul (f32.load (get_local $pa)) (f32.sub (f32.const 1) (f32.load (get_local $t))))
        (f32.mul (f32.load (get_local $pb)) (f32.load (get_local $t)))
      ))
      (f32.store (get_local $py2) (f32.load (get_local $py))) ;;y2 = copy(y)
      (set_local $pa (i32.add (get_local $pa) (i32.const 4))) ;;increment
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (set_local $py2 (i32.add (get_local $py2) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $vecmix (export "vecmix") (param $py i32) (param $pa i32) (param $pb i32) (param $t i32) (param $L i32)
    (local $N i32)
    ;;y = a*(1-t) + b*t
    (set_local $N (i32.add (get_local $L) (get_local $py)))
    (loop $continue
      (f32.store (get_local $py) (f32.add 
        (f32.mul (f32.load (get_local $pa)) (f32.sub (f32.const 1) (f32.load (get_local $t))))
        (f32.mul (f32.load (get_local $pb)) (f32.load (get_local $t)))
      ))
      (set_local $pa (i32.add (get_local $pa) (i32.const 4))) ;;increment
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $mix (export "mix") (param $py i32) (param $pa i32) (param $pb i32) (param $t f32) (param $L i32)
    (local $N i32)
    ;;y = a*(1-t) + b*t
    (set_local $N (i32.add (get_local $L) (get_local $py)))
    (loop $continue
      (f32.store (get_local $py) (f32.add 
        (f32.mul (f32.load (get_local $pa)) (f32.sub (f32.const 1) (get_local $t)))
        (f32.mul (f32.load (get_local $pb)) (get_local $t))
      ))
      (set_local $pa (i32.add (get_local $pa) (i32.const 4))) ;;increment
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $vecexpbiased (export "vecexpbiased") (param $py i32) (param $px i32) (param $b f32) (param $L i32)
    (local $N i32)
    ;;y = exp.(x - b)
    (set_local $N (i32.add (get_local $L) (get_local $py))) ;;last adress
    (loop $continue
      (f32.store (get_local $py) (call $exp (f32.sub (f32.load (get_local $px)) (get_local $b))))
      (set_local $px (i32.add (get_local $px) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $vecexpmulbiased (export "vecexpmulbiased") (param $py i32) (param $px i32) (param $b f32) (param $L i32)
    (local $N i32)
    ;;y = exp.(x .* b)
    (set_local $N (i32.add (get_local $L) (get_local $py))) ;;last adress
    (loop $continue
      (f32.store (get_local $py) (call $exp (f32.mul (f32.load (get_local $px)) (get_local $b))))
      (set_local $px (i32.add (get_local $px) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $sum (export "sum") (param $px i32) (param $L i32) (result f32)
    (local $N i32)
    (local $m f32)
    ;;sum(x)
    (set_local $N (i32.add (get_local $L) (get_local $px))) ;;last adress
    (set_local $m (f32.const 0))
    (loop $continue
      (set_local $m (f32.add (get_local $m) (f32.load (get_local $px))))
      (br_if $continue (i32.lt_u (tee_local $px (i32.add (get_local $px) (i32.const 4))) (get_local $N)))
    )
    (get_local $m)
  )


  (func $maximum (export "maximum") (param $px i32) (param $L i32) (result f32)
    (local $N i32)
    (local $m f32)
    ;;maximum(x)
    (set_local $N (i32.add (get_local $L) (get_local $px))) ;;last adress
    (set_local $m (f32.const 0))
    (loop $continue
      (set_local $m (f32.max (get_local $m) (f32.load (get_local $px))))
      (br_if $continue (i32.lt_u (tee_local $px (i32.add (get_local $px) (i32.const 4))) (get_local $N)))
    )
    (get_local $m)
  )

  (func $vecdivscalar (export "vecdivscalar") (param $py i32) (param $px i32) (param $k f32) (param $L i32)
    (local $N i32)
    ;;y = x ./ k
    (set_local $N (i32.add (get_local $L) (get_local $py))) ;;last adress
    (loop $continue
      (f32.store (get_local $py) (f32.div (f32.load (get_local $px)) (get_local $k)))
      (set_local $px (i32.add (get_local $px) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $vecmulscalar (export "vecmulscalar") (param $py i32) (param $px i32) (param $k f32) (param $L i32)
    (local $N i32)
    ;;y = x ./ k
    (set_local $N (i32.add (get_local $L) (get_local $py))) ;;last adress
    (loop $continue
      (f32.store (get_local $py) (f32.mul (f32.load (get_local $px)) (get_local $k)))
      (set_local $px (i32.add (get_local $px) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )


  (func $vecadd (export "vecadd") (param $py i32) (param $pa i32) (param $pb i32)  (param $L i32)
    (local $N i32)
    ;;y = a.+b
    (set_local $N (i32.add (get_local $L) (get_local $py))) ;;last adress    
    (loop $continue
      (f32.store (get_local $py) (f32.add (f32.load (get_local $pa)) (f32.load (get_local $pb))))
      (set_local $pa (i32.add (get_local $pa) (i32.const 4))) ;;increment
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $vecmul (export "vecmul") (param $py i32) (param $pa i32) (param $pb i32) (param $L i32)
    (local $N i32)
    ;;y = a.*b
    (set_local $N (i32.add (get_local $L) (get_local $py))) ;;last adress
    (loop $continue
      (f32.store (get_local $py) (f32.mul (f32.load (get_local $pa)) (f32.load (get_local $pb))))
      (set_local $pa (i32.add (get_local $pa) (i32.const 4))) ;;increment
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N)))
    )
  )

  (func $matmul (export "matmul") (param $py i32) (param $pw i32) (param $px i32)  (param $L i32)
    (local $pxi i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    ;;y = w*x
    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (loop $continue
        (set_local $res (f32.add (get_local $res)
          (f32.mul (f32.load (get_local $pw)) (f32.load (get_local $pxi)))
        ))
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=res
      (f32.store (get_local $py) (get_local $res))
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )

  (func $matmuladd (export "matmuladd") (param $py i32) (param $pw i32) (param $px i32) (param $pb i32) (param $L i32)
    (local $pxi i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    ;;y = w*x .+ b
    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (loop $continue
        (set_local $res (f32.add (get_local $res)
          (f32.mul (f32.load (get_local $pw)) (f32.load (get_local $pxi)))
        ))
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=res+b
      (f32.store (get_local $py) (f32.add (get_local $res) (f32.load (get_local $pb))))
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )

  (func $leakyrelumatmuladd (export "leakyrelumatmuladd") (param $py i32) (param $pw i32) (param $px i32) (param $pb i32) (param $L i32)
    (local $pxi i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    ;;y = w*x .+ b
    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (loop $continue
        (set_local $res (f32.add (get_local $res)
          (f32.mul (f32.load (get_local $pw)) (f32.load (get_local $pxi)))
        ))
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;res=res+b
      (set_local $res (f32.add (get_local $res) (f32.load (get_local $pb))))
      ;;y=leakyrely(res)
      (f32.store (get_local $py) (f32.max (get_local $res) (f32.mul (get_local $res) (f32.const 0.1))))

      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )

  (func $matmuladd2 (export "matmuladd2") (param $py i32) (param $pw i32) (param $px i32) (param $pb i32) (param $L i32) (param $L2 i32)
    (local $pxi i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    ;;for nonsquare w
    ;;y = w*x .+ b
    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L2) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (loop $continue
        (set_local $res (f32.add (get_local $res)
          (f32.mul (f32.load (get_local $pw)) (f32.load (get_local $pxi)))
        ))
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=res+b
      (f32.store (get_local $py) (f32.add (get_local $res) (f32.load (get_local $pb))))
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )


  (func $doublematmuladd (export "doublematmuladd") (param $py i32) (param $pw i32) (param $px i32) (param $pw2 i32) (param $px2 i32) (param $pb i32) (param $L i32)
    (local $pxi i32)
    (local $px2i i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    ;;y = w*x .+ w2*x2 .+ b
    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (set_local $px2i (get_local $px2)) ;;reset
      (loop $continue
        (set_local $res (f32.add (get_local $res)
          (f32.add
            (f32.mul (f32.load (get_local $pw)) (f32.load (get_local $pxi)))
            (f32.mul (f32.load (get_local $pw2)) (f32.load (get_local $px2i)))
          )
        ))
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (set_local $pw2 (i32.add (get_local $pw2) (i32.const 4))) ;;increment
        (set_local $px2i (i32.add (get_local $px2i) (i32.const 4))) ;;increment
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=res+b
      (f32.store (get_local $py) (f32.add (get_local $res) (f32.load (get_local $pb))))
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )

  (func $sigmdoublematmuladd (export "sigmdoublematmuladd") (param $py i32) (param $pw i32) (param $px i32) (param $pw2 i32) (param $px2 i32) (param $pb i32) (param $L i32)    (local $pxi i32)
    (local $px2i i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    ;;y = sigm.(w*x .+ w2*x2 .+ b)
    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (set_local $px2i (get_local $px2)) ;;reset
      (loop $continue
        (set_local $res (f32.add (get_local $res)
          (f32.add
            (f32.mul (f32.load (get_local $pw)) (f32.load (get_local $pxi)))
            (f32.mul (f32.load (get_local $pw2)) (f32.load (get_local $px2i)))
          )
        ))
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (set_local $px2i (i32.add (get_local $px2i) (i32.const 4))) ;;increment
        (set_local $pw2 (i32.add (get_local $pw2) (i32.const 4))) ;;increment
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=sigm(res+b)
      (f32.store (get_local $py) (call $sigm (f32.add (get_local $res) (f32.load (get_local $pb)))))
      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )
  
  (func $tanhdoublematmuladd (export "tanhdoublematmuladd") (param $py i32) (param $pw i32) (param $px i32) (param $pw2 i32) (param $px2 i32) (param $pr i32) (param $pb i32) (param $L i32)
    (local $pxi i32)
    (local $px2i i32)
    (local $pri i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    (local $res2 f32)
    ;;tanh.(w*x .+ w2*(r.*x2) .+ b)

    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $res2 (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (set_local $px2i (get_local $px2)) ;;reset
      (set_local $pri (get_local $pr)) ;;reset
      (loop $continue
        (set_local $res  (f32.add (get_local $res)  (f32.mul (f32.load (get_local $pw))
          (f32.load (get_local $pxi))
        )))
        (set_local $res2 (f32.add (get_local $res2) (f32.mul (f32.load (get_local $pw2))
          (f32.mul (f32.load (get_local $pri)) (f32.load (get_local $px2i))) ;;r*x2
        )))
        
        
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (set_local $pw2 (i32.add (get_local $pw2) (i32.const 4))) ;;increment
        (set_local $px2i (i32.add (get_local $px2i) (i32.const 4))) ;;increment
        (set_local $pri (i32.add (get_local $pri) (i32.const 4))) ;;increment
        
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=tanh(res + res2 + b)
      (f32.store (get_local $py) (call $tanh
        (f32.add (get_local $res)
          (f32.add (get_local $res2) (f32.load (get_local $pb)))
        )
      ))

      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )


  (func $tanhdoublematmuladd2 (export "tanhdoublematmuladd2") (param $py i32) (param $pw i32) (param $px i32) (param $pw2 i32) (param $px2 i32) (param $pr i32) (param $pb i32) (param $L i32)
    (local $pxi i32)
    (local $px2i i32)
    (local $N i32)
    (local $N2 i32)
    (local $res f32)
    (local $res2 f32)
    ;;tanh.(w*x .+ r.*(w2*x2) .+ b)

    (set_local $N (i32.add (get_local $L) (get_local $px)))
    (set_local $N2 (i32.add (get_local $L) (get_local $py)))
    (loop $continue2
      (set_local $res (f32.const 0))
      (set_local $res2 (f32.const 0))
      (set_local $pxi (get_local $px)) ;;reset
      (set_local $px2i (get_local $px2)) ;;reset
      (loop $continue
        (set_local $res  (f32.add (get_local $res)  (f32.mul (f32.load (get_local $pw))
          (f32.load (get_local $pxi))
        )))
        (set_local $res2 (f32.add (get_local $res2) (f32.mul (f32.load (get_local $pw2))
          (f32.load (get_local $px2i))
        )))
        
        (set_local $pw (i32.add (get_local $pw) (i32.const 4))) ;;increment
        (set_local $pw2 (i32.add (get_local $pw2) (i32.const 4))) ;;increment
        (set_local $px2i (i32.add (get_local $px2i) (i32.const 4))) ;;increment
        
        (br_if $continue (i32.lt_u (tee_local $pxi (i32.add (get_local $pxi) (i32.const 4))) (get_local $N)))
      )
      ;;y=tanh(res + r*res2 + b)
      (f32.store (get_local $py) (call $tanh 
        (f32.add (get_local $res)
          (f32.add
            (f32.mul (f32.load (get_local $pr)) (get_local $res2))
            (f32.load (get_local $pb))
          )
        )
      ))

      (set_local $pb (i32.add (get_local $pb) (i32.const 4))) ;;increment
      (set_local $pr (i32.add (get_local $pr) (i32.const 4))) ;;increment
      (br_if $continue2 (i32.lt_u (tee_local $py (i32.add (get_local $py) (i32.const 4))) (get_local $N2)))
    )
  )

;;

);;module