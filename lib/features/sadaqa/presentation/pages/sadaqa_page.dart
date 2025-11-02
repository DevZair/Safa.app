import 'package:flutter/material.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/request_help.dart';
import 'package:safa_app/features/sadaqa/presentation/pages/sadaqa_detail.dart';
import 'package:safa_app/features/sadaqa/presentation/widgets/build_sement_tabs_sadaqa.dart';
import 'package:safa_app/features/sadaqa/presentation/widgets/builde_favorites_sadaqa.dart';
import 'package:safa_app/features/sadaqa/presentation/widgets/cause_card_sadaqa.dart';
import 'package:safa_app/widgets/gradient_header.dart';

class SadaqaPage extends StatefulWidget {
  const SadaqaPage({super.key});

  @override
  State<SadaqaPage> createState() => _SadaqaPageState();
}

class _SadaqaPageState extends State<SadaqaPage> {
  int _selectedTabIndex = 0;
  final int _favoritesCount = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Stack(
          children: [
            const GradientHeader(
              icon: Icons.favorite,
              title: 'Садака',
              subtitle: 'Отдавайте с открытым сердцем',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 200),
                  _AssistanceCard(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Assistance request feature coming soon',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  buildSegmentedTabs(
                    selectedTabIndex: _selectedTabIndex,
                    favoritesCount: _favoritesCount,
                    onTabSelected: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_selectedTabIndex == 0) ...[
                    Text(
                      'Актуальные фонды',
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        color: Colors.grey[800],
                      ),
                    ),
                    CauseCard(
                      imagePath: 'assets/images/font1.jpeg',
                      icon: Icons.favorite_border,
                      title: 'Набор деньги для детей Газа',
                      subtitle: 'Соберите деньги для детей в Газе',
                      amount: 50,
                      onDonate: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SadaqaDetail(),
                          ),
                        );
                      },
                    ),
                    CauseCard(
                      imagePath: 'assets/images/font2.jpg',
                      icon: Icons.favorite_border,
                      title: 'Набор деньги для детей в детском доме',
                      subtitle: 'Соберите деньги для детей в детском доме',
                      amount: 200,
                      onDonate: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SadaqaDetail(),
                          ),
                        );
                      },
                    ),
                  ] else
                    buildFavoritesPlaceholder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistanceCard extends StatelessWidget {
  const _AssistanceCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xFF1FAB82), Color(0xFF1A9CCB)];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(46, 125, 110, 0.20),
            blurRadius: 25,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Нуждаетесь в помощи ?',
                  style: TextStyle(
                    color: Color(0xFF1A2B4F),
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gradientColors.first, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(33, 147, 108, 0.18),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.help_outline, color: Color(0xFF1FAB82)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(33, 147, 108, 0.35),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestHelpPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Оставить заявку на помощь',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
