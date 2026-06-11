/// Result of a DA1 capability query: supported or unsupported.
sealed class Da1Query {
  const Da1Query._();

  const factory Da1Query.supported(int terminalId, List<int> attributes) =
      Da1Value;
  const factory Da1Query.unsupported() = Da1QueryUnsupported;

  TResult when<TResult extends Object?>({
    required TResult Function(int terminalId, List<int> attributes) supported,
    required TResult Function() unsupported,
  }) {
    return switch (this) {
      Da1Value(:final terminalId, :final attributes) =>
        supported(terminalId, attributes),
      Da1QueryUnsupported() => unsupported(),
    };
  }
}

/// Parsed DA1 response: terminal ID and attribute list.
final class Da1Value extends Da1Query {
  const Da1Value(this.terminalId, this.attributes) : super._();

  final int terminalId;
  final List<int> attributes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Da1Value &&
          terminalId == other.terminalId &&
          _listEquals(attributes, other.attributes);

  @override
  int get hashCode => Object.hash(terminalId, Object.hashAll(attributes));
}

/// DA1 query returned when the terminal does not respond.
final class Da1QueryUnsupported extends Da1Query {
  const Da1QueryUnsupported() : super._();

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
