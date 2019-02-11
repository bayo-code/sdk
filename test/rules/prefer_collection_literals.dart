// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// test w/ `pub run test -N prefer_collection_literals`

import 'dart:collection';

//ignore_for_file: unused_local_variable
void main() {
  var listToLint = new List(); //LINT
  var mapToLint = new Map(); // LINT
  var LinkedHashMapToLint = new LinkedHashMap(); // LINT

  var m1 = Map.unmodifiable({}); //OK
  var m2 = Map.fromIterable([]); //OK
  var m3 = Map.fromIterables([], []); //OK

  var constructedListInsideLiteralList = [[], new List()]; // LINT
  var literalListInsideLiteralList = [[], []]; // OK
  var fiveLengthList = new List(5); // OK

  var namedConstructorList = new List.filled(5, true); // OK
  var namedConstructorMap = new Map.identity(); // OK
  var namedConstructorLinkedHashMap = new LinkedHashMap.identity(); // OK

  var literalList = []; // OK
  var literalMap = {}; // OK

  Set s = new Set(); // LINT
  var s1 = new Set<int>(); // LINT
  Set<int> s2 = new Set(); // LINT
  var s3 = new Set.from(['foo', 'bar', 'baz']); // LINT
  var s4 = new Set.of(['foo', 'bar', 'baz']); // LINT

  var s5 = ['foo', 'bar', 'baz'].toSet(); // LINT

  var s6 = new LinkedHashSet.from(['foo', 'bar', 'baz']); // LINT
  var s7 = new LinkedHashSet.of(['foo', 'bar', 'baz']); // LINT
  var s8 = new LinkedHashSet.from(<int>[]); // LINT
  var s9 = new Set<int>.from([]); // LINT

  var is1 = new Set.identity(); // OK
  var is2 = new LinkedHashSet.identity(); // OK

  var ss1 = new Set(); // LINT
  var ss2 = new LinkedHashSet(); // LINT
  var ss3 = LinkedHashSet.from([]); // LINT
  var ss4 = LinkedHashSet.of([]); // LINT

  Iterable iter = Iterable.empty();
  var ss5 = Set.from(iter); //OK
}
