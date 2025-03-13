import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/viewModels/task_view_model.dart';
import 'package:annora_survey/widgets/project_card.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final String email;
  const HistoryPage({super.key, required this.email});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Task> historyTasks = [];
  String errorMsg = '';
  bool isLoading = true;

  final TaskViewModel taskViewModel = TaskViewModel();

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final result = await TaskViewModel().getTasks(widget.email, false);
    if (result['success']) {
      setState(() {
        historyTasks = result['data'];
        isLoading = false;
        print(historyTasks);
      });
    } else {
      setState(() {
        errorMsg = result['message'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History Task",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMsg.isNotEmpty
                      ? Center(child: Text(errorMsg))
                      : ListView.builder(
                        itemCount: historyTasks.length,
                        itemBuilder: (context, index) {
                          return ProjectCard(task: historyTasks[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    ));
  }
}
