// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.10

library types;

import 'package:kernel/ast.dart' as ir;
import '../common.dart' show failedAt, retainDataForTesting;
import '../common/metrics.dart' show Metrics;
import '../common/names.dart';
import '../common/tasks.dart' show CompilerTask;
import '../compiler.dart' show Compiler;
import '../elements/entities.dart';
import '../inferrer/engine.dart';
import '../inferrer/type_graph_inferrer.dart' show TypeGraphInferrer;
import '../js_backend/inferred_data.dart';
import '../js_model/element_map.dart';
import '../js_model/js_world.dart';
import '../js_model/locals.dart';
import '../serialization/serialization.dart';
import '../universe/selector.dart' show Selector;
import '../world.dart' show JClosedWorld;
import 'abstract_value_domain.dart';

/// Results about a single element (e.g. a method, parameter, or field)
/// produced by the global type-inference algorithm.
///
/// All queries in this class may contain results that assume whole-program
/// closed-world semantics. Any [TypeMask] for an element or node that we return
/// was inferred to be a "guaranteed type", that means, it is a type that we
/// can prove to be correct for all executions of the program.  A trivial
/// implementation would return false on all boolean properties (giving no
/// guarantees) and the `subclass of Object or null` type mask for the type
/// based queries (the runtime value could be anything).
abstract class GlobalTypeInferenceMemberResult {
  /// Deserializes a [GlobalTypeInferenceMemberResult] object from [source].
  factory GlobalTypeInferenceMemberResult.readFromDataSource(
          DataSourceReader source,
          ir.Member context,
          AbstractValueDomain abstractValueDomain) =
      GlobalTypeInferenceMemberResultImpl.readFromDataSource;

  /// Serializes this [GlobalTypeInferenceMemberResult] to [sink].
  void writeToDataSink(DataSinkWriter sink, ir.Member context,
      AbstractValueDomain abstractValueDomain);

  /// The inferred type when this result belongs to a field, null otherwise.
  AbstractValue get type;

  /// Whether the member associated with this result is only called once in one
  /// location in the entire program.
  bool get isCalledOnce;

  /// Whether the method element associated with this result always throws.
  bool get throwsAlways;

  /// The inferred return type when this result belongs to a function element.
  AbstractValue get returnType;

  /// Returns the receiver type of a node that is a property get, set, or method
  /// invocation.
  AbstractValue typeOfReceiver(ir.TreeNode node);

  /// Returns the type of the iterator in a [loop].
  AbstractValue typeOfIterator(ir.TreeNode node);

  /// Returns the type of the `moveNext` call of an iterator in a [loop].
  AbstractValue typeOfIteratorMoveNext(ir.TreeNode node);

  /// Returns the type of the `current` getter of an iterator in a [loop].
  AbstractValue typeOfIteratorCurrent(ir.TreeNode node);
}

/// Internal data used during type-inference to store intermediate results about
/// a single element.
abstract class GlobalTypeInferenceElementData {
  /// Deserializes a [GlobalTypeInferenceElementData] object from [source].
  factory GlobalTypeInferenceElementData.readFromDataSource(
          DataSourceReader source,
          ir.Member context,
          AbstractValueDomain abstractValueDomain) =
      KernelGlobalTypeInferenceElementData.readFromDataSource;

  /// Serializes this [GlobalTypeInferenceElementData] to [sink].
  void writeToDataSink(DataSinkWriter sink, ir.Member context,
      AbstractValueDomain abstractValueDomain);

  /// Compresses the inner representation by removing [AbstractValue] mappings
  /// to `null`. Returns the data object itself or `null` if the data object
  /// was empty after compression.
  GlobalTypeInferenceElementData compress();

  // TODO(johnniwinther): Remove this. Maybe split by access/invoke.
  AbstractValue typeOfReceiver(ir.TreeNode node);

  AbstractValue typeOfIterator(ir.TreeNode node);

  AbstractValue typeOfIteratorMoveNext(ir.TreeNode node);

  AbstractValue typeOfIteratorCurrent(ir.TreeNode node);
}

/// API to interact with the global type-inference engine.
abstract class TypesInferrer {
  GlobalTypeInferenceResults analyzeMain(FunctionEntity element);
}

/// Results produced by the global type-inference algorithm.
///
/// All queries in this class may contain results that assume whole-program
/// closed-world semantics. Any [AbstractValue] for an element or node that we
/// return was inferred to be a "guaranteed type", that means, it is a type that
/// we can prove to be correct for all executions of the program.
abstract class GlobalTypeInferenceResults {
  /// Deserializes a [GlobalTypeInferenceResults] object from [source].
  factory GlobalTypeInferenceResults.readFromDataSource(
      DataSourceReader source,
      JsToElementMap elementMap,
      JClosedWorld closedWorld,
      GlobalLocalsMap globalLocalsMap,
      InferredData inferredData) {
    bool isTrivial = source.readBool();
    if (isTrivial) {
      return TrivialGlobalTypeInferenceResults(closedWorld, globalLocalsMap);
    }
    return GlobalTypeInferenceResultsImpl.readFromDataSource(
        source, elementMap, closedWorld, globalLocalsMap, inferredData);
  }

  /// Serializes this [GlobalTypeInferenceResults] to [sink].
  void writeToDataSink(DataSinkWriter sink, JsToElementMap elementMap);

  JClosedWorld get closedWorld;

  GlobalLocalsMap get globalLocalsMap;

  InferredData get inferredData;

  GlobalTypeInferenceMemberResult resultOfMember(MemberEntity member);

  AbstractValue resultOfParameter(Local parameter);

  /// Returns the type of the result of applying [selector] to a receiver with
  /// the given [receiver] type.
  AbstractValue resultTypeOfSelector(Selector selector, AbstractValue receiver);

  /// Returns the type of a list new expression [node].  Returns `null` if
  /// [node] does not represent the construction of a new list.
  AbstractValue typeOfNewList(ir.TreeNode node);

  /// Returns the type of a list literal [node].
  AbstractValue typeOfListLiteral(ir.TreeNode node);
}

/// Global analysis that infers concrete types.
class GlobalTypeInferenceTask extends CompilerTask {
  // TODO(sigmund): rename at the same time as our benchmarking tools.
  @override
  final String name = 'Type inference';

  final Compiler compiler;

  /// The [TypeGraphInferrer] used by the global type inference. This should by
  /// accessed from outside this class for testing only.
  TypeGraphInferrer typesInferrerInternal;

  GlobalTypeInferenceResults resultsForTesting;

  Metrics _metrics;

  GlobalTypeInferenceTask(Compiler compiler)
      : compiler = compiler,
        super(compiler.measurer);

  @override
  Metrics get metrics => _metrics;

  /// Runs the global type-inference algorithm once.
  GlobalTypeInferenceResults runGlobalTypeInference(
      FunctionEntity mainElement,
      JClosedWorld closedWorld,
      GlobalLocalsMap globalLocalsMap,
      InferredDataBuilder inferredDataBuilder) {
    return measure(() {
      GlobalTypeInferenceResults results;
      if (compiler.disableTypeInference) {
        results =
            TrivialGlobalTypeInferenceResults(closedWorld, globalLocalsMap);
        _metrics = Metrics.none();
      } else {
        typesInferrerInternal ??= compiler.backendStrategy.createTypesInferrer(
            closedWorld, globalLocalsMap, inferredDataBuilder);
        results = typesInferrerInternal.analyzeMain(mainElement);
        _metrics = typesInferrerInternal.metrics;
      }
      closedWorld.noSuchMethodData.categorizeComplexImplementations(results);
      if (retainDataForTesting) {
        resultsForTesting = results;
      }
      return results;
    });
  }
}

class GlobalTypeInferenceResultsImpl implements GlobalTypeInferenceResults {
  /// Tag used for identifying serialized [GlobalTypeInferenceResults] objects
  /// in a debugging data stream.
  static const String tag = 'global-type-inference-results';

  @override
  final JClosedWorld closedWorld;
  @override
  final GlobalLocalsMap globalLocalsMap;
  @override
  final InferredData inferredData;
  final GlobalTypeInferenceMemberResult _deadFieldResult;
  final GlobalTypeInferenceMemberResult _deadMethodResult;
  final AbstractValue _trivialParameterResult;

  final Map<MemberEntity, GlobalTypeInferenceMemberResult> memberResults;
  final Map<Local, AbstractValue> parameterResults;
  final Set<Selector> returnsListElementTypeSet;
  final Map<ir.TreeNode, AbstractValue> _allocatedLists;

  GlobalTypeInferenceResultsImpl(
      this.closedWorld,
      this.globalLocalsMap,
      this.inferredData,
      this.memberResults,
      this.parameterResults,
      this.returnsListElementTypeSet,
      this._allocatedLists)
      : _deadFieldResult =
            DeadFieldGlobalTypeInferenceResult(closedWorld.abstractValueDomain),
        _deadMethodResult = DeadMethodGlobalTypeInferenceResult(
            closedWorld.abstractValueDomain),
        _trivialParameterResult = closedWorld.abstractValueDomain.dynamicType;

  factory GlobalTypeInferenceResultsImpl.readFromDataSource(
      DataSourceReader source,
      JsToElementMap elementMap,
      JClosedWorld closedWorld,
      GlobalLocalsMap globalLocalsMap,
      InferredData inferredData) {
    source.registerLocalLookup(LocalLookupImpl(globalLocalsMap));

    source.begin(tag);
    Map<MemberEntity, GlobalTypeInferenceMemberResult> memberResults =
        source.readMemberMap((MemberEntity member) =>
            GlobalTypeInferenceMemberResult.readFromDataSource(
                source,
                elementMap.getMemberContextNode(member),
                closedWorld.abstractValueDomain));
    Map<Local, AbstractValue> parameterResults = source.readLocalMap(() =>
        closedWorld.abstractValueDomain
            .readAbstractValueFromDataSource(source));
    Set<Selector> returnsListElementTypeSet =
        source.readList(() => Selector.readFromDataSource(source)).toSet();
    Map<ir.TreeNode, AbstractValue> allocatedLists = source.readTreeNodeMap(
        () => closedWorld.abstractValueDomain
            .readAbstractValueFromDataSource(source));
    source.end(tag);
    return GlobalTypeInferenceResultsImpl(
        closedWorld,
        globalLocalsMap,
        inferredData,
        memberResults,
        parameterResults,
        returnsListElementTypeSet,
        allocatedLists);
  }

  @override
  void writeToDataSink(DataSinkWriter sink, JsToElementMap elementMap) {
    sink.writeBool(false); // Is _not_ trivial.
    sink.begin(tag);
    sink.writeMemberMap(
        memberResults,
        (MemberEntity member, GlobalTypeInferenceMemberResult result) =>
            result.writeToDataSink(
                sink,
                elementMap.getMemberContextNode(member),
                closedWorld.abstractValueDomain));
    sink.writeLocalMap(
        parameterResults,
        (AbstractValue value) => closedWorld.abstractValueDomain
            .writeAbstractValueToDataSink(sink, value));
    sink.writeList(returnsListElementTypeSet,
        (Selector selector) => selector.writeToDataSink(sink));
    sink.writeTreeNodeMap(
        _allocatedLists,
        (AbstractValue value) => closedWorld.abstractValueDomain
            .writeAbstractValueToDataSink(sink, value));
    sink.end(tag);
  }

  @override
  GlobalTypeInferenceMemberResult resultOfMember(MemberEntity member) {
    assert(
        member is! ConstructorBodyEntity,
        failedAt(
            member,
            "unexpected input: ConstructorBodyElements are created"
            " after global type inference, no data is avaiable for them."));
    // TODO(sigmund,johnniwinther): Make it an error to query for results that
    // don't exist..
    /*assert(memberResults.containsKey(member) || member is JSignatureMethod,
        "No inference result for member $member");*/
    return memberResults[member] ??
        (member is FunctionEntity ? _deadMethodResult : _deadFieldResult);
  }

  @override
  AbstractValue resultOfParameter(Local parameter) {
    // TODO(sigmund,johnniwinther): Make it an error to query for results that
    // don't exist.
    /*assert(parameterResults.containsKey(parameter),
        "No inference result for parameter $parameter");*/
    return parameterResults[parameter] ?? _trivialParameterResult;
  }

  @override
  AbstractValue resultTypeOfSelector(
      Selector selector, AbstractValue receiver) {
    AbstractValueDomain abstractValueDomain = closedWorld.abstractValueDomain;

    // Bailout for closure calls. We're not tracking types of closures.
    if (selector.isClosureCall) {
      // But if the receiver is not callable, the call will fail.
      if (abstractValueDomain.isEmpty(receiver).isDefinitelyTrue ||
          abstractValueDomain.isNull(receiver).isDefinitelyTrue) {
        return abstractValueDomain.emptyType;
      }
      return abstractValueDomain.dynamicType;
    }
    if (selector.isSetter || selector.isIndexSet) {
      return abstractValueDomain.dynamicType;
    }
    if (returnsListElementType(selector, receiver)) {
      return abstractValueDomain.getContainerElementType(receiver);
    }
    if (returnsMapValueType(selector, receiver)) {
      return abstractValueDomain.getMapValueType(receiver);
    }

    if (closedWorld.includesClosureCall(selector, receiver)) {
      return abstractValueDomain.dynamicType;
    } else {
      Iterable<MemberEntity> elements =
          closedWorld.locateMembers(selector, receiver);
      List<AbstractValue> types = <AbstractValue>[];
      for (MemberEntity element in elements) {
        AbstractValue type = typeOfMemberWithSelector(element, selector);
        types.add(type);
      }
      return abstractValueDomain.unionOfMany(types);
    }
  }

  bool returnsListElementType(Selector selector, AbstractValue mask) {
    return mask != null &&
        closedWorld.abstractValueDomain.isContainer(mask) &&
        returnsListElementTypeSet.contains(selector);
  }

  bool returnsMapValueType(Selector selector, AbstractValue mask) {
    return mask != null &&
        closedWorld.abstractValueDomain.isMap(mask) &&
        selector.isIndex;
  }

  AbstractValue typeOfMemberWithSelector(
      MemberEntity element, Selector selector) {
    if (element.name == Identifiers.noSuchMethod_ &&
        selector.name != element.name) {
      // An invocation can resolve to a [noSuchMethod], in which case
      // we get the return type of [noSuchMethod].
      return resultOfMember(element).returnType;
    } else if (selector.isGetter) {
      if (element.isFunction) {
        // [functionType] is null if the inferrer did not run.
        return closedWorld.abstractValueDomain.functionType;
      } else if (element.isField) {
        return resultOfMember(element).type;
      } else if (element.isGetter) {
        return resultOfMember(element).returnType;
      } else {
        assert(false, failedAt(element, "Unexpected member $element"));
        return closedWorld.abstractValueDomain.dynamicType;
      }
    } else if (element.isGetter || element.isField) {
      assert(selector.isCall || selector.isSetter);
      return closedWorld.abstractValueDomain.dynamicType;
    } else {
      return resultOfMember(element).returnType;
    }
  }

  @override
  AbstractValue typeOfNewList(ir.Node node) => _allocatedLists[node];

  @override
  AbstractValue typeOfListLiteral(ir.Node node) => _allocatedLists[node];
}

class GlobalTypeInferenceMemberResultImpl
    implements GlobalTypeInferenceMemberResult {
  /// Tag used for identifying serialized [GlobalTypeInferenceMemberResult]
  /// objects in a debugging data stream.
  static const String tag = 'global-type-inference-member-result';

  final GlobalTypeInferenceElementData _data;
  @override
  final AbstractValue returnType;
  @override
  final AbstractValue type;
  @override
  final bool throwsAlways;
  @override
  final bool isCalledOnce;

  GlobalTypeInferenceMemberResultImpl(this._data, this.returnType, this.type,
      {this.throwsAlways, this.isCalledOnce});

  factory GlobalTypeInferenceMemberResultImpl.readFromDataSource(
      DataSourceReader source,
      ir.Member context,
      AbstractValueDomain abstractValueDomain) {
    source.begin(tag);
    GlobalTypeInferenceElementData data = source.readValueOrNull(() {
      return GlobalTypeInferenceElementData.readFromDataSource(
          source, context, abstractValueDomain);
    });
    AbstractValue returnType =
        abstractValueDomain.readAbstractValueFromDataSource(source);
    AbstractValue type =
        abstractValueDomain.readAbstractValueFromDataSource(source);
    bool throwsAlways = source.readBool();
    bool isCalledOnce = source.readBool();
    source.end(tag);
    return GlobalTypeInferenceMemberResultImpl(data, returnType, type,
        throwsAlways: throwsAlways, isCalledOnce: isCalledOnce);
  }

  @override
  void writeToDataSink(DataSinkWriter sink, ir.Member context,
      AbstractValueDomain abstractValueDomain) {
    sink.begin(tag);
    sink.writeValueOrNull(_data, (GlobalTypeInferenceElementData data) {
      data.writeToDataSink(sink, context, abstractValueDomain);
    });
    abstractValueDomain.writeAbstractValueToDataSink(sink, returnType);
    abstractValueDomain.writeAbstractValueToDataSink(sink, type);
    sink.writeBool(throwsAlways);
    sink.writeBool(isCalledOnce);
    sink.end(tag);
  }

  @override
  AbstractValue typeOfReceiver(ir.Node node) => _data?.typeOfReceiver(node);
  @override
  AbstractValue typeOfIterator(ir.Node node) => _data?.typeOfIterator(node);
  @override
  AbstractValue typeOfIteratorMoveNext(ir.Node node) =>
      _data?.typeOfIteratorMoveNext(node);
  @override
  AbstractValue typeOfIteratorCurrent(ir.Node node) =>
      _data?.typeOfIteratorCurrent(node);
}

class TrivialGlobalTypeInferenceResults implements GlobalTypeInferenceResults {
  @override
  final JClosedWorld closedWorld;
  final TrivialGlobalTypeInferenceMemberResult _trivialMemberResult;
  final AbstractValue _trivialParameterResult;
  @override
  final InferredData inferredData = TrivialInferredData();
  @override
  final GlobalLocalsMap globalLocalsMap;

  TrivialGlobalTypeInferenceResults(this.closedWorld, this.globalLocalsMap)
      : _trivialMemberResult = TrivialGlobalTypeInferenceMemberResult(
            closedWorld.abstractValueDomain.dynamicType),
        _trivialParameterResult = closedWorld.abstractValueDomain.dynamicType;

  @override
  void writeToDataSink(DataSinkWriter sink, JsToElementMap elementMap) {
    sink.writeBool(true); // Is trivial.
  }

  @override
  AbstractValue resultTypeOfSelector(Selector selector, AbstractValue mask) {
    return closedWorld.abstractValueDomain.dynamicType;
  }

  @override
  AbstractValue resultOfParameter(Local parameter) {
    return _trivialParameterResult;
  }

  @override
  GlobalTypeInferenceMemberResult resultOfMember(MemberEntity member) {
    return _trivialMemberResult;
  }

  @override
  AbstractValue typeOfListLiteral(ir.TreeNode node) => null;

  @override
  AbstractValue typeOfNewList(ir.TreeNode node) => null;
}

class TrivialGlobalTypeInferenceMemberResult
    implements GlobalTypeInferenceMemberResult {
  final AbstractValue dynamicType;

  TrivialGlobalTypeInferenceMemberResult(this.dynamicType);

  @override
  AbstractValue get type => dynamicType;

  @override
  AbstractValue get returnType => dynamicType;

  @override
  bool get throwsAlways => false;

  @override
  AbstractValue typeOfIteratorCurrent(ir.Node node) => null;

  @override
  AbstractValue typeOfIteratorMoveNext(ir.Node node) => null;

  @override
  AbstractValue typeOfIterator(ir.Node node) => null;

  @override
  AbstractValue typeOfReceiver(ir.Node node) => null;

  @override
  bool get isCalledOnce => false;

  @override
  void writeToDataSink(DataSinkWriter sink, ir.Member context,
      AbstractValueDomain abstractValueDomain) {
    throw UnsupportedError(
        "TrivialGlobalTypeInferenceMemberResult.writeToDataSink");
  }
}

class DeadFieldGlobalTypeInferenceResult
    implements GlobalTypeInferenceMemberResult {
  final AbstractValue dynamicType;
  final AbstractValue emptyType;

  DeadFieldGlobalTypeInferenceResult(AbstractValueDomain domain)
      : this.dynamicType = domain.dynamicType,
        this.emptyType = domain.emptyType;

  @override
  AbstractValue get type => emptyType;

  @override
  AbstractValue get returnType => dynamicType;

  @override
  bool get throwsAlways => false;

  @override
  AbstractValue typeOfIteratorCurrent(ir.Node node) => null;

  @override
  AbstractValue typeOfIteratorMoveNext(ir.Node node) => null;

  @override
  AbstractValue typeOfIterator(ir.Node node) => null;

  @override
  AbstractValue typeOfReceiver(ir.Node node) => null;

  @override
  bool get isCalledOnce => false;

  @override
  void writeToDataSink(DataSinkWriter sink, ir.Member context,
      AbstractValueDomain abstractValueDomain) {
    throw UnsupportedError(
        "DeadFieldGlobalTypeInferenceResult.writeToDataSink");
  }
}

class DeadMethodGlobalTypeInferenceResult
    implements GlobalTypeInferenceMemberResult {
  final AbstractValue emptyType;
  final AbstractValue functionType;

  DeadMethodGlobalTypeInferenceResult(AbstractValueDomain domain)
      : this.functionType = domain.functionType,
        this.emptyType = domain.emptyType;

  @override
  AbstractValue get type => functionType;

  @override
  AbstractValue get returnType => emptyType;

  @override
  bool get throwsAlways => false;

  @override
  AbstractValue typeOfIteratorCurrent(ir.Node node) => null;

  @override
  AbstractValue typeOfIteratorMoveNext(ir.Node node) => null;

  @override
  AbstractValue typeOfIterator(ir.Node node) => null;

  @override
  AbstractValue typeOfReceiver(ir.Node node) => null;

  @override
  bool get isCalledOnce => false;

  @override
  void writeToDataSink(DataSinkWriter sink, ir.Member context,
      AbstractValueDomain abstractValueDomain) {
    throw UnsupportedError(
        "DeadFieldGlobalTypeInferenceResult.writeToDataSink");
  }
}
