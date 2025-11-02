import 'package:flutter/material.dart';
import '../widgets/sadaqa_detail_components.dart';

class SadaqaDetail extends StatelessWidget {
  const SadaqaDetail({super.key});

  @override
  Widget build(BuildContext context) {
    const raised = 32450.0;
    const goal = 50000.0;
    const donors = 1247;
    final progress = (raised / goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SadaqaDetailHeader(
                    progress: progress,
                    onBack: () => Navigator.pop(context),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: -88,
                    child: SadaqaSummaryCard(
                      raised: raised,
                      goal: goal,
                      donors: donors,
                      progress: progress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 120),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SadaqaQuickStatsRow(),
                    SizedBox(height: 28),
                    SadaqaUpdatesSection(),
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
