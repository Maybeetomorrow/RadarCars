import 'package:http/http.dart' as http;
import 'dart:convert';

/// Репозиторий для работы с данными технического обслуживания
/// 
/// Особенности:
/// - Инкапсулирует HTTP-запросы к API
/// - Обрабатывает преобразование JSON данных
/// - Стандартизирует обработку ошибок
/// - Предоставляет статические методы для удобства
class ToRepository {
  
  /// Загрузка списка узлов оборудования
  /// 
  /// Возвращает:
  /// - Список узлов в формате JSON
  /// 
  /// Обработка ошибок:
  /// - Выбрасывает исключение при неудачном статусе ответа
  static Future<List<dynamic>> fetchNodes() async {
    final response = await http.get(Uri.parse('http://192.168.1.1:8080/nodes'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки: ${response.statusCode}');
    }
  }

  /// Получение данных об оставшемся пробеге
  /// 
  /// Особенности:
  /// - Запрашивает данные с endpoint /service/remaining-km
  /// - Возвращает словарь с ключевыми метриками
  static Future<Map<String, dynamic>> fetchRemainingKm() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.1:8080/service/remaining-km'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка загрузки пробега: ${response.statusCode}');
    }
  }

  /// Отправка данных о проведенных работах ТО
  /// 
  /// Параметры:
  /// - data: Список работ в формате "компонент-комментарий"
  /// 
  /// Особенности:
  /// - Использует POST-запрос с JSON-телом
  /// - Проверяет успешность операции по статусу 200
  static Future<void> submitMaintenance(List<Map<String, String>> data) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.1:8080/add-maintenance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка сервера: ${response.statusCode}');
    }
  }
}