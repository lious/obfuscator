; RUN: opt < %s -simplifycfg -S | FileCheck %s

; Test that a switch going to a switch on the same value can be merged.
; All three switches in this example can be merged into one big one.

declare void @foo1()

declare void @foo2()

declare void @foo3()

declare void @foo4()

define void @test1(i32 %V) {
        switch i32 %V, label %F [
                 i32 4, label %T
                 i32 17, label %T
                 i32 5, label %T
                 i32 1234, label %F
        ]
T:              ; preds = %0, %0, %0
        switch i32 %V, label %F [
                 i32 4, label %A
                 i32 17, label %B
                 i32 42, label %C
        ]
A:              ; preds = %T
        call void @foo1( )
        ret void
B:              ; preds = %F, %F, %T
        call void @foo2( )
        ret void
C:              ; preds = %T
        call void @foo3( )
        ret void
F:              ; preds = %F, %T, %0, %0
        switch i32 %V, label %F [
                 i32 4, label %B
                 i32 18, label %B
                 i32 42, label %D
        ]
D:              ; preds = %F
        call void @foo4( )
        ret void

; CHECK-LABEL: @test1(
; CHECK-NEXT:    switch i32 %V, label %infloop [
; CHECK-NEXT:    i32 4, label %A
; CHECK-NEXT:    i32 17, label %B
; CHECK-NEXT:    i32 18, label %B
; CHECK-NEXT:    i32 42, label %D
; CHECK-NEXT:    ]
; CHECK:       A:
; CHECK-NEXT:    call void @foo1()
; CHECK-NEXT:    ret void
; CHECK:       B:
; CHECK-NEXT:    call void @foo2()
; CHECK-NEXT:    ret void
; CHECK:       D:
; CHECK-NEXT:    call void @foo4()
; CHECK-NEXT:    ret void
; CHECK:       infloop:
; CHECK-NEXT:    br label %infloop
}

