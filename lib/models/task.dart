// ignore_for_file: public_member_api_docs, sort_constructors_first
class Task {
  DateTime startDate;
  DateTime targetDate;
  String nameProject;
  String company;
  String customerName;
  String address;
  String category;
  String surveyType;
  String surveyorName;
  String surveyorEmail;
  int progress;
  String status;
  Task({
    required this.startDate,
    required this.targetDate,
    required this.nameProject,
    required this.company,
    required this.customerName,
    required this.address,
    required this.category,
    required this.surveyType,
    required this.surveyorName,
    required this.surveyorEmail,
    required this.progress,
    required this.status,
  });
}
