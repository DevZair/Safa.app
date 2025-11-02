// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:safa_app/core/styles/app_colors.dart';

class SadaqaDetailHeader extends StatelessWidget {
  const SadaqaDetailHeader({
    super.key,
    required this.progress,
    required this.onBack,
    this.onFavorite,
    this.onShare,
  });

  final double progress;
  final VoidCallback onBack;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SadaqaCircleAction(icon: Icons.arrow_back, onTap: onBack),
                    const Spacer(),
                    SadaqaCircleAction(
                      icon: Icons.favorite_border,
                      onTap: onFavorite ?? () {},
                    ),
                    const SizedBox(width: 12),
                    SadaqaCircleAction(
                      icon: Icons.share_outlined,
                      onTap: onShare ?? () {},
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Feed the Hungry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provide meals to those in need',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% of goal raised',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
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
  const SadaqaCircleAction({super.key, required this.icon, required this.onTap});

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
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SadaqaSummaryColumn(
                  label: 'Raised',
                  value: _formatCurrency(raised),
                  valueColor: const Color(0xFF0F9D58),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SadaqaSummaryColumn(
                  label: 'Goal',
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
                '${(progress * 100).toStringAsFixed(1)}% funded',
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '$donors donors',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: onDonate ?? () {},
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1FC8A9), Color(0xFF2A9ED7)],
                ),
              ),
              child: const Text(
                'Donate Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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

class SadaqaQuickStatsRow extends StatelessWidget {
  const SadaqaQuickStatsRow({super.key});

  static const _stats = [
    SadaqaStatData(icon: Icons.trending_up, title: 'This Week', value: r'$2,450'),
    SadaqaStatData(icon: Icons.groups_outlined, title: 'New Donors', value: '127'),
    SadaqaStatData(
      icon: Icons.event_available_outlined,
      title: 'Days Left',
      value: '23',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        _stats.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == _stats.length - 1 ? 0 : 12),
            child: SadaqaStatCard(stat: _stats[index]),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: AppColors.primary),
          const Spacer(),
          Text(
            stat.title,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: const TextStyle(
              color: Color(0xFF111827),
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

class SadaqaUpdatesSection extends StatelessWidget {
  const SadaqaUpdatesSection({super.key});

  static const updates = [
    SadaqaUpdateData(
      image: 'assets/images/font1.jpeg',
      title: 'New Distribution in Rural Areas',
      timeAgo: '2 days ago',
      body:
          'Alhamdulillah, we distributed 500 meals to families across 5 villages. Your support keeps making a real difference.',
      likes: 234,
      comments: 45,
    ),
    SadaqaUpdateData(
      image: 'assets/images/font2.jpg',
      title: 'Ramadan Campaign Progress',
      timeAgo: '5 days ago',
      body:
          'We are grateful for your continuous support. We already reached 65% of our goal and helped over 1000 families.',
      likes: 198,
      comments: 28,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Updates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '3 posts',
                style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (final update in updates) ...[
          SadaqaUpdateCard(update: update),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class SadaqaUpdateCard extends StatelessWidget {
  const SadaqaUpdateCard({super.key, required this.update});

  final SadaqaUpdateData update;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            child: Image.asset(
              update.image,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      update.timeAgo,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  update.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  update.body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${update.likes}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.mode_comment_outlined,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${update.comments} comments',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SadaqaUpdateData {
  const SadaqaUpdateData({
    required this.image,
    required this.title,
    required this.timeAgo,
    required this.body,
    required this.likes,
    required this.comments,
  });

  final String image;
  final String title;
  final String timeAgo;
  final String body;
  final int likes;
  final int comments;
}

class SadaqaHeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.14)
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

String _formatCurrency(double value) {
  final digits = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining % 3 == 0 && remaining != 0) {
      buffer.write(' ');
    }
  }
  return '\$${buffer.toString()}';
}
