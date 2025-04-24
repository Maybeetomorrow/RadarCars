import 'package:wifi_scan/wifi_scan.dart';
import 'package:wifi_iot/wifi_iot.dart';

/// Сервис для работы с Wi-Fi сетями
/// 
/// Особенности:
/// - Проверка разрешений
/// - Сканирование доступных сетей
/// - Получение текущей подключенной SSID
/// - Подключение к новым сетям
class WiFiService {
  /// Проверяет разрешения на сканирование Wi-Fi
  /// 
  /// Выбрасывает исключение при отсутствии прав
  static Future<void> checkPermissions() async {
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      throw Exception('Требуются разрешения для сканирования Wi-Fi');
    }
  }

  /// Выполняет сканирование доступных Wi-Fi сетей
  /// 
  /// Возвращает список найденных точек доступа
  static Future<List<WiFiAccessPoint>> scanNetworks() async {
    final result = await WiFiScan.instance.startScan();
    if (result != true) throw Exception('Ошибка сканирования');
    return WiFiScan.instance.getScannedResults();
  }

  /// Получает SSID текущей подключенной сети
  static Future<String?> getConnectedSSID() async {
    return WiFiForIoTPlugin.getSSID();
  }

  /// Подключается к указанной Wi-Fi сети
  /// 
  /// Параметры:
  /// - [ssid]: Имя сети
  /// - [password]: Пароль
  /// - [security]: Тип безопасности сети
  /// 
  /// Возвращает статус успешности подключения
  static Future<bool> connectToNetwork({
    required String ssid,
    String? password,
    required NetworkSecurity security,
  }) async {
    return WiFiForIoTPlugin.connect(
      ssid,
      password: password ?? '',
      security: security,
      joinOnce: false,
      withInternet: true,
    );
  }
}