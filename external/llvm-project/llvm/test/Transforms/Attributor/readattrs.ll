; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=2 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM


@x = global i32 0

declare void @test1_1(i8* %x1_1, i8* readonly %y1_1, ...)

; NOTE: readonly for %y1_2 would be OK here but not for the similar situation in test13.
;
;.
; CHECK: @[[X:[a-zA-Z0-9_$"\\.-]+]] = global i32 0
; CHECK: @[[CONSTANT_MEM:[a-zA-Z0-9_$"\\.-]+]] = external dso_local constant i32, align 4
;.
define void @test1_2(i8* %x1_2, i8* %y1_2, i8* %z1_2) {
; CHECK-LABEL: define {{[^@]+}}@test1_2
; CHECK-SAME: (i8* [[X1_2:%.*]], i8* [[Y1_2:%.*]], i8* [[Z1_2:%.*]]) {
; CHECK-NEXT:    call void (i8*, i8*, ...) @test1_1(i8* [[X1_2]], i8* readonly [[Y1_2]], i8* [[Z1_2]])
; CHECK-NEXT:    store i32 0, i32* @x, align 4
; CHECK-NEXT:    ret void
;
  call void (i8*, i8*, ...) @test1_1(i8* %x1_2, i8* %y1_2, i8* %z1_2)
  store i32 0, i32* @x
  ret void
}

define i8* @test2(i8* %p) {
; CHECK: Function Attrs: nofree norecurse nosync nounwind willreturn writeonly
; CHECK-LABEL: define {{[^@]+}}@test2
; CHECK-SAME: (i8* nofree readnone returned "no-capture-maybe-returned" [[P:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    store i32 0, i32* @x, align 4
; CHECK-NEXT:    ret i8* [[P]]
;
  store i32 0, i32* @x
  ret i8* %p
}

define i1 @test3(i8* %p, i8* %q) {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@test3
; CHECK-SAME: (i8* nofree readnone [[P:%.*]], i8* nofree readnone [[Q:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:    [[A:%.*]] = icmp ult i8* [[P]], [[Q]]
; CHECK-NEXT:    ret i1 [[A]]
;
  %A = icmp ult i8* %p, %q
  ret i1 %A
}

declare void @test4_1(i8* nocapture) readonly

define void @test4_2(i8* %p) {
; CHECK: Function Attrs: readonly
; CHECK-LABEL: define {{[^@]+}}@test4_2
; CHECK-SAME: (i8* nocapture readonly [[P:%.*]]) #[[ATTR2:[0-9]+]] {
; CHECK-NEXT:    call void @test4_1(i8* nocapture readonly [[P]]) #[[ATTR2]]
; CHECK-NEXT:    ret void
;
  call void @test4_1(i8* %p)
  ret void
}

; Missed optz'n: we could make %q readnone, but don't break test6!
define void @test5(i8** %p, i8* %q) {
; CHECK: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; CHECK-LABEL: define {{[^@]+}}@test5
; CHECK-SAME: (i8** nocapture nofree noundef nonnull writeonly align 8 dereferenceable(8) [[P:%.*]], i8* nofree writeonly [[Q:%.*]]) #[[ATTR3:[0-9]+]] {
; CHECK-NEXT:    store i8* [[Q]], i8** [[P]], align 8
; CHECK-NEXT:    ret void
;
  store i8* %q, i8** %p
  ret void
}

declare void @test6_1()
; This is not a missed optz'n.
define void @test6_2(i8** %p, i8* %q) {
; CHECK-LABEL: define {{[^@]+}}@test6_2
; CHECK-SAME: (i8** nocapture nofree noundef nonnull writeonly align 8 dereferenceable(8) [[P:%.*]], i8* nofree [[Q:%.*]]) {
; CHECK-NEXT:    store i8* [[Q]], i8** [[P]], align 8
; CHECK-NEXT:    call void @test6_1()
; CHECK-NEXT:    ret void
;
  store i8* %q, i8** %p
  call void @test6_1()
  ret void
}

; inalloca parameters are always considered written
define void @test7_1(i32* inalloca(i32) %a) {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@test7_1
; CHECK-SAME: (i32* nocapture nofree nonnull writeonly inalloca(i32) dereferenceable(4) [[A:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:    ret void
;
  ret void
}

define i32* @test8_1(i32* %p) {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@test8_1
; CHECK-SAME: (i32* nofree readnone returned "no-capture-maybe-returned" [[P:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i32* [[P]]
;
entry:
  ret i32* %p
}

define void @test8_2(i32* %p) {
; IS__TUNIT____: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@test8_2
; IS__TUNIT____-SAME: (i32* nocapture nofree writeonly [[P:%.*]]) #[[ATTR3]] {
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    store i32 10, i32* [[P]], align 4
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree nosync nounwind willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@test8_2
; IS__CGSCC____-SAME: (i32* nofree writeonly [[P:%.*]]) #[[ATTR4:[0-9]+]] {
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call align 4 i32* @test8_1(i32* noalias nofree readnone [[P]]) #[[ATTR13:[0-9]+]]
; IS__CGSCC____-NEXT:    store i32 10, i32* [[CALL]], align 4
; IS__CGSCC____-NEXT:    ret void
;
entry:
  %call = call i32* @test8_1(i32* %p)
  store i32 10, i32* %call, align 4
  ret void
}

; CHECK: declare void @llvm.masked.scatter
declare void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32>%val, <4 x i32*>, i32, <4 x i1>)

; CHECK-NOT: readnone
; CHECK-NOT: readonly
define void @test9(<4 x i32*> %ptrs, <4 x i32>%val) {
; IS__TUNIT____: Function Attrs: nofree norecurse nosync nounwind willreturn writeonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@test9
; IS__TUNIT____-SAME: (<4 x i32*> [[PTRS:%.*]], <4 x i32> [[VAL:%.*]]) #[[ATTR0]] {
; IS__TUNIT____-NEXT:    call void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32> [[VAL]], <4 x i32*> [[PTRS]], i32 noundef 4, <4 x i1> noundef <i1 true, i1 false, i1 true, i1 false>) #[[ATTR12:[0-9]+]]
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind willreturn writeonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@test9
; IS__CGSCC____-SAME: (<4 x i32*> [[PTRS:%.*]], <4 x i32> [[VAL:%.*]]) #[[ATTR0]] {
; IS__CGSCC____-NEXT:    call void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32> [[VAL]], <4 x i32*> [[PTRS]], i32 noundef 4, <4 x i1> noundef <i1 true, i1 false, i1 true, i1 false>) #[[ATTR14:[0-9]+]]
; IS__CGSCC____-NEXT:    ret void
;
  call void @llvm.masked.scatter.v4i32.v4p0i32(<4 x i32>%val, <4 x i32*> %ptrs, i32 4, <4 x i1><i1 true, i1 false, i1 true, i1 false>)
  ret void
}

; CHECK: declare <4 x i32> @llvm.masked.gather
declare <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*>, i32, <4 x i1>, <4 x i32>)
define <4 x i32> @test10(<4 x i32*> %ptrs) {
; IS__TUNIT____: Function Attrs: nofree norecurse nosync nounwind readonly willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@test10
; IS__TUNIT____-SAME: (<4 x i32*> [[PTRS:%.*]]) #[[ATTR6:[0-9]+]] {
; IS__TUNIT____-NEXT:    [[RES:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[PTRS]], i32 noundef 4, <4 x i1> noundef <i1 true, i1 false, i1 true, i1 false>, <4 x i32> undef) #[[ATTR13:[0-9]+]]
; IS__TUNIT____-NEXT:    ret <4 x i32> [[RES]]
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind readonly willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@test10
; IS__CGSCC____-SAME: (<4 x i32*> [[PTRS:%.*]]) #[[ATTR7:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[RES:%.*]] = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> [[PTRS]], i32 noundef 4, <4 x i1> noundef <i1 true, i1 false, i1 true, i1 false>, <4 x i32> undef) #[[ATTR15:[0-9]+]]
; IS__CGSCC____-NEXT:    ret <4 x i32> [[RES]]
;
  %res = call <4 x i32> @llvm.masked.gather.v4i32.v4p0i32(<4 x i32*> %ptrs, i32 4, <4 x i1><i1 true, i1 false, i1 true, i1 false>, <4 x i32>undef)
  ret <4 x i32> %res
}

; CHECK: declare <4 x i32> @test11_1
declare <4 x i32> @test11_1(<4 x i32*>) argmemonly nounwind readonly
define <4 x i32> @test11_2(<4 x i32*> %ptrs) {
; IS__TUNIT____: Function Attrs: argmemonly nounwind readonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@test11_2
; IS__TUNIT____-SAME: (<4 x i32*> [[PTRS:%.*]]) #[[ATTR7:[0-9]+]] {
; IS__TUNIT____-NEXT:    [[RES:%.*]] = call <4 x i32> @test11_1(<4 x i32*> [[PTRS]]) #[[ATTR11:[0-9]+]]
; IS__TUNIT____-NEXT:    ret <4 x i32> [[RES]]
;
; IS__CGSCC____: Function Attrs: argmemonly nounwind readonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@test11_2
; IS__CGSCC____-SAME: (<4 x i32*> [[PTRS:%.*]]) #[[ATTR8:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[RES:%.*]] = call <4 x i32> @test11_1(<4 x i32*> [[PTRS]]) #[[ATTR12:[0-9]+]]
; IS__CGSCC____-NEXT:    ret <4 x i32> [[RES]]
;
  %res = call <4 x i32> @test11_1(<4 x i32*> %ptrs)
  ret <4 x i32> %res
}

declare <4 x i32> @test12_1(<4 x i32*>) argmemonly nounwind
; CHECK-NOT: readnone
define <4 x i32> @test12_2(<4 x i32*> %ptrs) {
; IS__TUNIT____: Function Attrs: argmemonly nounwind
; IS__TUNIT____-LABEL: define {{[^@]+}}@test12_2
; IS__TUNIT____-SAME: (<4 x i32*> [[PTRS:%.*]]) #[[ATTR8:[0-9]+]] {
; IS__TUNIT____-NEXT:    [[RES:%.*]] = call <4 x i32> @test12_1(<4 x i32*> [[PTRS]]) #[[ATTR14:[0-9]+]]
; IS__TUNIT____-NEXT:    ret <4 x i32> [[RES]]
;
; IS__CGSCC____: Function Attrs: argmemonly nounwind
; IS__CGSCC____-LABEL: define {{[^@]+}}@test12_2
; IS__CGSCC____-SAME: (<4 x i32*> [[PTRS:%.*]]) #[[ATTR9:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[RES:%.*]] = call <4 x i32> @test12_1(<4 x i32*> [[PTRS]]) #[[ATTR16:[0-9]+]]
; IS__CGSCC____-NEXT:    ret <4 x i32> [[RES]]
;
  %res = call <4 x i32> @test12_1(<4 x i32*> %ptrs)
  ret <4 x i32> %res
}

define i32 @volatile_load(i32* %p) {
; IS__TUNIT____: Function Attrs: argmemonly nofree norecurse nounwind willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@volatile_load
; IS__TUNIT____-SAME: (i32* nofree noundef align 4 [[P:%.*]]) #[[ATTR9:[0-9]+]] {
; IS__TUNIT____-NEXT:    [[LOAD:%.*]] = load volatile i32, i32* [[P]], align 4
; IS__TUNIT____-NEXT:    ret i32 [[LOAD]]
;
; IS__CGSCC____: Function Attrs: argmemonly nofree norecurse nounwind willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@volatile_load
; IS__CGSCC____-SAME: (i32* nofree noundef align 4 [[P:%.*]]) #[[ATTR10:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[LOAD:%.*]] = load volatile i32, i32* [[P]], align 4
; IS__CGSCC____-NEXT:    ret i32 [[LOAD]]
;
  %load = load volatile i32, i32* %p
  ret i32 %load
}

declare void @escape_readnone_ptr(i8** %addr, i8* readnone %ptr)
declare void @escape_readonly_ptr(i8** %addr, i8* readonly %ptr)

; The argument pointer %escaped_then_written cannot be marked readnone/only even
; though the only direct use, in @escape_readnone_ptr/@escape_readonly_ptr,
; is marked as readnone/only. However, the functions can write the pointer into
; %addr, causing the store to write to %escaped_then_written.
;
define void @unsound_readnone(i8* %ignored, i8* %escaped_then_written) {
; CHECK-LABEL: define {{[^@]+}}@unsound_readnone
; CHECK-SAME: (i8* nocapture nofree readnone [[IGNORED:%.*]], i8* [[ESCAPED_THEN_WRITTEN:%.*]]) {
; CHECK-NEXT:    [[ADDR:%.*]] = alloca i8*, align 8
; CHECK-NEXT:    call void @escape_readnone_ptr(i8** noundef nonnull align 8 dereferenceable(8) [[ADDR]], i8* noalias readnone [[ESCAPED_THEN_WRITTEN]])
; CHECK-NEXT:    [[ADDR_LD:%.*]] = load i8*, i8** [[ADDR]], align 8
; CHECK-NEXT:    store i8 0, i8* [[ADDR_LD]], align 1
; CHECK-NEXT:    ret void
;
  %addr = alloca i8*
  call void @escape_readnone_ptr(i8** %addr, i8* %escaped_then_written)
  %addr.ld = load i8*, i8** %addr
  store i8 0, i8* %addr.ld
  ret void
}

define void @unsound_readonly(i8* %ignored, i8* %escaped_then_written) {
; CHECK-LABEL: define {{[^@]+}}@unsound_readonly
; CHECK-SAME: (i8* nocapture nofree readnone [[IGNORED:%.*]], i8* [[ESCAPED_THEN_WRITTEN:%.*]]) {
; CHECK-NEXT:    [[ADDR:%.*]] = alloca i8*, align 8
; CHECK-NEXT:    call void @escape_readonly_ptr(i8** noundef nonnull align 8 dereferenceable(8) [[ADDR]], i8* readonly [[ESCAPED_THEN_WRITTEN]])
; CHECK-NEXT:    [[ADDR_LD:%.*]] = load i8*, i8** [[ADDR]], align 8
; CHECK-NEXT:    store i8 0, i8* [[ADDR_LD]], align 1
; CHECK-NEXT:    ret void
;
  %addr = alloca i8*
  call void @escape_readonly_ptr(i8** %addr, i8* %escaped_then_written)
  %addr.ld = load i8*, i8** %addr
  store i8 0, i8* %addr.ld
  ret void
}

; Byval but not readonly/none tests
;
;{
declare void @escape_i8(i8* %ptr)

define void @byval_not_readonly_1(i8* byval(i8) %written) readonly {
; CHECK: Function Attrs: readonly
; CHECK-LABEL: define {{[^@]+}}@byval_not_readonly_1
; CHECK-SAME: (i8* noalias nonnull byval(i8) dereferenceable(1) [[WRITTEN:%.*]]) #[[ATTR2]] {
; CHECK-NEXT:    call void @escape_i8(i8* nonnull dereferenceable(1) [[WRITTEN]])
; CHECK-NEXT:    ret void
;
  call void @escape_i8(i8* %written)
  ret void
}

define void @byval_not_readonly_2(i8* byval(i8) %written) readonly {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@byval_not_readonly_2
; CHECK-SAME: (i8* noalias nocapture nofree noundef nonnull writeonly byval(i8) dereferenceable(1) [[WRITTEN:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:    store i8 0, i8* [[WRITTEN]], align 1
; CHECK-NEXT:    ret void
;
  store i8 0, i8* %written
  ret void
}

define void @byval_not_readnone_1(i8* byval(i8) %written) readnone {
; IS__TUNIT____: Function Attrs: readnone
; IS__TUNIT____-LABEL: define {{[^@]+}}@byval_not_readnone_1
; IS__TUNIT____-SAME: (i8* noalias nonnull byval(i8) dereferenceable(1) [[WRITTEN:%.*]]) #[[ATTR10:[0-9]+]] {
; IS__TUNIT____-NEXT:    call void @escape_i8(i8* nonnull dereferenceable(1) [[WRITTEN]])
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: readnone
; IS__CGSCC____-LABEL: define {{[^@]+}}@byval_not_readnone_1
; IS__CGSCC____-SAME: (i8* noalias nonnull byval(i8) dereferenceable(1) [[WRITTEN:%.*]]) #[[ATTR11:[0-9]+]] {
; IS__CGSCC____-NEXT:    call void @escape_i8(i8* nonnull dereferenceable(1) [[WRITTEN]])
; IS__CGSCC____-NEXT:    ret void
;
  call void @escape_i8(i8* %written)
  ret void
}

define void @byval_not_readnone_2(i8* byval(i8) %written) readnone {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@byval_not_readnone_2
; CHECK-SAME: (i8* noalias nocapture nofree noundef nonnull writeonly byval(i8) dereferenceable(1) [[WRITTEN:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:    store i8 0, i8* [[WRITTEN]], align 1
; CHECK-NEXT:    ret void
;
  store i8 0, i8* %written
  ret void
}

define void @byval_no_fnarg(i8* byval(i8) %written) {
; CHECK: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn writeonly
; CHECK-LABEL: define {{[^@]+}}@byval_no_fnarg
; CHECK-SAME: (i8* noalias nocapture nofree noundef nonnull writeonly byval(i8) dereferenceable(1) [[WRITTEN:%.*]]) #[[ATTR3]] {
; CHECK-NEXT:    store i8 0, i8* [[WRITTEN]], align 1
; CHECK-NEXT:    ret void
;
  store i8 0, i8* %written
  ret void
}

define void @testbyval(i8* %read_only) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@testbyval
; IS__TUNIT____-SAME: (i8* nocapture readonly [[READ_ONLY:%.*]]) {
; IS__TUNIT____-NEXT:    call void @byval_not_readonly_1(i8* nocapture readonly byval(i8) [[READ_ONLY]]) #[[ATTR2]]
; IS__TUNIT____-NEXT:    call void @byval_not_readnone_1(i8* noalias nocapture readnone byval(i8) [[READ_ONLY]])
; IS__TUNIT____-NEXT:    call void @byval_no_fnarg(i8* nocapture nofree readonly byval(i8) [[READ_ONLY]]) #[[ATTR15:[0-9]+]]
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@testbyval
; IS__CGSCC____-SAME: (i8* nocapture noundef nonnull readonly dereferenceable(1) [[READ_ONLY:%.*]]) {
; IS__CGSCC____-NEXT:    call void @byval_not_readonly_1(i8* noalias nocapture noundef nonnull readonly byval(i8) dereferenceable(1) [[READ_ONLY]]) #[[ATTR2]]
; IS__CGSCC____-NEXT:    call void @byval_not_readnone_1(i8* noalias nocapture noundef nonnull readnone byval(i8) dereferenceable(1) [[READ_ONLY]])
; IS__CGSCC____-NEXT:    call void @byval_no_fnarg(i8* noalias nocapture nofree noundef nonnull readnone byval(i8) dereferenceable(1) [[READ_ONLY]]) #[[ATTR17:[0-9]+]]
; IS__CGSCC____-NEXT:    ret void
;
  call void @byval_not_readonly_1(i8* byval(i8) %read_only)
  call void @byval_not_readonly_2(i8* byval(i8) %read_only)
  call void @byval_not_readnone_1(i8* byval(i8) %read_only)
  call void @byval_not_readnone_2(i8* byval(i8) %read_only)
  call void @byval_no_fnarg(i8* byval(i8) %read_only)
  ret void
}
;}

declare i8* @maybe_returned_ptr(i8* readonly %ptr) readonly nounwind
declare i8 @maybe_returned_val(i8* %ptr) readonly nounwind
declare void @val_use(i8 %ptr) readonly nounwind

define void @ptr_uses(i8* %ptr) {
; IS__TUNIT____: Function Attrs: nounwind readonly
; IS__TUNIT____-LABEL: define {{[^@]+}}@ptr_uses
; IS__TUNIT____-SAME: (i8* nocapture readonly [[PTR:%.*]]) #[[ATTR11]] {
; IS__TUNIT____-NEXT:    [[CALL_PTR:%.*]] = call i8* @maybe_returned_ptr(i8* readonly [[PTR]]) #[[ATTR11]]
; IS__TUNIT____-NEXT:    [[CALL_VAL:%.*]] = call i8 @maybe_returned_val(i8* readonly [[CALL_PTR]]) #[[ATTR11]]
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nounwind readonly
; IS__CGSCC____-LABEL: define {{[^@]+}}@ptr_uses
; IS__CGSCC____-SAME: (i8* nocapture readonly [[PTR:%.*]]) #[[ATTR12]] {
; IS__CGSCC____-NEXT:    [[CALL_PTR:%.*]] = call i8* @maybe_returned_ptr(i8* readonly [[PTR]]) #[[ATTR12]]
; IS__CGSCC____-NEXT:    [[CALL_VAL:%.*]] = call i8 @maybe_returned_val(i8* readonly [[CALL_PTR]]) #[[ATTR12]]
; IS__CGSCC____-NEXT:    ret void
;
  %call_ptr = call i8* @maybe_returned_ptr(i8* %ptr)
  %call_val = call i8 @maybe_returned_val(i8* %call_ptr)
  call void @val_use(i8 %call_val)
  ret void
}

define void @ptr_use_chain(i8* %ptr) {
; CHECK-LABEL: define {{[^@]+}}@ptr_use_chain
; CHECK-SAME: (i8* [[PTR:%.*]]) {
; CHECK-NEXT:    call void @escape_i8(i8* [[PTR]])
; CHECK-NEXT:    ret void
;
  %bc0 = bitcast i8* %ptr to i32*
  %bc1 = bitcast i32* %bc0 to i8*
  %bc2 = bitcast i8* %bc1 to i32*
  %bc3 = bitcast i32* %bc2 to i8*
  %bc4 = bitcast i8* %bc3 to i32*
  %bc5 = bitcast i32* %bc4 to i8*
  %bc6 = bitcast i8* %bc5 to i32*
  %bc7 = bitcast i32* %bc6 to i8*
  %bc8 = bitcast i8* %bc7 to i32*
  %bc9 = bitcast i32* %bc8 to i8*
  %abc2 = bitcast i8* %bc9 to i32*
  %abc3 = bitcast i32* %abc2 to i8*
  %abc4 = bitcast i8* %abc3 to i32*
  %abc5 = bitcast i32* %abc4 to i8*
  %abc6 = bitcast i8* %abc5 to i32*
  %abc7 = bitcast i32* %abc6 to i8*
  %abc8 = bitcast i8* %abc7 to i32*
  %abc9 = bitcast i32* %abc8 to i8*
  call void @escape_i8(i8* %abc9)
  ret void
}

@constant_mem = external dso_local constant i32, align 4
define i32 @read_only_constant_mem() {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@read_only_constant_mem
; CHECK-SAME: () #[[ATTR1]] {
; CHECK-NEXT:    [[L:%.*]] = load i32, i32* @constant_mem, align 4
; CHECK-NEXT:    ret i32 [[L]]
;
  %l = load i32, i32* @constant_mem
  ret i32 %l
}
;.
; IS__TUNIT____: attributes #[[ATTR0]] = { nofree norecurse nosync nounwind willreturn writeonly }
; IS__TUNIT____: attributes #[[ATTR1]] = { nofree norecurse nosync nounwind readnone willreturn }
; IS__TUNIT____: attributes #[[ATTR2]] = { readonly }
; IS__TUNIT____: attributes #[[ATTR3]] = { argmemonly nofree norecurse nosync nounwind willreturn writeonly }
; IS__TUNIT____: attributes #[[ATTR4:[0-9]+]] = { nocallback nofree nosync nounwind willreturn writeonly }
; IS__TUNIT____: attributes #[[ATTR5:[0-9]+]] = { nocallback nofree nosync nounwind readonly willreturn }
; IS__TUNIT____: attributes #[[ATTR6]] = { nofree norecurse nosync nounwind readonly willreturn }
; IS__TUNIT____: attributes #[[ATTR7]] = { argmemonly nounwind readonly }
; IS__TUNIT____: attributes #[[ATTR8]] = { argmemonly nounwind }
; IS__TUNIT____: attributes #[[ATTR9]] = { argmemonly nofree norecurse nounwind willreturn }
; IS__TUNIT____: attributes #[[ATTR10]] = { readnone }
; IS__TUNIT____: attributes #[[ATTR11]] = { nounwind readonly }
; IS__TUNIT____: attributes #[[ATTR12]] = { willreturn writeonly }
; IS__TUNIT____: attributes #[[ATTR13]] = { readonly willreturn }
; IS__TUNIT____: attributes #[[ATTR14]] = { nounwind }
; IS__TUNIT____: attributes #[[ATTR15]] = { nounwind writeonly }
;.
; IS__CGSCC____: attributes #[[ATTR0]] = { nofree norecurse nosync nounwind willreturn writeonly }
; IS__CGSCC____: attributes #[[ATTR1]] = { nofree norecurse nosync nounwind readnone willreturn }
; IS__CGSCC____: attributes #[[ATTR2]] = { readonly }
; IS__CGSCC____: attributes #[[ATTR3]] = { argmemonly nofree norecurse nosync nounwind willreturn writeonly }
; IS__CGSCC____: attributes #[[ATTR4]] = { nofree nosync nounwind willreturn writeonly }
; IS__CGSCC____: attributes #[[ATTR5:[0-9]+]] = { nocallback nofree nosync nounwind willreturn writeonly }
; IS__CGSCC____: attributes #[[ATTR6:[0-9]+]] = { nocallback nofree nosync nounwind readonly willreturn }
; IS__CGSCC____: attributes #[[ATTR7]] = { nofree norecurse nosync nounwind readonly willreturn }
; IS__CGSCC____: attributes #[[ATTR8]] = { argmemonly nounwind readonly }
; IS__CGSCC____: attributes #[[ATTR9]] = { argmemonly nounwind }
; IS__CGSCC____: attributes #[[ATTR10]] = { argmemonly nofree norecurse nounwind willreturn }
; IS__CGSCC____: attributes #[[ATTR11]] = { readnone }
; IS__CGSCC____: attributes #[[ATTR12]] = { nounwind readonly }
; IS__CGSCC____: attributes #[[ATTR13]] = { readnone willreturn }
; IS__CGSCC____: attributes #[[ATTR14]] = { willreturn writeonly }
; IS__CGSCC____: attributes #[[ATTR15]] = { readonly willreturn }
; IS__CGSCC____: attributes #[[ATTR16]] = { nounwind }
; IS__CGSCC____: attributes #[[ATTR17]] = { nounwind writeonly }
;.
