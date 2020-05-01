(module
  (type (;0;) (func (param i32 i32 f32 i32)))
  (type (;1;) (func (param i32 i32 i32 i32)))
  (type (;2;) (func (param i32 i32 i32 i32 i32)))
  (type (;3;) (func (param i32 i32 i32)))
  (type (;4;) (func (param f32) (result f32)))
  (type (;5;) (func (param i32 i32 i32 i32 i32 i32 i32)))
  (type (;6;) (func (param i32 i32 i32 i32 i32 i32 i32 i32)))
  (type (;7;) (func (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)))
  (type (;8;) (func (param i32 i32) (result f32)))
  (type (;9;) (func (param i32 i32 i32 i32 i32 i32)))
  (type (;10;) (func (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)))
  (type (;11;) (func (param i32 i32 i32 i32 f32 i32 i32)))
  (type (;12;) (func (param i32 i32 i32 f32 i32)))
  (type (;13;) (func (param f32 f32) (result f32)))
  (import "imports" "exp" (func (;0;) (type 4)))
  (import "imports" "tanh" (func (;1;) (type 4)))
  (import "imports" "mem" (memory (;0;) 1))
  (func (;2;) (type 13) (param f32 f32) (result f32)
    local.get 0
    local.get 0
    local.get 0
    f32.mul
    f32.mul
    local.get 1
    f32.div)
  (func (;3;) (type 11) (param i32 i32 i32 i32 f32 i32 i32)
    local.get 0
    local.get 2
    local.get 1
    local.get 3
    local.get 5
    local.get 6
    call 27
    local.get 0
    local.get 0
    local.get 4
    local.get 6
    call 9)
  (func (;4;) (type 2) (param i32 i32 i32 i32 i32)
    local.get 0
    local.get 2
    local.get 1
    local.get 3
    local.get 4
    call 25
    local.get 0
    local.get 0
    local.get 4
    call 11)
  (func (;5;) (type 10) (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    local.get 3
    i32.const 0
    local.get 4
    i32.const 384
    call 26
    local.get 0
    local.get 1
    local.get 5
    local.get 6
    local.get 7
    local.get 8
    local.get 9
    local.get 10
    local.get 11
    local.get 12
    local.get 13
    i32.const 384
    call 6
    local.get 0
    local.get 2
    local.get 14
    local.get 15
    local.get 16
    local.get 17
    local.get 18
    local.get 19
    local.get 20
    local.get 21
    local.get 22
    i32.const 384
    call 7)
  (func (;6;) (type 7) (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 384
    local.get 5
    local.get 0
    local.get 6
    local.get 1
    local.get 7
    local.get 11
    call 29
    i32.const 768
    local.get 2
    local.get 0
    local.get 3
    local.get 1
    local.get 4
    local.get 11
    call 29
    i32.const 1152
    local.get 8
    local.get 0
    local.get 9
    local.get 1
    i32.const 384
    local.get 10
    local.get 11
    call 30
    local.get 1
    local.get 0
    local.get 1
    local.get 11
    call 13)
  (func (;7;) (type 7) (param i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 384
    local.get 5
    local.get 0
    local.get 6
    local.get 1
    local.get 7
    local.get 11
    call 29
    i32.const 768
    local.get 2
    local.get 0
    local.get 3
    local.get 1
    local.get 4
    local.get 11
    call 29
    i32.const 1152
    local.get 8
    local.get 0
    local.get 9
    local.get 1
    i32.const 384
    local.get 10
    local.get 11
    call 31
    local.get 1
    local.get 0
    local.get 1
    local.get 11
    call 13)
  (func (;8;) (type 3) (param i32 i32 i32)
    local.get 0
    local.get 1
    local.get 1
    local.get 2
    call 19
    local.get 2
    call 16
    local.get 0
    local.get 0
    local.get 0
    local.get 2
    call 18
    local.get 2
    call 20)
  (func (;9;) (type 0) (param i32 i32 f32 i32)
    local.get 0
    local.get 1
    local.get 2
    local.get 3
    call 21
    local.get 0
    local.get 0
    local.get 0
    local.get 3
    call 19
    local.get 3
    call 16
    local.get 0
    local.get 0
    local.get 0
    local.get 3
    call 18
    local.get 3
    call 20)
  (func (;10;) (type 4) (param f32) (result f32)
    f32.const 0x1p+0 (;=1;)
    f32.const 0x1p+0 (;=1;)
    local.get 0
    f32.neg
    call 0
    f32.add
    f32.div)
  (func (;11;) (type 3) (param i32 i32 i32)
    local.get 0
    local.get 2
    i32.add
    local.set 2
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      call 10
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 2
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;12;) (type 3) (param i32 i32 i32)
    local.get 0
    local.get 2
    i32.add
    local.set 2
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 1
      f32.load
      f32.const 0x1.99999ap-4 (;=0.1;)
      f32.mul
      f32.max
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 2
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;13;) (type 1) (param i32 i32 i32 i32)
    (local i32)
    i32.const 1152
    local.set 4
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 4
      f32.load
      f32.const 0x1p+0 (;=1;)
      i32.const 768
      f32.load
      f32.sub
      f32.mul
      local.get 2
      f32.load
      i32.const 768
      f32.load
      f32.mul
      f32.add
      f32.store
      local.get 1
      local.get 0
      f32.load
      f32.store
      local.get 4
      i32.const 4
      i32.add
      local.set 4
      local.get 2
      i32.const 4
      i32.add
      local.set 2
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;14;) (type 2) (param i32 i32 i32 i32 i32)
    local.get 0
    local.get 4
    i32.add
    local.set 4
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      f32.const 0x1p+0 (;=1;)
      local.get 3
      f32.load
      f32.sub
      f32.mul
      local.get 2
      f32.load
      local.get 3
      f32.load
      f32.mul
      f32.add
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 2
      i32.const 4
      i32.add
      local.set 2
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 4
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;15;) (type 12) (param i32 i32 i32 f32 i32)
    local.get 0
    local.get 4
    i32.add
    local.set 4
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      f32.const 0x1p+0 (;=1;)
      local.get 3
      f32.sub
      f32.mul
      local.get 2
      f32.load
      local.get 3
      f32.mul
      f32.add
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 2
      i32.const 4
      i32.add
      local.set 2
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 4
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;16;) (type 0) (param i32 i32 f32 i32)
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 2
      f32.sub
      call 0
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;17;) (type 0) (param i32 i32 f32 i32)
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 2
      f32.mul
      call 0
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;18;) (type 8) (param i32 i32) (result f32)
    (local f32)
    local.get 0
    local.get 1
    i32.add
    local.set 1
    loop  ;; label = @1
      local.get 2
      local.get 0
      f32.load
      f32.add
      local.set 2
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 1
      i32.lt_u
      br_if 0 (;@1;)
    end
    local.get 2)
  (func (;19;) (type 8) (param i32 i32) (result f32)
    (local f32)
    local.get 0
    local.get 1
    i32.add
    local.set 1
    loop  ;; label = @1
      local.get 2
      local.get 0
      f32.load
      f32.max
      local.set 2
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 1
      i32.lt_u
      br_if 0 (;@1;)
    end
    local.get 2)
  (func (;20;) (type 0) (param i32 i32 f32 i32)
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 2
      f32.div
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;21;) (type 0) (param i32 i32 f32 i32)
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 2
      f32.mul
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;22;) (type 1) (param i32 i32 i32 i32)
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 2
      f32.load
      f32.add
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 2
      i32.const 4
      i32.add
      local.set 2
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;23;) (type 1) (param i32 i32 i32 i32)
    local.get 0
    local.get 3
    i32.add
    local.set 3
    loop  ;; label = @1
      local.get 0
      local.get 1
      f32.load
      local.get 2
      f32.load
      f32.mul
      f32.store
      local.get 1
      i32.const 4
      i32.add
      local.set 1
      local.get 2
      i32.const 4
      i32.add
      local.set 2
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 3
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;24;) (type 1) (param i32 i32 i32 i32)
    (local i32 i32 f32)
    local.get 2
    local.get 3
    i32.add
    local.set 4
    local.get 0
    local.get 3
    i32.add
    local.set 5
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 6
      local.get 2
      local.set 3
      loop  ;; label = @2
        local.get 6
        local.get 1
        f32.load
        local.get 3
        f32.load
        f32.mul
        f32.add
        local.set 6
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 3
        i32.const 4
        i32.add
        local.tee 3
        local.get 4
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 6
      f32.store
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 5
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;25;) (type 2) (param i32 i32 i32 i32 i32)
    (local i32 i32 f32)
    local.get 2
    local.get 4
    i32.add
    local.set 5
    local.get 0
    local.get 4
    i32.add
    local.set 6
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 7
      local.get 2
      local.set 4
      loop  ;; label = @2
        local.get 7
        local.get 1
        f32.load
        local.get 4
        f32.load
        f32.mul
        f32.add
        local.set 7
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 4
        i32.const 4
        i32.add
        local.tee 4
        local.get 5
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 7
      local.get 3
      f32.load
      f32.add
      f32.store
      local.get 3
      i32.const 4
      i32.add
      local.set 3
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 6
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;26;) (type 2) (param i32 i32 i32 i32 i32)
    (local i32 i32 f32)
    local.get 2
    local.get 4
    i32.add
    local.set 5
    local.get 0
    local.get 4
    i32.add
    local.set 6
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 7
      local.get 2
      local.set 4
      loop  ;; label = @2
        local.get 7
        local.get 1
        f32.load
        local.get 4
        f32.load
        f32.mul
        f32.add
        local.set 7
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 4
        i32.const 4
        i32.add
        local.tee 4
        local.get 5
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 7
      local.get 3
      f32.load
      f32.add
      local.tee 7
      local.get 7
      f32.const 0x1.99999ap-4 (;=0.1;)
      f32.mul
      f32.max
      f32.store
      local.get 3
      i32.const 4
      i32.add
      local.set 3
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 6
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;27;) (type 9) (param i32 i32 i32 i32 i32 i32)
    (local i32 f32)
    local.get 2
    local.get 4
    i32.add
    local.set 6
    local.get 0
    local.get 5
    i32.add
    local.set 5
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 7
      local.get 2
      local.set 4
      loop  ;; label = @2
        local.get 7
        local.get 1
        f32.load
        local.get 4
        f32.load
        f32.mul
        f32.add
        local.set 7
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 4
        i32.const 4
        i32.add
        local.tee 4
        local.get 6
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 7
      local.get 3
      f32.load
      f32.add
      f32.store
      local.get 3
      i32.const 4
      i32.add
      local.set 3
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 5
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;28;) (type 5) (param i32 i32 i32 i32 i32 i32 i32)
    (local i32 i32 i32 f32)
    local.get 2
    local.get 6
    i32.add
    local.set 8
    local.get 0
    local.get 6
    i32.add
    local.set 9
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 10
      local.get 2
      local.set 6
      local.get 4
      local.set 7
      loop  ;; label = @2
        local.get 10
        local.get 1
        f32.load
        local.get 6
        f32.load
        f32.mul
        local.get 3
        f32.load
        local.get 7
        f32.load
        f32.mul
        f32.add
        f32.add
        local.set 10
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 3
        i32.const 4
        i32.add
        local.set 3
        local.get 7
        i32.const 4
        i32.add
        local.set 7
        local.get 6
        i32.const 4
        i32.add
        local.tee 6
        local.get 8
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 10
      local.get 5
      f32.load
      f32.add
      f32.store
      local.get 5
      i32.const 4
      i32.add
      local.set 5
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 9
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;29;) (type 5) (param i32 i32 i32 i32 i32 i32 i32)
    (local i32 i32 i32 f32)
    local.get 2
    local.get 6
    i32.add
    local.set 8
    local.get 0
    local.get 6
    i32.add
    local.set 9
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 10
      local.get 2
      local.set 6
      local.get 4
      local.set 7
      loop  ;; label = @2
        local.get 10
        local.get 1
        f32.load
        local.get 6
        f32.load
        f32.mul
        local.get 3
        f32.load
        local.get 7
        f32.load
        f32.mul
        f32.add
        f32.add
        local.set 10
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 7
        i32.const 4
        i32.add
        local.set 7
        local.get 3
        i32.const 4
        i32.add
        local.set 3
        local.get 6
        i32.const 4
        i32.add
        local.tee 6
        local.get 8
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 10
      local.get 5
      f32.load
      f32.add
      call 10
      f32.store
      local.get 5
      i32.const 4
      i32.add
      local.set 5
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 9
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;30;) (type 6) (param i32 i32 i32 i32 i32 i32 i32 i32)
    (local i32 i32 i32 i32 f32 f32)
    local.get 2
    local.get 7
    i32.add
    local.set 10
    local.get 0
    local.get 7
    i32.add
    local.set 11
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 12
      f32.const 0x0p+0 (;=0;)
      local.set 13
      local.get 2
      local.set 7
      local.get 4
      local.set 8
      local.get 5
      local.set 9
      loop  ;; label = @2
        local.get 12
        local.get 1
        f32.load
        local.get 7
        f32.load
        f32.mul
        f32.add
        local.set 12
        local.get 13
        local.get 3
        f32.load
        local.get 9
        f32.load
        local.get 8
        f32.load
        f32.mul
        f32.mul
        f32.add
        local.set 13
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 3
        i32.const 4
        i32.add
        local.set 3
        local.get 8
        i32.const 4
        i32.add
        local.set 8
        local.get 9
        i32.const 4
        i32.add
        local.set 9
        local.get 7
        i32.const 4
        i32.add
        local.tee 7
        local.get 10
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 12
      local.get 13
      local.get 6
      f32.load
      f32.add
      f32.add
      call 1
      f32.store
      local.get 6
      i32.const 4
      i32.add
      local.set 6
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 11
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (func (;31;) (type 6) (param i32 i32 i32 i32 i32 i32 i32 i32)
    (local i32 i32 i32 f32 f32)
    local.get 2
    local.get 7
    i32.add
    local.set 9
    local.get 0
    local.get 7
    i32.add
    local.set 10
    loop  ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.set 11
      f32.const 0x0p+0 (;=0;)
      local.set 12
      local.get 2
      local.set 7
      local.get 4
      local.set 8
      loop  ;; label = @2
        local.get 11
        local.get 1
        f32.load
        local.get 7
        f32.load
        f32.mul
        f32.add
        local.set 11
        local.get 12
        local.get 3
        f32.load
        local.get 8
        f32.load
        f32.mul
        f32.add
        local.set 12
        local.get 1
        i32.const 4
        i32.add
        local.set 1
        local.get 3
        i32.const 4
        i32.add
        local.set 3
        local.get 8
        i32.const 4
        i32.add
        local.set 8
        local.get 7
        i32.const 4
        i32.add
        local.tee 7
        local.get 9
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      local.get 11
      local.get 5
      f32.load
      local.get 12
      f32.mul
      local.get 6
      f32.load
      f32.add
      f32.add
      call 1
      f32.store
      local.get 6
      i32.const 4
      i32.add
      local.set 6
      local.get 5
      i32.const 4
      i32.add
      local.set 5
      local.get 0
      i32.const 4
      i32.add
      local.tee 0
      local.get 10
      i32.lt_u
      br_if 0 (;@1;)
    end)
  (export "debugfunc" (func 2))
  (export "mixture_m" (func 3))
  (export "mixture_p" (func 4))
  (export "fprop" (func 5))
  (export "gru" (func 6))
  (export "gru2" (func 7))
  (export "softmax" (func 8))
  (export "softmaxbiased" (func 9))
  (export "vecsigm" (func 11))
  (export "vecleakyrelu" (func 12))
  (export "vecmix" (func 14))
  (export "mix" (func 15))
  (export "vecexpbiased" (func 16))
  (export "vecexpmulbiased" (func 17))
  (export "sum" (func 18))
  (export "maximum" (func 19))
  (export "vecdivscalar" (func 20))
  (export "vecmulscalar" (func 21))
  (export "vecadd" (func 22))
  (export "vecmul" (func 23))
  (export "matmul" (func 24))
  (export "matmuladd" (func 25))
  (export "leakyrelumatmuladd" (func 26))
  (export "matmuladd2" (func 27))
  (export "doublematmuladd" (func 28))
  (export "sigmdoublematmuladd" (func 29))
  (export "tanhdoublematmuladd" (func 30))
  (export "tanhdoublematmuladd2" (func 31)))
