import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "To-Do App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHome(),
    );
  }
}

class TodoHome extends StatefulWidget {
  const TodoHome({super.key});

  @override
  State<TodoHome> createState() => _TodoHomeState();
}

class _TodoHomeState extends State<TodoHome> {
  final Box tasks = Hive.box("tasks");
  final TextEditingController controller = TextEditingController();

  void addTask() {
    if (controller.text.isEmpty) return;
    tasks.add({"title": controller.text, "done": false});
    controller.clear();
  }

  void toggleTask(int index) {
    final task = tasks.getAt(index);
    tasks.putAt(index, {
      "title": task["title"],
      "done": !task["done"],
    });
  }

  void deleteTask(int index) {
    tasks.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do App"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Görev ekle...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    addTask();
                    setState(() {});
                  },
                  child: const Text("Ekle"),
                )
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: tasks.listenable(),
              builder: (context, box, child) {
                if (box.isEmpty) {
                  return const Center(
                    child: Text("Henüz görev yok"),
                  );
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final task = box.getAt(index);
                    final done = task["done"];

                    return ListTile(
                      title: Text(
                        task["title"],
                        style: TextStyle(
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          color: done ? Colors.grey : Colors.black,
                        ),
                      ),
                      leading: Checkbox(
                        value: done,
                        onChanged: (_) {
                          toggleTask(index);
                          setState(() {});
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
