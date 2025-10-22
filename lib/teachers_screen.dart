import 'package:flutter/material.dart';

// Map для списка преподавателей
Map<int, Map<String, dynamic>> teachers = {
  1: {
    'position': 'Профессор',
    'name': 'Иванов И.И.',
    'phone': '+7 (999) 123-45-67'
  },
  2: {
    'position': 'Доцент',
    'name': 'Петрова П.П.',
    'phone': '+7 (999) 123-45-68'
  },
  3: {
    'position': 'Старший преподаватель',
    'name': 'Сидоров С.С.',
    'phone': '+7 (999) 123-45-69'
  }
};

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список преподавателей'),
      ),
      body: ListView.builder(
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          int teacherId = index + 1;
          var teacher = teachers[teacherId];
          
          // Получение данных преподавателя
          String teacherName = teacher?['name'] ?? 'Неизвестно';
          String teacherPosition = teacher?['position'] ?? 'Неизвестно';
          String teacherPhone = teacher?['phone'] ?? 'Неизвестно';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(teacherId.toString()),
              ),
              title: Text(teacherName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Должность: $teacherPosition'),
                  Text('Телефон: $teacherPhone'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}