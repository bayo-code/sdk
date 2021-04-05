// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This test contains a test case for each condition that can lead to the front
// end's `ArgumentTypeNotAssignableNullability` error, for which we wish to
// report "why not promoted" context information.

class C1 {
  int? bad;
  //   ^^^
  // [context 29] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 47] 'bad' refers to a property so it couldn't be promoted.
  f(int i) {}
}

required_unnamed(C1 c) {
  if (c.bad == null) return;
  c.f(c.bad);
  //  ^^^^^
  // [analyzer 29] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //    ^
  // [cfe 47] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C2 {
  int? bad;
  //   ^^^
  // [context 38] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 48] 'bad' refers to a property so it couldn't be promoted.
  f([int i = 0]) {}
}

optional_unnamed(C2 c) {
  if (c.bad == null) return;
  c.f(c.bad);
  //  ^^^^^
  // [analyzer 38] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //    ^
  // [cfe 48] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C3 {
  int? bad;
  //   ^^^
  // [context 6] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 49] 'bad' refers to a property so it couldn't be promoted.
  f({required int i}) {}
}

required_named(C3 c) {
  if (c.bad == null) return;
  c.f(i: c.bad);
  //  ^^^^^^^^
  // [analyzer 6] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe 49] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C4 {
  int? bad;
  //   ^^^
  // [context 16] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 50] 'bad' refers to a property so it couldn't be promoted.
  f({int i = 0}) {}
}

optional_named(C4 c) {
  if (c.bad == null) return;
  c.f(i: c.bad);
  //  ^^^^^^^^
  // [analyzer 16] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe 50] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C5 {
  List<int>? bad;
  //         ^^^
  // [context 33] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 51] 'bad' refers to a property so it couldn't be promoted.
  f<T>(List<T> x) {}
}

type_inferred(C5 c) {
  if (c.bad == null) return;
  c.f(c.bad);
  //  ^^^^^
  // [analyzer 33] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //    ^
  // [cfe 51] The argument type 'List<int>?' can't be assigned to the parameter type 'List<int>' because 'List<int>?' is nullable and 'List<int>' isn't.
}

class C6 {
  int? bad;
  //   ^^^
  // [context 21] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 52] 'bad' refers to a property so it couldn't be promoted.
  C6(int i);
}

C6? constructor_with_implicit_new(C6 c) {
  if (c.bad == null) return null;
  return C6(c.bad);
  //        ^^^^^
  // [analyzer 21] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //          ^
  // [cfe 52] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C7 {
  int? bad;
  //   ^^^
  // [context 42] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 53] 'bad' refers to a property so it couldn't be promoted.
  C7(int i);
}

C7? constructor_with_explicit_new(C7 c) {
  if (c.bad == null) return null;
  return new C7(c.bad);
  //            ^^^^^
  // [analyzer 42] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //              ^
  // [cfe 53] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C8 {
  int? bad;
  //   ^^^
  // [context 13] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 54] 'bad' refers to a property so it couldn't be promoted.
}

userDefinableBinaryOpRhs(C8 c) {
  if (c.bad == null) return;
  1 + c.bad;
  //  ^^^^^
  // [analyzer 13] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //    ^
  // [cfe 54] A value of type 'int?' can't be assigned to a variable of type 'num' because 'int?' is nullable and 'num' isn't.
}

class C9 {
  int? bad;
  f(int i) {}
}

questionQuestionRhs(C9 c, int? i) {
  // Note: "why not supported" functionality is currently not supported for the
  // RHS of `??` because it requires more clever reasoning than we currently do:
  // we would have to understand that the reason `i ?? c.bad` has a type of
  // `int?` rather than `int` is because `c.bad` was not promoted.  We currently
  // only support detecting non-promotion when the expression that had the wrong
  // type *is* the expression that wasn't promoted.
  if (c.bad == null) return;
  c.f(i ?? c.bad);
  //  ^^^^^^^^^^
  // [analyzer] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //    ^
  // [cfe] The argument type 'int?' can't be assigned to the parameter type 'int' because 'int?' is nullable and 'int' isn't.
}

class C10 {
  D10? bad;
  f(bool b) {}
}

class D10 {
  bool operator ==(covariant D10 other) => true;
}

equalRhs(C10 c, D10 d) {
  if (c.bad == null) return;
  // Note: we don't report an error here because `==` always accepts `null`.
  c.f(d == c.bad);
  c.f(d != c.bad);
}

class C11 {
  bool? bad;
  //    ^^^
  // [context 30] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 46] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 55] 'bad' refers to a property so it couldn't be promoted.
  // [context 56] 'bad' refers to a property so it couldn't be promoted.
  f(bool b) {}
}

andOperand(C11 c, bool b) {
  if (c.bad == null) return;
  c.f(c.bad && b);
  //  ^^^^^
  // [analyzer 46] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //    ^
  // [cfe 55] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  c.f(b && c.bad);
  //       ^^^^^
  // [analyzer 30] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //         ^
  // [cfe 56] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C12 {
  bool? bad;
  //    ^^^
  // [context 27] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 36] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 57] 'bad' refers to a property so it couldn't be promoted.
  // [context 58] 'bad' refers to a property so it couldn't be promoted.
  f(bool b) {}
}

orOperand(C12 c, bool b) {
  if (c.bad == null) return;
  c.f(c.bad || b);
  //  ^^^^^
  // [analyzer 27] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //    ^
  // [cfe 57] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  c.f(b || c.bad);
  //       ^^^^^
  // [analyzer 36] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //         ^
  // [cfe 58] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C13 {
  bool? bad;
  //    ^^^
  // [context 40] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 59] 'bad' refers to a property so it couldn't be promoted.
}

assertStatementCondition(C13 c) {
  if (c.bad == null) return;
  assert(c.bad);
  //     ^^^^^
  // [analyzer 40] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //       ^
  // [cfe 59] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C14 {
  bool? bad;
  //    ^^^
  // [context 1] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 60] 'bad' refers to a property so it couldn't be promoted.
  C14.assertInitializerCondition(C14 c)
      : bad = c.bad!,
        assert(c.bad);
        //     ^^^^^
        // [analyzer 1] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
        //       ^
        // [cfe 60] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C15 {
  bool? bad;
  //    ^^^
  // [context 28] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 61] 'bad' refers to a property so it couldn't be promoted.
  f(bool b) {}
}

notOperand(C15 c) {
  if (c.bad == null) return;
  c.f(!c.bad);
  //   ^^^^^
  // [analyzer 28] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //     ^
  // [cfe 61] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C16 {
  bool? bad;
  //    ^^^
  // [context 22] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 24] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 25] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 32] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 62] 'bad' refers to a property so it couldn't be promoted.
  // [context 63] 'bad' refers to a property so it couldn't be promoted.
  // [context 64] 'bad' refers to a property so it couldn't be promoted.
  // [context 65] 'bad' refers to a property so it couldn't be promoted.
}

forLoopCondition(C16 c) {
  if (c.bad == null) return;
  for (; c.bad;) {}
  //     ^^^^^
  // [analyzer 32] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //       ^
  // [cfe 62] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  [for (; c.bad;) null];
  //      ^^^^^
  // [analyzer 25] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //        ^
  // [cfe 63] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  ({for (; c.bad;) null});
  //       ^^^^^
  // [analyzer 22] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //         ^
  // [cfe 64] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  ({for (; c.bad;) null: null});
  //       ^^^^^
  // [analyzer 24] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //         ^
  // [cfe 65] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C17 {
  bool? bad;
  //    ^^^
  // [context 10] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 66] 'bad' refers to a property so it couldn't be promoted.
  f(int i) {}
}

conditionalExpressionCondition(C17 c) {
  if (c.bad == null) return;
  c.f(c.bad ? 1 : 2);
  //  ^^^^^
  // [analyzer 10] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //    ^
  // [cfe 66] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C18 {
  bool? bad;
  //    ^^^
  // [context 26] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 67] 'bad' refers to a property so it couldn't be promoted.
}

doLoopCondition(C18 c) {
  if (c.bad == null) return;
  do {} while (c.bad);
  //           ^^^^^
  // [analyzer 26] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //             ^
  // [cfe 67] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C19 {
  bool? bad;
  //    ^^^
  // [context 5] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 9] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 12] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 39] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 68] 'bad' refers to a property so it couldn't be promoted.
  // [context 69] 'bad' refers to a property so it couldn't be promoted.
  // [context 70] 'bad' refers to a property so it couldn't be promoted.
  // [context 71] 'bad' refers to a property so it couldn't be promoted.
}

ifCondition(C19 c) {
  if (c.bad == null) return;
  if (c.bad) {}
  //  ^^^^^
  // [analyzer 5] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //    ^
  // [cfe 68] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  [if (c.bad) null];
  //   ^^^^^
  // [analyzer 12] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //     ^
  // [cfe 69] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  ({if (c.bad) null});
  //    ^^^^^
  // [analyzer 9] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //      ^
  // [cfe 70] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
  ({if (c.bad) null: null});
  //    ^^^^^
  // [analyzer 39] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //      ^
  // [cfe 71] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C20 {
  bool? bad;
  //    ^^^
  // [context 3] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 72] 'bad' refers to a property so it couldn't be promoted.
}

whileCondition(C20 c) {
  if (c.bad == null) return;
  while (c.bad) {}
  //     ^^^^^
  // [analyzer 3] COMPILE_TIME_ERROR.UNCHECKED_USE_OF_NULLABLE_VALUE
  //       ^
  // [cfe 72] A value of type 'bool?' can't be assigned to a variable of type 'bool' because 'bool?' is nullable and 'bool' isn't.
}

class C21 {
  int? bad;
  //   ^^^
  // [context 17] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 73] 'bad' refers to a property so it couldn't be promoted.
}

assignmentRhs(C21 c, int i) {
  if (c.bad == null) return;
  i = c.bad;
  //  ^^^^^
  // [analyzer 17] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //    ^
  // [cfe 73] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C22 {
  int? bad;
  //   ^^^
  // [context 18] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 74] 'bad' refers to a property so it couldn't be promoted.
}

variableInitializer(C22 c) {
  if (c.bad == null) return;
  int i = c.bad;
  //      ^^^^^
  // [analyzer 18] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //        ^
  // [cfe 74] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C23 {
  int? bad;
  //   ^^^
  // [context 20] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 75] 'bad' refers to a property so it couldn't be promoted.
  final int x;
  final int y;
  C23.constructorInitializer(C23 c)
      : x = c.bad!,
        y = c.bad;
        //  ^^^^^
        // [analyzer 20] COMPILE_TIME_ERROR.FIELD_INITIALIZER_NOT_ASSIGNABLE
        //    ^
        // [cfe 75] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C24 {
  int? bad;
  //   ^^^
  // [context 14] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 41] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 43] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 44] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 76] 'bad' refers to a property so it couldn't be promoted.
  // [context 77] 'bad' refers to a property so it couldn't be promoted.
  // [context 78] 'bad' refers to a property so it couldn't be promoted.
  // [context 79] 'bad' refers to a property so it couldn't be promoted.
}

forVariableInitializer(C24 c) {
  if (c.bad == null) return;
  for (int i = c.bad; false;) {}
  //           ^^^^^
  // [analyzer 44] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //             ^
  // [cfe 76] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  [for (int i = c.bad; false;) null];
  //            ^^^^^
  // [analyzer 43] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //              ^
  // [cfe 77] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  ({for (int i = c.bad; false;) null});
  //             ^^^^^
  // [analyzer 41] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //               ^
  // [cfe 78] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  ({for (int i = c.bad; false;) null: null});
  //             ^^^^^
  // [analyzer 14] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //               ^
  // [cfe 79] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C25 {
  int? bad;
  //   ^^^
  // [context 2] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 4] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 8] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 11] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 80] 'bad' refers to a property so it couldn't be promoted.
  // [context 81] 'bad' refers to a property so it couldn't be promoted.
  // [context 82] 'bad' refers to a property so it couldn't be promoted.
  // [context 83] 'bad' refers to a property so it couldn't be promoted.
}

forAssignmentInitializer(C25 c, int i) {
  if (c.bad == null) return;
  for (i = c.bad; false;) {}
  //       ^^^^^
  // [analyzer 2] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //         ^
  // [cfe 80] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  [for (i = c.bad; false;) null];
  //        ^^^^^
  // [analyzer 4] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //          ^
  // [cfe 81] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  ({for (i = c.bad; false;) null});
  //         ^^^^^
  // [analyzer 11] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //           ^
  // [cfe 82] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  ({for (i = c.bad; false;) null: null});
  //         ^^^^^
  // [analyzer 8] COMPILE_TIME_ERROR.INVALID_ASSIGNMENT
  //           ^
  // [cfe 83] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C26 {
  int? bad;
  //   ^^^
  // [context 45] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 84] 'bad' refers to a property so it couldn't be promoted.
}

compoundAssignmentRhs(C26 c) {
  num n = 0;
  if (c.bad == null) return;
  n += c.bad;
  //   ^^^^^
  // [analyzer 45] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //     ^
  // [cfe 84] A value of type 'int?' can't be assigned to a variable of type 'num' because 'int?' is nullable and 'num' isn't.
}

class C27 {
  int? bad;
  //   ^^^
  // [context 7] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 85] 'bad' refers to a property so it couldn't be promoted.
}

indexGet(C27 c, List<int> values) {
  if (c.bad == null) return;
  values[c.bad];
  //     ^^^^^
  // [analyzer 7] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe 85] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C28 {
  int? bad;
  //   ^^^
  // [context 23] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 86] 'bad' refers to a property so it couldn't be promoted.
}

indexSet(C28 c, List<int> values) {
  if (c.bad == null) return;
  values[c.bad] = 0;
  //     ^^^^^
  // [analyzer 23] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe 86] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C29 {
  int? bad;
  //   ^^^
  // [context 19] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
}

indexSetCompound(C29 c, List<int> values) {
  // TODO(paulberry): get this to work with the CFE
  if (c.bad == null) return;
  values[c.bad] += 1;
  //     ^^^^^
  // [analyzer 19] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C30 {
  int? bad;
  //   ^^^
  // [context 37] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
}

indexSetIfNull(C30 c, List<int?> values) {
  // TODO(paulberry): get this to work with the CFE
  if (c.bad == null) return;
  values[c.bad] ??= 1;
  //     ^^^^^
  // [analyzer 37] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C31 {
  int? bad;
  //   ^^^
  // [context 31] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 35] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
}

indexSetPreIncDec(C31 c, List<int> values) {
  // TODO(paulberry): get this to work with the CFE
  if (c.bad == null) return;
  ++values[c.bad];
  //       ^^^^^
  // [analyzer 31] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //         ^
  // [cfe] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  --values[c.bad];
  //       ^^^^^
  // [analyzer 35] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //         ^
  // [cfe] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}

class C32 {
  int? bad;
  //   ^^^
  // [context 15] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
  // [context 34] 'bad' refers to a property so it couldn't be promoted.  See http://dart.dev/go/non-promo-property
}

indexSetPostIncDec(C32 c, List<int> values) {
  // TODO(paulberry): get this to work with the CFE
  if (c.bad == null) return;
  values[c.bad]++;
  //     ^^^^^
  // [analyzer 34] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
  values[c.bad]--;
  //     ^^^^^
  // [analyzer 15] COMPILE_TIME_ERROR.ARGUMENT_TYPE_NOT_ASSIGNABLE
  //       ^
  // [cfe] A value of type 'int?' can't be assigned to a variable of type 'int' because 'int?' is nullable and 'int' isn't.
}
