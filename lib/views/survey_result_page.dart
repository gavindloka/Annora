import 'dart:convert';
import 'dart:typed_data';

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

  Future<void> _loadSurveyPhoto() async {
    final result = await QuestionViewModel().getSurveyPhoto(
      widget.task.projectID.toString(),
    );
    if (result['success']) {
      setState(() {
        surveyPhotos = List<Map<String, dynamic>>.from(result['results']);
        // [result['results'][2]];
      });
    }
    print(surveyPhotos[1]);
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
    print(result['results']);
  }

  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurveyResults();
    _loadSurveyPhoto();
  }

Future<Uint8List> normalizeAndDecodeBase64(String data) async {
  try {
    data = data.replaceAll(RegExp(r'^data:image\/\w+;base64,'), '');
    data = data.replaceAll(RegExp(r'\s+'), '');

    if (data.length < 1000 || data.length > 200000) {
      print("Invalid base64 length: ${data.length}");
      return Uint8List(0);
    }

    int mod4 = data.length % 4;
    if (mod4 > 0) {
      data += '=' * (4 - mod4); 
    }

    final decoded = base64.decode(data);

    if (decoded.length < 10 || decoded[0] != 0xFF || decoded[1] != 0xD8) {
      print("Not a valid JPEG header");
      return Uint8List(0);
    }

    return decoded;
  } catch (error, stackTrace) {
    print('Decode error: $error\n$stackTrace');
    return Uint8List(0);
  }
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
          Text(
            "Question: $question",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
    List<Widget> locationItems = [];

    if (surveyPhotos.isNotEmpty) {
      String coordinate = surveyPhotos[0]['coordinate'] ?? '';
      List<String> coordinateParts = coordinate.split(',');

      if (coordinateParts.length == 2) {
        String longitude = coordinateParts[0].trim();
        String latitude = coordinateParts[1].trim();

        locationItems.add(
          _buildLocationItem(
            label: "Coordinate",
            coordinate: '$longitude, $latitude',
          ),
        );
      }
    }

    for (int index = 0; index < surveyPhotos.length; index++) {
      String label = surveyPhotos[index]['title'] ?? "No title";
      String photoUrl = surveyPhotos[index]['photo'] ?? "";

      locationItems.add(_buildLocationItem(label: label, imageUrl: photoUrl));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Detail Lokasi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.73,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.9,
            children: locationItems,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required String label,
    String? imageUrl,
    String? coordinate,
  }) {
    if (coordinate != null) {
      List<String> coordinateParts = coordinate.split(',');

      if (coordinateParts.length == 2) {
        String longitude = coordinateParts[0].trim();
        String latitude = coordinateParts[1].trim();

        return Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Longitude",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(longitude, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    "Latitude",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(latitude, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        );
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          child:
              imageUrl != null && imageUrl.isNotEmpty
                  ? Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(color: Colors.grey[200]),
                    child: FutureBuilder<Uint8List>(
                      future:
                          imageUrl != null && imageUrl.isNotEmpty
                              ? normalizeAndDecodeBase64(imageUrl)
                              : Future.value(Uint8List(0)),
                      builder: (context, snapshot) {
                        print('Base64 string length: ${imageUrl.length}');

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        final imageBytes = snapshot.data ?? Uint8List(0);
                        return Image.memory(
                          imageBytes,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  )
                  : Icon(Icons.image, size: 40, color: Colors.grey),
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
