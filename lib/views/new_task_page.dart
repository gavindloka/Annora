import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/viewModels/task_view_model.dart';
import 'package:annora_survey/widgets/project_card.dart';
import 'package:flutter/material.dart';

class NewTaskPage extends StatefulWidget {
  final String email;
  const NewTaskPage({super.key, required this.email});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  List<Task> newTasks = [];
  String errorMsg = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
  final result = await TaskViewModel().getTasks(widget.email,true);
  if (result['success']) {
    setState(() {
      newTasks = result['data'];
      isLoading = false;
      print(newTasks);
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
              "New Task",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMsg.isNotEmpty
                      ? Center(child: Text(errorMsg))
                      : ListView.builder(
                              itemCount: newTasks.length,
                              itemBuilder: (context, index) {
                                return ProjectCard(task: newTasks[index]);
                              },
                      ),
            ),
          ],
        ),
      ),
    ));
  }
}
