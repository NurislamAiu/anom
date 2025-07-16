import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final controller = PageController();
  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      'title': 'Добро пожаловать!',
      'desc': 'Приватные чаты с end-to-end шифрованием.',
    },
    {
      'title': 'Анонимность',
      'desc': 'Никаких телефонов. Только имя и пароль.',
    },
    {
      'title': 'Безопасность',
      'desc': 'Блокировка, PIN, алгоритмы — всё под твоим контролем.',
    },
  ];

  late final AnimationController logoAnim;
  late final Animation<double> logoScale;

  @override
  void initState() {
    super.initState();
    logoAnim = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    logoScale = CurvedAnimation(
      parent: logoAnim,
      curve: Curves.easeInOutBack,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    logoAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 30,
                right: 0,
                left: 0,
                child: Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
              Column(
                children: [

                  const SizedBox(height: 16),
                  Expanded(
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: (index) => setState(() => currentPage = index),
                      itemCount: pages.length,
                      itemBuilder: (_, index) {
                        final item = pages[index];
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                item['desc']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: currentPage == index ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index ? Colors.white : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('seenOnboarding', true);

                            context.go('/login');
                          },
                          child: Text(
                            currentPage == pages.length - 1 ? 'Начать' : 'Пропустить',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}