import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:safa_app/core/navigation/app_router.dart';
import 'package:safa_app/features/sadaqa/domain/entities/sadaqa_cause.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_detail.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';

class SadaqaCompanyArgs {
  const SadaqaCompanyArgs({
    required this.companyName,
    this.companyLogo,
    this.cover,
    required this.causes,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final String companyName;
  final String? companyLogo;
  final String? cover;
  final List<SadaqaCause> causes;
  final bool Function(String id) isFavorite;
  final void Function(String id) onToggleFavorite;
}

class SadaqaCompanyPage extends StatelessWidget {
  const SadaqaCompanyPage({super.key, required this.args});

  final SadaqaCompanyArgs args;

  @override
  Widget build(BuildContext context) {
    final causes = args.causes;
    final cover = args.cover ?? (causes.isNotEmpty ? causes.first.imagePath : null);
    final logo = args.companyLogo ?? (causes.isNotEmpty ? causes.first.companyLogo : null);

    return Scaffold(
      appBar: AppBar(
        title: Text(args.companyName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        children: [
          _CompanyHeader(
            name: args.companyName,
            logo: logo,
            cover: cover,
            postsCount: causes.length,
          ),
          SizedBox(height: 16.h),
          for (final cause in causes) ...[
            _CauseTile(
              cause: cause,
              isFavorite: args.isFavorite(cause.id),
              onFavoriteToggle: () => args.onToggleFavorite(cause.id),
            ),
            SizedBox(height: 12.h),
          ],
        ],
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({
    required this.name,
    this.logo,
    this.cover,
    required this.postsCount,
  });

  final String name;
  final String? logo;
  final String? cover;
  final int postsCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedCover = cover != null ? resolveMediaUrl(cover!) : null;
    final isNetworkCover = resolvedCover != null && isNetworkUrl(resolvedCover);
    final safeCover = resolvedCover == null
        ? null
        : (isNetworkCover ? encodeUrlIfNeeded(resolvedCover) : resolvedCover);

    final coverWidget = safeCover == null
        ? Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: const Center(child: Icon(Icons.image_not_supported)),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: isNetworkCover
                ? Image.network(
                    safeCover,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    safeCover,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        coverWidget,
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Logo(logo: logo, name: name),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ) ??
                        TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$postsCount пост${postsCount == 1 ? '' : 'ов'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({this.logo, required this.name});

  final String? logo;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    if (logo != null && logo!.trim().isNotEmpty) {
      final resolvedLogo = resolveMediaUrl(logo!);
      final isNetwork = isNetworkUrl(resolvedLogo);
      final safeLogo = isNetwork ? encodeUrlIfNeeded(resolvedLogo) : resolvedLogo;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: isNetwork
            ? Image.network(
                safeLogo,
                width: 52.r,
                height: 52.r,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _LogoFallback(bg: bg, name: name),
              )
            : Image.asset(
                safeLogo,
                width: 52.r,
                height: 52.r,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _LogoFallback(bg: bg, name: name),
              ),
      );
    }
    return _LogoFallback(bg: bg, name: name);
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback({required this.bg, required this.name});

  final Color bg;
  final String name;

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : '—';
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _CauseTile extends StatelessWidget {
  const _CauseTile({
    required this.cause,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final SadaqaCause cause;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          context.pushNamed(
            AppRoute.sadaqaDetail.name,
            extra: SadaqaDetailArgs(
              cause: cause,
              isFavorite: isFavorite,
              onFavoriteChanged: (_) => onFavoriteToggle(),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  encodeUrlIfNeeded(resolveMediaUrl(cause.imagePath)),
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80.w,
                    height: 80.w,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cause.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      cause.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                          onPressed: () {
                            context.pushNamed(
                              AppRoute.sadaqaDetail.name,
                              extra: SadaqaDetailArgs(
                                cause: cause,
                                isFavorite: isFavorite,
                                onFavoriteChanged: (_) => onFavoriteToggle(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
