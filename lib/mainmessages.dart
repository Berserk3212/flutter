import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';
import 'register.dart';
import 'example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://diatfsydzbqpfdzwcgil.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpYXRmc3lkemJxcGZkendjZ2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMTIxNzIsImV4cCI6MjA3Njc4ODE3Mn0.o5w70G_DuDtwR2MEaylJC68g-UTN5dzOJmVVmzVog8w',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/messages': (context) => const MessagesScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<List<dynamic>>? _futureUsers;

  // Метод для загрузки пользователей
  Future<List<dynamic>> fetchUsers() async {
    try {
      final data = await Supabase.instance.client
          .from('users')
          .select('id, username, created_at')
          .order('created_at', ascending: false);
      
      debugPrint('Загружено пользователей: ${data.length}');
      return data;
    } catch (e) {
      debugPrint('Ошибка загрузки пользователей: $e');
      rethrow;
    }
  }

  void _refreshUsers() {
    setState(() {
      _futureUsers = fetchUsers();
    });
  }

  @override
  void initState() {
    super.initState();
    _futureUsers = fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'Обновить список пользователей',
          ),
        ],
      ),
      body: Column(
        children: [
          // Кнопки регистрации и входа
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: const Text('Регистрация'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  ),
                  child: const Text('Вход'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Заголовок списка пользователей
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Список пользователей',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _refreshUsers,
                  tooltip: 'Обновить список',
                ),
              ],
            ),
          ),
          
          // Список пользователей
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureUsers,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const Center(child: Text('Не начато'));
                    
                  case ConnectionState.waiting:
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Загрузка пользователей...'),
                        ],
                      ),
                    );
                    
                  case ConnectionState.active:
                    return const Center(child: Text('Загрузка...'));
                    
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Ошибка: ${snapshot.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshUsers,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (snapshot.hasData) {
                      final users = snapshot.data!;
                      
                      if (users.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Нет пользователей'),
                              SizedBox(height: 8),
                              Text('Зарегистрируйтесь первым!'),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final createdAt = user['created_at'] != null 
                              ? DateTime.parse(user['created_at']).toString().substring(0, 16)
                              : 'Неизвестно';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                user['username']?.toString() ?? 'Без имени',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ID: ${user['id']}'),
                                  Text('Создан: $createdAt'),
                                ],
                              ),
                              trailing: const Icon(Icons.person, color: Colors.grey),
                            ),
                          );
                        },
                      );
                    }
                    
                    return const Center(child: Text('Нет данных'));
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshUsers,
        tooltip: 'Обновить список пользователей',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}