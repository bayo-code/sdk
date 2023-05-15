// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "native_add.h"

MYLIB_EXPORT int32_t add(int32_t a, int32_t b) {
   return a + b;
}


MYLIB_EXPORT intptr_t subtract(intptr_t a, intptr_t b) {
  return a - b;
}
