import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/question_view_model.dart';
import 'package:flutter/material.dart';

class SurveyResultPage extends StatefulWidget {
  final Task task;
  const SurveyResultPage({super.key, required this.task});

  @override
  State<SurveyResultPage> createState() => _SurveyResultPageState();
}

class _SurveyResultPageState extends State<SurveyResultPage>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> formData = {};
  late TabController _tabController;
  List<Map<String, dynamic>> surveyResults = [];
  List<Map<String, dynamic>> surveyPhotos = [];
  bool isLoading = true;
  bool isError = false;

  Future<void> _loadSurveyPhoto()async{
    final result = await QuestionViewModel().getSurveyPhoto(widget.task.projectID.toString());
    if (result['success']) {
      setState(() {
        surveyPhotos = List<Map<String, dynamic>>.from(result['results']);
      });
    }
  }


  Future<void> _loadSurveyResults() async {
    final result = await QuestionViewModel().getSurveyResult(
      widget.task.projectID.toString(),
    );
    if (result['success']) {
      setState(() {
        isLoading = false;
        surveyResults = List<Map<String, dynamic>>.from(result['results']);
      });
    } else {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
    print(result);
  }

  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurveyResults();
    _loadSurveyPhoto();
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
          "Survey Result",
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
                    "Start Date : ${widget.task.startDate.toString().substring(0, widget.task.startDate.toString().indexOf(' '))}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Target Date : ${widget.task.targetDate.toString().substring(0, widget.task.targetDate.toString().indexOf(' '))}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Nama Client : ${widget.task.company}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "WO ID : ${widget.task.woID}",
                    style: TextStyle(color: Colors.white),
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

  Widget _buildFormSurveyTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError) {
      return const Center(child: Text("Failed to load survey data"));
    }
    if (surveyResults.isEmpty) {
      return const Center(child: Text("No data available"));
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...surveyResults.map((questionData) {
              String question = questionData['question'] ?? 'No question';
              String answer = questionData['answer'] ?? 'No answer provided';

              return _buildQuestionAnswer(question, answer);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Question: $question", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(answer),
        ],
      ),
    );
  }

  Widget _buildLokasiSurveyTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildLocationGrid()],
        ),
      ),
    );
  }

  Widget _buildLocationGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Detail Lokasi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: 1.2,
          children: [
            _buildLocationItem(
              icon: Icons.location_pin,
              label: "Titik Koordinat",
              color: Colors.red,
            ),
            _buildLocationItem(
              icon: Icons.camera_alt,
              label: "Foto Selfie",
              color: Colors.orange,
            ),
            _buildLocationItem(
              icon: Icons.image,
              label: "Foto Tampak Depan",
              color: Colors.blue,
            ),
            _buildLocationItem(
              icon: Icons.image_outlined,
              label: "Foto Tampak Samping",
              color: Colors.purple,
            ),
            _buildLocationItem(
              icon: Icons.directions_walk,
              label: "Foto Jalan",
              color: Colors.lightBlue,
            ),
            _buildLocationItem(
              icon: Icons.landscape,
              label: "Foto Lingkungan",
              color: Colors.pink,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
