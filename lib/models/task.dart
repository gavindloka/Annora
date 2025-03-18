class Task {
  int projectID;
  int woID;
  String appNo;
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
    required this. appNo,
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
