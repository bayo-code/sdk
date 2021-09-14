// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/plugin/protocol/protocol_dart.dart';
import 'package:analyzer/dart/element/element.dart' as engine;
import 'package:analyzer/src/dart/element/element.dart' as engine;
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../abstract_single_unit.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConvertElementNullableTest);
    defineReflectiveTests(ConvertElementTest);
    defineReflectiveTests(ElementKindTest);
  });
}

@reflectiveTest
class ConvertElementNullableTest extends AbstractSingleUnitTest {
  @override
  String? get testPackageLanguageVersion => '2.9';

  Future<void> test_CONSTRUCTOR_required_parameters_1() async {
    writeTestPackageConfig(meta: true);
    await resolveTestCode('''
import 'package:meta/meta.dart';
class A {
  const A.myConstructor(int a, {int b, @required int c});
}''');

    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: false);
    expect(element.parameters, '(int a, {@required int c, int b})');
  }

  /// Verify parameter re-ordering for required params
  Future<void> test_CONSTRUCTOR_required_parameters_2() async {
    writeTestPackageConfig(meta: true);
    await resolveTestCode('''
import 'package:meta/meta.dart';
class A {
  const A.myConstructor(int a, {int b, @required int d, @required int c});
}''');

    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: false);
    expect(element.parameters,
        '(int a, {@required int d, @required int c, int b})');
  }

  /// Verify parameter re-ordering for required params
  Future<void> test_CONSTRUCTOR_required_parameters_3() async {
    writeTestPackageConfig(meta: true);
    verifyNoTestUnitErrors = false;
    await resolveTestCode('''
import 'package:meta/meta.dart';
class A {
  const A.myConstructor(int a, {int b, @required int d, @required int c, int a});
}''');

    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: false);
    expect(element.parameters,
        '(int a, {@required int d, @required int c, int b, int a})');
  }
}

@reflectiveTest
class ConvertElementTest extends AbstractSingleUnitTest {
  Future<void> test_CLASS() async {
    await resolveTestCode('''
@deprecated
abstract class _A {}
class B<K, V> {}''');
    {
      var engineElement = findElement.class_('_A');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.CLASS);
      expect(element.name, '_A');
      expect(element.typeParameters, isNull);
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, 27);
        expect(location.length, '_A'.length);
        expect(location.startLine, 2);
        expect(location.startColumn, 16);
      }
      expect(element.parameters, isNull);
      expect(
          element.flags,
          Element.FLAG_ABSTRACT |
              Element.FLAG_DEPRECATED |
              Element.FLAG_PRIVATE);
    }
    {
      var engineElement = findElement.class_('B');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.CLASS);
      expect(element.name, 'B');
      expect(element.typeParameters, '<K, V>');
      expect(element.flags, 0);
    }
  }

  Future<void> test_CONSTRUCTOR() async {
    await resolveTestCode('''
class A {
  const A.myConstructor(int a, [String? b]);
}''');
    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.CONSTRUCTOR);
    expect(element.name, 'myConstructor');
    expect(element.typeParameters, isNull);
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 20);
      expect(location.length, 'myConstructor'.length);
      expect(location.startLine, 2);
      expect(location.startColumn, 11);
    }
    expect(element.parameters, '(int a, [String? b])');
    expect(element.returnType, 'A');
    expect(element.flags, Element.FLAG_CONST);
  }

  Future<void> test_CONSTRUCTOR_required_parameters_1() async {
    writeTestPackageConfig(meta: true);
    await resolveTestCode('''
import 'package:meta/meta.dart';
class A {
  const A.myConstructor(int a, {int? b, required int c});
}''');

    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.parameters, '(int a, {required int c, int? b})');
  }

  /// Verify parameter re-ordering for required params
  Future<void> test_CONSTRUCTOR_required_parameters_2() async {
    writeTestPackageConfig(meta: true);
    await resolveTestCode('''
import 'package:meta/meta.dart';
class A {
  const A.myConstructor(int a, {int? b, required int d, required int c});
}''');

    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.parameters,
        '(int a, {required int d, required int c, int? b})');
  }

  /// Verify parameter re-ordering for required params
  Future<void> test_CONSTRUCTOR_required_parameters_3() async {
    writeTestPackageConfig(meta: true);
    verifyNoTestUnitErrors = false;
    await resolveTestCode('''
import 'package:meta/meta.dart';
class A {
  const A.myConstructor(int a, {int b, required int d, required int c, int a});
}''');

    var engineElement = findElement.constructor('myConstructor');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.parameters,
        '(int a, {required int d, required int c, int b, int a})');
  }

  void test_dynamic() {
    var engineElement = engine.DynamicElementImpl.instance;
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.UNKNOWN);
    expect(element.name, 'dynamic');
    expect(element.location, isNull);
    expect(element.parameters, isNull);
    expect(element.returnType, isNull);
    expect(element.flags, 0);
  }

  Future<void> test_ENUM() async {
    await resolveTestCode('''
@deprecated
enum _E1 { one, two }
enum E2 { three, four }''');
    {
      var engineElement = findElement.enum_('_E1');
      expect(engineElement.hasDeprecated, isTrue);
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.ENUM);
      expect(element.name, '_E1');
      expect(element.typeParameters, isNull);
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, 17);
        expect(location.length, '_E1'.length);
        expect(location.startLine, 2);
        expect(location.startColumn, 6);
      }
      expect(element.parameters, isNull);
      expect(
          element.flags,
          (engineElement.hasDeprecated ? Element.FLAG_DEPRECATED : 0) |
              Element.FLAG_PRIVATE);
    }
    {
      var engineElement = findElement.enum_('E2');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.ENUM);
      expect(element.name, 'E2');
      expect(element.typeParameters, isNull);
      expect(element.flags, 0);
    }
  }

  Future<void> test_ENUM_CONSTANT() async {
    await resolveTestCode('''
@deprecated
enum _E1 { one, two }
enum E2 { three, four }''');
    {
      var engineElement = findElement.field('one');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.ENUM_CONSTANT);
      expect(element.name, 'one');
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, 23);
        expect(location.length, 'one'.length);
        expect(location.startLine, 2);
        expect(location.startColumn, 12);
      }
      expect(element.parameters, isNull);
      expect(element.returnType, '_E1');
      // TODO(danrubel) determine why enum constant is not marked as deprecated
      //engine.ClassElement classElement = engineElement.enclosingElement;
      //expect(classElement.isDeprecated, isTrue);
      expect(
          element.flags,
          // Element.FLAG_DEPRECATED |
          Element.FLAG_CONST | Element.FLAG_STATIC);
    }
    {
      var engineElement = findElement.field('three');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.ENUM_CONSTANT);
      expect(element.name, 'three');
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, 44);
        expect(location.length, 'three'.length);
        expect(location.startLine, 3);
        expect(location.startColumn, 11);
      }
      expect(element.parameters, isNull);
      expect(element.returnType, 'E2');
      expect(element.flags, Element.FLAG_CONST | Element.FLAG_STATIC);
    }
    {
      var engineElement = findElement.field('index', of: 'E2');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.FIELD);
      expect(element.name, 'index');
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, -1);
        expect(location.length, 'index'.length);
        expect(location.startLine, 1);
        expect(location.startColumn, 0);
      }
      expect(element.parameters, isNull);
      expect(element.returnType, 'int');
      expect(element.flags, Element.FLAG_FINAL);
    }
    {
      var engineElement = findElement.field('values', of: 'E2');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.FIELD);
      expect(element.name, 'values');
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, -1);
        expect(location.length, 'values'.length);
        expect(location.startLine, 1);
        expect(location.startColumn, 0);
      }
      expect(element.parameters, isNull);
      expect(element.returnType, 'List<E2>');
      expect(element.flags, Element.FLAG_CONST | Element.FLAG_STATIC);
    }
  }

  Future<void> test_FIELD() async {
    await resolveTestCode('''
class A {
  static const myField = 42;
}''');
    var engineElement = findElement.field('myField');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.FIELD);
    expect(element.name, 'myField');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 25);
      expect(location.length, 'myField'.length);
      expect(location.startLine, 2);
      expect(location.startColumn, 16);
    }
    expect(element.parameters, isNull);
    expect(element.returnType, 'int');
    expect(element.flags, Element.FLAG_CONST | Element.FLAG_STATIC);
  }

  Future<void> test_FUNCTION_TYPE_ALIAS_functionType() async {
    await resolveTestCode('''
typedef F<T> = int Function(String x);
''');
    var engineElement = findElement.typeAlias('F');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.TYPE_ALIAS);
    expect(element.name, 'F');
    expect(element.typeParameters, '<T>');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 8);
      expect(location.length, 'F'.length);
      expect(location.startLine, 1);
      expect(location.startColumn, 9);
    }
    expect(element.parameters, '(String x)');
    expect(element.returnType, 'int');
    expect(element.flags, 0);
  }

  Future<void> test_FUNCTION_TYPE_ALIAS_interfaceType() async {
    await resolveTestCode('''
typedef F<T> = Map<int, T>;
''');
    var engineElement = findElement.typeAlias('F');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.TYPE_ALIAS);
    expect(element.name, 'F');
    expect(element.typeParameters, '<out T>');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 8);
      expect(location.length, 'F'.length);
      expect(location.startLine, 1);
      expect(location.startColumn, 9);
    }
    expect(element.aliasedType, 'Map<int, T>');
    expect(element.parameters, isNull);
    expect(element.returnType, isNull);
    expect(element.flags, 0);
  }

  Future<void> test_FUNCTION_TYPE_ALIAS_legacy() async {
    await resolveTestCode('''
typedef int F<T>(String x);
''');
    var engineElement = findElement.typeAlias('F');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.TYPE_ALIAS);
    expect(element.name, 'F');
    expect(element.typeParameters, '<T>');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 12);
      expect(location.length, 'F'.length);
      expect(location.startLine, 1);
      expect(location.startColumn, 13);
    }
    expect(element.parameters, '(String x)');
    expect(element.returnType, 'int');
    expect(element.flags, 0);
  }

  Future<void> test_GETTER() async {
    verifyNoTestUnitErrors = false;
    await resolveTestCode('''
class A {
  String get myGetter => 42;
}''');
    var engineElement = findElement.getter('myGetter');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.GETTER);
    expect(element.name, 'myGetter');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 23);
      expect(location.length, 'myGetter'.length);
      expect(location.startLine, 2);
      expect(location.startColumn, 14);
    }
    expect(element.parameters, isNull);
    expect(element.returnType, 'String');
    expect(element.flags, 0);
  }

  Future<void> test_LABEL() async {
    await resolveTestCode('''
main() {
myLabel:
  while (true) {
    break myLabel;
  }
}''');
    var engineElement = findElement.label('myLabel');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.LABEL);
    expect(element.name, 'myLabel');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 9);
      expect(location.length, 'myLabel'.length);
      expect(location.startLine, 2);
      expect(location.startColumn, 1);
    }
    expect(element.parameters, isNull);
    expect(element.returnType, isNull);
    expect(element.flags, 0);
  }

  Future<void> test_METHOD() async {
    await resolveTestCode('''
class A {
  static List<String> myMethod(int a, {String? b, int? c}) {
    return [];
  }
}''');
    var engineElement = findElement.method('myMethod');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.METHOD);
    expect(element.name, 'myMethod');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 32);
      expect(location.length, 'myGetter'.length);
      expect(location.startLine, 2);
      expect(location.startColumn, 23);
    }
    expect(element.parameters, '(int a, {String? b, int? c})');
    expect(element.returnType, 'List<String>');
    expect(element.flags, Element.FLAG_STATIC);
  }

  Future<void> test_MIXIN() async {
    await resolveTestCode('''
mixin A {}
''');
    {
      var engineElement = findElement.mixin('A');
      // create notification Element
      var element = convertElement(engineElement, withNullability: true);
      expect(element.kind, ElementKind.MIXIN);
      expect(element.name, 'A');
      expect(element.typeParameters, isNull);
      {
        var location = element.location!;
        expect(location.file, testFile);
        expect(location.offset, 6);
        expect(location.length, 'A'.length);
        expect(location.startLine, 1);
        expect(location.startColumn, 7);
      }
      expect(element.parameters, isNull);
      expect(element.flags, Element.FLAG_ABSTRACT);
    }
  }

  Future<void> test_SETTER() async {
    await resolveTestCode('''
class A {
  set mySetter(String x) {}
}''');
    var engineElement = findElement.setter('mySetter');
    // create notification Element
    var element = convertElement(engineElement, withNullability: true);
    expect(element.kind, ElementKind.SETTER);
    expect(element.name, 'mySetter');
    {
      var location = element.location!;
      expect(location.file, testFile);
      expect(location.offset, 16);
      expect(location.length, 'mySetter'.length);
      expect(location.startLine, 2);
      expect(location.startColumn, 7);
    }
    expect(element.parameters, '(String x)');
    expect(element.returnType, isNull);
    expect(element.flags, 0);
  }
}

@reflectiveTest
class ElementKindTest {
  void test_fromEngine() {
    expect(convertElementKind(engine.ElementKind.CLASS), ElementKind.CLASS);
    expect(convertElementKind(engine.ElementKind.COMPILATION_UNIT),
        ElementKind.COMPILATION_UNIT);
    expect(convertElementKind(engine.ElementKind.CONSTRUCTOR),
        ElementKind.CONSTRUCTOR);
    expect(convertElementKind(engine.ElementKind.FIELD), ElementKind.FIELD);
    expect(
        convertElementKind(engine.ElementKind.FUNCTION), ElementKind.FUNCTION);
    expect(convertElementKind(engine.ElementKind.FUNCTION_TYPE_ALIAS),
        ElementKind.FUNCTION_TYPE_ALIAS);
    expect(convertElementKind(engine.ElementKind.GENERIC_FUNCTION_TYPE),
        ElementKind.FUNCTION_TYPE_ALIAS);
    expect(convertElementKind(engine.ElementKind.GETTER), ElementKind.GETTER);
    expect(convertElementKind(engine.ElementKind.LABEL), ElementKind.LABEL);
    expect(convertElementKind(engine.ElementKind.LIBRARY), ElementKind.LIBRARY);
    expect(convertElementKind(engine.ElementKind.LOCAL_VARIABLE),
        ElementKind.LOCAL_VARIABLE);
    expect(convertElementKind(engine.ElementKind.METHOD), ElementKind.METHOD);
    expect(convertElementKind(engine.ElementKind.PARAMETER),
        ElementKind.PARAMETER);
    expect(convertElementKind(engine.ElementKind.SETTER), ElementKind.SETTER);
    expect(convertElementKind(engine.ElementKind.TOP_LEVEL_VARIABLE),
        ElementKind.TOP_LEVEL_VARIABLE);
    expect(convertElementKind(engine.ElementKind.TYPE_ALIAS),
        ElementKind.TYPE_ALIAS);
    expect(convertElementKind(engine.ElementKind.TYPE_PARAMETER),
        ElementKind.TYPE_PARAMETER);
  }

  void test_string_constructor() {
    expect(ElementKind(ElementKind.CLASS.name), ElementKind.CLASS);
    expect(ElementKind(ElementKind.CLASS_TYPE_ALIAS.name),
        ElementKind.CLASS_TYPE_ALIAS);
    expect(ElementKind(ElementKind.COMPILATION_UNIT.name),
        ElementKind.COMPILATION_UNIT);
    expect(ElementKind(ElementKind.CONSTRUCTOR.name), ElementKind.CONSTRUCTOR);
    expect(ElementKind(ElementKind.FIELD.name), ElementKind.FIELD);
    expect(ElementKind(ElementKind.FUNCTION.name), ElementKind.FUNCTION);
    expect(ElementKind(ElementKind.FUNCTION_TYPE_ALIAS.name),
        ElementKind.FUNCTION_TYPE_ALIAS);
    expect(ElementKind(ElementKind.GETTER.name), ElementKind.GETTER);
    expect(ElementKind(ElementKind.LIBRARY.name), ElementKind.LIBRARY);
    expect(ElementKind(ElementKind.LOCAL_VARIABLE.name),
        ElementKind.LOCAL_VARIABLE);
    expect(ElementKind(ElementKind.METHOD.name), ElementKind.METHOD);
    expect(ElementKind(ElementKind.PARAMETER.name), ElementKind.PARAMETER);
    expect(ElementKind(ElementKind.SETTER.name), ElementKind.SETTER);
    expect(ElementKind(ElementKind.TOP_LEVEL_VARIABLE.name),
        ElementKind.TOP_LEVEL_VARIABLE);
    expect(ElementKind(ElementKind.TYPE_ALIAS.name), ElementKind.TYPE_ALIAS);
    expect(ElementKind(ElementKind.TYPE_PARAMETER.name),
        ElementKind.TYPE_PARAMETER);
    expect(ElementKind(ElementKind.UNIT_TEST_TEST.name),
        ElementKind.UNIT_TEST_TEST);
    expect(ElementKind(ElementKind.UNIT_TEST_GROUP.name),
        ElementKind.UNIT_TEST_GROUP);
    expect(ElementKind(ElementKind.UNKNOWN.name), ElementKind.UNKNOWN);
    expect(() {
      ElementKind('no-such-kind');
    }, throwsException);
  }

  void test_toString() {
    expect(ElementKind.CLASS.toString(), 'ElementKind.CLASS');
    expect(ElementKind.COMPILATION_UNIT.toString(),
        'ElementKind.COMPILATION_UNIT');
  }
}
