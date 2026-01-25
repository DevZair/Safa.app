import 'package:flutter/material.dart';
import 'package:safa_app/core/constants/api_constants.dart';
import 'package:safa_app/core/service/db_service.dart';

class CompanyImage extends StatelessWidget {
  final String imagePath;
  final double size;

  const CompanyImage({
    super.key,
    required this.imagePath,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPath = resolveRemoteImagePath(imagePath);
    if (resolvedPath.isEmpty) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Icon(
          Icons.image_not_supported_outlined,
          size: (size * 0.55).clamp(16.0, 32.0).toDouble(),
          color: Theme.of(context).iconTheme.color?.withOpacity(0.8),
        ),
      );
    }

    if (resolvedPath.startsWith('http')) {
      return Image.network(
        resolvedPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported_outlined),
      );
    }

    return Image.asset(
      resolvedPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.image_not_supported_outlined),
    );
  }
}

String resolveRemoteImagePath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http')) return trimmed;
  final base = normalizeBaseUrl(
    DBService.baseUrl.isNotEmpty ? DBService.baseUrl : ApiConstants.baseUrl,
  );
  if (base.isEmpty) return trimmed;
  if (trimmed.startsWith('/')) {
    return '$base$trimmed';
  }
  return '$base/$trimmed';
}

String normalizeBaseUrl(String value) {
  var normalized = value.trim();
  if (normalized.isEmpty) return '';
  if (!normalized.startsWith('http')) {
    normalized = 'https://$normalized';
  }
  while (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}
