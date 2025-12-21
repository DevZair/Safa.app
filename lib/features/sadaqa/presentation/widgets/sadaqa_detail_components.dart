// ignore_for_file: deprecated_member_use
import 'package:safa_app/core/localization/app_localizations.dart';
import 'package:safa_app/core/styles/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:safa_app/features/sadaqa/utils/media_resolver.dart';
import 'package:safa_app/features/sadaqa/models/sadaqa_post.dart';

String _formatCurrency(double value) => '${value.toStringAsFixed(0)}₸';

class SadaqaDetailHeader extends StatelessWidget {
  const SadaqaDetailHeader({
    super.key,
    required this.progress,
    required this.onBack,
    required this.title,
    required this.subtitle,
    this.companyName,
    this.companyLogo,
    this.isFavorite = false,
    this.onFavorite,
    this.onShare,
  });

  final double progress;
  final VoidCallback onBack;
  final String title;
  final String subtitle;
  final String? companyName;
  final String? companyLogo;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 380),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1FC8A9), Color(0xFF2A9ED7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: SadaqaHeaderPatternPainter()),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 70, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SadaqaCircleAction(icon: Icons.arrow_back, onTap: onBack),
                    const Spacer(),
                    SadaqaCircleAction(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      onTap: onFavorite ?? () {},
                    ),
                    const SizedBox(width: 12),
                    SadaqaCircleAction(
                      icon: Icons.share_outlined,
                      onTap: onShare ?? () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _CompanyHeader(name: companyName, logo: companyLogo),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SadaqaCircleAction extends StatelessWidget {
  const SadaqaCircleAction({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _CompanyHeader extends StatelessWidget {
  const _CompanyHeader({this.name, this.logo});

  final String? name;
  final String? logo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = Colors.white.withValues(alpha: 0.22);
    return Row(
      children: [
        _CompanyAvatar(logo: logo, fallback: name),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name?.isNotEmpty == true ? name! : 'Без названия',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: const [
              Icon(Icons.verified_rounded, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Фонд',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompanyAvatar extends StatelessWidget {
  const _CompanyAvatar({this.logo, this.fallback});

  final String? logo;
  final String? fallback;

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: Colors.white.withValues(alpha: 0.35));
    final radius = BorderRadius.circular(14);

    Widget avatar;
    if (logo != null && logo!.isNotEmpty) {
      final resolvedLogo = resolveMediaUrl(logo!);
      final isNetwork = isNetworkUrl(resolvedLogo);
      avatar = ClipRRect(
        borderRadius: radius,
        child: isNetwork
            ? Image.network(
                resolvedLogo,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _FallbackAvatar(fallback),
              )
            : Image.asset(
                resolvedLogo,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
      );
    } else {
      avatar = _FallbackAvatar(fallback);
    }

    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: Colors.white.withValues(alpha: 0.18),
      ),
      child: ClipRRect(borderRadius: radius, child: avatar),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar(this.fallback);

  final String? fallback;

  @override
  Widget build(BuildContext context) {
    final trimmed = fallback?.trim() ?? '';
    final initial = trimmed.isNotEmpty
        ? trimmed.substring(0, 1).toUpperCase()
        : '—';
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _ResolvedImage extends StatelessWidget {
  const _ResolvedImage({
    required this.path,
    this.width,
    this.height,
    this.radius,
  });

  final String path;
  final double? width;
  final double? height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final resolved = resolveMediaUrl(path);
    final isNetwork = isNetworkUrl(resolved);
    final isSvg = isSvgPath(resolved);
    final borderRadius = radius != null
        ? BorderRadius.circular(radius!)
        : BorderRadius.zero;

    final image = _buildImage(resolved, isNetwork, isSvg);

    return ClipRRect(borderRadius: borderRadius, child: image);
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined),
    );
  }

  Widget _buildImage(String resolved, bool isNetwork, bool isSvg) {
    final safeResolved = (resolved.contains('http'))
        ? encodeUrlIfNeeded(resolved)
        : resolved;
    if (safeResolved.isEmpty) return _placeholder();
    if (isSvg) {
      if (safeResolved.contains('http')) {
        return _networkSvgWithFallback(safeResolved);
      }
      return SvgPicture.asset(
        safeResolved,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => _placeholder(),
      );
    }

    final builder = safeResolved.contains('http') ? Image.network : Image.asset;
    return builder(
      safeResolved,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (isNetwork && safeResolved.startsWith('https://')) {
          final fallbackUrl = safeResolved.replaceFirst('https://', 'http://');
          return builder(
            fallbackUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _placeholder(),
          );
        }
        debugPrint('Image load failed for $safeResolved');
        return _placeholder();
      },
    );
  }

  Widget _networkSvgWithFallback(String url) {
    final httpUrl = url.startsWith('https://')
        ? url.replaceFirst('https://', 'http://')
        : null;

    return SvgPicture.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => _placeholder(),
      errorBuilder: (context, error, stackTrace) {
        if (httpUrl != null) {
          return SvgPicture.network(
            httpUrl,
            width: width,
            height: height,
            fit: BoxFit.cover,
            placeholderBuilder: (_) => _placeholder(),
          );
        }
        return _placeholder();
      },
    );
  }
}

class SadaqaSummaryCard extends StatelessWidget {
  const SadaqaSummaryCard({
    super.key,
    required this.raised,
    required this.goal,
    required this.donors,
    required this.progress,
    this.onDonate,
  });

  final double raised;
  final double goal;
  final int donors;
  final double progress;
  final VoidCallback? onDonate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percentText = (progress * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SadaqaSummaryColumn(
                  label: l10n.t('sadaqa.detail.raised'),
                  value: _formatCurrency(raised),
                  valueColor: const Color(0xFF0F9D58),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SadaqaSummaryColumn(
                  label: l10n.t('sadaqa.detail.goal'),
                  value: _formatCurrency(goal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF0F172A)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.t(
                  'sadaqa.detail.funded',
                  params: {'percent': percentText},
                ),
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                l10n.t('sadaqa.detail.donors', params: {'count': '$donors'}),
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SadaqaPrimaryButton(
            label: l10n.t('sadaqa.detail.donateNow'),
            onPressed: onDonate,
          ),
        ],
      ),
    );
  }
}

class SadaqaPrimaryButton extends StatelessWidget {
  const SadaqaPrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          if (isEnabled) {
            onPressed!();
          }
        },
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: isEnabled
                  ? const [Color(0xFF1FC8A9), Color(0xFF2A9ED7)]
                  : const [Color(0xFF9CA3AF), Color(0xFFCBD5E1)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SadaqaSummaryColumn extends StatelessWidget {
  const SadaqaSummaryColumn({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1F2937),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class SadaqaBeneficiaryOverviewCard extends StatelessWidget {
  const SadaqaBeneficiaryOverviewCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.raised,
    required this.goal,
    required this.donors,
    required this.progress,
    this.statusLabel,
    this.statusColor = const Color(0xFFE11D48),
    required this.donateLabel,
    this.onDonate,
    this.paymentUrl,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final String description;
  final double raised;
  final double goal;
  final int donors;
  final double progress;
  final String? statusLabel;
  final Color statusColor;
  final String donateLabel;
  final ValueChanged<String?>? onDonate;
  final String? paymentUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percentText = (progress * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(minHeight: 470),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _ResolvedImage(
                  path: imagePath,
                  width: 62,
                  height: 62,
                  radius: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (statusLabel != null)
                SadaqaStatusChip(label: statusLabel!, color: statusColor),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SadaqaSummaryColumn(
                  label: l10n.t('sadaqa.detail.raised'),
                  value: _formatCurrency(raised),
                  valueColor: const Color(0xFF0F9D58),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SadaqaSummaryColumn(
                  label: l10n.t('sadaqa.detail.goal'),
                  value: _formatCurrency(goal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 12,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.t(
                    'sadaqa.detail.funded',
                    params: {'percent': percentText},
                  ),
                  style: const TextStyle(
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.t(
                      'sadaqa.detail.donors',
                      params: {'count': '$donors'},
                    ),
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SadaqaPrimaryButton(
            label: donateLabel,
            onPressed:
                onDonate == null ? null : () => onDonate!(paymentUrl),
          ),
        ],
      ),
    );
  }
}

class SadaqaStatusChip extends StatelessWidget {
  const SadaqaStatusChip({
    super.key,
    required this.label,
    this.color = const Color(0xFFE11D48),
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class SadaqaPinnedFundCard extends StatelessWidget {
  const SadaqaPinnedFundCard({
    super.key,
    required this.companyName,
    required this.companyLogo,
    required this.causeTitle,
    required this.causeSubtitle,
  });

  final String? companyName;
  final String? companyLogo;
  final String causeTitle;
  final String causeSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CompanyAvatar(logo: companyLogo, fallback: companyName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName?.trim().isNotEmpty == true
                          ? companyName!.trim()
                          : 'Без названия',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ) ??
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Текущий сбор фонда',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.verified_outlined,
                      size: 16,
                      color: Color(0xFF0EA5E9),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Фонд',
                      style: TextStyle(
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            causeTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: titleStyle,
          ),
          const SizedBox(height: 6),
          Text(
            causeSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style:
                theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                ) ??
                const TextStyle(color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}

class SadaqaQuickStatsRow extends StatelessWidget {
  const SadaqaQuickStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = [
      SadaqaStatData(
        icon: Icons.trending_up,
        title: l10n.t('sadaqa.quickStats.thisWeek'),
        value: r'$2,450',
      ),
      SadaqaStatData(
        icon: Icons.groups_outlined,
        title: l10n.t('sadaqa.quickStats.newDonors'),
        value: '127',
      ),
      SadaqaStatData(
        icon: Icons.event_available_outlined,
        title: l10n.t('sadaqa.quickStats.daysLeft'),
        value: '23',
      ),
    ];

    return Row(
      children: List.generate(
        stats.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == stats.length - 1 ? 0 : 12),
            child: SadaqaStatCard(stat: stats[index]),
          ),
        ),
      ),
    );
  }
}

class SadaqaStatCard extends StatelessWidget {
  const SadaqaStatCard({super.key, required this.stat});

  final SadaqaStatData stat;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final bodyColor =
        Theme.of(context).textTheme.bodyMedium?.color ??
        AppColors.darkTextPrimary;
    final mutedColor = bodyColor.withValues(alpha: 0.65);
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: AppColors.primary),
          const SizedBox(height: 18),
          Text(
            stat.title,
            style: TextStyle(color: mutedColor, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: TextStyle(
              color: bodyColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class SadaqaStatData {
  const SadaqaStatData({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class SadaqaCompanyPostsSection extends StatelessWidget {
  const SadaqaCompanyPostsSection({
    super.key,
    required this.futurePosts,
    this.companyName,
  });

  final Future<List<SadaqaPost>> futurePosts;
  final String? companyName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bodyColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        AppColors.darkTextPrimary;
    return FutureBuilder<List<SadaqaPost>>(
      future: futurePosts,
      builder: (context, snapshot) {
        final posts = snapshot.data ?? const [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;

        if (isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('sadaqa.updates.title'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: bodyColor,
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }

        if (hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('sadaqa.updates.title'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: bodyColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('sadaqa.updates.error'),
                style: TextStyle(color: bodyColor.withValues(alpha: 0.7)),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.t('sadaqa.updates.title'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: bodyColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.t(
                      'sadaqa.updates.count',
                      params: {'count': '${posts.length}'},
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (posts.isEmpty)
              Text(
                l10n.t('sadaqa.placeholder.subtitle'),
                style: TextStyle(color: bodyColor.withValues(alpha: 0.7)),
              )
            else
              for (final post in posts) ...[
                SadaqaPostCard(post: post, companyName: companyName),
                const SizedBox(height: 16),
              ],
          ],
        );
      },
    );
  }
}

class SadaqaPostCard extends StatelessWidget {
  const SadaqaPostCard({super.key, required this.post, this.companyName});

  final SadaqaPost post;
  final String? companyName;

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final bodyColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    final mutedColor = bodyColor.withValues(alpha: 0.65);
    final safeImage = encodeUrlIfNeeded(resolveMediaUrl(post.image));

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              safeImage,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (companyName != null && companyName!.trim().isNotEmpty) ...[
                  Text(
                    companyName!,
                    style: TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SadaqaHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    const step = 26.0;
    for (double y = step / 2; y < size.height; y += step) {
      for (double x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
