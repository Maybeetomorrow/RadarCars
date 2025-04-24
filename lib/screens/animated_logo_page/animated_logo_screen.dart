import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/screens/wifi_page/wifi_screen.dart';
import 'animated_logo_animations.dart';
import 'animated_logo_widgets.dart';

/// Экран с анимированным логотипом при старте приложения
///
/// Последовательность анимаций:
/// 1. Появление логотипа с эффектом "отскока"
/// 2. Появление подчеркивающей линии
/// 3. Постепенное отображение текста
/// 4. Плавный переход на следующий экран
class AnimatedLogoScreen extends StatefulWidget {
  const AnimatedLogoScreen({super.key});

  @override
  State<AnimatedLogoScreen> createState() => _AnimatedLogoScreenState();
}

class _AnimatedLogoScreenState extends State<AnimatedLogoScreen>
    with TickerProviderStateMixin {
  late final AnimatedLogoAnimations _animations;
  final String _fullText = 'Контроль транспорта 24/7';
  String _visibleText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animations = AnimatedLogoAnimations(vsync: this);
    _setupListeners();
    _animations.mainController.forward();
  }

  /// Настройка слушателей анимаций
  void _setupListeners() {
    _animations.mainController.addListener(() {
      final textLength = (_fullText.length * _animations.textAnimation.value).round();
      if (textLength > _currentIndex) {
        setState(() {
          _visibleText = _fullText.substring(0, textLength);
          _currentIndex = textLength;
        });
      }
    });

    _animations.mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animations.fadeOutController.forward();
      }
    });

    _animations.fadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WifiScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedLogo(animations: _animations),
            AnimatedLine(animations: _animations),
            AnimatedText(animations: _animations, visibleText: _visibleText),
          ],
        ),
      ),
    );
  }
}