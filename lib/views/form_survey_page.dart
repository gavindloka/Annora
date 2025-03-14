import 'package:annora_survey/models/question.dart';
import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/question_view_model.dart';
import 'package:flutter/material.dart';

class FormSurveyPage extends StatefulWidget {
  final Task task;
  const FormSurveyPage({super.key, required this.task});

  @override
  State<FormSurveyPage> createState() => _FormSurveyPageState();
}

class _FormSurveyPageState extends State<FormSurveyPage>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> formData = {};
  late TabController _tabController;
  List<Question> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchSurveyData();
  }

  Future<void> fetchSurveyData() async {
    setState(() => isLoading = true);
    final result = await QuestionViewModel().getSurveyProjectForm(widget.task.projectID.toString());

    if (result['success']) {
      setState(() {
        questions =
            (result['data']['question'] as List)
                .map((q) => Question.fromJson(q))
                .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            child: IconButton(
              iconSize: 18,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          "Form Survey",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.orange,
              size: 30,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Helper.getStatusSurveyorColor(
                  widget.task.statusSurveyor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal : ${widget.task.startDate}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Nama Client : ${widget.task.company}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "App No : ${widget.task.projectID}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.orange,
            tabs: const [Tab(text: "Lokasi Survey"), Tab(text: "Form Survey")],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildLokasiSurveyTab(), _buildFormSurveyTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiSurveyTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Lokasi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildFormSurveyTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (questions.isEmpty) {
      return const Center(child: Text("No data available"));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...questions.map((question) {
            switch (question.type) {
              case 'shorttext':
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: question.question,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      formData[question.id] = value;
                    },
                  ),
                );
              case 'dropdown':
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: question.question,
                      border: OutlineInputBorder(),
                    ),
                    items:
                        question.options
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.label,
                                child: Text(option.label),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      formData[question.id] = value;
                    },
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          }),
          ElevatedButton(
            onPressed: (){},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
