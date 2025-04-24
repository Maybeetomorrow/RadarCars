import 'package:flutter/material.dart';

/// Класс для управления анимациями на экране Wi-Fi
/// 
/// Особенности:
/// - Плавное появление элементов
/// - Анимация масштабирования
/// - Синхронизация с контроллером анимаций
class WiFiAnimations {
  /// Создает анимацию появления
  /// 
  /// Интервал: 0.0 - 0.5 секунд
  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
  }

  /// Создает анимацию масштабирования
  /// 
  /// Начальный масштаб: 0.8, конечный: 1.0
  /// Интервал: 0.2 - 0.7 секунд
  static Animation<double> createScaleAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  /// Создает анимацию появления текста
  /// 
  /// Интервал: 0.3 - 0.8 секунд
  static Animation<double> createTextAnimation(AnimationController controller) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );
  }
}