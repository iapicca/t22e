/// The result of diffing two frames: a list of changed row indices.
extension type DiffResult(List<int> it) implements Iterable<int> {
  /// True if at least one row changed.
  bool get hasChanges => it.isNotEmpty;
}
