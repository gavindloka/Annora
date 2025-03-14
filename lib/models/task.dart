// ignore_for_file: public_member_api_docs, sort_constructors_first
class Task {
  int projectID;
  int woID;
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
  String statusSurveyor;
  Task({
    required this.projectID,
    required this.woID,
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
    required this.statusSurveyor
  });
}
