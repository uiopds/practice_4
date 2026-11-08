import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_4/calculator.dart';
import 'package:practice_4/calculator_screen.dart';
import 'package:practice_4/user_service.dart';

void main() {
  // ==========================================
  // БАЗОВЫЙ УРОВЕНЬ: Unit-тесты для функции
  // ==========================================
  group('1. Базовый уровень - Unit-тесты скидок', () {
    test('1. Стандартный расчет 10% скидки', () {
      final result = calculateDiscountedPrice(1000, 10);
      expect(result, 900.0);
    });

    test('2. Расчет 50% скидки', () {
      final result = calculateDiscountedPrice(500, 50);
      expect(result, 250.0);
    });

    test('3. Граничные случаи: 0% и 100% скидки, отрицательные числа', () {
      // 0% скидка — цена не меняется
      expect(calculateDiscountedPrice(1000, 0), 1000.0);
      // 100% скидка — товар бесплатный
      expect(calculateDiscountedPrice(1000, 100), 0.0);
      // Отрицательная цена вызывает ArgumentError
      expect(() => calculateDiscountedPrice(-50, 10), throwsArgumentError);
    });
  });

  // ==========================================
  // ПОВЫШЕННЫЙ УРОВЕНЬ: Widget-тест экрана
  // ==========================================
  group('2. Повышенный уровень - Widget-тест экрана', () {
    testWidgets('Ввод цены, нажатие кнопки и проверка отображения результата',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CalculatorScreen()),
      );

      // 1. Ввод текста в поле
      await tester.enterText(find.byKey(const Key('price_input')), '1000');
      await tester.pump();

      // 2. Нажатие на кнопку
      await tester.tap(find.byKey(const Key('calc_button')));
      await tester.pump();

      // 3. Проверка результата
      expect(find.text('Итог: 900 руб.'), findsOneWidget);
    });
  });

  // ==========================================
  // ТВОРЧЕСКИЙ УРОВЕНЬ: ViewModel, Mock и Логи
  // ==========================================
  group('3. Творческий уровень - Тесты ViewModel и FakeRepo', () {
    test('Успешная загрузка данных через FakeRepo', () async {
      final fakeRepo = FakeUserRepository(shouldFail: false);
      final viewModel = UserViewModel(repository: fakeRepo);

      expect(viewModel.isLoading, false);
      expect(viewModel.data, null);

      await viewModel.loadProfile('shadrin@example.com');

      expect(viewModel.isLoading, false);
      expect(viewModel.data, 'Профиль: Никита (Премиум)');
      expect(viewModel.errorMessage, null);
    });

    test('Обработка ошибки загрузки через FakeRepo', () async {
      final fakeRepo = FakeUserRepository(shouldFail: true);
      final viewModel = UserViewModel(repository: fakeRepo);

      await viewModel.loadProfile('shadrin@example.com');

      expect(viewModel.isLoading, false);
      expect(viewModel.data, null);
      expect(viewModel.errorMessage, contains('Ошибка сервера: 500'));
    });
  });
}