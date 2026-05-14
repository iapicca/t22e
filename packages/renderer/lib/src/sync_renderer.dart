import 'package:ansi/ansi.dart' show startSync, endSync;
import 'frame.dart';
import 'line_renderer.dart';

/// Wraps line-based rendering with DEC synchronized update markers when supported.
class SyncRenderer {
  /// Whether the terminal supports synchronized updates.
  final bool syncSupported;
  final LineRenderer _lineRenderer;

  const SyncRenderer({this.syncSupported = false, LineRenderer? lineRenderer})
    : _lineRenderer = lineRenderer ?? const LineRenderer();

  /// Renders changed lines, wrapping with sync markers if supported.
  String render(DiffResult diff, Frame currentFrame) {
    final content = _lineRenderer.render(diff, currentFrame);
    if (content.isEmpty) return '';
    if (!syncSupported) return content;
    return '${startSync()}$content${endSync()}';
  }
}
