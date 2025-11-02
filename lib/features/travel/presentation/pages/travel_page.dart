import 'package:flutter/material.dart';
import 'package:safa_app/features/travel/presentation/widgets/travel_package_card.dart';
import 'package:safa_app/widgets/gradient_header.dart';

class TravelPage extends StatelessWidget {
  const TravelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const GradientHeader(
                    height: 280,
                    icon: Icons.travel_explore_rounded,
                    title: 'Туры и путешествия',
                    subtitle: 'Откройте для себя священные путешествия',
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_travelPackages.length} доступно туров',
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final package in _travelPackages)
                      TravelPackageCard(package: package),
                    const SizedBox(height: 12),
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

const _travelPackages = <TravelPackage>[
  TravelPackage(
    title: 'Умра 2024 – Эконом',
    location: 'Makkah & Madinah',
    imagePath: 'assets/images/travel_card1.jpg',
    guideName: 'Abdruhman Qori',
    guideRating: 4.9,
    priceUsd: 2500,
    availabilityLabel: '8 spots left',
    startDateLabel: '15.12.2024',
    durationLabel: '10 days',
    tags: [
      TravelBadgeData('NEW', Color(0xFF16A34A)),
      TravelBadgeData('Umrah', Color(0xFFF8FAFC), Color(0xFF1F2937)),
    ],
  ),
  TravelPackage(
    title: 'Хадж 2025 – Премиум',
    location: 'Saudi Arabia',
    imagePath: 'assets/images/travel_card2.jpg',
    guideName: 'Islam Qori',
    guideRating: 4.8,
    priceUsd: 5500,
    availabilityLabel: '5 spots left',
    startDateLabel: '10.06.2025',
    durationLabel: '15 days',
    tags: [
      TravelBadgeData('NEW', Color(0xFF16A34A)),
      TravelBadgeData('Hajj', Color(0xFFF1F5F9), Color(0xFF1E293B)),
    ],
  ),
];
