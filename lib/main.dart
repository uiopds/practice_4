import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Практика: Форма регистрации',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Ключ для управления валидацией формы (Повышенный уровень)
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей ввода (Повышенный уровень)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Состояние для Базового уровня (счётчик)
  int _counter = 0;

  // Состояния для Творческого уровня
  bool _agreedToTerms = false; // Переключатель условий
  String _selectedGroup = 'ИСП-1-23'; // Выбранная группа в Dropdown
  final List<String> _groups = ['ИСП-1-23', 'ИСП-2-23', 'ИСП-3-22', 'ИСП-4-22'];

  // Методы управления счётчиком (Базовый уровень)
  void _increment() => setState(() => _counter++);
  void _decrement() => setState(() => _counter--);
  void _reset() => setState(() => _counter = 0);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Логика отправки формы
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Показываем SnackBar (Повышенный уровень)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Регистрация выполнена'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Практика: Форма регистрации'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- БАЗОВЫЙ УРОВЕНЬ (Счётчик) ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Базовый уровень: Счётчик',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Нажато: $_counter раз',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: _decrement, child: const Text('-')),
                          const SizedBox(width: 10),
                          ElevatedButton(onPressed: _increment, child: const Text('+')),
                          const SizedBox(width: 10),
                          OutlinedButton(onPressed: _reset, child: const Text('Сброс')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Форма регистрации (Повышенный и Творческий уровни)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // --- ПОВЫШЕННЫЙ УРОВЕНЬ: Поле Имя с валидатором ---
              CustomTextField(
                controller: _nameController,
                label: 'Имя',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- ПОВЫШЕННЫЙ УРОВЕНЬ: Поле Email с валидатором ---
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Введите корректный email (должен содержать @ и .)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // --- ПОВЫШЕННЫЙ УРОВЕНЬ: Поле Пароль с валидатором ---
              CustomTextField(
                controller: _passwordController,
                label: 'Пароль',
                icon: Icons.lock,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен быть не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // --- ТВОРЧЕСКИЙ УРОВЕНЬ: Dropdown выбора группы ---
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Учебная группа',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedGroup,
                    isExpanded: true,
                    items: _groups.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGroup = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- ТВОРЧЕСКИЙ УРОВЕНЬ: Switch «Принимаю условия» ---
              SwitchListTile(
                title: const Text('Принимаю условия пользовательского соглашения'),
                value: _agreedToTerms,
                onChanged: (bool value) {
                  setState(() {
                    _agreedToTerms = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- ТВОРЧЕСКИЙ УРОВЕНЬ: Кнопка заблокирована, если Switch выключен ---
              ElevatedButton(
                onPressed: _agreedToTerms ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Зарегистрироваться',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ТВОРЧЕСКИЙ УРОВЕНЬ: Вынесенный отдельный виджет с callback (CustomTextField) ---
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}