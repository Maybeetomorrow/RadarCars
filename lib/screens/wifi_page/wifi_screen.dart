import 'package:flutter/material.dart';
import 'package:radar/resources/pallete.dart';
import 'package:radar/resources/utils/animations.dart';
import 'package:radar/screens/state_page/state_screen.dart';
import 'package:radar/widgets/button.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';
import 'wifi_service.dart';
import 'wifi_list_item.dart';
import 'wifi_animations.dart';

/// Основной экран управления Wi-Fi подключением
/// 
/// Отвечает за:
/// - Анимированное отображение интерфейса
/// - Сканирование и отображение доступных сетей
/// - Подключение к выбранным сетям
/// - Обработку ошибок и состояний загрузки
/// - Навигацию на следующий экран приложения
class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key});

  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> with SingleTickerProviderStateMixin {
  // Контроллер для управления анимациями
  late AnimationController _controller;
  
  // Анимации для разных элементов интерфейса
  late Animation<double> _fadeAnimation;    // Плавное появление
  late Animation<double> _scaleAnimation;   // Масштабирование
  late Animation<double> _textAnimation;    // Анимация текста
  late Animation<double> _listFadeAnimation; // Анимация списка сетей

  // Список найденных точек доступа
  List<WiFiAccessPoint> _accessPoints = [];
  
  // Флаги состояний
  bool _isScanning = false;     // В процессе сканирования
  bool _isConnecting = false;   // В процессе подключения
  String? _error;               // Сообщение об ошибке
  String? _connectedSSID;       // Текущая подключенная сеть

  // Константы анимации и размеров
  static const _animationDuration = Duration(milliseconds: 2000);
  static const _listHeightRatio = 0.55; // 55% высоты экрана для списка

  @override
  void initState() {
    super.initState();
    _initializeAnimations(); // Инициализация анимаций
    _controller.forward();   // Запуск анимаций
    _initWifi();            // Инициализация Wi-Fi модуля
  }

  /// Инициализация всех анимаций экрана
  void _initializeAnimations() {
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = WiFiAnimations.createFadeAnimation(_controller);
    _scaleAnimation = WiFiAnimations.createScaleAnimation(_controller);
    _textAnimation = WiFiAnimations.createTextAnimation(_controller);
    
    _listFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  /// Инициализация Wi-Fi функционала
  /// 
  /// Проверяет разрешения, запускает сканирование и получает текущую SSID
  Future<void> _initWifi() async {
    try {
      await WiFiService.checkPermissions(); // Проверка разрешений
      await _startScan();                   // Сканирование сетей
      await _getConnectedSSID();            // Получение текущей сети
    } catch (e) {
      _handleError(e.toString());           // Обработка ошибок
    }
  }

  /// Запуск сканирования Wi-Fi сетей
  Future<void> _startScan() async {
    setState(() => _isScanning = true); // Включаем индикатор загрузки
    
    try {
      _accessPoints = await WiFiService.scanNetworks(); // Получаем список сетей
    } catch (e) {
      _handleError(e.toString()); // Обработка ошибок сканирования
    } finally {
      setState(() => _isScanning = false); // Выключаем индикатор
    }
  }

  /// Получение SSID текущей подключенной сети
  Future<void> _getConnectedSSID() async {
    final ssid = await WiFiService.getConnectedSSID();
    setState(() => _connectedSSID = ssid); // Обновляем состояние
  }

  /// Подключение к выбранной Wi-Fi сети
  /// 
  /// Параметры:
  /// - [ap]: Точка доступа для подключения
  Future<void> _connectToNetwork(WiFiAccessPoint ap) async {
    // Проверка на уже активное подключение или процесс подключения
    if (_isConnecting || ap.ssid == _connectedSSID) return;
    
    setState(() => _isConnecting = true); // Включаем состояние подключения
    
    try {
      String? password;
      
      // Запрашиваем пароль для защищенных сетей
      if (ap.capabilities.contains('PSK')) {
        password = await _showPasswordDialog(context, ap.ssid);
        
        // Если пользователь отменил ввод
        if (password == null || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Отменено подключение')),
          );
          return;
        }
      }
      
      // Определяем тип безопасности сети
      final security = ap.capabilities.contains('PSK')
          ? NetworkSecurity.WPA
          : NetworkSecurity.NONE;

      // Попытка подключения
      final success = await WiFiService.connectToNetwork(
        ssid: ap.ssid,
        password: password,
        security: security,
      );
      
      // Обработка результата подключения
      if (success) {
        await _getConnectedSSID(); // Обновляем текущую сеть
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Успешно подключено к ${ap.ssid}')),
        );
      }
    } catch (e) {
      // Обработка неизвестных ошибок
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неизвестная ошибка: ${e.toString()}')),
      );
    } finally {
      setState(() => _isConnecting = false); // Сбрасываем состояние
    }
  }

  /// Диалог ввода пароля для защищенной сети
  /// 
  /// Параметры:
  /// - [context]: Контекст для отображения диалога
  /// - [ssid]: Имя сети, к которой подключаемся
  /// 
  /// Возвращает введенный пароль или null при отмене
  Future<String?> _showPasswordDialog(BuildContext context, String ssid) async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: true, // Закрытие по клику вне диалога
      builder: (context) => AlertDialog(
        title: Text('Подключение к $ssid'),
        content: TextField(
          controller: controller,
          obscureText: true, // Скрытие вводимого текста
          decoration: const InputDecoration(
            labelText: 'Пароль',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          // Кнопка отмены
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          // Кнопка подтверждения
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Подключить'),
          ),
        ],
      ),
    );
  }

  /// Обработчик ошибок
  /// 
  /// Параметры:
  /// - [message]: Текст ошибки
  void _handleError(String message) {
    setState(() => _error = message); // Обновление состояния ошибки
  }

  @override
  void dispose() {
    _controller.dispose(); // Очистка контроллера анимаций
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backColor,
      body: Column(
        children: [
          // Заголовок с логотипом и анимацией
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20),
            child: _buildLogoAnimation(),
          ),
          // Основная область контента
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(), // Заголовок "Wi-Fi"
                  _buildHelloSection(),   // Подзаголовок
                  const SizedBox(height: 25),
                  _buildWifiListFragment(), // Список сетей или индикатор
                  const Spacer(),
                ],
              ),
            ),
          ),
          // Кнопка перехода на следующий экран
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: _buildStartButton(),
          ),
        ],
      ),
    );
  }

  /// Анимированный логотип приложения
  Widget _buildLogoAnimation() {
    return FadeScaleTransition(
      fadeAnimation: _fadeAnimation,
      scaleAnimation: _scaleAnimation,
      child: Image.asset(
        'assets/images/mainLogo/logo.png',
        width: 200,
        height: 120,
      ),
    );
  }

  /// Анимированный заголовок "Wi-Fi"
  Widget _buildWelcomeSection() {
    return FadeTransition(
      opacity: _textAnimation,
      child: const Text(
        'Wi-Fi',
        style: TextStyle(
          fontSize: 48,
          color: Pallete.textPageColorSecond,
          fontFamily: 'CuprumBold',
        ),
      ),
    );
  }

  /// Анимированный подзаголовок
  Widget _buildHelloSection() {
    return FadeTransition(
      opacity: _textAnimation,
      child: const Text(
        'Подключитесь к устройству',
        style: TextStyle(
          fontSize: 32,
          color: Pallete.textPageColorSecond,
          fontFamily: 'CuprumRegular',
        ),
      ),
    );
  }

  /// Фрагмент списка доступных Wi-Fi сетей
  /// 
  /// Отображает:
  /// - Список сетей при успешном сканировании
  /// - Индикатор загрузки при сканировании
  /// - Сообщение об ошибке при неудаче
  Widget _buildWifiListFragment() {
    if (_error != null) return _buildErrorWidget();
    if (_isScanning) return _buildLoadingIndicator();
    
    return FadeTransition(
      opacity: _listFadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_listFadeAnimation),
        child: Container(
          height: MediaQuery.of(context).size.height * _listHeightRatio,
          decoration: BoxDecoration(
            color: Pallete.textPageColorSecond,
            borderRadius: BorderRadius.circular(15),
          ),
          child: RefreshIndicator(
            onRefresh: _startScan, // Обновление по свайпу
            child: Scrollbar(
              thickness: 6,
              radius: const Radius.circular(3),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                itemCount: _accessPoints.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (_, index) => WiFiListItem(
                  ap: _accessPoints[index],
                  connectedSSID: _connectedSSID,
                  isConnecting: _isConnecting,
                  onTap: () => _connectToNetwork(_accessPoints[index]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Индикатор загрузки при сканировании сетей
  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * _listHeightRatio,
      child: const Center(
        child: CircularProgressIndicator(color: Pallete.textPageColorSecond),
      ),
    );
  }

  /// Сообщение об ошибке
  Widget _buildErrorWidget() {
    return Container(
      height: MediaQuery.of(context).size.height * _listHeightRatio,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Pallete.textPageColorSecond,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Кнопка перехода на следующий экран
  /// 
  /// С анимацией масштабирования и кастомной навигацией
  Widget _buildStartButton() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: Button(
        onPressed: () => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const StatePage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            ),
          ),
        ),
        buttonText: 'Начать работу',
        width: 300,
        height: 50,
      ),
    );
  }
}