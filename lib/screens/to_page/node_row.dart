import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/screens/to_page/node_item.dart';
import 'package:radar/widgets/textbox.dart';

/// Виджет строки узла с чекбоксом и комментарием
/// 
/// Особенности:
/// - Интеграция с моделью [NodeItem] для состояний
/// - Поддержка управления фокусом через колбэк
/// - Кастомная стилизация элементов
/// - Адаптивная верстка с flex-пропорциями
class NodeRow extends StatelessWidget {
  /// Модель данных узла
  final NodeItem node;
  
  /// Колбэк при получении фокуса текстовым полем
  final VoidCallback onFocus;
  
  /// Глобальный ключ для идентификации виджета
  final GlobalKey rowKey;

  const NodeRow({
    required this.node,
    required this.onFocus,
    required this.rowKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: rowKey, // Используется для доступа к виджету
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Чекбокс с кастомным цветом
          Checkbox(
            value: node.isSelected,
            onChanged: (value) {
              node.isSelected = value ?? false;
            },
            activeColor: Pallete.mainOrange,
          ),
          // Название узла с ограничением на 2 строки
          Expanded(
            flex: 3,
            child: Text(
              node.name,
              style: TextStyle(
                color: Pallete.textPageColorSecond,
                fontSize: 16,
                fontFamily: 'CuprumBold',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
          // Расширяемое текстовое поле для комментариев
          Expanded(
            flex: 2,
            child: ExpandableTextbox(
              hintText: 'Комментарий',
              controller: node.commentController,
              onFocus: onFocus, // Уведомление о фокусе
            ),
          ),
        ],
      ),
    );
  }
}