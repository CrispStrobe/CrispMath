// lib/utils/share_link.dart
//
// Shareable state links for the web version.
// Encodes calculator expression + optional result into a URL query
// parameter that can be shared and auto-loaded on visit.
//
// URL format: https://crisp-math.vercel.app/?expr=<encoded>&tab=<0-5>
//
// On native platforms, share uses the system share sheet (if available)
// or clipboard. On web, it generates a shareable URL.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

/// Build a shareable URL for the given expression.
String buildShareUrl(String expression, {int tab = 0, Uri? baseUri}) {
  final base = baseUri ??
      (kIsWeb ? Uri.base : Uri.parse('https://crisp-math.vercel.app/'));
  return base.replace(
      queryParameters: {'expr': expression, if (tab != 0) 'tab': '$tab'},
      fragment: '').toString();
}

/// Copy a shareable link to the clipboard. Returns the URL.
Future<String> copyShareLink(String expression, {int tab = 0}) async {
  final url = buildShareUrl(expression, tab: tab);
  await Clipboard.setData(ClipboardData(text: url));
  return url;
}

/// Parse share parameters from the current web URL.
/// Returns null on native platforms or when no params are present.
class ShareParams {
  final String? expression;
  final int? tab;

  const ShareParams({this.expression, this.tab});

  /// Read from the current web URL query parameters.
  /// Returns null if not on web or no share params found.
  static ShareParams? fromCurrentUrl() {
    if (!kIsWeb) return null;
    try {
      return fromUri(Uri.base);
    } catch (_) {
      return null;
    }
  }

  static ShareParams? fromUri(Uri uri) {
    try {
      final expr = uri.queryParameters['expr'];
      final tabStr = uri.queryParameters['tab'];
      if (expr == null && tabStr == null) return null;
      return ShareParams(
        expression: expr,
        tab: tabStr != null ? int.tryParse(tabStr) : null,
      );
    } catch (_) {
      return null;
    }
  }
}
