import 'package:flutter/material.dart';

// Map для списка предметов
Map<int, Map<String, dynamic>> subjects = {
  1: {
    'name': 'Математика',
    'duration': 90,
    'day': 'Понедельник'
  },
  2: {
    'name': 'Физика',
    'duration': 120,
    'day': 'Вторник'
  },
  3: {
    'name': 'Программирование',
    'duration': 150,
    'day': 'Среда'
  }
};

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список предметов'),
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          int subjectId = index + 1;
          var subject = subjects[subjectId];
          
          // Получение данных предмета
          String subjectName = subject?['name'] ?? 'Неизвестно';
          int subjectDuration = subject?['duration'] ?? 0;
          String subjectDay = subject?['day'] ?? 'Неизвестно';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(subjectId.toString()),
              ),
              title: Text(subjectName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Продолжительность: $subjectDuration минут'),
                  Text('День недели: $subjectDay'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}