// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
// @dart=2.9
main() {
  new C(42);
}

class C {
  final d;

  C() {}
  C(this.d) {}
}
