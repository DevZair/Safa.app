import 'package:flutter/material.dart';
import 'package:safa_app/core/styles/app_colors.dart';

class UnderDevelopmentPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const UnderDevelopmentPage({
    super.key,
    this.title = 'Страница в разработке',
    this.subtitle = 'Мы уже работаем над этой функцией 🚀',
    this.icon = Icons.construction_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Иконка с мягким градиентом
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF48C6B6), Color(0xFF35A0D3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),

                // 🔹 Заголовок
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                    fontFamily: 'SF',
                  ),
                ),

                const SizedBox(height: 12),

                // 🔹 Подзаголовок
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                    fontFamily: 'SF',
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 Кнопка “Назад” или “Главная”
                ElevatedButton.icon(
                  onPressed: () => () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    'Вернуться назад',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
