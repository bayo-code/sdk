// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_CONSTANTS_ARM64_H_
#define VM_CONSTANTS_ARM64_H_

#include "platform/assert.h"

namespace dart {

enum Register {
  kFirstFreeCpuRegister = 0,
  R0  =  0,
  R1  =  1,
  R2  =  2,
  R3  =  3,
  R4  =  4,
  R5  =  5,
  R6  =  6,
  R7  =  7,
  R8  =  8,
  R9  =  9,
  R10 = 10,
  R11 = 11,
  R12 = 12,
  R13 = 13,
  R14 = 14,
  R15 = 15,
  R16 = 16,
  R17 = 17,
  R18 = 18,
  R19 = 19,
  R20 = 20,
  R21 = 21,
  R22 = 22,
  R23 = 23,
  R24 = 24,
  kLastFreeCpuRegister = 24,
  R25 = 25,  // IP0
  R26 = 26,  // IP1
  R27 = 27,  // PP
  R28 = 28,  // CTX
  R29 = 29,  // FP
  R30 = 30,  // LR
  R31 = 31,  // ZR, SP
  kNumberOfCpuRegisters = 32,
  kNoRegister = -1,

  // These registers both use the encoding R31, but to avoid mistakes we give
  // them different values, and then translate before encoding.
  SP = 32,
  ZR = 33,

  // Aliases.
  IP0 = R25,
  IP1 = R26,
  FP = R29,
  LR = R30,
};

enum VRegister {
  V0  =  0,
  V1  =  1,
  V2  =  2,
  V3  =  3,
  V4  =  4,
  V5  =  5,
  V6  =  6,
  V7  =  7,
  V8  =  8,
  V9  =  9,
  V10 = 10,
  V11 = 11,
  V12 = 12,
  V13 = 13,
  V14 = 14,
  V15 = 15,
  V16 = 16,
  V17 = 17,
  V18 = 18,
  V19 = 19,
  V20 = 20,
  V21 = 21,
  V22 = 22,
  V23 = 24,
  V24 = 24,
  V25 = 25,
  V26 = 26,
  V27 = 27,
  V28 = 28,
  V29 = 29,
  V30 = 30,
  V31 = 31,
  kNumberOfVRegisters = 32,
  kNoVRegister = -1,
};

// Register alias for floating point scratch register.
const VRegister VTMP0 = V30;
const VRegister VTMP1 = V31;

// Architecture independent aliases.
typedef VRegister FpuRegister;
const FpuRegister FpuTMP = VTMP0;
const int kNumberOfFpuRegisters = kNumberOfVRegisters;
const FpuRegister kNoFpuRegister = kNoVRegister;

// Register aliases.
const Register TMP = R25;  // Used as scratch register by assembler.
const Register TMP0 = R25;
const Register TMP1 = R26;
const Register CTX = R27;  // Caches current context in generated code.
const Register PP = R26;  // Caches object pool pointer in generated code.
const Register SPREG = R31;  // Stack pointer register.
const Register FPREG = FP;  // Frame pointer register.
const Register ICREG = R5;  // IC data register.

// Exception object is passed in this register to the catch handlers when an
// exception is thrown.
const Register kExceptionObjectReg = R0;

// Stack trace object is passed in this register to the catch handlers when
// an exception is thrown.
const Register kStackTraceObjectReg = R1;

// Masks, sizes, etc.
const int kXRegSizeInBits = 64;
const int kWRegSizeInBits = 32;
const int64_t kXRegMask = 0xffffffffffffffffL;
const int64_t kWRegMask = 0x00000000ffffffffL;

// List of registers used in load/store multiple.
typedef uint32_t RegList;
const RegList kAllCpuRegistersList = 0xFFFF;


// C++ ABI call registers.
const RegList kAbiArgumentCpuRegs =
    (1 << R0) | (1 << R1) | (1 << R2) | (1 << R3) |
    (1 << R4) | (1 << R5) | (1 << R6) | (1 << R7);
const RegList kAbiPreservedCpuRegs =
    (1 << R19) | (1 << R20) | (1 << R21) | (1 << R22) |
    (1 << R23) | (1 << R24) | (1 << R25) | (1 << R26) |
    (1 << R27) | (1 << R28) | (1 << R29);
const int kAbiPreservedCpuRegCount = 11;
const VRegister kAbiFirstPreservedFpuReg = V8;
const VRegister kAbiLastPreservedFpuReg = V15;
const int kAbiPreservedFpuRegCount = 8;

// CPU registers available to Dart allocator.
const RegList kDartAvailableCpuRegs =
    (1 << R0)  | (1 << R1)  | (1 << R2)  | (1 << R3)  |
    (1 << R4)  | (1 << R5)  | (1 << R6)  | (1 << R7)  |
    (1 << R8)  | (1 << R9)  | (1 << R10) | (1 << R11) |
    (1 << R12) | (1 << R13) | (1 << R14) | (1 << R15) |
    (1 << R16) | (1 << R17) | (1 << R18) | (1 << R19) |
    (1 << R20) | (1 << R21) | (1 << R22) | (1 << R23) |
    (1 << R24);

// Registers available to Dart that are not preserved by runtime calls.
const RegList kDartVolatileCpuRegs =
    kDartAvailableCpuRegs & ~kAbiPreservedCpuRegs;
const int kDartVolatileCpuRegCount = 19;
const VRegister kDartFirstVolatileFpuReg = V0;
const VRegister kDartLastVolatileFpuReg = V7;
const int kDartVolatileFpuRegCount = 8;

static inline Register ConcreteRegister(Register r) {
  return ((r == ZR) || (r == SP)) ? R31 : r;
}

// Values for the condition field as defined in section A3.2.
enum Condition {
  kNoCondition = -1,
  EQ =  0,  // equal
  NE =  1,  // not equal
  CS =  2,  // carry set/unsigned higher or same
  CC =  3,  // carry clear/unsigned lower
  MI =  4,  // minus/negative
  PL =  5,  // plus/positive or zero
  VS =  6,  // overflow
  VC =  7,  // no overflow
  HI =  8,  // unsigned higher
  LS =  9,  // unsigned lower or same
  GE = 10,  // signed greater than or equal
  LT = 11,  // signed less than
  GT = 12,  // signed greater than
  LE = 13,  // signed less than or equal
  AL = 14,  // always (unconditional)
  NV = 15,  // special condition (refer to section C1.2.3)
  kMaxCondition = 16,
};

enum Bits {
  B0  =  (1 << 0), B1  =  (1 << 1), B2  =  (1 << 2), B3  =  (1 << 3),
  B4  =  (1 << 4), B5  =  (1 << 5), B6  =  (1 << 6), B7  =  (1 << 7),
  B8  =  (1 << 8), B9  =  (1 << 9), B10 = (1 << 10), B11 = (1 << 11),
  B12 = (1 << 12), B13 = (1 << 13), B14 = (1 << 14), B15 = (1 << 15),
  B16 = (1 << 16), B17 = (1 << 17), B18 = (1 << 18), B19 = (1 << 19),
  B20 = (1 << 20), B21 = (1 << 21), B22 = (1 << 22), B23 = (1 << 23),
  B24 = (1 << 24), B25 = (1 << 25), B26 = (1 << 26), B27 = (1 << 27),
  B28 = (1 << 28), B29 = (1 << 29), B30 = (1 << 30), B31 = (1 << 31),
};

enum OperandSize {
  kByte,
  kUnsignedByte,
  kHalfword,
  kUnsignedHalfword,
  kWord,
  kUnsignedWord,
  kDoubleWord,
  kSWord,
  kDWord,
};

static inline int Log2OperandSizeBytes(OperandSize os) {
  switch (os) {
    case kByte:
    case kUnsignedByte:
      return 0;
    case kHalfword:
    case kUnsignedHalfword:
      return 1;
    case kWord:
    case kUnsignedWord:
    case kSWord:
      return 2;
    case kDoubleWord:
    case kDWord:
      return 3;
    default:
      UNREACHABLE();
      break;
  }
  return -1;
}

// Opcodes from C3
// C3.1.
enum MainOp {
  DPImmediateMask = 0x1c000000,
  DPImmediateFixed = B28,

  CompareBranchMask = 0x1c000000,
  CompareBranchFixed = B28 | B26,

  LoadStoreMask = B27 | B25,
  LoadStoreFixed = B27,

  DPRegisterMask = 0x0e000000,
  DPRegisterFixed = B27 | B25,

  DPSimd1Mask = 0x1e000000,
  DPSimd1Fixed = B27 | B26 | B25,

  DPSimd2Mask = 0x1e000000,
  DPSimd2Fixed = B28 | DPSimd1Fixed,
};

// C3.2.1
enum CompareAndBranchOp {
  CompareAndBranchMask = 0x7e000000,
  CompareAndBranchFixed = CompareBranchFixed | B29,
  CBZ = CompareBranchFixed,
  CBNZ = CompareBranchFixed | B24,
};

// C.3.2.2
enum ConditionalBranchOp {
  ConditionalBranchMask = 0xfe000000,
  ConditionalBranchFixed = CompareBranchFixed | B30,
  BCOND = ConditionalBranchFixed,
};

// C3.2.3
enum ExceptionGenOp {
  ExceptionGenMask = 0xff000000,
  ExceptionGenFixed = CompareBranchFixed | B31 | B30,
  SVC = ExceptionGenFixed | B0,
  BRK = ExceptionGenFixed | B21,
  HLT = ExceptionGenFixed | B22,
};

// C3.2.4
enum SystemOp {
  SystemMask = 0xffc00000,
  SystemFixed = CompareBranchFixed | B31 | B30 | B24,
  HINT = SystemFixed | B17 | B16 | B13 | B4 | B3 | B2 | B1 | B0,
};

// C3.2.5
enum TestAndBranchOp {
  TestAndBranchMask = 0x7e000000,
  TestAndBranchFixed = CompareBranchFixed | B29 | B25,
  TBZ = TestAndBranchFixed,
  TBNZ = TestAndBranchFixed | B24,
};

// C3.2.6
enum UnconditionalBranchOp {
  UnconditionalBranchMask = 0x7c000000,
  UnconditionalBranchFixed = CompareBranchFixed,
  B = UnconditionalBranchFixed,
  BL = UnconditionalBranchFixed | B31,
};

// C3.2.7
enum UnconditionalBranchRegOp {
  UnconditionalBranchRegMask = 0xfe000000,
  UnconditionalBranchRegFixed = CompareBranchFixed | B31 | B30 | B25,
  BR = UnconditionalBranchRegFixed | B20 | B19 | B18 | B17 | B16,
  BLR = BR | B21,
  RET = BR | B22,
};

enum LoadStoreRegOp {
  LoadStoreRegMask = 0x3a000000,
  LoadStoreRegFixed = LoadStoreFixed | B29 | B28,
  STR = LoadStoreRegFixed,
  LDR = LoadStoreRegFixed | B22,
};

// C3.4.1
enum AddSubImmOp {
  AddSubImmMask = 0x1f000000,
  AddSubImmFixed = DPImmediateFixed | B24,
  ADDI = AddSubImmFixed,
  SUBI = AddSubImmFixed | B30,
};

// C3.4.4
enum LogicalImmOp {
  LogicalImmMask = 0x1f800000,
  LogicalImmFixed = DPImmediateFixed | B25,
  ANDI = LogicalImmFixed,
  ORRI = LogicalImmFixed | B29,
  EORI = LogicalImmFixed | B30,
  ANDIS = LogicalImmFixed | B30 | B29,
};

// C3.4.5
enum MoveWideOp {
  MoveWideMask = 0x1f800000,
  MoveWideFixed = DPImmediateFixed | B25 | B23,
  MOVN = MoveWideFixed,
  MOVZ = MoveWideFixed | B30,
  MOVK = MoveWideFixed | B30 | B29,
};

// C3.4.6
enum PCRelOp {
  PCRelMask = 0x1f000000,
  PCRelFixed = DPImmediateFixed,
  ADR = PCRelFixed,
  ADRP = PCRelFixed | B31,
};

// C3.5.1
enum AddSubShiftExtOp {
  AddSubShiftExtMask = 0x1f000000,
  AddSubShiftExtFixed = DPRegisterFixed | B24,
  ADD = AddSubShiftExtFixed,
  SUB = AddSubShiftExtFixed | B30,
};

enum LogicalShiftOp {
  LogicalShiftMask = 0x1f000000,
  LogicalShiftFixed = DPRegisterFixed,
  AND = LogicalShiftFixed,
  BIC = LogicalShiftFixed | B21,
  ORR = LogicalShiftFixed | B29,
  ORN = LogicalShiftFixed | B29 | B21,
  EOR = LogicalShiftFixed | B30,
  EON = LogicalShiftFixed | B30 | B21,
  ANDS = LogicalShiftFixed | B30 | B29,
  BICS = LogicalShiftFixed | B30 | B29 | B21,
};

#define APPLY_OP_LIST(_V)                                                      \
_V(DPImmediate)                                                                \
_V(CompareBranch)                                                              \
_V(LoadStore)                                                                  \
_V(DPRegister)                                                                 \
_V(DPSimd1)                                                                    \
_V(DPSimd2)                                                                    \
_V(CompareAndBranch)                                                           \
_V(ConditionalBranch)                                                          \
_V(ExceptionGen)                                                               \
_V(System)                                                                     \
_V(TestAndBranch)                                                              \
_V(UnconditionalBranch)                                                        \
_V(UnconditionalBranchReg)                                                     \
_V(LoadStoreReg)                                                               \
_V(AddSubImm)                                                                  \
_V(LogicalImm)                                                                 \
_V(MoveWide)                                                                   \
_V(PCRel)                                                                      \
_V(AddSubShiftExt)                                                             \
_V(LogicalShift)                                                               \


enum Shift {
  kNoShift = -1,
  LSL = 0,  // Logical shift left
  LSR = 1,  // Logical shift right
  ASR = 2,  // Arithmetic shift right
  ROR = 3,  // Rotate right
  kMaxShift = 4,
};

enum Extend {
  kNoExtend = -1,
  UXTB = 0,
  UXTH = 1,
  UXTW = 2,
  UXTX = 3,
  SXTB = 4,
  SXTH = 5,
  SXTW = 6,
  SXTX = 7,
  kMaxExtend = 8,
};

enum R31Type {
  R31IsSP,
  R31IsZR,
  R31IsUndef,
};

// Constants used for the decoding or encoding of the individual fields of
// instructions. Based on the "Figure 3-1 ARM instruction set summary".
enum InstructionFields {
  // S-bit (modify condition register)
  kSShift = 29,
  kSBits = 1,

  // sf field.
  kSFShift = 31,
  kSFBits = 1,

  // size field,
  kSzShift = 30,
  kSzBits = 2,

  // Registers.
  kRdShift = 0,
  kRdBits = 5,
  kRnShift = 5,
  kRnBits = 5,
  kRaShift = 10,
  kRaBits = 5,
  kRmShift = 16,
  kRmBits = 5,
  kRtShift = 0,
  kRtBits = 5,

  // Immediates.
  kImm3Shift = 10,
  kImm3Bits = 3,
  kImm6Shift = 10,
  kImm6Bits = 6,
  kImm9Shift = 12,
  kImm9Bits = 9,
  kImm12Shift = 10,
  kImm12Bits = 12,
  kImm12ShiftShift = 22,
  kImm12ShiftBits = 2,
  kImm14Shift = 5,
  kImm14Bits = 14,
  kImm16Shift = 5,
  kImm16Bits = 16,
  kImm19Shift = 5,
  kImm19Bits = 19,
  kImm19Mask = 0x7ffff,
  kImm26Shift = 0,
  kImm26Bits = 26,

  kCondShift = 0,
  kCondBits = 4,

  // Bitfield immediates.
  kNShift = 22,
  kNBits = 1,
  kImmRShift = 16,
  kImmRBits = 6,
  kImmSShift = 10,
  kImmSBits = 6,

  kHWShift = 21,
  kHWBits = 2,

  // Shift and Extend.
  kAddShiftExtendShift = 21,
  kAddShiftExtendBits = 1,
  kShiftTypeShift = 22,
  kShiftTypeBits = 2,
  kExtendTypeShift = 13,
  kExtendTypeBits = 3,

  // Hint Fields.
  kHintCRmShift = 8,
  kHintCRmBits = 4,
  kHintOp2Shift = 5,
  kHintOp2Bits = 3,
};


const uint32_t kImmExceptionIsRedirectedCall = 0xca11;
const uint32_t kImmExceptionIsUnreachable = 0xdebf;
const uint32_t kImmExceptionIsPrintf = 0xdeb1;
const uint32_t kImmExceptionIsDebug = 0xdeb0;

// Helper functions for decoding logical immediates.
static inline uint64_t RotateRight(
    uint64_t value, uint8_t rotate, uint8_t width) {
  ASSERT(width <= 64);
  rotate &= 63;
  return ((value & ((1UL << rotate) - 1UL)) << (width - rotate)) |
         (value >> rotate);
}

static inline uint64_t RepeatBitsAcrossReg(
    uint8_t reg_size, uint64_t value, uint8_t width) {
  ASSERT((width == 2) || (width == 4) || (width == 8) || (width == 16) ||
         (width == 32));
  ASSERT((reg_size == kWRegSizeInBits) || (reg_size == kXRegSizeInBits));
  uint64_t result = value & ((1UL << width) - 1UL);
  for (unsigned i = width; i < reg_size; i *= 2) {
    result |= (result << i);
  }
  return result;
}

// The class Instr enables access to individual fields defined in the ARM
// architecture instruction set encoding as described in figure A3-1.
//
// Example: Test whether the instruction at ptr sets the condition code bits.
//
// bool InstructionSetsConditionCodes(byte* ptr) {
//   Instr* instr = Instr::At(ptr);
//   int type = instr->TypeField();
//   return ((type == 0) || (type == 1)) && instr->HasS();
// }
//
class Instr {
 public:
  enum {
    kInstrSize = 4,
    kInstrSizeLog2 = 2,
    kPCReadOffset = 8
  };

  static const int32_t kNopInstruction = HINT;  // hint #0 === nop.
  static const int32_t kBreakPointInstruction =  // hlt #kImmExceptionIsDebug.
      HLT | (kImmExceptionIsDebug << kImm16Shift);
  static const int kBreakPointInstructionSize = kInstrSize;

  // Get the raw instruction bits.
  inline int32_t InstructionBits() const {
    return *reinterpret_cast<const int32_t*>(this);
  }

  // Set the raw instruction bits to value.
  inline void SetInstructionBits(int32_t value) {
    *reinterpret_cast<int32_t*>(this) = value;
  }

  // Read one particular bit out of the instruction bits.
  inline int Bit(int nr) const {
    return (InstructionBits() >> nr) & 1;
  }

  // Read a bit field out of the instruction bits.
  inline int Bits(int shift, int count) const {
    return (InstructionBits() >> shift) & ((1 << count) - 1);
  }

  inline int NField() const { return Bit(22); }
  inline int SField() const { return Bit(kSShift); }
  inline int SFField() const { return Bit(kSFShift); }
  inline int SzField() const { return Bits(kSzShift, kSzBits); }
  inline Register RdField() const { return static_cast<Register>(
                                        Bits(kRdShift, kRdBits)); }
  inline Register RnField() const { return static_cast<Register>(
                                        Bits(kRnShift, kRnBits)); }
  inline Register RaField() const { return static_cast<Register>(
                                        Bits(kRaShift, kRaBits)); }
  inline Register RmField() const { return static_cast<Register>(
                                        Bits(kRmShift, kRmBits)); }
  inline Register RtField() const { return static_cast<Register>(
                                        Bits(kRtShift, kRtBits)); }

  // Immediates
  inline int Imm3Field() const { return Bits(kImm3Shift, kImm3Bits); }
  inline int Imm6Field() const { return Bits(kImm6Shift, kImm6Bits); }

  inline int Imm9Field() const { return Bits(kImm9Shift, kImm9Bits); }
  // Sign-extended Imm9Field()
  inline int64_t SImm9Field() const {
      return (static_cast<int32_t>(Imm9Field()) << 23) >> 23; }

  inline int Imm12Field() const { return Bits(kImm12Shift, kImm12Bits); }
  inline int Imm12ShiftField() const {
    return Bits(kImm12ShiftShift, kImm12ShiftBits); }

  inline int Imm16Field() const { return Bits(kImm16Shift, kImm16Bits); }
  inline int HWField() const { return Bits(kHWShift, kHWBits); }

  inline int ImmRField() const { return Bits(kImmRShift, kImmRBits); }
  inline int ImmSField() const { return Bits(kImmSShift, kImmSBits); }

  inline int Imm14Field() const { return Bits(kImm14Shift, kImm14Bits); }
  inline int64_t SImm14Field() const {
      return (static_cast<int32_t>(Imm14Field()) << 18) >> 18; }
  inline int Imm19Field() const { return Bits(kImm19Shift, kImm19Bits); }
  inline int64_t SImm19Field() const {
      return (static_cast<int32_t>(Imm19Field()) << 13) >> 13; }
  inline int Imm26Field() const { return Bits(kImm26Shift, kImm26Bits); }
  inline int64_t SImm26Field() const {
      return (static_cast<int32_t>(Imm26Field()) << 6) >> 6; }

  inline Condition ConditionField() const {
    return static_cast<Condition>(Bits(kCondShift, kCondBits));
  }

  // Shift and Extend.
  inline bool IsShift() const {
    return IsLogicalShiftOp() || (Bit(kAddShiftExtendShift) == 0);
  }
  inline bool IsExtend() const {
    return !IsLogicalShiftOp() && (Bit(kAddShiftExtendShift) == 1);
  }
  inline Shift ShiftTypeField() const {
      return static_cast<Shift>(Bits(kShiftTypeShift, kShiftTypeBits)); }
  inline Extend ExtendTypeField() const {
      return static_cast<Extend>(Bits(kExtendTypeShift, kExtendTypeBits)); }
  inline int ShiftAmountField() const { return Imm6Field(); }
  inline int ExtShiftAmountField() const { return Imm3Field(); }

  // Instruction identification.
  #define IS_OP(op)                                                            \
    inline bool Is##op##Op() const {                                           \
      return ((InstructionBits() & op##Mask) == (op##Fixed & op##Mask)); }
  APPLY_OP_LIST(IS_OP)
  #undef IS_OP

  inline bool HasS() const { return (SField() == 1); }

  // Indicate whether Rd can be the SP or ZR. This does not check that the
  // instruction actually has an Rd field.
  R31Type RdMode() const {
    // The following instructions use SP as Rd:
    //  Add/sub (immediate) when not setting the flags.
    //  Add/sub (extended) when not setting the flags.
    //  Logical (immediate) when not setting the flags.
    // Otherwise, R31 is the ZR.
    if (IsAddSubImmOp() || (IsAddSubShiftExtOp() && IsExtend())) {
      if (HasS()) {
        return R31IsZR;
      } else {
        return R31IsSP;
      }
    }
    // TODO(zra): Handle for logical immediate operations.
    return R31IsZR;
  }

  // Indicate whether Rn can be SP or ZR. This does not check that the
  // instruction actually has an Rn field.
  R31Type RnMode() const {
    // The following instructions use SP as Rn:
    //  All loads and stores.
    //  Add/sub (immediate).
    //  Add/sub (extended).
    // Otherwise, r31 is ZR.
    if (IsLoadStoreOp() ||
        IsAddSubImmOp() ||
        (IsAddSubShiftExtOp() && IsExtend())) {
      return R31IsSP;
    }
    return R31IsZR;
  }

  // Logical immediates can't encode zero, so a return value of zero is used to
  // indicate a failure case. Specifically, where the constraints on imm_s are
  // not met.
  uint64_t ImmLogical() {
    const uint8_t reg_size =
        SFField() == 1 ? kXRegSizeInBits : kWRegSizeInBits;
    const int64_t n = NField();
    const int64_t imm_s = ImmSField();
    const int64_t imm_r = ImmRField();

    // An integer is constructed from the n, imm_s and imm_r bits according to
    // the following table:
    //
    //  N   imms    immr    size        S             R
    //  1  ssssss  rrrrrr    64    UInt(ssssss)  UInt(rrrrrr)
    //  0  0sssss  xrrrrr    32    UInt(sssss)   UInt(rrrrr)
    //  0  10ssss  xxrrrr    16    UInt(ssss)    UInt(rrrr)
    //  0  110sss  xxxrrr     8    UInt(sss)     UInt(rrr)
    //  0  1110ss  xxxxrr     4    UInt(ss)      UInt(rr)
    //  0  11110s  xxxxxr     2    UInt(s)       UInt(r)
    // (s bits must not be all set)
    //
    // A pattern is constructed of size bits, where the least significant S+1
    // bits are set. The pattern is rotated right by R, and repeated across a
    // 32 or 64-bit value, depending on destination register width.

    if (n == 1) {
      if (imm_s == 0x3F) {
        return 0;
      }
      uint64_t bits = (1UL << (imm_s + 1)) - 1;
      return RotateRight(bits, imm_r, 64);
    } else {
      if ((imm_s >> 1) == 0x1F) {
        return 0;
      }
      for (int width = 0x20; width >= 0x2; width >>= 1) {
        if ((imm_s & width) == 0) {
          int mask = width - 1;
          if ((imm_s & mask) == mask) {
            return 0;
          }
          uint64_t bits = (1UL << ((imm_s & mask) + 1)) - 1;
          return RepeatBitsAcrossReg(reg_size,
                                     RotateRight(bits, imm_r & mask, width),
                                     width);
        }
      }
    }
    UNREACHABLE();
    return 0;
  }

  // Instructions are read out of a code stream. The only way to get a
  // reference to an instruction is to convert a pointer. There is no way
  // to allocate or create instances of class Instr.
  // Use the At(pc) function to create references to Instr.
  static Instr* At(uword pc) { return reinterpret_cast<Instr*>(pc); }

 private:
  DISALLOW_ALLOCATION();
  DISALLOW_IMPLICIT_CONSTRUCTORS(Instr);
};

}  // namespace dart

#endif  // VM_CONSTANTS_ARM64_H_
