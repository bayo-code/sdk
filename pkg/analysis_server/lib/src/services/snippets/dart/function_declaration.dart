// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/src/services/snippets/snippet.dart';
import 'package:analysis_server/src/services/snippets/snippet_producer.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';

/// Produces a [Snippet] that creates a function definition.
class FunctionDeclaration extends DartSnippetProducer {
  static const prefix = 'fun';
  static const label = 'fun';

  FunctionDeclaration(super.request);

  @override
  Future<Snippet> compute() async {
    final builder = ChangeBuilder(session: request.analysisSession);
    final indent = utils.getLinePrefix(request.offset);

    await builder.addDartFileEdit(request.filePath, (builder) {
      builder.addReplacement(request.replacementRange, (builder) {
        void writeIndented(String string) => builder.write('$indent$string');

        builder.addSimpleLinkedEdit('returnType', 'void');
        builder.write(' ');
        builder.addSimpleLinkedEdit('name', 'name');
        builder.write('(');
        builder.addSimpleLinkedEdit('params', 'params');
        builder.writeln(') {');
        writeIndented('  ');
        builder.selectHere();
        builder.writeln();
        writeIndented('}');
      });
    });

    return Snippet(
      prefix,
      label,
      'Insert a function definition.',
      builder.sourceChange,
    );
  }
}
