import 'package:flutter/material.dart';

/// Утилитарный класс для создания стандартизированных анимаций
/// Содержит предварительно настроенные анимации для повторного использования
class CustomAnimations {
  /// Создает анимацию плавного появления/исчезновения (fade)
  /// [controller] - контроллер анимации для управления продолжительностью и состоянием
  /// [interval] - временной интервал относительно продолжительности анимации (0.0-1.0)
  /// [curve] - кривая скорости анимации (по умолчанию easeInOut)
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    Interval interval = const Interval(0.0, 0.7),
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(interval.begin, interval.end, curve: curve),
      ),
    );
  }

  /// Создает анимацию масштабирования с эффектом "пружины"
  /// [begin] и [end] - начальный и конечный масштаб
  /// По умолчанию анимация начинается с 80% размера и анимируется до 100%
  /// с elasticOut кривой для эффекта превышения конечной точки
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.8,
    double end = 1.0,
    Interval interval = const Interval(0.2, 0.9),
    Curve curve = Curves.elasticOut,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(interval.begin, interval.end, curve: curve),
      ),
    );
  }

  /// Анимация для текстовых элементов с запаздывающим стартом
  /// Начинает анимироваться, когда основная анимация выполнена наполовину
  /// По умолчанию использует easeIn кривую для ускорения в начале
  static Animation<double> createTextAnimation(
    AnimationController controller, {
    Interval interval = const Interval(0.5, 1.0),
    Curve curve = Curves.easeIn,
  }) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(interval.begin, interval.end, curve: curve),
      ),
    );
  }
}

/// Кастомный анимированный виджет, комбинирующий эффекты:
/// - Плавное появление (fade)
/// - Масштабирование (scale)
/// Наследуется от [AnimatedWidget] для автоматической подписки на изменения анимации
class FadeScaleTransition extends AnimatedWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Widget child;

  const FadeScaleTransition({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.child,
  }) : super(listenable: fadeAnimation);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fadeAnimation.value,
      child: Transform.scale(
        scale: scaleAnimation.value,
        child: child,
      ),
    );
  }
}