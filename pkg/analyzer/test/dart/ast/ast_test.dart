// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/ast.dart';
import 'package:analyzer/src/dart/ast/ast_factory.dart';
import 'package:analyzer/src/dart/ast/utilities.dart';
import 'package:analyzer/src/dart/error/syntactic_errors.dart';
import 'package:analyzer/src/generated/testing/ast_test_factory.dart';
import 'package:analyzer/src/generated/testing/token_factory.dart';
import 'package:analyzer/src/test_utilities/find_node.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../generated/parser_test_base.dart' show ParserTestCase;
import '../../src/diagnostics/parser_diagnostics.dart';
import '../../util/feature_sets.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ConstructorDeclarationTest);
    defineReflectiveTests(FieldFormalParameterTest);
    defineReflectiveTests(FormalParameterIsExplicitlyTypedTest);
    defineReflectiveTests(HideClauseImplTest);
    defineReflectiveTests(ImplementsClauseImplTest);
    defineReflectiveTests(IndexExpressionTest);
    defineReflectiveTests(InterpolationStringTest);
    defineReflectiveTests(MethodDeclarationTest);
    defineReflectiveTests(MethodInvocationTest);
    defineReflectiveTests(NodeListTest);
    defineReflectiveTests(NormalFormalParameterTest);
    defineReflectiveTests(OnClauseImplTest);
    defineReflectiveTests(PreviousTokenTest);
    defineReflectiveTests(PropertyAccessTest);
    defineReflectiveTests(ShowClauseImplTest);
    defineReflectiveTests(SimpleIdentifierTest);
    defineReflectiveTests(SimpleStringLiteralTest);
    defineReflectiveTests(SpreadElementTest);
    defineReflectiveTests(StringInterpolationTest);
    defineReflectiveTests(VariableDeclarationTest);
    defineReflectiveTests(WithClauseImplTest);
  });
}

@reflectiveTest
class ConstructorDeclarationTest extends ParserDiagnosticsTest {
  void test_firstTokenAfterCommentAndMetadata_all_inverted() {
    final parseResult = parseStringWithErrors(r'''
class A {
  factory const external A();
}
''');
    parseResult.assertErrors([
      error(ParserErrorCode.MODIFIER_OUT_OF_ORDER, 20, 5),
      error(ParserErrorCode.MODIFIER_OUT_OF_ORDER, 26, 8),
    ]);

    final node = parseResult.findNode.constructor('A()');
    expect(node.firstTokenAfterCommentAndMetadata, node.factoryKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_all_normal() {
    final parseResult = parseStringWithErrors(r'''
class A {
  external const factory A();
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.constructor('A()');
    expect(node.firstTokenAfterCommentAndMetadata, node.externalKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_constOnly() {
    final parseResult = parseStringWithErrors(r'''
class A {
  const A();
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.constructor('A()');
    expect(node.firstTokenAfterCommentAndMetadata, node.constKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_externalOnly() {
    final parseResult = parseStringWithErrors(r'''
class A {
  external A();
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.constructor('A()');
    expect(node.firstTokenAfterCommentAndMetadata, node.externalKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_factoryOnly() {
    final parseResult = parseStringWithErrors(r'''
class A {
  factory A() => throw 0;
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.constructor('A()');
    expect(node.firstTokenAfterCommentAndMetadata, node.factoryKeyword);
  }
}

@reflectiveTest
class FieldFormalParameterTest {
  void test_endToken_noParameters() {
    FieldFormalParameter parameter =
        AstTestFactory.fieldFormalParameter2('field');
    expect(parameter.endToken, parameter.name);
  }

  void test_endToken_parameters() {
    FieldFormalParameter parameter = AstTestFactory.fieldFormalParameter(
        null, null, 'field', AstTestFactory.formalParameterList([]));
    expect(parameter.endToken, parameter.parameters!.endToken);
  }
}

@reflectiveTest
class FormalParameterIsExplicitlyTypedTest extends ParserTestCase {
  test_field_functionTyped_explicitReturn() {
    _checkExplicitlyTyped('''
class C {
  C(int this.x());
  final Object x;
}
''', true);
  }

  test_field_functionTyped_explicitReturn_default() {
    _checkExplicitlyTyped('''
class C {
  C([int this.x() = y]);
  final Object x;
}
''', true);
  }

  test_field_functionTyped_explicitReturn_named() {
    _checkExplicitlyTyped('''
class C {
  C({required int this.x()});
  final Object x;
}
''', true);
  }

  test_field_functionTyped_explicitReturn_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({int this.x() = y});
  final Object x;
}
''', true);
  }

  test_field_functionTyped_implicitReturn() {
    _checkExplicitlyTyped('''
class C {
  C(this.x());
  final Object x;
}
''', true);
  }

  test_field_functionTyped_implicitReturn_default() {
    _checkExplicitlyTyped('''
class C {
  C([this.x() = y]);
  final Object x;
}
''', true);
  }

  test_field_functionTyped_implicitReturn_named() {
    _checkExplicitlyTyped('''
class C {
  C({required this.x()});
  final Object x;
}
''', true);
  }

  test_field_functionTyped_implicitReturn_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({this.x() = y});
  final Object x;
}
''', true);
  }

  test_field_simple_explicit() {
    _checkExplicitlyTyped('''
class C {
  C(int this.x);
  final Object x;
}
''', true);
  }

  test_field_simple_explicit_default() {
    _checkExplicitlyTyped('''
class C {
  C([int this.x = y]);
  final Object x;
}
''', true);
  }

  test_field_simple_explicit_named() {
    _checkExplicitlyTyped('''
class C {
  C({int? this.x});
  final Object? x;
}
''', true);
  }

  test_field_simple_explicit_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({int this.x = y});
  final Object x;
}
''', true);
  }

  test_field_simple_implicit() {
    _checkExplicitlyTyped('''
class C {
  C(this.x);
  final Object x;
}
''', false);
  }

  test_field_simple_implicit_default() {
    _checkExplicitlyTyped('''
class C {
  C([this.x = y]);
  final Object x;
}
''', false);
  }

  test_field_simple_implicit_named() {
    _checkExplicitlyTyped('''
class C {
  C({this.x});
  final Object? x;
}
''', false);
  }

  test_field_simple_implicit_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({this.x = y});
  final Object x;
}
''', false);
  }

  test_functionTyped_explicitReturn() {
    _checkExplicitlyTyped('''
class C {
  C(int x());
}
''', true);
  }

  test_functionTyped_explicitReturn_default() {
    _checkExplicitlyTyped('''
class C {
  C([int x() = y]);
}
''', true);
  }

  test_functionTyped_explicitReturn_named() {
    _checkExplicitlyTyped('''
class C {
  C({required int x()});
}
''', true);
  }

  test_functionTyped_explicitReturn_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({int x() = y});
}
''', true);
  }

  test_functionTyped_implicitReturn() {
    _checkExplicitlyTyped('''
class C {
  C(x());
}
''', true);
  }

  test_functionTyped_implicitReturn_default() {
    _checkExplicitlyTyped('''
class C {
  C([x() = y]);
}
''', true);
  }

  test_functionTyped_implicitReturn_named() {
    _checkExplicitlyTyped('''
class C {
  C({required x()});
}
''', true);
  }

  test_functionTyped_implicitReturn_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({x() = y});
}
''', true);
  }

  test_simple_explicit() {
    _checkExplicitlyTyped('''
class C {
  C(int x);
}
''', true);
  }

  test_simple_explicit_default() {
    _checkExplicitlyTyped('''
class C {
  C([int x = y]);
}
''', true);
  }

  test_simple_explicit_named() {
    _checkExplicitlyTyped('''
class C {
  C({int? x});
}
''', true);
  }

  test_simple_explicit_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({int x = y});
}
''', true);
  }

  test_simple_implicit() {
    _checkExplicitlyTyped('''
class C {
  C(x);
}
''', false);
  }

  test_simple_implicit_default() {
    _checkExplicitlyTyped('''
class C {
  C([x = y]);
}
''', false);
  }

  test_simple_implicit_named() {
    _checkExplicitlyTyped('''
class C {
  C({x});
}
''', false);
  }

  test_simple_implicit_named_default() {
    _checkExplicitlyTyped('''
class C {
  C({x = y});
}
''', false);
  }

  test_super_functionTyped_explicitReturn() {
    _checkExplicitlyTyped('''
class C extends B {
  C(int super.x());
}
''', true);
  }

  test_super_functionTyped_explicitReturn_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C([int super.x() = y]);
}
''', true);
  }

  test_super_functionTyped_explicitReturn_named() {
    _checkExplicitlyTyped('''
class C extends B {
  C({required int super.x()});
}
''', true);
  }

  test_super_functionTyped_explicitReturn_named_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C({int super.x() = y});
}
''', true);
  }

  test_super_functionTyped_implicitReturn() {
    _checkExplicitlyTyped('''
class C extends B {
  C(super.x());
}
''', true);
  }

  test_super_functionTyped_implicitReturn_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C([super.x() = y]);
}
''', true);
  }

  test_super_functionTyped_implicitReturn_named() {
    _checkExplicitlyTyped('''
class C extends B {
  C({required super.x()});
}
''', true);
  }

  test_super_functionTyped_implicitReturn_named_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C({super.x() = y});
}
''', true);
  }

  test_super_simple_explicit() {
    _checkExplicitlyTyped('''
class C extends B {
  C(int super.x);
}
''', true);
  }

  test_super_simple_explicit_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C([int super.x = y]);
}
''', true);
  }

  test_super_simple_explicit_named() {
    _checkExplicitlyTyped('''
class C extends B {
  C({int? super.x});
}
''', true);
  }

  test_super_simple_explicit_named_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C({int super.x = y});
}
''', true);
  }

  test_super_simple_implicit() {
    _checkExplicitlyTyped('''
class C extends B {
  C(super.x);
}
''', false);
  }

  test_super_simple_implicit_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C([super.x = y]);
}
''', false);
  }

  test_super_simple_implicit_named() {
    _checkExplicitlyTyped('''
class C extends B {
  C({super.x});
}
''', false);
  }

  test_super_simple_implicit_named_default() {
    _checkExplicitlyTyped('''
class C extends B {
  C({super.x = y});
}
''', false);
  }

  void _checkExplicitlyTyped(String input, bool expected) {
    var parseResult = parseString(content: input);
    var class_ = parseResult.unit.declarations[0] as ClassDeclaration;
    var constructor = class_.members[0] as ConstructorDeclaration;
    var parameter = constructor.parameters.parameters[0];
    expect(parameter.isExplicitlyTyped, expected);
  }
}

@reflectiveTest
class HideClauseImplTest extends ParserDiagnosticsTest {
  void test_endToken_invalidClass() {
    final parseResult = parseStringWithErrors('''
import 'dart:core' hide int Function();
''');
    final node = parseResult.findNode.import('import');
    expect(node.combinators[0].endToken, isNotNull);
  }
}

@reflectiveTest
class ImplementsClauseImplTest extends ParserDiagnosticsTest {
  void test_endToken_invalidClass() {
    final parseResult = parseStringWithErrors('''
class A implements C Function() {}
class C {}
''');
    final node = parseResult.findNode.classDeclaration('A');
    expect(node.implementsClause!.endToken, isNotNull);
  }
}

@reflectiveTest
class IndexExpressionTest extends _AstTest {
  void test_inGetterContext_assignment_compound_left() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // a[b] += c
    AstTestFactory.assignmentExpression(
        expression, TokenType.PLUS_EQ, AstTestFactory.identifier3("c"));
    expect(expression.inGetterContext(), isTrue);
  }

  void test_inGetterContext_assignment_simple_left() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // a[b] = c
    AstTestFactory.assignmentExpression(
        expression, TokenType.EQ, AstTestFactory.identifier3("c"));
    expect(expression.inGetterContext(), isFalse);
  }

  void test_inGetterContext_nonAssignment() {
    var node = _parseStringToNode<IndexExpression>(r'''
var v = ^a[b] + c;
''');
    expect(node.inGetterContext(), isTrue);
  }

  void test_inSetterContext_assignment_compound_left() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // a[b] += c
    AstTestFactory.assignmentExpression(
        expression, TokenType.PLUS_EQ, AstTestFactory.identifier3("c"));
    expect(expression.inSetterContext(), isTrue);
  }

  void test_inSetterContext_assignment_compound_right() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // c += a[b]
    AstTestFactory.assignmentExpression(
        AstTestFactory.identifier3("c"), TokenType.PLUS_EQ, expression);
    expect(expression.inSetterContext(), isFalse);
  }

  void test_inSetterContext_assignment_simple_left() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // a[b] = c
    AstTestFactory.assignmentExpression(
        expression, TokenType.EQ, AstTestFactory.identifier3("c"));
    expect(expression.inSetterContext(), isTrue);
  }

  void test_inSetterContext_assignment_simple_right() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // c = a[b]
    AstTestFactory.assignmentExpression(
        AstTestFactory.identifier3("c"), TokenType.EQ, expression);
    expect(expression.inSetterContext(), isFalse);
  }

  void test_inSetterContext_nonAssignment() {
    var node = _parseStringToNode<IndexExpression>(r'''
var v = ^a[b] + c;
''');
    expect(node.inSetterContext(), isFalse);
  }

  void test_inSetterContext_postfix_bang() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // a[b]!
    AstTestFactory.postfixExpression(expression, TokenType.BANG);
    expect(expression.inSetterContext(), isFalse);
  }

  void test_inSetterContext_postfix_plusPlus() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    AstTestFactory.postfixExpression(expression, TokenType.PLUS_PLUS);
    // a[b]++
    expect(expression.inSetterContext(), isTrue);
  }

  void test_inSetterContext_prefix_bang() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // !a[b]
    AstTestFactory.prefixExpression(TokenType.BANG, expression);
    expect(expression.inSetterContext(), isFalse);
  }

  void test_inSetterContext_prefix_minusMinus() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // --a[b]
    AstTestFactory.prefixExpression(TokenType.MINUS_MINUS, expression);
    expect(expression.inSetterContext(), isTrue);
  }

  void test_inSetterContext_prefix_plusPlus() {
    IndexExpression expression = AstTestFactory.indexExpression(
      target: AstTestFactory.identifier3("a"),
      index: AstTestFactory.identifier3("b"),
    );
    // ++a[b]
    AstTestFactory.prefixExpression(TokenType.PLUS_PLUS, expression);
    expect(expression.inSetterContext(), isTrue);
  }

  void test_isNullAware_cascade_false() {
    final findNode = _parseStringToFindNode('''
void f() {
  a..[0];
}
''');
    final expression = findNode.index('[0]');
    expect(expression.isNullAware, isFalse);
  }

  void test_isNullAware_cascade_true() {
    final findNode = _parseStringToFindNode('''
void f() {
  a?..[0];
}
''');
    final expression = findNode.index('[0]');
    expect(expression.isNullAware, isTrue);
  }

  void test_isNullAware_false() {
    final expression = AstTestFactory.indexExpression(
      target: AstTestFactory.nullLiteral(),
      index: AstTestFactory.nullLiteral(),
    );
    expect(expression.isNullAware, isFalse);
  }

  void test_isNullAware_regularIndex() {
    final expression = AstTestFactory.indexExpression(
      target: AstTestFactory.nullLiteral(),
      index: AstTestFactory.nullLiteral(),
    );
    expect(expression.isNullAware, isFalse);
  }

  void test_isNullAware_true() {
    final expression = AstTestFactory.indexExpression(
      target: AstTestFactory.nullLiteral(),
      hasQuestion: true,
      index: AstTestFactory.nullLiteral(),
    );
    expect(expression.isNullAware, isTrue);
  }
}

@reflectiveTest
class InterpolationStringTest extends ParserTestCase {
  /// This field is updated in [_parseStringInterpolation].
  /// It is used in [_assertContentsOffsetEnd].
  var _baseOffset = 0;

  void test_contentsOffset_doubleQuote_first() {
    var interpolation = _parseStringInterpolation('"foo\$x last"');
    var node = interpolation.firstString;
    _assertContentsOffsetEnd(node, 1, 4);
  }

  void test_contentsOffset_doubleQuote_last() {
    var interpolation = _parseStringInterpolation('"first \$x foo"');
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 9, 13);
  }

  void test_contentsOffset_doubleQuote_last_empty() {
    var interpolation = _parseStringInterpolation('"first \$x"');
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 9, 9);
  }

  void test_contentsOffset_doubleQuote_last_unterminated() {
    var interpolation = _parseStringInterpolation('"first \$x foo');
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 9, 13);
  }

  void test_contentsOffset_doubleQuote_multiline_first() {
    var interpolation = _parseStringInterpolation('"""foo\n\$x last"""');
    var node = interpolation.firstString;
    _assertContentsOffsetEnd(node, 3, 7);
  }

  void test_contentsOffset_doubleQuote_multiline_last() {
    var interpolation = _parseStringInterpolation('"""first\$x foo\n"""');
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 10, 15);
  }

  void test_contentsOffset_doubleQuote_multiline_last_empty() {
    var interpolation = _parseStringInterpolation('"""first\$x"""');
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 10, 10);
  }

  void test_contentsOffset_doubleQuote_multiline_last_unterminated() {
    var interpolation = _parseStringInterpolation('"""first\$x foo\n');
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 10, 15);
  }

  void test_contentsOffset_escapeCharacters() {
    // Contents offset cannot use 'value' string, because of escape sequences.
    var interpolation = _parseStringInterpolation(r'"foo\nbar$x last"');
    var node = interpolation.firstString;
    _assertContentsOffsetEnd(node, 1, 9);
  }

  void test_contentsOffset_middle() {
    var interpolation =
        _parseStringInterpolation(r'"first $x foo\nbar $y last"');
    var node = interpolation.elements[2] as InterpolationString;
    _assertContentsOffsetEnd(node, 9, 19);
  }

  void test_contentsOffset_middle_quoteBegin() {
    var interpolation = _parseStringInterpolation('"first \$x \'foo\$y last"');
    var node = interpolation.elements[2] as InterpolationString;
    _assertContentsOffsetEnd(node, 9, 14);
  }

  void test_contentsOffset_middle_quoteBeginEnd() {
    var interpolation =
        _parseStringInterpolation('"first \$x \'foo\'\$y last"');
    var node = interpolation.elements[2] as InterpolationString;
    _assertContentsOffsetEnd(node, 9, 15);
  }

  void test_contentsOffset_middle_quoteEnd() {
    var interpolation = _parseStringInterpolation('"first \$x foo\'\$y last"');
    var node = interpolation.elements[2] as InterpolationString;
    _assertContentsOffsetEnd(node, 9, 14);
  }

  void test_contentsOffset_singleQuote_first() {
    var interpolation = _parseStringInterpolation("'foo\$x last'");
    var node = interpolation.firstString;
    _assertContentsOffsetEnd(node, 1, 4);
  }

  void test_contentsOffset_singleQuote_last() {
    var interpolation = _parseStringInterpolation("'first \$x foo'");
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 9, 13);
  }

  void test_contentsOffset_singleQuote_last_empty() {
    var interpolation = _parseStringInterpolation("'first \$x'");
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 9, 9);
  }

  void test_contentsOffset_singleQuote_last_unterminated() {
    var interpolation = _parseStringInterpolation("'first \$x");
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 9, 9);
  }

  void test_contentsOffset_singleQuote_multiline_first() {
    var interpolation = _parseStringInterpolation("'''foo\n\$x last'''");
    var node = interpolation.firstString;
    _assertContentsOffsetEnd(node, 3, 7);
  }

  void test_contentsOffset_singleQuote_multiline_last() {
    var interpolation = _parseStringInterpolation("'''first\$x foo\n'''");
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 10, 15);
  }

  void test_contentsOffset_singleQuote_multiline_last_empty() {
    var interpolation = _parseStringInterpolation("'''first\$x'''");
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 10, 10);
  }

  void test_contentsOffset_singleQuote_multiline_last_unterminated() {
    var interpolation = _parseStringInterpolation("'''first\$x'''");
    var node = interpolation.lastString;
    _assertContentsOffsetEnd(node, 10, 10);
  }

  void _assertContentsOffsetEnd(InterpolationString node, int offset, int end) {
    expect(node.contentsOffset, _baseOffset + offset);
    expect(node.contentsEnd, _baseOffset + end);
  }

  StringInterpolation _parseStringInterpolation(String code) {
    var unitCode = 'var x = ';
    _baseOffset = unitCode.length;
    unitCode += code;
    var unit = parseString(
      content: unitCode,
      throwIfDiagnostics: false,
    ).unit;
    var declaration = unit.declarations[0] as TopLevelVariableDeclaration;
    return declaration.variables.variables[0].initializer
        as StringInterpolation;
  }
}

@reflectiveTest
class MethodDeclarationTest extends ParserDiagnosticsTest {
  void test_firstTokenAfterCommentAndMetadata_external() {
    final parseResult = parseStringWithErrors(r'''
class A {
  external void foo();
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.methodDeclaration('foo()');
    expect(node.firstTokenAfterCommentAndMetadata, node.externalKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_external_getter() {
    final parseResult = parseStringWithErrors(r'''
class A {
  external get foo;
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.methodDeclaration('get foo');
    expect(node.firstTokenAfterCommentAndMetadata, node.externalKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_external_operator() {
    final parseResult = parseStringWithErrors(r'''
class A {
  external operator +(int other);
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.methodDeclaration('external operator');
    expect(node.firstTokenAfterCommentAndMetadata, node.externalKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_getter() {
    final parseResult = parseStringWithErrors(r'''
class A {
  get foo => 0;
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.methodDeclaration('get foo');
    expect(node.firstTokenAfterCommentAndMetadata, node.propertyKeyword);
  }

  void test_firstTokenAfterCommentAndMetadata_operator() {
    final parseResult = parseStringWithErrors(r'''
class A {
  operator +(int other) => 0;
}
''');
    parseResult.assertNoErrors();

    final node = parseResult.findNode.methodDeclaration('operator');
    expect(node.firstTokenAfterCommentAndMetadata, node.operatorKeyword);
  }
}

@reflectiveTest
class MethodInvocationTest extends _AstTest {
  void test_isNullAware_cascade() {
    final findNode = _parseStringToFindNode('''
void f() {
  a..foo();
}
''');
    final invocation = findNode.methodInvocation('foo');
    expect(invocation.isNullAware, isFalse);
  }

  void test_isNullAware_cascade_true() {
    final findNode = _parseStringToFindNode('''
void f() {
  a?..foo();
}
''');
    final invocation = findNode.methodInvocation('foo');
    expect(invocation.isNullAware, isTrue);
  }

  void test_isNullAware_regularInvocation() {
    final findNode = _parseStringToFindNode('''
void f() {
  a.foo();
}
''');
    final invocation = findNode.methodInvocation('foo');
    expect(invocation.isNullAware, isFalse);
  }

  void test_isNullAware_true() {
    final findNode = _parseStringToFindNode('''
void f() {
  a?.foo();
}
''');
    final invocation = findNode.methodInvocation('foo');
    expect(invocation.isNullAware, isTrue);
  }
}

@reflectiveTest
class NodeListTest extends ParserDiagnosticsTest {
  void test_getBeginToken_empty() {
    final parseResult = parseStringWithErrors(r'''
final x = f();
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('()');
    final nodeList = argumentList.arguments;
    expect(nodeList.beginToken, isNull);
  }

  void test_getBeginToken_nonEmpty() {
    final parseResult = parseStringWithErrors(r'''
final x = f(0, 1);
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('(0');
    final nodeList = argumentList.arguments;
    final first = nodeList[0];
    expect(nodeList.beginToken, same(first.beginToken));
  }

  void test_getEndToken_empty() {
    final parseResult = parseStringWithErrors(r'''
final x = f();
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('()');
    final nodeList = argumentList.arguments;
    expect(nodeList.endToken, isNull);
  }

  void test_getEndToken_nonEmpty() {
    final parseResult = parseStringWithErrors(r'''
final x = f(0, 1);
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('(0');
    final nodeList = argumentList.arguments;
    final last = nodeList[nodeList.length - 1];
    expect(nodeList.endToken, same(last.endToken));
  }

  void test_indexOf() {
    final parseResult = parseStringWithErrors(r'''
final x = f(0, 1, 2);
final y = 42;
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('(0');
    final nodeList = argumentList.arguments;

    final first = nodeList[0];
    final second = nodeList[1];
    final third = nodeList[2];

    expect(nodeList, hasLength(3));
    expect(nodeList.indexOf(first), 0);
    expect(nodeList.indexOf(second), 1);
    expect(nodeList.indexOf(third), 2);

    final notInList = parseResult.findNode.integerLiteral('42');
    expect(nodeList.indexOf(notInList), -1);
  }

  void test_set_negative() {
    final parseResult = parseStringWithErrors(r'''
final x = f(0);
final y = 42;
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('(0');
    final nodeList = argumentList.arguments;

    try {
      nodeList[-1] = nodeList.first;
      fail("Expected IndexOutOfBoundsException");
    } on RangeError {
      // Expected
    }
  }

  void test_set_tooBig() {
    final parseResult = parseStringWithErrors(r'''
final x = f(0);
final y = 42;
''');
    parseResult.assertNoErrors();

    final argumentList = parseResult.findNode.argumentList('(0');
    final nodeList = argumentList.arguments;
    try {
      nodeList[1] = nodeList.first;
      fail("Expected IndexOutOfBoundsException");
    } on RangeError {
      // Expected
    }
  }
}

@reflectiveTest
class NormalFormalParameterTest extends ParserTestCase {
  test_sortedCommentAndAnnotations_noComment() {
    var result = parseString(content: '''
void f(int i) {}
''');
    var function = result.unit.declarations[0] as FunctionDeclaration;
    var parameters = function.functionExpression.parameters;
    var parameter = parameters?.parameters[0] as NormalFormalParameter;
    expect(parameter.sortedCommentAndAnnotations, isEmpty);
  }
}

@reflectiveTest
class OnClauseImplTest extends ParserDiagnosticsTest {
  void test_endToken_invalidClass() {
    final parseResult = parseStringWithErrors('''
mixin M on C Function() {}
class C {}
''');
    final node = parseResult.findNode.mixinDeclaration('M');
    expect(node.onClause!.endToken, isNotNull);
  }
}

@reflectiveTest
class PreviousTokenTest {
  static final String contents = '''
class A {
  B foo(C c) {
    return bar;
  }
  D get baz => null;
}
E f() => g;
''';

  CompilationUnit? _unit;

  CompilationUnit get unit {
    return _unit ??= parseString(content: contents).unit;
  }

  Token findToken(String lexeme) {
    Token token = unit.beginToken;
    while (!token.isEof) {
      if (token.lexeme == lexeme) {
        return token;
      }
      token = token.next!;
    }
    fail('Failed to find $lexeme');
  }

  void test_findPrevious_basic_class() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    expect(clazz.findPrevious(findToken('A'))!.lexeme, 'class');
  }

  void test_findPrevious_basic_method() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    var method = clazz.members[0] as MethodDeclaration;
    expect(method.findPrevious(findToken('foo'))!.lexeme, 'B');
  }

  void test_findPrevious_basic_statement() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    var method = clazz.members[0] as MethodDeclaration;
    var body = method.body as BlockFunctionBody;
    Statement statement = body.block.statements[0];
    expect(statement.findPrevious(findToken('bar'))!.lexeme, 'return');
    expect(statement.findPrevious(findToken(';'))!.lexeme, 'bar');
  }

  void test_findPrevious_missing() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    var method = clazz.members[0] as MethodDeclaration;
    var body = method.body as BlockFunctionBody;
    Statement statement = body.block.statements[0];

    var missing = parseString(
      content: 'missing',
      throwIfDiagnostics: false,
    ).unit.beginToken;
    expect(statement.findPrevious(missing), null);
  }

  void test_findPrevious_parent_method() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    var method = clazz.members[0] as MethodDeclaration;
    expect(method.findPrevious(findToken('B'))!.lexeme, '{');
  }

  void test_findPrevious_parent_statement() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    var method = clazz.members[0] as MethodDeclaration;
    var body = method.body as BlockFunctionBody;
    Statement statement = body.block.statements[0];
    expect(statement.findPrevious(findToken('return'))!.lexeme, '{');
  }

  void test_findPrevious_sibling_class() {
    CompilationUnitMember declaration = unit.declarations[1];
    expect(declaration.findPrevious(findToken('E'))!.lexeme, '}');
  }

  void test_findPrevious_sibling_method() {
    var clazz = unit.declarations[0] as ClassDeclaration;
    var method = clazz.members[1] as MethodDeclaration;
    expect(method.findPrevious(findToken('D'))!.lexeme, '}');
  }
}

@reflectiveTest
class PropertyAccessTest extends _AstTest {
  void test_isNullAware_cascade() {
    final findNode = _parseStringToFindNode('''
void f() {
  a..foo;
}
''');
    final invocation = findNode.propertyAccess('foo');
    expect(invocation.isNullAware, isFalse);
  }

  void test_isNullAware_cascade_true() {
    final findNode = _parseStringToFindNode('''
void f() {
  a?..foo;
}
''');
    final invocation = findNode.propertyAccess('foo');
    expect(invocation.isNullAware, isTrue);
  }

  void test_isNullAware_regularPropertyAccess() {
    final invocation = AstTestFactory.propertyAccess2(
        AstTestFactory.nullLiteral(), 'foo', TokenType.PERIOD);
    expect(invocation.isNullAware, isFalse);
  }

  void test_isNullAware_true() {
    final invocation = AstTestFactory.propertyAccess2(
        AstTestFactory.nullLiteral(), 'foo', TokenType.QUESTION_PERIOD);
    expect(invocation.isNullAware, isTrue);
  }
}

@reflectiveTest
class ShowClauseImplTest extends ParserDiagnosticsTest {
  void test_endToken_invalidClass() {
    final parseResult = parseStringWithErrors('''
import 'dart:core' show int Function();
''');
    final node = parseResult.findNode.import('import');
    expect(node.combinators[0].endToken, isNotNull);
  }
}

@reflectiveTest
class SimpleIdentifierTest extends _AstTest {
  void test_inGetterContext() {
    for (_WrapperKind wrapper in _WrapperKind.values) {
      for (_AssignmentKind assignment in _AssignmentKind.values) {
        SimpleIdentifier identifier = _createIdentifier(wrapper, assignment);
        if (assignment == _AssignmentKind.SIMPLE_LEFT &&
            wrapper != _WrapperKind.PREFIXED_LEFT &&
            wrapper != _WrapperKind.PROPERTY_LEFT) {
          if (identifier.inGetterContext()) {
            fail("Expected ${_topMostNode(identifier).toSource()} to be false");
          }
        } else {
          if (!identifier.inGetterContext()) {
            fail("Expected ${_topMostNode(identifier).toSource()} to be true");
          }
        }
      }
    }
  }

  void test_inGetterContext_constructorFieldInitializer() {
    final initializer = _parseStringToNode<ConstructorFieldInitializer>('''
class A {
  A() : ^f = 0;
}
''');
    SimpleIdentifier identifier = initializer.fieldName;
    expect(identifier.inGetterContext(), isFalse);
  }

  void test_inGetterContext_forEachLoop() {
    final parseResult = parseStringWithErrors('''
void f() {
  for (v in [0]) {}
}
''');
    final identifier = parseResult.findNode.simple('v in');
    expect(identifier.inGetterContext(), isFalse);
  }

  void test_inReferenceContext() {
    final parseResult = parseStringWithErrors('''
void f() {
  foo(id: 0);
}
final v = f(0, 1, 2);
class C {}
''');
    final identifier = parseResult.findNode.simple('id:');
    expect(identifier.inGetterContext(), isFalse);
    expect(identifier.inSetterContext(), isFalse);
  }

  void test_inSetterContext() {
    for (_WrapperKind wrapper in _WrapperKind.values) {
      for (_AssignmentKind assignment in _AssignmentKind.values) {
        SimpleIdentifier identifier = _createIdentifier(wrapper, assignment);
        if (wrapper == _WrapperKind.PREFIXED_LEFT ||
            wrapper == _WrapperKind.PROPERTY_LEFT ||
            assignment == _AssignmentKind.BINARY ||
            assignment == _AssignmentKind.COMPOUND_RIGHT ||
            assignment == _AssignmentKind.POSTFIX_BANG ||
            assignment == _AssignmentKind.PREFIX_NOT ||
            assignment == _AssignmentKind.SIMPLE_RIGHT) {
          if (identifier.inSetterContext()) {
            fail("Expected ${_topMostNode(identifier).toSource()} to be false");
          }
        } else {
          if (!identifier.inSetterContext()) {
            fail("Expected ${_topMostNode(identifier).toSource()} to be true");
          }
        }
      }
    }
  }

  void test_inSetterContext_forEachLoop() {
    final parseResult = parseStringWithErrors('''
void f() {
  for (v in [0]) {}
}
''');
    final identifier = parseResult.findNode.simple('v in');
    expect(identifier.inSetterContext(), isTrue);
  }

  void test_isQualified_inConstructorName() {
    final constructor = _parseStringToNode<ConstructorName>(r'''
final x = List<String>.^foo();
''');
    final name = constructor.name!;
    expect(name.isQualified, isTrue);
  }

  void test_isQualified_inMethodInvocation_noTarget() {
    final findNode = _parseStringToFindNode('''
void f() {
  foo(0);
}
''');
    final invocation = findNode.methodInvocation('foo');
    final identifier = invocation.methodName;
    expect(identifier.isQualified, isFalse);
  }

  void test_isQualified_inMethodInvocation_withTarget() {
    final findNode = _parseStringToFindNode('''
void f() {
  a.foo();
}
''');
    final invocation = findNode.methodInvocation('foo');
    final identifier = invocation.methodName;
    expect(identifier.isQualified, isTrue);
  }

  void test_isQualified_inPrefixedIdentifier_name() {
    SimpleIdentifier identifier = AstTestFactory.identifier3("test");
    AstTestFactory.identifier4("prefix", identifier);
    expect(identifier.isQualified, isTrue);
  }

  void test_isQualified_inPrefixedIdentifier_prefix() {
    SimpleIdentifier identifier = AstTestFactory.identifier3("test");
    AstTestFactory.identifier(identifier, AstTestFactory.identifier3("name"));
    expect(identifier.isQualified, isFalse);
  }

  void test_isQualified_inPropertyAccess_name() {
    SimpleIdentifier identifier = AstTestFactory.identifier3("test");
    AstTestFactory.propertyAccess(
        AstTestFactory.identifier3("target"), identifier);
    expect(identifier.isQualified, isTrue);
  }

  void test_isQualified_inPropertyAccess_target() {
    SimpleIdentifier identifier = AstTestFactory.identifier3("test");
    AstTestFactory.propertyAccess(
        identifier, AstTestFactory.identifier3("name"));
    expect(identifier.isQualified, isFalse);
  }

  void test_isQualified_inReturnStatement() {
    SimpleIdentifier identifier = AstTestFactory.identifier3("test");
    AstTestFactory.returnStatement2(identifier);
    expect(identifier.isQualified, isFalse);
  }

  SimpleIdentifier _createIdentifier(
      _WrapperKind wrapper, _AssignmentKind assignment) {
    var identifier = AstTestFactory.identifier3("a");
    ExpressionImpl expression = identifier;
    while (true) {
      if (wrapper == _WrapperKind.PREFIXED_LEFT) {
        expression = AstTestFactory.identifier(
            identifier, AstTestFactory.identifier3("_"));
      } else if (wrapper == _WrapperKind.PREFIXED_RIGHT) {
        expression = AstTestFactory.identifier(
            AstTestFactory.identifier3("_"), identifier);
      } else if (wrapper == _WrapperKind.PROPERTY_LEFT) {
        expression = AstTestFactory.propertyAccess2(expression, "_");
      } else if (wrapper == _WrapperKind.PROPERTY_RIGHT) {
        expression = AstTestFactory.propertyAccess(
            AstTestFactory.identifier3("_"), identifier);
      } else {
        throw UnimplementedError();
      }
      break;
    }
    while (true) {
      if (assignment == _AssignmentKind.BINARY) {
        BinaryExpressionImpl(
          leftOperand: expression,
          operator: TokenFactory.tokenFromType(TokenType.PLUS),
          rightOperand: AstTestFactory.identifier3("_"),
        );
      } else if (assignment == _AssignmentKind.COMPOUND_LEFT) {
        AstTestFactory.assignmentExpression(
            expression, TokenType.PLUS_EQ, AstTestFactory.identifier3("_"));
      } else if (assignment == _AssignmentKind.COMPOUND_RIGHT) {
        AstTestFactory.assignmentExpression(
            AstTestFactory.identifier3("_"), TokenType.PLUS_EQ, expression);
      } else if (assignment == _AssignmentKind.POSTFIX_BANG) {
        AstTestFactory.postfixExpression(expression, TokenType.BANG);
      } else if (assignment == _AssignmentKind.POSTFIX_INC) {
        AstTestFactory.postfixExpression(expression, TokenType.PLUS_PLUS);
      } else if (assignment == _AssignmentKind.PREFIX_DEC) {
        AstTestFactory.prefixExpression(TokenType.MINUS_MINUS, expression);
      } else if (assignment == _AssignmentKind.PREFIX_INC) {
        AstTestFactory.prefixExpression(TokenType.PLUS_PLUS, expression);
      } else if (assignment == _AssignmentKind.PREFIX_NOT) {
        AstTestFactory.prefixExpression(TokenType.BANG, expression);
      } else if (assignment == _AssignmentKind.SIMPLE_LEFT) {
        AstTestFactory.assignmentExpression(
            expression, TokenType.EQ, AstTestFactory.identifier3("_"));
      } else if (assignment == _AssignmentKind.SIMPLE_RIGHT) {
        AstTestFactory.assignmentExpression(
            AstTestFactory.identifier3("_"), TokenType.EQ, expression);
      } else {
        throw UnimplementedError();
      }
      break;
    }
    return identifier;
  }

  /// Return the top-most node in the AST structure containing the given
  /// identifier.
  ///
  /// @param identifier the identifier in the AST structure being traversed
  /// @return the root of the AST structure containing the identifier
  AstNode _topMostNode(SimpleIdentifier identifier) {
    AstNode child = identifier;
    var parent = identifier.parent;
    while (parent != null) {
      child = parent;
      parent = parent.parent;
    }
    return child;
  }
}

@reflectiveTest
class SimpleStringLiteralTest extends ParserTestCase {
  void test_contentsEnd() {
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'X'"), "X")
            .contentsEnd,
        2);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString('"X"'), "X")
            .contentsEnd,
        2);

    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString('"""X"""'), "X")
            .contentsEnd,
        4);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'''X'''"), "X")
            .contentsEnd,
        4);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("'''  \nX'''"), "X")
            .contentsEnd,
        7);

    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'X'"), "X")
            .contentsEnd,
        3);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString('r"X"'), "X")
            .contentsEnd,
        3);

    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString('r"""X"""'), "X")
            .contentsEnd,
        5);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'''X'''"), "X")
            .contentsEnd,
        5);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("r'''  \nX'''"), "X")
            .contentsEnd,
        8);
  }

  void test_contentsOffset() {
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'X'"), "X")
            .contentsOffset,
        1);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("\"X\""), "X")
            .contentsOffset,
        1);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("\"\"\"X\"\"\""), "X")
            .contentsOffset,
        3);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'''X'''"), "X")
            .contentsOffset,
        3);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'X'"), "X")
            .contentsOffset,
        2);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r\"X\""), "X")
            .contentsOffset,
        2);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("r\"\"\"X\"\"\""), "X")
            .contentsOffset,
        4);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'''X'''"), "X")
            .contentsOffset,
        4);
    // leading whitespace
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("'''  \nX''"), "X")
            .contentsOffset,
        6);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString('r"""  \nX"""'), "X")
            .contentsOffset,
        7);
  }

  void test_isMultiline() {
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'X'"), "X")
            .isMultiline,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'X'"), "X")
            .isMultiline,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("\"X\""), "X")
            .isMultiline,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r\"X\""), "X")
            .isMultiline,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'''X'''"), "X")
            .isMultiline,
        isTrue);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'''X'''"), "X")
            .isMultiline,
        isTrue);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("\"\"\"X\"\"\""), "X")
            .isMultiline,
        isTrue);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("r\"\"\"X\"\"\""), "X")
            .isMultiline,
        isTrue);
  }

  void test_isRaw() {
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'X'"), "X")
            .isRaw,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("\"X\""), "X")
            .isRaw,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("\"\"\"X\"\"\""), "X")
            .isRaw,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("'''X'''"), "X")
            .isRaw,
        isFalse);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'X'"), "X")
            .isRaw,
        isTrue);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r\"X\""), "X")
            .isRaw,
        isTrue);
    expect(
        astFactory
            .simpleStringLiteral(
                TokenFactory.tokenFromString("r\"\"\"X\"\"\""), "X")
            .isRaw,
        isTrue);
    expect(
        astFactory
            .simpleStringLiteral(TokenFactory.tokenFromString("r'''X'''"), "X")
            .isRaw,
        isTrue);
  }

  void test_isSingleQuoted() {
    // '
    {
      var token = TokenFactory.tokenFromString("'X'");
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isTrue);
    }
    // '''
    {
      var token = TokenFactory.tokenFromString("'''X'''");
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isTrue);
    }
    // "
    {
      var token = TokenFactory.tokenFromString('"X"');
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isFalse);
    }
    // """
    {
      var token = TokenFactory.tokenFromString('"""X"""');
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isFalse);
    }
  }

  void test_isSingleQuoted_raw() {
    // r'
    {
      var token = TokenFactory.tokenFromString("r'X'");
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isTrue);
    }
    // r'''
    {
      var token = TokenFactory.tokenFromString("r'''X'''");
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isTrue);
    }
    // r"
    {
      var token = TokenFactory.tokenFromString('r"X"');
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isFalse);
    }
    // r"""
    {
      var token = TokenFactory.tokenFromString('r"""X"""');
      var node = astFactory.simpleStringLiteral(token, 'X');
      expect(node.isSingleQuoted, isFalse);
    }
  }

  void test_simple() {
    Token token = TokenFactory.tokenFromString("'value'");
    SimpleStringLiteral stringLiteral =
        astFactory.simpleStringLiteral(token, "value");
    expect(stringLiteral.literal, same(token));
    expect(stringLiteral.beginToken, same(token));
    expect(stringLiteral.endToken, same(token));
    expect(stringLiteral.value, "value");
  }
}

@reflectiveTest
class SpreadElementTest extends ParserTestCase {
  void test_notNullAwareSpread() {
    final spread = AstTestFactory.spreadElement(
        TokenType.PERIOD_PERIOD_PERIOD, AstTestFactory.nullLiteral());
    expect(spread.isNullAware, isFalse);
  }

  void test_nullAwareSpread() {
    final spread = AstTestFactory.spreadElement(
        TokenType.PERIOD_PERIOD_PERIOD_QUESTION, AstTestFactory.nullLiteral());
    expect(spread.isNullAware, isTrue);
  }
}

@reflectiveTest
class StringInterpolationTest extends ParserDiagnosticsTest {
  void test_contentsOffsetEnd() {
    {
      final parseResult = parseStringWithErrors(r'''
final v = 'a${bb}ccc';
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.contentsOffset, 11);
      expect(node.contentsEnd, 20);
    }

    {
      final parseResult = parseStringWithErrors(r"""
final v = '''a${bb}ccc''';
""");
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.contentsOffset, 13);
      expect(node.contentsEnd, 22);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = """a${bb}ccc""";
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.contentsOffset, 13);
      expect(node.contentsEnd, 22);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = r'a${bb}ccc';
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.simpleStringLiteral('ccc');
      expect(node.contentsOffset, 12);
      expect(node.contentsEnd, 21);
    }

    {
      final parseResult = parseStringWithErrors(r"""
final v = r'''a${bb}ccc''';
""");
      parseResult.assertNoErrors();
      final node = parseResult.findNode.simpleStringLiteral('ccc');
      expect(node.contentsOffset, 14);
      expect(node.contentsEnd, 23);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = r"""a${bb}ccc""";
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.simpleStringLiteral('ccc');
      expect(node.contentsOffset, 14);
      expect(node.contentsEnd, 23);
    }
  }

  void test_isMultiline() {
    {
      final parseResult = parseStringWithErrors(r'''
final v = 'a${bb}ccc';
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isMultiline, isFalse);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = "a${bb}ccc";
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isMultiline, isFalse);
    }

    {
      final parseResult = parseStringWithErrors(r"""
final v = '''a${bb}ccc''';
""");
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isMultiline, isTrue);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = """a${bb}ccc""";
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isMultiline, isTrue);
    }
  }

  void test_isRaw() {
    final parseResult = parseStringWithErrors(r'''
final v = 'a${bb}ccc';
''');
    parseResult.assertNoErrors();
    final node = parseResult.findNode.stringInterpolation('ccc');
    expect(node.isRaw, isFalse);
  }

  void test_isSingleQuoted() {
    {
      final parseResult = parseStringWithErrors(r'''
final v = 'a${bb}ccc';
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isSingleQuoted, isTrue);
    }

    {
      final parseResult = parseStringWithErrors(r"""
final v = '''a${bb}ccc''';
""");
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isSingleQuoted, isTrue);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = "a${bb}ccc";
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isSingleQuoted, isFalse);
    }

    {
      final parseResult = parseStringWithErrors(r'''
final v = """a${bb}ccc""";
''');
      parseResult.assertNoErrors();
      final node = parseResult.findNode.stringInterpolation('ccc');
      expect(node.isSingleQuoted, isFalse);
    }
  }
}

@reflectiveTest
// TODO(srawlins): Re-enable?
// ignore: unreachable_from_main
class SuperFormalParameterTest {
  void test_endToken_noParameters() {
    SuperFormalParameter parameter =
        AstTestFactory.superFormalParameter2('field');
    expect(parameter.endToken, parameter.name);
  }

  void test_endToken_parameters() {
    SuperFormalParameter parameter = AstTestFactory.superFormalParameter(
        null, null, 'field', AstTestFactory.formalParameterList([]));
    expect(parameter.endToken, parameter.parameters!.endToken);
  }
}

@reflectiveTest
class VariableDeclarationTest extends ParserTestCase {
  void test_getDocumentationComment_onGrandParent() {
    VariableDeclaration varDecl = AstTestFactory.variableDeclaration("a");
    var decl =
        AstTestFactory.topLevelVariableDeclaration2(Keyword.VAR, [varDecl]);
    Comment comment = astFactory.documentationComment([]);
    expect(varDecl.documentationComment, isNull);
    decl.documentationComment = comment;
    expect(varDecl.documentationComment, isNotNull);
    expect(decl.documentationComment, isNotNull);
  }

  void test_getDocumentationComment_onNode() {
    var decl = AstTestFactory.variableDeclaration("a");
    Comment comment = astFactory.documentationComment([]);
    decl.documentationComment = comment;
    expect(decl.documentationComment, isNotNull);
  }

  test_sortedCommentAndAnnotations_noComment() {
    var result = parseString(content: '''
int i = 0;
''');
    var variables = result.unit.declarations[0] as TopLevelVariableDeclaration;
    var variable = variables.variables.variables[0];
    expect(variable.sortedCommentAndAnnotations, isEmpty);
  }
}

@reflectiveTest
class WithClauseImplTest extends ParserDiagnosticsTest {
  void test_endToken_invalidClass() {
    final parseResult = parseStringWithErrors('''
class A with C Function() {}
class C {}
''');
    final node = parseResult.findNode.classDeclaration('A');
    expect(node.withClause!.endToken, isNotNull);
  }
}

class _AssignmentKind {
  static const _AssignmentKind BINARY = _AssignmentKind('BINARY', 0);

  static const _AssignmentKind COMPOUND_LEFT =
      _AssignmentKind('COMPOUND_LEFT', 1);

  static const _AssignmentKind COMPOUND_RIGHT =
      _AssignmentKind('COMPOUND_RIGHT', 2);

  static const _AssignmentKind POSTFIX_BANG = _AssignmentKind('POSTFIX_INC', 3);

  static const _AssignmentKind POSTFIX_INC = _AssignmentKind('POSTFIX_INC', 4);

  static const _AssignmentKind PREFIX_DEC = _AssignmentKind('PREFIX_DEC', 5);

  static const _AssignmentKind PREFIX_INC = _AssignmentKind('PREFIX_INC', 6);

  static const _AssignmentKind PREFIX_NOT = _AssignmentKind('PREFIX_NOT', 7);

  static const _AssignmentKind SIMPLE_LEFT = _AssignmentKind('SIMPLE_LEFT', 8);

  static const _AssignmentKind SIMPLE_RIGHT =
      _AssignmentKind('SIMPLE_RIGHT', 9);

  static const List<_AssignmentKind> values = [
    BINARY,
    COMPOUND_LEFT,
    COMPOUND_RIGHT,
    POSTFIX_BANG,
    POSTFIX_INC,
    PREFIX_DEC,
    PREFIX_INC,
    PREFIX_NOT,
    SIMPLE_LEFT,
    SIMPLE_RIGHT,
  ];

  final String name;

  final int ordinal;

  const _AssignmentKind(this.name, this.ordinal);

  @override
  int get hashCode => ordinal;

  int compareTo(_AssignmentKind other) => ordinal - other.ordinal;

  @override
  String toString() => name;
}

class _AstTest {
  ParseStringResult parseStringWithErrors(String content) {
    return parseString(
      content: content,
      featureSet: FeatureSets.latestWithExperiments,
      throwIfDiagnostics: false,
    );
  }

  FindNode _parseStringToFindNode(String content) {
    var parseResult = parseString(
      content: content,
      featureSet: FeatureSets.latestWithExperiments,
    );
    return FindNode(parseResult.content, parseResult.unit);
  }

  T _parseStringToNode<T extends AstNode>(String codeWithMark) {
    var offset = codeWithMark.indexOf('^');
    expect(offset, isNot(equals(-1)), reason: 'missing ^');

    var nextOffset = codeWithMark.indexOf('^', offset + 1);
    expect(nextOffset, equals(-1), reason: 'too many ^');

    var codeBefore = codeWithMark.substring(0, offset);
    var codeAfter = codeWithMark.substring(offset + 1);
    var code = codeBefore + codeAfter;

    var parseResult = parseString(
      content: code,
      featureSet: FeatureSets.latestWithExperiments,
    );

    var node = NodeLocator2(offset).searchWithin(parseResult.unit);
    if (node == null) {
      throw StateError('No node at $offset:\n$code');
    }

    var result = node.thisOrAncestorOfType<T>();
    if (result == null) {
      throw StateError('No node of $T at $offset:\n$code');
    }

    return result;
  }
}

class _WrapperKind {
  static const _WrapperKind PREFIXED_LEFT = _WrapperKind('PREFIXED_LEFT', 0);

  static const _WrapperKind PREFIXED_RIGHT = _WrapperKind('PREFIXED_RIGHT', 1);

  static const _WrapperKind PROPERTY_LEFT = _WrapperKind('PROPERTY_LEFT', 2);

  static const _WrapperKind PROPERTY_RIGHT = _WrapperKind('PROPERTY_RIGHT', 3);

  static const List<_WrapperKind> values = [
    PREFIXED_LEFT,
    PREFIXED_RIGHT,
    PROPERTY_LEFT,
    PROPERTY_RIGHT,
  ];

  final String name;

  final int ordinal;

  const _WrapperKind(this.name, this.ordinal);

  @override
  int get hashCode => ordinal;

  int compareTo(_WrapperKind other) => ordinal - other.ordinal;

  @override
  String toString() => name;
}
