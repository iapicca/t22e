import '../ansi/term.dart' show startSync, endSync;
import 'frame.dart';
import 'line_renderer.dart';

/// Wraps line renderer output in synchronized update brackets when supported
class SyncRenderer {
  /// Whether the terminal supports synchronized updates
  final bool syncSupported;
  /// The underlying line renderer
  final LineRenderer _lineRenderer;

  const SyncRenderer({
    this.syncSupported = false,
    LineRenderer? lineRenderer,
  }) : _lineRenderer = lineRenderer ?? const LineRenderer();

  /// Renders diff, wrapping in sync brackets if supported
  String render(DiffResult diff, Frame currentFrame) {
    final content = _lineRenderer.render(diff, currentFrame);
    if (content.isEmpty) return '';
    if (!syncSupported) return content;
    return '${startSync()}$content${endSync()}';
  }
}
