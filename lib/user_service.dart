import 'package:flutter/foundation.dart';

/// Логирование без персональных данных (PII)
class AppLogger {
  static void log(String level, String message, {String? userEmail}) {
    String sanitized = message;
    if (userEmail != null) {
      // Маскирование email: user@test.com -> u***@test.com
      final parts = userEmail.split('@');
      final maskedName = parts[0].isNotEmpty ? '${parts[0][0]}***' : '***';
      final maskedEmail = '$maskedName@${parts.length > 1 ? parts[1] : ''}';
      sanitized = '$message [User: $maskedEmail]';
    }
    debugPrint('[$level] ${DateTime.now().toIso8601String()}: $sanitized');
  }

  static void info(String message, {String? userEmail}) =>
      log('INFO', message, userEmail: userEmail);

  static void error(String message, {String? userEmail}) =>
      log('ERROR', message, userEmail: userEmail);
}

/// Абстракция репозитория
abstract class UserRepository {
  Future<String> fetchUserData();
}

/// Фейковый репозиторий для тестов
class FakeUserRepository implements UserRepository {
  final bool shouldFail;
  FakeUserRepository({this.shouldFail = false});

  @override
  Future<String> fetchUserData() async {
    if (shouldFail) {
      throw Exception('Ошибка сервера: 500');
    }
    return 'Профиль: Никита (Премиум)';
  }
}

/// ViewModel, управляющая состоянием экрана
class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  bool isLoading = false;
  String? data;
  String? errorMessage;

  UserViewModel({required this.repository});

  Future<void> loadProfile(String userEmail) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    AppLogger.info('Запрос данных профиля', userEmail: userEmail);

    try {
      data = await repository.fetchUserData();
      AppLogger.info('Профиль успешно загружен', userEmail: userEmail);
    } catch (e) {
      errorMessage = e.toString();
      AppLogger.error('Сбой загрузки данных: $e', userEmail: userEmail);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}