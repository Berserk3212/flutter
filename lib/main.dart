import 'package:flutter/material.dart';
import 'teachers_screen.dart';
import 'subjects_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      routes: {
        '/teachers': (context) => const TeachersScreen(),
        '/subjects': (context) => const SubjectsScreen(),
        '/profile': (context) => const ProfileScreen(), // Добавляем маршрут профиля
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное меню'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка перехода на экран преподавателей
            ElevatedButton(
              onPressed: () {
                // Способ 1: Named routes
                Navigator.pushNamed(context, '/teachers');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Преподаватели'),
            ),
            const SizedBox(height: 20),
            
            // Кнопка перехода на экран предметов
            ElevatedButton(
              onPressed: () {
                // Способ 2: MaterialPageRoute
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SubjectsScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Предметы'),
            ),
            const SizedBox(height: 20),
            
            // Кнопка перехода на экран профиля
            ElevatedButton(
              onPressed: () {
                // Способ 3: Named routes с переходом на профиль
                Navigator.pushNamed(context, '/profile');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text('Мой профиль'),
            ),
          ],
        ),
      ),
    );
  }
}