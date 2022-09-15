// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:js_util';
import 'dart:wasm';

import 'package:expect/expect.dart';
import 'package:js/js.dart';

@JS()
external void eval(String code);

typedef SumTwoPositionalFun = String Function(String a, String b);
typedef SumOnePositionalAndOneOptionalFun = String Function(String a,
    [String? b]);
typedef SumTwoOptionalFun = String Function([String? a, String? b]);
typedef SumOnePositionalAndOneOptionalNonNullFun = String Function(String a,
    [String b]);
typedef SumTwoOptionalNonNullFun = String Function([String a, String b]);

@JS()
@staticInterop
class DartFromJSCallbackHelper {
  external factory DartFromJSCallbackHelper.factory(
      SumTwoPositionalFun sumTwoPositional,
      SumOnePositionalAndOneOptionalFun sumOnePositionalOneOptional,
      SumTwoOptionalFun sumTwoOptional,
      SumOnePositionalAndOneOptionalNonNullFun
          sumOnePositionalAndOneOptionalNonNull,
      SumTwoOptionalNonNullFun sumTwoOptionalNonNull);
}

extension DartFromJSCallbackHelperMethods on DartFromJSCallbackHelper {
  external String doSum1();
  external String doSum2(String a, String b);
  external String doSum3(Object summer);

  external String doSumOnePositionalAndOneOptionalA(String a);
  external String doSumOnePositionalAndOneOptionalB(String a, String b);
  external String doSumTwoOptionalA();
  external String doSumTwoOptionalB(String a);
  external String doSumTwoOptionalC(String a, String b);

  external String doSumOnePositionalAndOneOptionalANonNull(String a);
  external String doSumOnePositionalAndOneOptionalBNonNull(String a, String b);
  external String doSumTwoOptionalANonNull();
  external String doSumTwoOptionalBNonNull(String a);
  external String doSumTwoOptionalCNonNull(String a, String b);
}

String sumTwoPositional(String a, String b) {
  return a + b;
}

String sumOnePositionalAndOneOptional(String a, [String? b]) {
  return a + (b ?? 'bar');
}

String sumTwoOptional([String? a, String? b]) {
  return (a ?? 'foo') + (b ?? 'bar');
}

String sumOnePositionalAndOneOptionalNonNull(String a, [String b = 'bar']) {
  return a + b;
}

String sumTwoOptionalNonNull([String a = 'foo', String b = 'bar']) {
  return a + b;
}

void staticInteropCallbackTest() {
  eval(r'''
    globalThis.DartFromJSCallbackHelper = function(
        sumTwoPositional, sumOnePositionalOneOptional, sumTwoOptional,
        sumOnePositionalAndOneOptionalNonNull, sumTwoOptionalNonNull) {
      this.a = 'hello ';
      this.b = 'world!';
      this.sum = null;
      this.sumTwoPositional = sumTwoPositional;
      this.sumOnePositionalOneOptional = sumOnePositionalOneOptional;
      this.sumTwoOptional = sumTwoOptional;
      this.sumOnePositionalAndOneOptionalNonNull = sumOnePositionalAndOneOptionalNonNull;
      this.sumTwoOptionalNonNull = sumTwoOptionalNonNull;
      this.doSum1 = () => {
        return this.sumTwoPositional(this.a, this.b);
      }
      this.doSum2 = (a, b) => {
        return this.sumTwoPositional(a, b);
      }
      this.doSum3 = (summer) => {
        return summer(this.a, this.b);
      }
      this.doSumOnePositionalAndOneOptionalA = (a) => {
        return sumOnePositionalOneOptional(a);
      }
      this.doSumOnePositionalAndOneOptionalB = (a, b) => {
        return sumOnePositionalOneOptional(a, b);
      }
      this.doSumTwoOptionalA = () => {
        return sumTwoOptional();
      }
      this.doSumTwoOptionalB = (a) => {
        return sumTwoOptional(a);
      }
      this.doSumTwoOptionalC = (a, b) => {
        return sumTwoOptional(a, b);
      }
      this.doSumOnePositionalAndOneOptionalANonNull = (a) => {
        return sumOnePositionalAndOneOptionalNonNull(a);
      }
      this.doSumOnePositionalAndOneOptionalBNonNull = (a, b) => {
        return sumOnePositionalAndOneOptionalNonNull(a, b);
      }
      this.doSumTwoOptionalANonNull = () => {
        return sumTwoOptionalNonNull();
      }
      this.doSumTwoOptionalBNonNull = (a) => {
        return sumTwoOptionalNonNull(a);
      }
      this.doSumTwoOptionalCNonNull = (a, b) => {
        return sumTwoOptionalNonNull(a, b);
      }

    }
  ''');

  final helper = DartFromJSCallbackHelper.factory(
      allowInterop<SumTwoPositionalFun>(sumTwoPositional),
      allowInterop<SumOnePositionalAndOneOptionalFun>(
          sumOnePositionalAndOneOptional),
      allowInterop<SumTwoOptionalFun>(sumTwoOptional),
      allowInterop<SumOnePositionalAndOneOptionalNonNullFun>(
          sumOnePositionalAndOneOptionalNonNull),
      allowInterop<SumTwoOptionalNonNullFun>(sumTwoOptionalNonNull));

  Expect.equals('hello world!', helper.doSum1());
  Expect.equals('foobar', helper.doSum2('foo', 'bar'));
  Expect.equals('hello world!',
      helper.doSum3(allowInterop<SumTwoPositionalFun>((a, b) => a + b)));

  Expect.equals('foobar', helper.doSumOnePositionalAndOneOptionalA('foo'));
  Expect.equals(
      'foobar', helper.doSumOnePositionalAndOneOptionalB('foo', 'bar'));
  Expect.equals('foobar', helper.doSumTwoOptionalA());
  Expect.equals('foobar', helper.doSumTwoOptionalB('foo'));
  Expect.equals('foobar', helper.doSumTwoOptionalC('foo', 'bar'));

  Expect.equals(
      'foobar', helper.doSumOnePositionalAndOneOptionalANonNull('foo'));
  Expect.equals(
      'foobar', helper.doSumOnePositionalAndOneOptionalBNonNull('foo', 'bar'));
  Expect.equals('foobar', helper.doSumTwoOptionalANonNull());
  Expect.equals('foobar', helper.doSumTwoOptionalBNonNull('foo'));
  Expect.equals('foobar', helper.doSumTwoOptionalCNonNull('foo', 'bar'));
}

void allowInteropCallbackTest() {
  eval(r'''
    globalThis.doSum1 = function(summer) {
      return summer('foo', 'bar');
    }
    globalThis.doSum2 = function(a, b) {
      return globalThis.summer(a, b);
    }
    globalThis.doSumOnePositionalAndOneOptionalA = function(a) {
      return summer(a);
    }
    globalThis.doSumOnePositionalAndOneOptionalB = function(a, b) {
      return summer(a, b);
    }
    globalThis.doSumTwoOptionalA = function() {
      return summer();
    }
    globalThis.doSumTwoOptionalB = function(a) {
      return summer(a);
    }
    globalThis.doSumTwoOptionalC = function(a, b) {
      return summer(a, b);
    }
    globalThis.doSumOnePositionalAndOneOptionalANonNull = function(a) {
      return summer(a);
    }
    globalThis.doSumOnePositionalAndOneOptionalBNonNull = function(a, b) {
      return summer(a, b);
    }
    globalThis.doSumTwoOptionalANonNull = function() {
      return summer();
    }
    globalThis.doSumTwoOptionalBNonNull = function(a) {
      return summer(a);
    }
    globalThis.doSumTwoOptionalCNonNull = function(a, b) {
      return summer(a, b);
    }
  ''');

  // General
  {
    final interopCallback = allowInterop<SumTwoPositionalFun>((a, b) => a + b);
    Expect.equals('foobar',
        callMethod(globalThis, 'doSum1', [interopCallback]).toString());
    setProperty(globalThis, 'summer', interopCallback);
    Expect.equals(
        'foobar', callMethod(globalThis, 'doSum2', ['foo', 'bar']).toString());
    final roundTripCallback = getProperty(globalThis, 'summer');
    Expect.equals('foobar',
        (dartify(roundTripCallback) as SumTwoPositionalFun)('foo', 'bar'));
  }

  // 1 nullable optional argument
  {
    final interopCallback = allowInterop<SumOnePositionalAndOneOptionalFun>(
        (a, [b]) => a + (b ?? 'bar'));
    setProperty(globalThis, 'summer', interopCallback);
    Expect.equals(
        'foobar',
        callMethod(globalThis, 'doSumOnePositionalAndOneOptionalA', ['foo'])
            .toString());
    Expect.equals(
        'foobar',
        callMethod(
                globalThis, 'doSumOnePositionalAndOneOptionalB', ['foo', 'bar'])
            .toString());
  }

  // All nullable optional arguments
  {
    final interopCallback = allowInterop<SumTwoOptionalFun>(
        ([a, b]) => (a ?? 'foo') + (b ?? 'bar'));
    setProperty(globalThis, 'summer', interopCallback);
    Expect.equals(
        'foobar', callMethod(globalThis, 'doSumTwoOptionalA', []).toString());
    Expect.equals('foobar',
        callMethod(globalThis, 'doSumTwoOptionalB', ['foo']).toString());
    Expect.equals('foobar',
        callMethod(globalThis, 'doSumTwoOptionalC', ['foo', 'bar']).toString());
  }

  // 1 non-nullable optional argument
  {
    final interopCallback =
        allowInterop<SumOnePositionalAndOneOptionalNonNullFun>(
            (a, [b = 'bar']) => a + b);
    setProperty(globalThis, 'summer', interopCallback);
    Expect.equals(
        'foobar',
        callMethod(globalThis, 'doSumOnePositionalAndOneOptionalA', ['foo'])
            .toString());
    Expect.equals(
        'foobar',
        callMethod(
                globalThis, 'doSumOnePositionalAndOneOptionalB', ['foo', 'bar'])
            .toString());
  }

  // All non-nullable optional arguments
  {
    final interopCallback = allowInterop<SumTwoOptionalNonNullFun>(
        ([a = 'foo', b = 'bar']) => a + b);
    setProperty(globalThis, 'summer', interopCallback);
    Expect.equals(
        'foobar', callMethod(globalThis, 'doSumTwoOptionalA', []).toString());
    Expect.equals('foobar',
        callMethod(globalThis, 'doSumTwoOptionalB', ['foo']).toString());
    Expect.equals('foobar',
        callMethod(globalThis, 'doSumTwoOptionalC', ['foo', 'bar']).toString());
  }
}

void main() {
  staticInteropCallbackTest();
  allowInteropCallbackTest();
}
