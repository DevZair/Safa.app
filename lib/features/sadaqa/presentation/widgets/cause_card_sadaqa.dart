import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:safa_app/features/sadaqa/domain/utils/media_resolver.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CauseCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String? companyName;
  final List<String> gallery;
  final int amount;
  final bool isFavorite;
  final String recommendedLabel;
  final String donateLabel;
  final VoidCallback onDonate;
  final VoidCallback onFavoriteToggle;

  const CauseCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.companyName,
    this.gallery = const [],
    required this.amount,
    required this.isFavorite,
    required this.recommendedLabel,
    required this.donateLabel,
    required this.onDonate,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDonate,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _ImageCarousel(
                  height: 200.h,
                  images: (gallery.isNotEmpty ? gallery : [imagePath]),
                ),
                if (companyName?.isNotEmpty == true)
                  Positioned(
                    left: 12.w,
                    top: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.handshake_rounded,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            companyName!,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppColors.primary
                            : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.iconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ) ??
                        TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style:
                        Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey) ??
                        TextStyle(fontSize: 14.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendedLabel,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            '$amount₸',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2F855A),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 22.w,
                            vertical: 10.h,
                          ),
                        ),
                        onPressed: onDonate,
                        child: Text(
                          donateLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  const _ImageCarousel({required this.images, required this.height});

  final List<String> images;
  final double height;

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.images.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _current = (_current + 1) % widget.images.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: Stack(
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _current = index),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final path = images[index];
                final resolvedPath = resolveMediaUrl(path);
                // resolveMediaUrl already prefixes the base URL for relative paths
                return _buildImage(resolvedPath);
              },
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 10.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _current == index ? 10.w : 6.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _current == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined, size: 28.sp),
    );
  }

  Widget _buildImage(String resolvedPath) {
    final isNetwork = resolvedPath.contains('http');
    final isSvg = isSvgPath(resolvedPath);
    final safePath = isNetwork ? encodeUrlIfNeeded(resolvedPath) : resolvedPath;

    if (safePath.isEmpty) return _fallbackImage();

    if (isSvg) {
      if (isNetwork) {
        return _networkSvgWithFallback(safePath);
      }
      return SvgPicture.asset(
        safePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: widget.height,
        placeholderBuilder: (_) => _fallbackImage(),
      );
    }

    final builder = isNetwork ? Image.network : Image.asset;
    return builder(
      safePath,
      fit: BoxFit.cover,
      width: double.infinity,
      height: widget.height,
      errorBuilder: (context, error, stackTrace) {
        if (isNetwork && resolvedPath.startsWith('https://')) {
          final fallbackUrl = safePath.replaceFirst('https://', 'http://');
          return builder(
            fallbackUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height,
            errorBuilder: (context, error, stackTrace) => _fallbackImage(),
          );
        }
        debugPrint('Image load failed for $safePath');
        return _fallbackImage();
      },
    );
  }

  Widget _networkSvgWithFallback(String url) {
    final httpUrl = url.startsWith('https://')
        ? url.replaceFirst('https://', 'http://')
        : null;

    return SvgPicture.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: widget.height,
      placeholderBuilder: (_) => _fallbackImage(),
      colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.srcIn),
      clipBehavior: Clip.hardEdge,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) {
        if (httpUrl != null) {
          return SvgPicture.network(
            httpUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: widget.height,
            placeholderBuilder: (_) => _fallbackImage(),
          );
        }
        return _fallbackImage();
      },
    );
  }
}
