// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'argument_list_test.dart' as argument_list;
import 'as_expression_test.dart' as as_expression;
import 'assert_initializer_test.dart' as assert_initializer;
import 'assert_statement_test.dart' as assert_statement;
import 'assignment_expression_test.dart' as assignment_expression;
import 'block_test.dart' as block;
import 'case_clause_test.dart' as case_clause;
import 'cast_pattern_test.dart' as cast_pattern;
import 'catch_clause_test.dart' as catch_clause;
import 'class_body_test.dart' as class_body;
import 'class_declaration_test.dart' as class_declaration;
import 'compilation_unit_member_test.dart' as compilation_unit_member;
import 'compilation_unit_test.dart' as compilation_unit;
import 'conditional_expression_test.dart' as conditional_expression;
import 'constructor_declaration_test.dart' as constructor_declaration;
import 'constructor_invocation_test.dart' as constructor_invocation;
import 'directive_uri_test.dart' as directive_uri;
import 'enum_constant_test.dart' as enum_constant;
import 'enum_declaration_test.dart' as enum_declaration;
import 'extends_clause_test.dart' as extends_clause;
import 'extension_body_test.dart' as extension_body;
import 'extension_declaration_test.dart' as extension_declaration;
import 'extension_type_declaration_test.dart' as extension_type_declaration;
import 'field_declaration_test.dart' as field_declaration;
import 'field_formal_parameter_test.dart' as field_formal_parameter;
import 'for_element_test.dart' as for_element;
import 'for_statement_test.dart' as for_statement;
import 'function_declaration_test.dart' as function_declaration;
import 'function_expression_test.dart' as function_expression;
import 'if_element_test.dart' as if_element;
import 'if_statement_test.dart' as if_statement;
import 'implements_clause_test.dart' as implements_clause;
import 'import_directive_test.dart' as import_directive;
import 'index_expression_test.dart' as index_expression;
import 'instance_creation_expression_test.dart' as instance_creation_expression;
import 'is_expression_test.dart' as is_expression;
import 'library_directive_test.dart' as library_directive;
import 'list_literal_test.dart' as list_literal;
import 'list_pattern_test.dart' as list_pattern;
import 'logical_and_pattern_test.dart' as logical_and_pattern;
import 'logical_or_pattern_test.dart' as logical_or_pattern;
import 'map_literal_test.dart' as map_literal;
import 'map_pattern_test.dart' as map_pattern;
import 'method_declaration_test.dart' as method_declaration;
import 'method_invocation_test.dart' as method_invocation;
import 'mixin_declaration_test.dart' as mixin_declaration;
import 'named_expression_test.dart' as named_expression;
import 'named_type_test.dart' as named_type;
import 'object_pattern_test.dart' as object_pattern;
import 'parameter_list_test.dart' as parameter_list;
import 'parenthesized_pattern_test.dart' as parenthesized_pattern;
import 'pattern_assignment_test.dart' as pattern_assignment;
import 'pattern_variable_declaration_test.dart' as pattern_variable_declaration;
import 'property_access_expression_test.dart' as property_access_expression;
import 'record_literal_test.dart' as record_literal;
import 'record_pattern_test.dart' as record_pattern;
import 'record_type_annotation_test.dart' as record_type_annotation;
import 'redirecting_constructor_invocation_test.dart'
    as redirecting_constructor_invocation;
import 'relational_pattern_test.dart' as relational_pattern;
import 'rest_pattern_test.dart' as rest_pattern;
import 'return_statement_test.dart' as return_statement;
import 'set_literal_test.dart' as set_literal;
import 'string_literal_test.dart' as string_literal;
import 'super_constructor_invocation_test.dart' as super_constructor_invocation;
import 'super_formal_parameter_test.dart' as super_formal_parameter;
import 'switch_expression_test.dart' as switch_expression;
import 'switch_pattern_case_test.dart' as switch_pattern_case;
import 'switch_statement_test.dart' as switch_statement;
import 'try_statement_test.dart' as try_statement;
import 'type_argument_list_test.dart' as type_argument_list;
import 'type_test_test.dart' as type_test;
import 'variable_declaration_list_test.dart' as variable_declaration_list;
import 'with_clause_test.dart' as with_clause;

/// Tests suggestions produced at specific locations.
void main() {
  defineReflectiveSuite(() {
    argument_list.main();
    as_expression.main();
    assert_initializer.main();
    assert_statement.main();
    assignment_expression.main();
    block.main();
    case_clause.main();
    cast_pattern.main();
    catch_clause.main();
    class_body.main();
    class_declaration.main();
    compilation_unit_member.main();
    compilation_unit.main();
    conditional_expression.main();
    constructor_declaration.main();
    constructor_invocation.main();
    directive_uri.main();
    enum_constant.main();
    enum_declaration.main();
    extends_clause.main();
    extension_body.main();
    extension_declaration.main();
    extension_type_declaration.main();
    field_declaration.main();
    field_formal_parameter.main();
    for_element.main();
    for_statement.main();
    function_declaration.main();
    function_expression.main();
    if_element.main();
    if_statement.main();
    implements_clause.main();
    import_directive.main();
    index_expression.main();
    instance_creation_expression.main();
    is_expression.main();
    library_directive.main();
    list_literal.main();
    list_pattern.main();
    logical_and_pattern.main();
    logical_or_pattern.main();
    map_literal.main();
    map_pattern.main();
    method_declaration.main();
    method_invocation.main();
    mixin_declaration.main();
    named_expression.main();
    named_type.main();
    object_pattern.main();
    parameter_list.main();
    parenthesized_pattern.main();
    pattern_assignment.main();
    pattern_variable_declaration.main();
    property_access_expression.main();
    record_literal.main();
    record_pattern.main();
    record_type_annotation.main();
    redirecting_constructor_invocation.main();
    relational_pattern.main();
    rest_pattern.main();
    return_statement.main();
    set_literal.main();
    string_literal.main();
    super_constructor_invocation.main();
    super_formal_parameter.main();
    switch_expression.main();
    switch_pattern_case.main();
    switch_statement.main();
    try_statement.main();
    type_argument_list.main();
    type_test.main();
    variable_declaration_list.main();
    with_clause.main();
  });
}
