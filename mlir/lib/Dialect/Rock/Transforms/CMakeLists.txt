add_rocmlir_dialect_library(MLIRRockTransforms
  AffixTuningParameters.cpp
  AlignTiling.cpp
  BlockwiseGemmToThreadwise.cpp
  BufferLoadMerge.cpp
  BufferizableOpInterfaceImpl.cpp
  CleanMath.cpp
  ConvToGemm.cpp
  GemmToGridwise.cpp
  Regularize.cpp
  SugarToLoops.cpp
  GridwiseGemmToBlockwise.cpp
  LoopsToCf.cpp
  ThreadwiseGemmLowering.cpp
  TransformToMemref.cpp
  ViewToTransform.cpp
  LowerRockReduce.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/Rock

  DEPENDS
  MLIRRockOpsIncGen
  MLIRRockPassIncGen

  LINK_LIBS PUBLIC
  MLIRAffineTransforms
  MLIRArithmeticTransforms
  MLIRBufferizationDialect
  MLIRBufferizationTransforms
  MLIRDialect
  MLIRXModel
  MLIRFuncDialect
  MLIRIR
  MLIRPass
  MLIRLLVMDialect
  MLIRMathToLLVM
  MLIRMemRefTransforms
  MLIRAffineToStandard
  MLIRReconcileUnrealizedCasts
  MLIRRockOps
  MLIRRockTuning
  MLIRRockUtility
  MLIRSCFToControlFlow
  MLIRSupport
  MLIRTosaDialect
)

