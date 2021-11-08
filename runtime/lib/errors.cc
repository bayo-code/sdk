// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/bootstrap_natives.h"
#include "vm/exceptions.h"
#include "vm/object_store.h"
#include "vm/runtime_entry.h"
#include "vm/stack_frame.h"
#include "vm/symbols.h"

namespace dart {

// Scan the stack until we hit the first function in the _AssertionError
// class. We then return the next frame's script taking inlining into account.
static ScriptPtr FindScript(DartFrameIterator* iterator) {
#if defined(DART_PRECOMPILED_RUNTIME)
  // The precompiled runtime faces two issues in recovering the correct
  // assertion text. First, the precompiled runtime does not include
  // the inlining meta-data so we cannot walk the inline-aware stack trace.
  // Second, the script text itself is missing so whatever script is returned
  // from here will be missing the assertion expression text.
  iterator->NextFrame();  // Skip _AssertionError._evaluateAssertion frame
  return Exceptions::GetCallerScript(iterator);
#else
  StackFrame* stack_frame = iterator->NextFrame();
  Code& code = Code::Handle();
  Function& func = Function::Handle();
  const Class& assert_error_class =
      Class::Handle(Library::LookupCoreClass(Symbols::AssertionError()));
  ASSERT(!assert_error_class.IsNull());
  bool hit_assertion_error = false;
  for (; stack_frame != NULL; stack_frame = iterator->NextFrame()) {
    code = stack_frame->LookupDartCode();
    if (code.is_optimized()) {
      InlinedFunctionsIterator inlined_iterator(code, stack_frame->pc());
      while (!inlined_iterator.Done()) {
        func = inlined_iterator.function();
        if (hit_assertion_error) {
          return func.script();
        }
        ASSERT(!hit_assertion_error);
        hit_assertion_error = (func.Owner() == assert_error_class.ptr());
        inlined_iterator.Advance();
      }
      continue;
    } else {
      func = code.function();
    }
    ASSERT(!func.IsNull());
    if (hit_assertion_error) {
      return func.script();
    }
    ASSERT(!hit_assertion_error);
    hit_assertion_error = (func.Owner() == assert_error_class.ptr());
  }
  UNREACHABLE();
  return Script::null();
#endif  // defined(DART_PRECOMPILED_RUNTIME)
}

// Allocate and throw a new AssertionError.
// Arg0: index of the first token of the failed assertion.
// Arg1: index of the first token after the failed assertion.
// Arg2: Message object or null.
// Return value: none, throws an exception.
DEFINE_NATIVE_ENTRY(AssertionError_throwNew, 0, 3) {
  // No need to type check the arguments. This function can only be called
  // internally from the VM.
  const TokenPosition assertion_start = TokenPosition::Deserialize(
      Smi::CheckedHandle(zone, arguments->NativeArgAt(0)).Value());
  const TokenPosition assertion_end = TokenPosition::Deserialize(
      Smi::CheckedHandle(zone, arguments->NativeArgAt(1)).Value());

  const Instance& message =
      Instance::CheckedHandle(zone, arguments->NativeArgAt(2));
  const Array& args = Array::Handle(zone, Array::New(5));

  DartFrameIterator iterator(thread,
                             StackFrameIterator::kNoCrossThreadIteration);
  iterator.NextFrame();  // Skip native call.
  const Script& script = Script::Handle(FindScript(&iterator));

  // Initialize argument 'failed_assertion' with source snippet.
  auto& condition_text = String::Handle();
  // Extract the assertion condition text (if source is available).
  intptr_t from_line = -1, from_column = -1;
  if (script.GetTokenLocation(assertion_start, &from_line, &from_column)) {
    // Extract the assertion condition text (if source is available).
    intptr_t to_line, to_column;
    script.GetTokenLocation(assertion_end, &to_line, &to_column);
    condition_text =
        script.GetSnippet(from_line, from_column, to_line, to_column);
  }
  if (condition_text.IsNull()) {
    condition_text = Symbols::OptimizedOut().ptr();
  }
  args.SetAt(0, condition_text);

  // Initialize location arguments starting at position 1.
  args.SetAt(1, String::Handle(script.url()));
  args.SetAt(2, Smi::Handle(Smi::New(from_line)));
  args.SetAt(3, Smi::Handle(Smi::New(from_column)));
  args.SetAt(4, message);

  Exceptions::ThrowByType(Exceptions::kAssertion, args);
  UNREACHABLE();
  return Object::null();
}

// Allocate and throw a new AssertionError.
// Arg0: Source code snippet of failed assertion.
// Arg1: Line number.
// Arg2: Column number.
// Arg3: Message object or null.
// Return value: none, throws an exception.
DEFINE_NATIVE_ENTRY(AssertionError_throwNewSource, 0, 4) {
  // No need to type check the arguments. This function can only be called
  // internally from the VM.
  const String& failed_assertion =
      String::CheckedHandle(zone, arguments->NativeArgAt(0));
  const intptr_t line =
      Smi::CheckedHandle(zone, arguments->NativeArgAt(1)).Value();
  const intptr_t column =
      Smi::CheckedHandle(zone, arguments->NativeArgAt(2)).Value();
  const Instance& message =
      Instance::CheckedHandle(zone, arguments->NativeArgAt(3));

  const Array& args = Array::Handle(zone, Array::New(5));

  DartFrameIterator iterator(thread,
                             StackFrameIterator::kNoCrossThreadIteration);
  iterator.NextFrame();  // Skip native call.
  const Script& script = Script::Handle(zone, FindScript(&iterator));

  args.SetAt(0, failed_assertion);
  args.SetAt(1, String::Handle(zone, script.url()));
  args.SetAt(2, Smi::Handle(zone, Smi::New(line)));
  args.SetAt(3, Smi::Handle(zone, Smi::New(column)));
  args.SetAt(4, message);

  Exceptions::ThrowByType(Exceptions::kAssertion, args);
  UNREACHABLE();
  return Object::null();
}

// Allocate and throw a new TypeError or CastError.
// Arg0: index of the token of the failed type check.
// Arg1: src value.
// Arg2: dst type.
// Arg3: dst name.
// Return value: none, throws an exception.
DEFINE_NATIVE_ENTRY(TypeError_throwNew, 0, 4) {
  // No need to type check the arguments. This function can only be called
  // internally from the VM.
  const TokenPosition location = TokenPosition::Deserialize(
      Smi::CheckedHandle(zone, arguments->NativeArgAt(0)).Value());
  const Instance& src_value =
      Instance::CheckedHandle(zone, arguments->NativeArgAt(1));
  const AbstractType& dst_type =
      AbstractType::CheckedHandle(zone, arguments->NativeArgAt(2));
  const String& dst_name =
      String::CheckedHandle(zone, arguments->NativeArgAt(3));
  const AbstractType& src_type =
      AbstractType::Handle(src_value.GetType(Heap::kNew));
  Exceptions::CreateAndThrowTypeError(location, src_type, dst_type, dst_name);
  UNREACHABLE();
  return Object::null();
}

// Allocate and throw a new FallThroughError.
// Arg0: index of the case clause token into which we fall through.
// Return value: none, throws an exception.
DEFINE_NATIVE_ENTRY(FallThroughError_throwNew, 0, 1) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, smi_pos, arguments->NativeArgAt(0));
  TokenPosition fallthrough_pos = TokenPosition::Deserialize(smi_pos.Value());

  const Array& args = Array::Handle(Array::New(2));

  // Initialize 'url' and 'line' arguments.
  DartFrameIterator iterator(thread,
                             StackFrameIterator::kNoCrossThreadIteration);
  iterator.NextFrame();  // Skip native call.
  const Script& script = Script::Handle(Exceptions::GetCallerScript(&iterator));
  args.SetAt(0, String::Handle(script.url()));
  intptr_t line = -1;
  script.GetTokenLocation(fallthrough_pos, &line);
  args.SetAt(1, Smi::Handle(Smi::New(line)));

  Exceptions::ThrowByType(Exceptions::kFallThrough, args);
  UNREACHABLE();
  return Object::null();
}

// Allocate and throw a new AbstractClassInstantiationError.
// Arg0: Token position of allocation statement.
// Arg1: class name of the abstract class that cannot be instantiated.
// Return value: none, throws an exception.
DEFINE_NATIVE_ENTRY(AbstractClassInstantiationError_throwNew, 0, 2) {
  GET_NON_NULL_NATIVE_ARGUMENT(Smi, smi_pos, arguments->NativeArgAt(0));
  GET_NON_NULL_NATIVE_ARGUMENT(String, class_name, arguments->NativeArgAt(1));
  TokenPosition error_pos = TokenPosition::Deserialize(smi_pos.Value());

  const Array& args = Array::Handle(Array::New(3));

  // Initialize 'className', 'url' and 'line' arguments.
  DartFrameIterator iterator(thread,
                             StackFrameIterator::kNoCrossThreadIteration);
  iterator.NextFrame();  // Skip native call.
  const Script& script = Script::Handle(Exceptions::GetCallerScript(&iterator));
  args.SetAt(0, class_name);
  args.SetAt(1, String::Handle(script.url()));
  intptr_t line = -1;
  script.GetTokenLocation(error_pos, &line);
  args.SetAt(2, Smi::Handle(Smi::New(line)));

  Exceptions::ThrowByType(Exceptions::kAbstractClassInstantiation, args);
  UNREACHABLE();
  return Object::null();
}

// Rethrow an error with a stacktrace.
DEFINE_NATIVE_ENTRY(Error_throwWithStackTrace, 0, 2) {
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, error, arguments->NativeArgAt(0));
  GET_NON_NULL_NATIVE_ARGUMENT(Instance, stacktrace, arguments->NativeArgAt(1));
  Exceptions::ThrowWithStackTrace(thread, error, stacktrace);
  return Object::null();
}

}  // namespace dart
