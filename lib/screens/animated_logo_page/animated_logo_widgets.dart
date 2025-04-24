import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'animated_logo_animations.dart';

/// Виджет анимированного логотипа
///
/// Содержит:
/// - Анимацию появления
/// - Анимацию масштабирования
/// - Анимацию вращения
class AnimatedLogo extends StatelessWidget {
  /// Объект управления анимациями
  final AnimatedLogoAnimations animations;

  const AnimatedLogo({super.key, required this.animations});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animations.mainController, animations.fadeOutController]),
      builder: (context, child) {
        return Opacity(
          opacity: animations.opacityAnimation.value * animations.fadeOutAnimation.value,
          child: Transform.scale(
            scale: animations.scaleAnimation.value,
            child: Transform.rotate(
              angle: animations.rotationAnimation.value,
              child: Image.asset(
                'assets/images/mainLogo/logo.png',
                width: 320,
                height: 200,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Виджет анимированной линии под логотипом
///
/// Особенности:
/// - Плавное появление
/// - Адаптивная ширина
/// - Стилизация под дизайн-систему
class AnimatedLine extends StatelessWidget {
  final AnimatedLogoAnimations animations;

  const AnimatedLine({super.key, required this.animations});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: AnimatedBuilder(
        animation: Listenable.merge([animations.lineAnimation, animations.fadeOutController]),
        builder: (context, child) {
          return Opacity(
            opacity: animations.fadeOutAnimation.value,
            child: Container(
              width: animations.lineAnimation.value * 320,
              height: 2,
              decoration: BoxDecoration(
                color: Pallete.textPageColorSecond,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Виджет анимированного текста под логотипом
///
/// Особенности:
/// - Постепенное появление символов
/// - Кастомный шрифт
/// - Привязка к анимационным параметрам
class AnimatedText extends StatelessWidget {
  final AnimatedLogoAnimations animations;
  final String visibleText;

  const AnimatedText({super.key, required this.animations, required this.visibleText});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: AnimatedBuilder(
        animation: Listenable.merge([animations.textAnimation, animations.fadeOutController]),
        builder: (context, child) {
          return Opacity(
            opacity: animations.fadeOutAnimation.value,
            child: Text(
              visibleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                color: Pallete.textPageColorSecond,
                fontFamily: 'CuprumBold',
                height: 1.3),
            ),
          );
        },
      ),
    );
  }
}