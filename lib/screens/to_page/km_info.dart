import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';

/// Виджет отображения информации о пробеге
/// 
/// Особенности:
/// - Поддержка трех состояний: загрузка/ошибка/данные
/// - Автоматическое форматирование числовых значений
/// - Интеграция с системой цветов [Pallete]
/// - Кастомизация шрифтов и размеров текста
class KmInfo extends StatelessWidget {
  /// Флаг состояния загрузки данных
  final bool isKmLoading;
  
  /// Сообщение об ошибке при получении данных
  final String kmErrorMessage;
  
  /// Значение оставшегося пробега в км
  final double remainingKm;

  const KmInfo({
    required this.isKmLoading,
    required this.kmErrorMessage,
    required this.remainingKm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isKmLoading) {
      return const CircularProgressIndicator(color: Pallete.mainOrange);
    }
    
    if (kmErrorMessage.isNotEmpty) {
      return Text(
        kmErrorMessage,
        style: const TextStyle(
          color: Pallete.cherryDark,
          fontFamily: 'Cuprum',
          fontSize: 16,
        ),
      );
    }
    
    return Text(
      '${remainingKm.toStringAsFixed(1)} км',
      style: TextStyle(
        color: Pallete.textPageColorSecond,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'CuprumBold',
      ),
    );
  }
}