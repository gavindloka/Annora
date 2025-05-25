import 'dart:typed_data';

import 'package:annora_survey/models/notif.dart';
import 'package:annora_survey/models/question.dart';
import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/models/user.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/notif_view_model.dart';
import 'package:annora_survey/viewModels/question_view_model.dart';
import 'package:annora_survey/views/main_page.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FormSurveyPage extends StatefulWidget {
  final Task task;
  final User user;
  const FormSurveyPage({super.key, required this.task, required this.user});

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

  Map<String, String> surveyPhotos = {};

  List<Notif> notifications = [];

  bool _isLoadingPhotoTitles = true;
  List<String> _photoTitles = [];

  Map<String, File?> _imageFiles = {};

  Future<void> fetchNotifications() async {
    final result = await NotifViewModel().getNotifications(widget.user.email);
    if (result['success']) {
      setState(() {
        notifications = result['data'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchSurveyData();
    await fetchSurveyPhotos();
    await fetchNotifications();
    await _fetchPhotoTitles();
  }

  Future<void> _fetchPhotoTitles() async {
    setState(() {
      _isLoadingPhotoTitles = true;
    });

    final result = await QuestionViewModel().getTitlePhoto(
      questions.first.surveyID,
    );

    print("Full result: $result");

    if (result['success']) {
      print("Result data type: ${result['data'].runtimeType}");
      print("Result data: ${result['data']}");

      setState(() {
        if (result['data'] is List) {
          _photoTitles =
              (result['data'] as List)
                  .map<String>((item) => item['title'] as String)
                  .toList();
        } else if (result['data'] is Map) {
          _photoTitles =
              (result['data']['data'] as List)
                  .map<String>((item) => item['title'] as String)
                  .toList();
        } else {
          _photoTitles = [];
          print("Unexpected data type: ${result['data'].runtimeType}");
        }

        _imageFiles = {
          "Titik Koordinat": _imageTitikKoordinat,
          for (String title in _photoTitles) title: null,
        };

        _selectedLocationItem =
            _photoTitles.isNotEmpty ? _photoTitles.first : '';
        print("Photo titles: $_photoTitles");
      });
    } else {
      _showErrorDialog('Error', result['message']);
      print("Error result: ${result['message']}");
    }

    setState(() {
      _isLoadingPhotoTitles = false;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm"),
            content: const Text(
              "Are you sure you want to leave? You may lose your progress.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop();
                },
                child: const Text("Yes"),
              ),
            ],
          ),
    );
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
        print(questions.length);
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

  Future<void> fetchSurveyPhotos() async {
    final result = await QuestionViewModel().getSurveyPhoto(
      widget.task.projectID.toString(),
    );

    if (result['success']) {
      for (var photo in result['results']) {
        surveyPhotos[photo['title']] = photo['photo'];

        if (photo['coordinate'] != null) {
          final parts = photo['coordinate'].split(',');
          if (parts.length == 2) {
            setState(() {
              _latitude = parts[0].trim();
              _longitude = parts[1].trim();
              _isLocationFetched = true;
            });
          }
        }
      }
      setState(() {});
    } else {
      print(result['message']);
    }
  }

  void _updateImageVariable(File image) async {
    List<int> imageBytes = await image.readAsBytes();

    Uint8List uint8ListImageBytes = Uint8List.fromList(imageBytes);
    var compressedImage = await FlutterImageCompress.compressWithList(
      uint8ListImageBytes,
      minWidth: 300,
      minHeight: 300,
      quality: 85,
      format: CompressFormat.jpeg,
    );

    if (compressedImage.isEmpty) {
      print("Image compression failed or returned empty.");
      return;
    }

    String base64Image;
    try {
      base64Image = base64Encode(compressedImage);
      print("Image compressed and encoded successfully.");
    } catch (e) {
      print("Failed to base64 encode: $e");
      return;
    }

    setState(() {
      surveyPhotos[_selectedLocationItem] = base64Image;
    });
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
    for (var question in questions) {
      if (question.required == 'Y' &&
          (formData[question.id] == null || formData[question.id].isEmpty)) {
        _showErrorDialog(
          "Validation Error",
          "Please fill out the required field: ${question.question}",
        );
        return;
      }
    }

    Map<String, dynamic> surveyData = await prepareSurveyData();

    final result = await QuestionViewModel().addSurveyResult(surveyData);

    if (result['success']) {
      await _showSuccessDialog(
        "Survey Submitted",
        "Your survey has been successfully submitted. The survey answers will be checked by the central admin.",
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainPage(user: widget.user)),
      );

      print(result['data']);
    } else {
      _showErrorDialog("Submission Failed", result['message']);
    }
  }

  Future<void> _showErrorDialog(String title, String message) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _addPhoto(
    String projectID,
    String title,
    String photo,
    String coordinate,
  ) async {
    try {
      final result = await QuestionViewModel().addPhoto(
        projectID,
        title,
        photo,
        coordinate,
      );
      if (result['success']) {
        await _showSuccessDialog(
          "Photo Added Successfully",
          "The $title photo has been uploaded successfully.",
        );
        setState(() {
          _isLocationFetched = false;
        });
      } else {
        await _showErrorDialog(
          "Failed to Add Photo",
          result['message'] ?? "Something went wrong.",
        );
      }
    } catch (e) {
      await _showErrorDialog(
        "Error",
        "An error occurred while adding the photo: $e",
      );
    }
  }

  Future<void> _addCoordinate(
    String projectID,
    String latitude,
    String longitude,
  ) async {
    try {
      final result = await QuestionViewModel().addCoordinate(
        projectID,
        latitude,
        longitude,
      );
      if (result['success']) {
        await _showSuccessDialog(
          "Coordinate Added Successfully",
          "The coordinates have been added successfully.",
        );
        setState(() {
          _isLocationFetched = false;
        });
      } else {
        await _showErrorDialog(
          "Failed to Add Coordinates",
          result['message'] ?? "Something went wrong.",
        );
      }
    } catch (e) {
      await _showErrorDialog(
        "Error",
        "An error occurred while adding the coordinates: $e",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount =
        notifications.where((notif) => notif.status == "unread").length;
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
              onPressed: _showConfirmationDialog,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              PopupMenuButton(
                icon: const Icon(
                  Icons.notifications,
                  size: 30,
                  color: Colors.amber,
                ),
                itemBuilder: (context) {
                  if (isLoading) {
                    return [
                      const PopupMenuItem(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ];
                  }
                  if (notifications.isEmpty) {
                    return [
                      const PopupMenuItem(child: Text("No new notifications")),
                    ];
                  }
                  return notifications.map((notif) {
                    bool isUnread = notif.status == "unread";

                    return PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          isUnread
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: isUnread ? Colors.orange : Colors.grey,
                        ),
                        title: Text(
                          notif.notification,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(notif.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                    );
                  }).toList();
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 5,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
                    "App No : ${widget.task.appNo}",
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
    if (_isLoadingPhotoTitles) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
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
                childAspectRatio: 1,
                children: [
                  _buildLocationItem(
                    icon: Icons.location_pin,
                    label: "Titik Koordinat",
                    color: Colors.red,
                  ),
                  ..._photoTitles
                      .map(
                        (title) => _buildLocationItem(
                          icon: Icons.image,
                          label: title,
                          color: Colors.blue,
                        ),
                      )
                      .toList(),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              if (_selectedLocationItem != "Titik Koordinat" &&
                  (_latitude == "Loading..." || _longitude == "Loading...")) {
                _showErrorDialog(
                  "Coordinate Required",
                  "Please select and save coordinates first before uploading any photos.",
                );
                return;
              }
              setState(() {
                _selectedLocationItem =
                    _photoTitles.isNotEmpty
                        ? _photoTitles.first
                        : "Titik Koordinat";
                _isDetailVisible = true;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final String? base64Photo = surveyPhotos[label];
    final ImageProvider? imageProvider =
        base64Photo != null ? MemoryImage(base64Decode(base64Photo)) : null;

    final bool isTitikKoordinat = label == "Titik Koordinat";
    final bool hasCoordinate =
        _latitude != "Loading..." && _longitude != "Loading...";

    return GestureDetector(
      onTap: () {
        if (!isTitikKoordinat && !hasCoordinate) {
          _showErrorDialog(
            "Coordinate Required",
            "Please select and save coordinates first before uploading any photos.",
          );
          return;
        }

        setState(() {
          _selectedLocationItem = label;
          _isDetailVisible = true;
        });
      },
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            padding: imageProvider == null ? const EdgeInsets.all(5) : null,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
              image:
                  imageProvider != null
                      ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      )
                      : null,
            ),
            child:
                imageProvider == null
                    ? isTitikKoordinat && hasCoordinate
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Longitude",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(_longitude, style: TextStyle(fontSize: 12)),
                              SizedBox(height: 8),
                              Text(
                                "Latitude",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(_latitude, style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        )
                        : Icon(icon, size: 40, color: color)
                    : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
              print(
                "Rendering Question: ${question.id} - ${question.question}",
              );
              switch (question.type) {
                case 'shorttext':
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: question.question,
                        labelStyle: const TextStyle(fontSize: 14),
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
                        labelStyle: const TextStyle(fontSize: 14),
                        border: OutlineInputBorder(),
                      ),
                      items:
                          question.options
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option.label,
                                  child: Text(option.label, style: TextStyle(fontSize: 12),),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        formData[question.id] = value;
                      },
                    ),
                  );
                case 'options':
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...question.options.map((option) {
                              return Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: option.label,
                                      groupValue: formData[question.id],
                                      onChanged: (String? selected) {
                                        setState(() {
                                          formData[question.id] = selected;
                                        });
                                      },
                                    ),
                                    Text(option.label, style: const TextStyle(fontSize: 12),),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ],
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
                  fetchSurveyPhotos();
                },
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                _selectedLocationItem,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (_selectedLocationItem == "Titik Koordinat") ...[
          Text("Latitude: $_latitude", style: const TextStyle(fontSize: 12)),
          Text("Longitude: $_longitude", style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
        ],
        if (_selectedLocationItem != "Titik Koordinat")
          _buildImagePlaceholder(),
        const SizedBox(height: 15),
        if (_selectedLocationItem != "Titik Koordinat")
          DropdownButton<String>(
            value: _selectedLocationItem,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedLocationItem = newValue!;
              });
            },
            items:
                _photoTitles.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),
        const SizedBox(height: 15),

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
        const SizedBox(height: 10),
        Center(
          child: ElevatedButton(
            onPressed: () async {
              String? imageBase64 = surveyPhotos[_selectedLocationItem] ?? "";

              if (_selectedLocationItem == "Titik Koordinat") {
                await _addCoordinate(
                  widget.task.projectID.toString(),
                  _latitude,
                  _longitude,
                );
              } else {
                await _addPhoto(
                  widget.task.projectID.toString(),
                  _selectedLocationItem,
                  imageBase64,
                  "$_latitude, $_longitude",
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    final String? base64Photo = surveyPhotos[_selectedLocationItem];
    final File? selectedImage = _imageFiles[_selectedLocationItem];

    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image:
              base64Photo != null || selectedImage != null
                  ? DecorationImage(
                    image:
                        base64Photo != null
                            ? MemoryImage(
                              base64Decode(
                                surveyPhotos[_selectedLocationItem]!,
                              ),
                            )
                            : FileImage(selectedImage!),
                    fit: BoxFit.contain,
                  )
                  : null,
        ),
        child:
            base64Photo == null && selectedImage == null
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
      ),
    );
  }
}
