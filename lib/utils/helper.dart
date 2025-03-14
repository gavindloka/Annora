import 'package:flutter/material.dart';

class Helper {
  static getStatusSurveyorColor(String surveyorStatus) {
    switch (surveyorStatus) {
      case 'New Task':
        return Colors.red;
      case 'Download Task':
        return Colors.amber;
      case 'Read Task':
        return Colors.blue;
      case 'On Progress Task':
        return Colors.lightBlue;
      case 'Uploading Task':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
