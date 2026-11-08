import 'package:flutter/material.dart';
import 'calculator.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';

  void _calculate() {
    final price = double.tryParse(_controller.text);
    if (price == null) {
      setState(() => _result = 'Неверный ввод');
      return;
    }

    // Применяем 10% фиксированную скидку для проверки
    final finalPrice = calculateDiscountedPrice(price, 10);
    setState(() {
      _result = 'Итог: ${finalPrice.toStringAsFixed(0)} руб.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор скидки')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: const Key('price_input'),
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Введите цену'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('calc_button'),
              onPressed: _calculate,
              child: const Text('Рассчитать скидку'),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              key: const Key('result_text'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}