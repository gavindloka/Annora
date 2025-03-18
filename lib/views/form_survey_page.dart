import 'package:annora_survey/models/question.dart';
import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/question_view_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

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
  String _selectedLocationItem = "";
  bool _isDetailVisible = false;

  final ImagePicker _picker = ImagePicker();
  File? _imageSelfie;
  File? _imageTampakDepan;
  File? _imageTampakSamping;
  File? _imageJalan;
  File? _imageLingkungan;
  File? _imageTitikKoordinat;

  String? _imageSelfieBase64;
  String? _imageTampakDepanBase64;
  String? _imageTampakSampingBase64;
  String? _imageJalanBase64;
  String? _imageLingkunganBase64;
  String? _imageTitikKoordinatBase64;

  String _latitude = "Loading...";
  String _longitude = "Loading...";

  bool _isLocationFetched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchSurveyData();
  }

  Future<void> fetchSurveyData() async {
    setState(() => isLoading = true);
    final result = await QuestionViewModel().getSurveyProjectForm(
      widget.task.projectID.toString(),
    );

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

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _updateImageVariable(File(pickedFile.path));
      });
    }
  }

  Future<void> _choosePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _updateImageVariable(File(pickedFile.path));
      });
    }
  }

  void _updateImageVariable(File image) async {
    List<int> imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    switch (_selectedLocationItem) {
      case "Foto Selfie":
        _imageSelfie = image;
        _imageSelfieBase64 = base64Image;
        print("ini base imageselfie: $_imageSelfieBase64");
        break;
      case "Foto Tampak Depan":
        _imageTampakDepan = image;
        _imageTampakDepanBase64 = base64Image;
        print(_imageTampakDepanBase64);
        break;
      case "Foto Tampak Samping":
        _imageTampakSamping = image;
        _imageTampakSampingBase64 = base64Image;
        print(_imageTampakSampingBase64);
        break;
      case "Foto Jalan":
        _imageJalan = image;
        _imageJalanBase64 = base64Image;
        print(_imageJalanBase64);
        break;
      case "Foto Lingkungan":
        _imageLingkungan = image;
        _imageLingkunganBase64 = base64Image;
        print(_imageLingkunganBase64);
        break;
      case "Titik Koordinat":
        _imageTitikKoordinat = image;
        _imageTitikKoordinatBase64 = base64Image;
        print(_imageTitikKoordinatBase64);
        break;
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLocationFetched) return;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showPermissionDialog(
        "Location Services Disabled",
        "Please enable location services in your settings.",
        openSettings: false,
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog(
          "Location Permission Required",
          "This app needs location access to work properly.",
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog(
        "Location Permission Denied Forever",
        "You have permanently denied location access. Please enable it in settings.",
        openSettings: true,
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _isLocationFetched = true;
      });
    } catch (e) {
      _showPermissionDialog("Error", "Failed to get location: $e");
    }
  }

  void _showPermissionDialog(
    String title,
    String message, {
    bool openSettings = false,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              if (openSettings)
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text("Open Settings"),
                ),
            ],
          ),
    );
  }

Future<Map<String, dynamic>> prepareSurveyData() async {
  List<Map<String, dynamic>> surveyResults = [];

  formData.forEach((id, answer) {
    var question = questions.firstWhere((q) => q.id == id);
    
    surveyResults.add({
      "id_pertanyaan": id,
      "pertanyaan": question.question,
      "jawaban": answer,
    });
  });

  Map<String, dynamic> surveyData = {
    "project_id": widget.task.projectID,
    "survey_results": surveyResults,
  };

  return surveyData;
}

  Future<void> _submitSurveyForm() async {
  if (formData.isEmpty) {
    _showErrorDialog("Form is empty", "Please fill out all the fields.");
    return;
  }

  Map<String, dynamic> surveyData = await prepareSurveyData();

  final result = await QuestionViewModel().addSurveyResult(surveyData);

  if (result['success']) {
    _showSuccessDialog(
      "Survey Submitted",
      "Your survey has been successfully submitted.",
    );
    print(result['data']);
  } else {
    _showErrorDialog("Submission Failed", result['message']);
  }
}
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isDetailVisible ? _buildLocationDetail() : _buildLocationGrid(),
          ],
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocationItem = label;
          _isDetailVisible = true;
        });
      },
      child: Column(
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
    return SingleChildScrollView(
      child: Padding(
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
              onPressed: _submitSurveyForm,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDetail() {
    if (_selectedLocationItem == "Titik Koordinat") {
      _getCurrentLocation();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 5,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orange),
                onPressed: () {
                  setState(() {
                    _isLocationFetched = false;
                    _isDetailVisible = false;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedLocationItem,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_selectedLocationItem == "Titik Koordinat") ...[
          Text("Latitude: $_latitude", style: const TextStyle(fontSize: 16)),
          Text("Longitude: $_longitude", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
        ],
        if (_selectedLocationItem != "Titik Koordinat")
          _buildImagePlaceholder(),

        const SizedBox(height: 30),

        if (_selectedLocationItem != "Titik Koordinat")
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Take Photo"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              ElevatedButton.icon(
                onPressed: _choosePhoto,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text("Choose Photo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 121, 179, 227),
                ),
              ),
            ],
          ),
        // const SizedBox(height: 30),
        // Center(
        //   child: ElevatedButton(
        //     onPressed: () {},
        //     style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        //     child: const Text("Save", style: TextStyle(color: Colors.white)),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    File? selectedImage;

    switch (_selectedLocationItem) {
      case "Foto Selfie":
        selectedImage = _imageSelfie;
        break;
      case "Foto Tampak Depan":
        selectedImage = _imageTampakDepan;
        break;
      case "Foto Tampak Samping":
        selectedImage = _imageTampakSamping;
        break;
      case "Foto Jalan":
        selectedImage = _imageJalan;
        break;
      case "Foto Lingkungan":
        selectedImage = _imageLingkungan;
        break;
      case "Titik Koordinat":
        selectedImage = _imageTitikKoordinat;
        break;
    }

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image:
            selectedImage != null
                ? DecorationImage(
                  image: FileImage(selectedImage),
                  fit: BoxFit.cover,
                )
                : null,
      ),
      child:
          selectedImage == null
              ? Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.home, size: 80, color: Colors.grey),
                ),
              )
              : null,
    );
  }
}
