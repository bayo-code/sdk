// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../base/messages.dart';
import '../base/scope.dart';
import '../builder/builder.dart';
import '../builder/declaration_builders.dart';
import '../builder/member_builder.dart';
import '../builder/type_builder.dart';
import 'name_scheme.dart';

// The kind of type parameter scope built by a [TypeParameterScopeBuilder]
// object.
enum TypeParameterScopeKind {
  library,
  classOrNamedMixinApplication,
  classDeclaration,
  mixinDeclaration,
  unnamedMixinApplication,
  namedMixinApplication,
  extensionOrExtensionTypeDeclaration,
  extensionDeclaration,
  extensionTypeDeclaration,
  typedef,
  staticMethod,
  instanceMethod,
  constructor,
  topLevelMethod,
  factoryMethod,
  functionType,
  enumDeclaration,
}

extension TypeParameterScopeBuilderExtension on TypeParameterScopeBuilder {
  /// Returns the [ContainerName] corresponding to this type parameter scope,
  /// if any.
  ContainerName? get containerName {
    switch (kind) {
      case TypeParameterScopeKind.library:
        return null;
      case TypeParameterScopeKind.classOrNamedMixinApplication:
      case TypeParameterScopeKind.classDeclaration:
      case TypeParameterScopeKind.mixinDeclaration:
      case TypeParameterScopeKind.unnamedMixinApplication:
      case TypeParameterScopeKind.namedMixinApplication:
      case TypeParameterScopeKind.enumDeclaration:
      case TypeParameterScopeKind.extensionTypeDeclaration:
        return new ClassName(name);
      case TypeParameterScopeKind.extensionDeclaration:
        return extensionName;
      // Coverage-ignore(suite): Not run.
      case TypeParameterScopeKind.typedef:
      case TypeParameterScopeKind.staticMethod:
      case TypeParameterScopeKind.instanceMethod:
      case TypeParameterScopeKind.constructor:
      case TypeParameterScopeKind.topLevelMethod:
      case TypeParameterScopeKind.factoryMethod:
      case TypeParameterScopeKind.functionType:
      case TypeParameterScopeKind.extensionOrExtensionTypeDeclaration:
        throw new UnsupportedError("Unexpected field container: ${this}");
    }
  }

  /// Returns the [ContainerType] corresponding to this type parameter scope.
  ContainerType get containerType {
    switch (kind) {
      case TypeParameterScopeKind.library:
        return ContainerType.Library;
      case TypeParameterScopeKind.classOrNamedMixinApplication:
      case TypeParameterScopeKind.classDeclaration:
      case TypeParameterScopeKind.mixinDeclaration:
      case TypeParameterScopeKind.unnamedMixinApplication:
      case TypeParameterScopeKind.namedMixinApplication:
      case TypeParameterScopeKind.enumDeclaration:
        return ContainerType.Class;
      case TypeParameterScopeKind.extensionDeclaration:
        return ContainerType.Extension;
      case TypeParameterScopeKind.extensionTypeDeclaration:
        return ContainerType.ExtensionType;
      // Coverage-ignore(suite): Not run.
      case TypeParameterScopeKind.typedef:
      case TypeParameterScopeKind.staticMethod:
      case TypeParameterScopeKind.instanceMethod:
      case TypeParameterScopeKind.constructor:
      case TypeParameterScopeKind.topLevelMethod:
      case TypeParameterScopeKind.factoryMethod:
      case TypeParameterScopeKind.functionType:
      case TypeParameterScopeKind.extensionOrExtensionTypeDeclaration:
        throw new UnsupportedError("Unexpected field container: ${this}");
    }
  }
}

/// A builder object preparing for building declarations that can introduce type
/// parameter and/or members.
///
/// Unlike [Scope], this scope is used during construction of builders to
/// ensure types and members are added to and resolved in the correct location.
class TypeParameterScopeBuilder {
  TypeParameterScopeKind _kind;

  final TypeParameterScopeBuilder? parent;

  final Map<String, Builder>? members;

  final Map<String, MemberBuilder>? constructors;

  final Map<String, MemberBuilder>? setters;

  final Set<ExtensionBuilder>? extensions;

  final List<NamedTypeBuilder> unresolvedNamedTypes = <NamedTypeBuilder>[];

  final Map<String, List<Builder>> augmentations = <String, List<Builder>>{};

  final Map<String, List<Builder>> setterAugmentations =
      <String, List<Builder>>{};

  // TODO(johnniwinther): Stop using [_name] for determining the declaration
  // kind.
  String _name;

  ExtensionName? _extensionName;

  /// Offset of name token, updated by the outline builder along
  /// with the name as the current declaration changes.
  int _charOffset;

  List<NominalVariableBuilder>? _typeVariables;

  /// The type of `this` in instance methods declared in extension declarations.
  ///
  /// Instance methods declared in extension declarations methods are extended
  /// with a synthesized parameter of this type.
  TypeBuilder? _extensionThisType;

  bool declaresConstConstructor = false;

  TypeParameterScopeBuilder(
      this._kind,
      this.members,
      this.setters,
      this.constructors,
      this.extensions,
      this._name,
      this._charOffset,
      this.parent);

  TypeParameterScopeBuilder.library()
      : this(
            TypeParameterScopeKind.library,
            <String, Builder>{},
            <String, MemberBuilder>{},
            null,
            // No support for constructors in library scopes.
            <ExtensionBuilder>{},
            "<library>",
            -1,
            null);

  TypeParameterScopeBuilder createNested(
      TypeParameterScopeKind kind, String name, bool hasMembers) {
    return new TypeParameterScopeBuilder(
        kind,
        hasMembers ? <String, MemberBuilder>{} : null,
        hasMembers ? <String, MemberBuilder>{} : null,
        hasMembers ? <String, MemberBuilder>{} : null,
        null,
        // No support for extensions in nested scopes.
        name,
        -1,
        this);
  }

  /// Registers that this builder is preparing for a class declaration with the
  /// given [name] and [typeVariables] located [charOffset].
  void markAsClassDeclaration(String name, int charOffset,
      List<NominalVariableBuilder>? typeVariables) {
    assert(
        _kind == TypeParameterScopeKind.classOrNamedMixinApplication,
        // Coverage-ignore(suite): Not run.
        "Unexpected declaration kind: $_kind");
    _kind = TypeParameterScopeKind.classDeclaration;
    _name = name;
    _charOffset = charOffset;
    _typeVariables = typeVariables;
  }

  /// Registers that this builder is preparing for a named mixin application
  /// with the given [name] and [typeVariables] located [charOffset].
  void markAsNamedMixinApplication(String name, int charOffset,
      List<NominalVariableBuilder>? typeVariables) {
    assert(
        _kind == TypeParameterScopeKind.classOrNamedMixinApplication,
        // Coverage-ignore(suite): Not run.
        "Unexpected declaration kind: $_kind");
    _kind = TypeParameterScopeKind.namedMixinApplication;
    _name = name;
    _charOffset = charOffset;
    _typeVariables = typeVariables;
  }

  /// Registers that this builder is preparing for a mixin declaration with the
  /// given [name] and [typeVariables] located [charOffset].
  void markAsMixinDeclaration(String name, int charOffset,
      List<NominalVariableBuilder>? typeVariables) {
    // TODO(johnniwinther): Avoid using 'classOrNamedMixinApplication' for mixin
    // declaration. These are syntactically distinct so we don't need the
    // transition.
    assert(
        _kind == TypeParameterScopeKind.classOrNamedMixinApplication,
        // Coverage-ignore(suite): Not run.
        "Unexpected declaration kind: $_kind");
    _kind = TypeParameterScopeKind.mixinDeclaration;
    _name = name;
    _charOffset = charOffset;
    _typeVariables = typeVariables;
  }

  /// Registers that this builder is preparing for an extension declaration with
  /// the given [name] and [typeVariables] located [charOffset].
  void markAsExtensionDeclaration(String? name, int charOffset,
      List<NominalVariableBuilder>? typeVariables) {
    assert(
        _kind == TypeParameterScopeKind.extensionOrExtensionTypeDeclaration,
        // Coverage-ignore(suite): Not run.
        "Unexpected declaration kind: $_kind");
    _kind = TypeParameterScopeKind.extensionDeclaration;
    _extensionName = name != null
        ? new FixedExtensionName(name)
        : new UnnamedExtensionName();
    _name = _extensionName!.name;
    _charOffset = charOffset;
    _typeVariables = typeVariables;
  }

  /// Registers that this builder is preparing for an extension type declaration
  /// with the given [name] and [typeVariables] located [charOffset].
  void markAsExtensionTypeDeclaration(String name, int charOffset,
      List<NominalVariableBuilder>? typeVariables) {
    assert(
        _kind == TypeParameterScopeKind.extensionOrExtensionTypeDeclaration,
        // Coverage-ignore(suite): Not run.
        "Unexpected declaration kind: $_kind");
    _kind = TypeParameterScopeKind.extensionTypeDeclaration;
    _name = name;
    _charOffset = charOffset;
    _typeVariables = typeVariables;
  }

  /// Registers that this builder is preparing for an enum declaration with
  /// the given [name] and [typeVariables] located [charOffset].
  void markAsEnumDeclaration(String name, int charOffset,
      List<NominalVariableBuilder>? typeVariables) {
    assert(
        _kind == TypeParameterScopeKind.enumDeclaration,
        // Coverage-ignore(suite): Not run.
        "Unexpected declaration kind: $_kind");
    _name = name;
    _charOffset = charOffset;
    _typeVariables = typeVariables;
  }

  /// Registers the 'extension this type' of the extension declaration prepared
  /// for by this builder.
  ///
  /// See [extensionThisType] for terminology.
  void registerExtensionThisType(TypeBuilder type) {
    assert(
        _kind == TypeParameterScopeKind.extensionDeclaration,
        // Coverage-ignore(suite): Not run.
        "DeclarationBuilder.registerExtensionThisType is not supported $_kind");
    assert(_extensionThisType == null,
        "Extension this type has already been set.");
    _extensionThisType = type;
  }

  /// Returns what kind of declaration this [TypeParameterScopeBuilder] is
  /// preparing for.
  ///
  /// This information is transient for some declarations. In particular
  /// classes and named mixin applications are initially created with the kind
  /// [TypeParameterScopeKind.classOrNamedMixinApplication] before a call to
  /// either [markAsClassDeclaration] or [markAsNamedMixinApplication] sets the
  /// value to its actual kind.
  // TODO(johnniwinther): Avoid the transition currently used on mixin
  // declarations.
  TypeParameterScopeKind get kind => _kind;

  String get name => _name;

  ExtensionName? get extensionName => _extensionName;

  int get charOffset => _charOffset;

  List<NominalVariableBuilder>? get typeVariables => _typeVariables;

  /// Returns the 'extension this type' of the extension declaration prepared
  /// for by this builder.
  ///
  /// The 'extension this type' is the type mentioned in the on-clause of the
  /// extension declaration. For instance `B` in this extension declaration:
  ///
  ///     extension A on B {
  ///       B method() => this;
  ///     }
  ///
  /// The 'extension this type' is the type if `this` expression in instance
  /// methods declared in extension declarations.
  TypeBuilder get extensionThisType {
    assert(
        kind == TypeParameterScopeKind.extensionDeclaration,
        // Coverage-ignore(suite): Not run.
        "DeclarationBuilder.extensionThisType not supported on $kind.");
    assert(
        _extensionThisType != null,
        // Coverage-ignore(suite): Not run.
        "DeclarationBuilder.extensionThisType has not been set on $this.");
    return _extensionThisType!;
  }

  /// Adds the yet unresolved [type] to this scope builder.
  ///
  /// Unresolved type will be resolved through [resolveNamedTypes] when the
  /// scope is fully built. This allows for resolving self-referencing types,
  /// like type parameter used in their own bound, for instance
  /// `<T extends A<T>>`.
  void registerUnresolvedNamedType(NamedTypeBuilder type) {
    unresolvedNamedTypes.add(type);
  }

  /// Resolves type variables in [unresolvedNamedTypes] and propagate other
  /// types to [parent].
  void resolveNamedTypes(List<NominalVariableBuilder>? typeVariables,
      ProblemReporting problemReporting) {
    Map<String, NominalVariableBuilder>? map;
    if (typeVariables != null) {
      map = <String, NominalVariableBuilder>{};
      for (NominalVariableBuilder builder in typeVariables) {
        if (builder.isWildcard) continue;
        map[builder.name] = builder;
      }
    }
    Scope? scope;
    for (NamedTypeBuilder namedTypeBuilder in unresolvedNamedTypes) {
      TypeName typeName = namedTypeBuilder.typeName;
      String? qualifier = typeName.qualifier;
      String? name = qualifier ?? typeName.name;
      Builder? declaration;
      if (members != null) {
        declaration = members![name];
      }
      if (declaration == null && map != null) {
        declaration = map[name];
      }
      if (declaration == null) {
        // Since name didn't resolve in this scope, propagate it to the
        // parent declaration.
        parent!.registerUnresolvedNamedType(namedTypeBuilder);
      } else if (qualifier != null) {
        // Attempt to use a member or type variable as a prefix.
        int nameOffset = typeName.fullNameOffset;
        int nameLength = typeName.fullNameLength;
        Message message = templateNotAPrefixInTypeAnnotation.withArguments(
            qualifier, typeName.name);
        problemReporting.addProblem(
            message, nameOffset, nameLength, namedTypeBuilder.fileUri!);
        namedTypeBuilder.bind(
            problemReporting,
            namedTypeBuilder.buildInvalidTypeDeclarationBuilder(
                message.withLocation(
                    namedTypeBuilder.fileUri!, nameOffset, nameLength)));
      } else {
        scope ??= toScope(null).withTypeVariables(typeVariables);
        namedTypeBuilder.resolveIn(scope, namedTypeBuilder.charOffset!,
            namedTypeBuilder.fileUri!, problemReporting);
      }
    }
    unresolvedNamedTypes.clear();
  }

  /// Resolves type variables in [unresolvedNamedTypes] and propagate other
  /// types to [parent].
  void resolveNamedTypesWithStructuralVariables(
      List<StructuralVariableBuilder>? typeVariables,
      ProblemReporting problemReporting) {
    Map<String, StructuralVariableBuilder>? map;
    if (typeVariables != null) {
      map = <String, StructuralVariableBuilder>{};
      for (StructuralVariableBuilder builder in typeVariables) {
        map[builder.name] = builder;
      }
    }
    Scope? scope;
    for (NamedTypeBuilder namedTypeBuilder in unresolvedNamedTypes) {
      TypeName typeName = namedTypeBuilder.typeName;
      String? qualifier = typeName.qualifier;
      String name = qualifier ?? typeName.name;
      Builder? declaration;
      if (members != null) {
        // Coverage-ignore-block(suite): Not run.
        declaration = members![name];
      }
      if (declaration == null && map != null) {
        declaration = map[name];
      }
      if (declaration == null) {
        // Since name didn't resolve in this scope, propagate it to the
        // parent declaration.
        parent!.registerUnresolvedNamedType(namedTypeBuilder);
      } else if (qualifier != null) {
        // Coverage-ignore-block(suite): Not run.
        // Attempt to use a member or type variable as a prefix.
        int nameOffset = typeName.fullNameOffset;
        int nameLength = typeName.fullNameLength;
        Message message = templateNotAPrefixInTypeAnnotation.withArguments(
            qualifier, namedTypeBuilder.typeName.name);
        problemReporting.addProblem(
            message, nameOffset, nameLength, namedTypeBuilder.fileUri!);
        namedTypeBuilder.bind(
            problemReporting,
            namedTypeBuilder.buildInvalidTypeDeclarationBuilder(
                message.withLocation(
                    namedTypeBuilder.fileUri!, nameOffset, nameLength)));
      } else {
        scope ??= toScope(null).withStructuralVariables(typeVariables);
        namedTypeBuilder.resolveIn(scope, namedTypeBuilder.charOffset!,
            namedTypeBuilder.fileUri!, problemReporting);
      }
    }
    unresolvedNamedTypes.clear();
  }

  Scope toScope(Scope? parent,
      {Map<String, Builder>? omittedTypeDeclarationBuilders}) {
    // Coverage-ignore(suite): Not run.
    if (omittedTypeDeclarationBuilders != null &&
        omittedTypeDeclarationBuilders.isNotEmpty) {
      parent = new Scope(
          kind: ScopeKind.typeParameters,
          local: omittedTypeDeclarationBuilders,
          parent: parent,
          debugName: 'omitted-types',
          isModifiable: false);
    }
    return new Scope(
        kind: ScopeKind.typeParameters,
        local: members ?? const {},
        setters: setters,
        extensions: extensions,
        parent: parent,
        debugName: name,
        isModifiable: false,
        augmentations: augmentations,
        setterAugmentations: setterAugmentations);
  }

  @override
  String toString() => 'DeclarationBuilder(${hashCode}:kind=$kind,name=$name)';
}
