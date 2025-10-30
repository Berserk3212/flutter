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
  Future<List<dynamic>>? _futureMsgs;

  Future<List<dynamic>> fetchMsgs() async {
    final data = await Supabase.instance.client
        .from('messages')
        .select();
    
    // Для отладки (уберите в продакшене)
    debugPrint(data.runtimeType.toString());
    if (data.isNotEmpty) {
      debugPrint(data[0]['text'].toString());
    }
    
    return data;
  }

  void _refreshData() {
    setState(() {
      _futureMsgs = fetchMsgs();
    });
  }

  @override
  void initState() {
    super.initState();
    _futureMsgs = fetchMsgs();
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
            ),
          ],
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _futureMsgs,
          builder: (context, snapshot) {
            // Отображаем состояние подключения
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
                      Text('Загрузка данных...'),
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
                    return const Center(child: Text('Нет сообщений'));
                  }
                  
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message['text']?.toString() ?? 'Без текста'),
                        subtitle: Text('ID: ${message['id']}'),
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                      );
                    },
                  );
                }
                
                return const Center(child: Text('Нет данных'));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refreshData,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}