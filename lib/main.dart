import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Инициализация движка Flutter перед асинхронными вызовами
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCalcApp());
}

class SmartCalcApp extends StatelessWidget {
  const SmartCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCalc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amber,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ============================================================================
// ГЛАВНЫЙ ЭКРАН С НАВИГАЦИЕЙ, ЖИЗНЕННЫМ ЦИКЛОМ И SHAREDPREFERENCES
// ============================================================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CalculatorScreen(),
    DiscountScreen(),
    ConverterScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Регистрация наблюдателя системного жизненного цикла приложения
    WidgetsBinding.instance.addObserver(this);
    // Восстановление сохраненного состояния из памяти
    _loadState();
  }

  @override
  void dispose() {
    // Удаление наблюдателя при завершении работы экрана
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // --- Отслеживание жизненного цикла (WidgetsBindingObserver) ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // При сворачивании приложения сохраняем активный экран в хранилище
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _saveState();
    }
  }

  // --- Сохранение и загрузка данных (SharedPreferences) ---
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_screen_index', _currentIndex);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentIndex = prefs.getInt('active_screen_index') ?? 0;
      });
    }
  }

  // --- Навигационная панель (BottomNavigationBar) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _saveState();
        },
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.percent),
            label: 'Скидки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Конвертер',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. ЭКРАН: КАЛЬКУЛЯТОР
// ============================================================================
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _currentNumber = "";
  double _num1 = 0;
  String _operand = "";

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _currentNumber = "";
        _num1 = 0;
        _operand = "";
      } else if (buttonText == "⌫") {
        if (_currentNumber.isNotEmpty) {
          _currentNumber = _currentNumber.substring(0, _currentNumber.length - 1);
          _output = _currentNumber.isEmpty ? "0" : _currentNumber;
        }
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
        if (_currentNumber.isNotEmpty) {
          _num1 = double.tryParse(_currentNumber) ?? 0;
          _operand = buttonText;
          _currentNumber = "";
        }
      } else if (buttonText == ".") {
        if (!_currentNumber.contains(".")) {
          _currentNumber = _currentNumber.isEmpty ? "0." : _currentNumber + ".";
          _output = _currentNumber;
        }
      } else if (buttonText == "=") {
        if (_operand.isNotEmpty && _currentNumber.isNotEmpty) {
          double num2 = double.tryParse(_currentNumber) ?? 0;
          double res = 0;
          if (_operand == "+") res = _num1 + num2;
          if (_operand == "-") res = _num1 - num2;
          if (_operand == "×") res = _num1 * num2;
          if (_operand == "÷") res = num2 != 0 ? _num1 / num2 : 0;

          _output = res % 1 == 0 ? res.toInt().toString() : res.toStringAsFixed(2);
          _currentNumber = _output;
          _operand = "";
        }
      } else {
        _currentNumber += buttonText;
        _output = _currentNumber;
      }
    });
  }

  Widget _buildButton(String text, {Color? color, Color textColor = Colors.white}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF2C2C2C),
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Калькулятор",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Text(
              _output,
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Row(
                children: [
                  _buildButton("C", color: const Color(0xFF8B2525)),
                  _buildButton("⌫", color: const Color(0xFF384654)),
                  _buildButton("÷", color: const Color(0xFF2E3D6E)),
                ],
              ),
              Row(
                children: [
                  _buildButton("7"),
                  _buildButton("8"),
                  _buildButton("9"),
                  _buildButton("×", color: const Color(0xFF2E3D6E)),
                ],
              ),
              Row(
                children: [
                  _buildButton("4"),
                  _buildButton("5"),
                  _buildButton("6"),
                  _buildButton("-", color: const Color(0xFF2E3D6E)),
                ],
              ),
              Row(
                children: [
                  _buildButton("1"),
                  _buildButton("2"),
                  _buildButton("3"),
                  _buildButton("+", color: const Color(0xFF2E3D6E)),
                ],
              ),
              Row(
                children: [
                  _buildButton("0"),
                  _buildButton("."),
                  _buildButton("=", color: const Color(0xFF2E7D32)),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 2. ЭКРАН: СКИДКИ И НАЛОГИ
// ============================================================================
class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  final TextEditingController _priceController = TextEditingController();
  double _discountPercent = 10;
  double _savings = 0;
  double _finalPrice = 0;

  void _calculate() {
    double price = double.tryParse(_priceController.text) ?? 0;
    setState(() {
      _savings = price * (_discountPercent / 100);
      _finalPrice = price - _savings;
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Скидки и налоги",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                labelText: "Исходная цена (руб)",
                prefixIcon: const Icon(Icons.attach_money, color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Процент скидки:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                Text(
                  "${_discountPercent.toInt()}%",
                  style: const TextStyle(color: Colors.indigoAccent, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _discountPercent,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: Colors.indigoAccent,
              onChanged: (val) {
                setState(() => _discountPercent = val);
                _calculate();
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E212B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Экономия:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text(
                        "${_savings.toStringAsFixed(2)} ₽",
                        style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Итоговая цена:", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "${_finalPrice.toStringAsFixed(2)} ₽",
                        style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. ЭКРАН: КОНВЕРТЕР ВЕЛИЧИН
// ============================================================================
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _valController = TextEditingController();
  String _conversionType = "Длина: метры → километры";
  String _result = "0.000";

  final List<String> _types = const [
    "Длина: метры → километры",
    "Длина: километры → мили",
    "Масса: килограммы → фунты",
    "Температура: °C → °F",
  ];

  void _convert() {
    double val = double.tryParse(_valController.text) ?? 0;
    double res = 0;

    switch (_conversionType) {
      case "Длина: метры → километры":
        res = val / 1000;
        break;
      case "Длина: километры → мили":
        res = val * 0.621371;
        break;
      case "Масса: килограммы → фунты":
        res = val * 2.20462;
        break;
      case "Температура: °C → °F":
        res = (val * 9 / 5) + 32;
        break;
    }

    setState(() {
      _result = res.toStringAsFixed(3);
    });
  }

  @override
  void dispose() {
    _valController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Конвертер величин",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: _conversionType,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              dropdownColor: const Color(0xFF1E1E1E),
              decoration: InputDecoration(
                labelText: "Тип конвертации",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _conversionType = val);
                  _convert();
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _valController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                labelText: "Значение для перевода",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2F38),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Результат: ", style: TextStyle(color: Colors.white70, fontSize: 18)),
                  Text(
                    _result,
                    style: const TextStyle(color: Color(0xFF5C8DFF), fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}