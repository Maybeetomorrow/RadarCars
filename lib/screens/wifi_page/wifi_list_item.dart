import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// Элемент списка доступных Wi-Fi сетей
/// 
/// Особенности:
/// - Отображение статуса подключения
/// - Индикация уровня сигнала
/// - Обработка нажатий на элемент
/// - Анимация загрузки при подключении
class WiFiListItem extends StatelessWidget {
  final WiFiAccessPoint ap;
  final String? connectedSSID;
  final bool isConnecting;
  final Function() onTap;

  const WiFiListItem({
    required this.ap,
    required this.connectedSSID,
    required this.isConnecting,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isConnected = ap.ssid == connectedSSID;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (isConnected)
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ap.ssid.isNotEmpty ? ap.ssid : 'Скрытая сеть',
                style: TextStyle(
                  fontSize: 22,
                  color: isConnected ? Colors.green : Colors.white,
                  fontFamily: 'CuprumRegular',
                ),
              ),
            ),
            _buildSignalIcon(ap.level),
            if (ap.capabilities.contains('PSK'))
              const Icon(Icons.lock, size: 20, color: Colors.white54),
            if (isConnecting && ap.ssid == connectedSSID)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  /// Построение иконки уровня сигнала
  /// 
  /// Цвет иконки зависит от силы сигнала (RSSI):
  /// - Зеленый: сильный сигнал (>= -50 dBm)
  /// - Желтый: средний сигнал (>= -60 dBm)
  /// - Оранжевый: слабый сигнал (>= -70 dBm)
  /// - Красный: очень слабый сигнал
  Widget _buildSignalIcon(int rssi) {
    const size = 28.0;
    if (rssi >= -50) return const Icon(Icons.wifi, size: size, color: Colors.green);
    if (rssi >= -60) return const Icon(Icons.wifi, size: size, color: Colors.yellow);
    if (rssi >= -70) return const Icon(Icons.wifi_2_bar, size: size, color: Colors.orange);
    return const Icon(Icons.wifi_1_bar, size: size, color: Colors.red);
  }
}