import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedDark = prefs.getBool('is_dark_mode') ?? false;
  runApp(ShadrinkalkApp(initialDarkMode: savedDark));
}

class ShadrinkalkApp extends StatefulWidget {
  final bool initialDarkMode;

  const ShadrinkalkApp({super.key, required this.initialDarkMode});

  @override
  State<ShadrinkalkApp> createState() => _ShadrinkalkAppState();
}

class _ShadrinkalkAppState extends State<ShadrinkalkApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'shadrinkalk',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    CalculatorScreen(),
    DiscountScreen(),
    ConverterScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('--> HomeScreen: initState (Главный экран создан)');
    _loadSavedTab();
  }

  Future<void> _loadSavedTab() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('selected_tab') ?? 0;
    if (mounted && savedIndex >= 0 && savedIndex < _pages.length) {
      setState(() {
        _selectedIndex = savedIndex;
      });
    }
  }

  Future<void> _onTabTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_tab', index);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('--> Жизненный цикл приложения: $state');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('--> HomeScreen: dispose (Экран уничтожен)');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'shadrinkalk',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Включить светлую тему'
                : 'Включить тёмную тему',
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          NavigationDestination(
            icon: Icon(Icons.percent_outlined),
            selectedIcon: Icon(Icons.percent),
            label: 'Скидки',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Конвертер',
          ),
        ],
      ),
    );
  }
}

// ==================== 1. КАЛЬКУЛЯТОР ====================

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _history = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onButtonPressed(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _history = '';
        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = false;
        return;
      }

      if (label == '⌫') {
        if (_display == 'Ошибка' || _shouldResetDisplay) {
          _display = '0';
          _shouldResetDisplay = false;
          return;
        }
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
          if (_display == '-') _display = '0';
        } else {
          _display = '0';
        }
        return;
      }

      if (label == '%') {
        final value = double.tryParse(_display);
        if (value != null) {
          _display = _formatNumber(value / 100);
        }
        return;
      }

      if (['+', '-', '×', '÷'].contains(label)) {
        final current = double.tryParse(_display);
        if (current == null) return;

        if (_firstOperand != null && _operator != null && !_shouldResetDisplay) {
          final result = _calculate(_firstOperand!, current, _operator!);
          if (result == null) {
            _display = 'Ошибка';
            _history = '';
            _firstOperand = null;
            _operator = null;
            _shouldResetDisplay = true;
            return;
          }
          _firstOperand = result;
          _display = _formatNumber(result);
        } else {
          _firstOperand = current;
        }

        _operator = label;
        _history = '${_formatNumber(_firstOperand!)} $label';
        _shouldResetDisplay = true;
        return;
      }

      if (label == '=') {
        if (_firstOperand == null || _operator == null) return;
        final secondOperand = double.tryParse(_display);
        if (secondOperand == null) return;

        final result = _calculate(_firstOperand!, secondOperand, _operator!);
        _history =
            '${_formatNumber(_firstOperand!)} $_operator ${_formatNumber(secondOperand)} =';

        if (result == null) {
          _display = 'Ошибка';
        } else {
          _display = _formatNumber(result);
        }

        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = true;
        return;
      }

      // Цифры и точка
      if (_display == 'Ошибка' || _shouldResetDisplay) {
        _display = (label == '.') ? '0.' : label;
        _shouldResetDisplay = false;
        return;
      }

      if (label == '.') {
        if (!_display.contains('.')) {
          _display += '.';
        }
        return;
      }

      if (_display == '0') {
        _display = label;
      } else if (_display.length < 15) {
        _display += label;
      }
    });
  }

  double? _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return null;
        return a / b;
      default:
        return b;
    }
  }

  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) return 'Ошибка';
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    return double.parse(value.toStringAsFixed(8)).toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buttons = [
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['0', '.', '='],
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Дисплей
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _history,
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Сетка кнопок
          Expanded(
            child: Column(
              children: buttons.map((row) {
                return Expanded(
                  child: Row(
                    children: row.map((label) {
                      final isEqual = label == '=';
                      final isClear = label == 'C';
                      final isOp = ['÷', '×', '-', '+', '%', '⌫'].contains(label);

                      Color bgColor;
                      Color fgColor;

                      if (isEqual) {
                        bgColor = colors.primary;
                        fgColor = colors.onPrimary;
                      } else if (isClear) {
                        bgColor = colors.errorContainer;
                        fgColor = colors.onErrorContainer;
                      } else if (isOp) {
                        bgColor = colors.secondaryContainer;
                        fgColor = colors.onSecondaryContainer;
                      } else {
                        bgColor = colors.surfaceContainerLow;
                        fgColor = colors.onSurface;
                      }

                      return Expanded(
                        flex: label == '0' ? 2 : 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox.expand(
                            child: FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                backgroundColor: bgColor,
                                foregroundColor: fgColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => _onButtonPressed(label),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 2. РАСЧЁТ СКИДОК ====================

class DiscountScreen extends StatefulWidget {
  const DiscountScreen({super.key});

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  final TextEditingController _priceController = TextEditingController();
  double _discountPercent = 15;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rawText = _priceController.text.replaceAll(',', '.');
    final price = double.tryParse(rawText) ?? 0.0;
    final saved = price * (_discountPercent / 100);
    final finalPrice = price - saved;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Исходная цена (₽)',
              hintText: 'Например: 2500',
              prefixIcon: const Icon(Icons.payments_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Размер скидки:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                '${_discountPercent.round()}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _discountPercent,
            min: 0,
            max: 90,
            divisions: 18,
            label: '${_discountPercent.round()}%',
            onChanged: (value) {
              setState(() {
                _discountPercent = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: colors.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Итоговая цена:',
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        '${finalPrice.toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ваша экономия:',
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.onSecondaryContainer,
                        ),
                      ),
                      Text(
                        '${saved.toStringAsFixed(2)} ₽',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 3. КОНВЕРТЕР ВЕЛИЧИН ====================

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  int _categoryIndex = 0; // 0: Длина, 1: Масса, 2: Температура

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final val =
        double.tryParse(_inputController.text.replaceAll(',', '.')) ?? 0.0;

    String inputLabel;
    String result1Title;
    String result1Value;
    String result2Title;
    String result2Value;

    if (_categoryIndex == 0) {
      inputLabel = 'Значение в метрах (м)';
      result1Title = 'Километры (км)';
      result1Value = '${(val / 1000).toStringAsFixed(4)} км';
      result2Title = 'Сантиметры (см)';
      result2Value = '${(val * 100).toStringAsFixed(1)} см';
    } else if (_categoryIndex == 1) {
      inputLabel = 'Значение в килограммах (кг)';
      result1Title = 'Граммы (г)';
      result1Value = '${(val * 1000).toStringAsFixed(1)} г';
      result2Title = 'Тонны (т)';
      result2Value = '${(val / 1000).toStringAsFixed(4)} т';
    } else {
      inputLabel = 'Температура в Цельсиях (°C)';
      result1Title = 'Фаренгейты (°F)';
      result1Value = '${(val * 9 / 5 + 32).toStringAsFixed(2)} °F';
      result2Title = 'Кельвины (K)';
      result2Value = '${(val + 273.15).toStringAsFixed(2)} K';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Длина')),
              ButtonSegment(value: 1, label: Text('Масса')),
              ButtonSegment(value: 2, label: Text('Градусы')),
            ],
            selected: {_categoryIndex},
            onSelectionChanged: (selection) {
              setState(() {
                _categoryIndex = selection.first;
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _inputController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(
              labelText: inputLabel,
              hintText: 'Введите число',
              prefixIcon: const Icon(Icons.straighten),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: colors.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(result1Title, style: const TextStyle(fontSize: 16)),
                      Text(
                        result1Value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(result2Title, style: const TextStyle(fontSize: 16)),
                      Text(
                        result2Value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}