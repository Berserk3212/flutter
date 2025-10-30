import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://diatfsydzbqpfdzwcgil.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRpYXRmc3lkemJxcGZkendjZ2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyMTIxNzIsImV4cCI6MjA3Njc4ODE3Mn0.o5w70G_DuDtwR2MEaylJC68g-UTN5dzOJmVVmzVog8w',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  
  Future<List<dynamic>>? _futureMessages;
  bool _isLoading = false;

  // Метод для загрузки данных из таблицы messages
  Future<List<dynamic>> fetchMessages() async {
    try {
      final data = await Supabase.instance.client
          .from('messages')
          .select()
          .order('id', ascending: false); // Сортировка по ID (новые сверху)
      
      debugPrint('Загружено сообщений: ${data.length}');
      return data;
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
      rethrow;
    }
  }

  // Метод для добавления данных в таблицу messages
  Future<void> addMessage() async {
    if (_usernameController.text.isEmpty || _textController.text.isEmpty) {
      _showSnackBar('Заполните username и text');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('messages')
          .insert({
            'username': _usernameController.text,
            'text': _textController.text,
            // ID обычно генерируется автоматически в базе данных
            // Если нужно ручное указание ID, раскомментируйте:
            // 'id': int.tryParse(_idController.text) ?? 0,
          });

      _showSnackBar('Сообщение успешно добавлено');
      
      // Очищаем поля после успешного добавления
      _clearFields();
      
      // Обновляем список
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

  void _refreshData() {
    setState(() {
      _futureMessages = fetchMessages();
    });
  }

  void _clearFields() {
    _idController.clear();
    _usernameController.clear();
    _textController.clear();
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
    _futureMessages = fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Supabase Messages'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Обновить список',
            ),
          ],
        ),
        body: Column(
          children: [
            // Форма для ввода данных
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID (опционально)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Text',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : addMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _refreshData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Загрузить сообщения'),
                        ),
                      ),
                    ],
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
                                  message['username']?.toString() ?? 'Без имени',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(message['text']?.toString() ?? 'Без текста'),
                                trailing: Text(
                                  'ID: ${message['id']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _usernameController.dispose();
    _textController.dispose();
    super.dispose();
  }
}