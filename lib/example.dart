import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _textController = TextEditingController();
  Future<List<dynamic>>? _futureMessages;
  bool _isLoading = false;
  String? _username;
  String? _userId;

  // Метод для загрузки сообщений и пользователей отдельно
  Future<List<dynamic>> fetchMessages() async {
    try {
      // Загружаем сообщения
      final messages = await Supabase.instance.client
          .from('messages')
          .select()
          .order('created_at', ascending: false);

      // Загружаем пользователей
      final users = await Supabase.instance.client
          .from('users')
          .select('id, username');

      // Создаем карту пользователей для быстрого поиска по ID
      final usersMap = {
        for (var user in users) user['id']: user['username']
      };

      // Объединяем данные
      final combinedData = messages.map((message) {
        return {
          ...message,
          'username': usersMap[message['user_id']] ?? 'Неизвестный',
        };
      }).toList();

      debugPrint('Загружено сообщений: ${combinedData.length}');
      return combinedData;
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      rethrow;
    }
  }

  // Метод для добавления сообщения
  Future<void> addMessage() async {
    if (_textController.text.isEmpty) {
      _showSnackBar('Введите текст сообщения');
      return;
    }

    if (_userId == null) {
      _showSnackBar('Ошибка: пользователь не авторизован');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('messages')
          .insert({
            'user_id': _userId,
            'text': _textController.text,
          });

      _showSnackBar('Сообщение успешно добавлено');
      
      _textController.clear();
      _refreshData();
      
    } catch (e) {
      debugPrint('Ошибка добавления: $e');
      _showSnackBar('Ошибка добавления: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _userId = prefs.getString('user_id');
    });
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      });
    } catch (e) {
      debugPrint('Ошибка выхода: $e');
    }
  }

  void _refreshData() {
    setState(() {
      _futureMessages = fetchMessages();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _futureMessages = fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        actions: [
          if (_username != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text('Привет, $_username'),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Обновить список',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: Column(
        children: [
          // Форма для ввода сообщения
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Текст сообщения',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : addMessage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Добавить сообщение'),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Список сообщений
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _futureMessages,
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
                          Text('Загрузка сообщений...'),
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
                              onPressed: _refreshData,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (snapshot.hasData) {
                      final messages = snapshot.data!;
                      
                      if (messages.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Нет сообщений'),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                message['username']?.toString() ?? 'Неизвестный',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(message['text']?.toString() ?? 'Без текста'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ID: ${message['id']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'User: ${message['user_id']}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
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
        onPressed: _refreshData,
        tooltip: 'Обновить список',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}