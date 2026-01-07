import 'package:safa_app/core/constants/api_constants.dart';

bool isNetworkUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null) return false;
  if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return true;
  }
  final lower = value.trim().toLowerCase();
  return lower.startsWith('http://') || lower.startsWith('https://');
}

bool isSvgPath(String value) {
  final lower = value.trim().toLowerCase();
  return lower.endsWith('.svg');
}

bool _isPlaceholderValue(String value) {
  final lower = value.trim().toLowerCase();
  return lower.isEmpty || lower == 'string' || lower == 'null' || lower == 'undefined';
}

String encodeUrlIfNeeded(String url) {
  // Encode only if there are spaces or unsafe chars to avoid breaking already-valid URLs.
  if (url.contains(' ')) return Uri.encodeFull(url);
  return url;
}

String resolveMediaUrl(String path) {
  final trimmed = path.trim();
  if (_isPlaceholderValue(trimmed)) return '';
  if (isNetworkUrl(trimmed)) return trimmed;
  if (trimmed.startsWith('assets/') || trimmed.startsWith('packages/')) {
    return trimmed;
  }

  final base = ApiConstants.baseUrl.endsWith('/')
      ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
      : ApiConstants.baseUrl;

  if (trimmed.startsWith('/')) return '$base$trimmed';

  return '$base/$trimmed';
}
