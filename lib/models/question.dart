import 'dart:convert';

import 'package:annora_survey/models/question_option.dart';

class Question {
  final String id;
  final String surveyId;
  final String question;
  final String description;
  final int order;
  final String type;
  final String required;
  final List<String> validation;
  final List<QuestionOption> options;

  Question({
    required this.id,
    required this.surveyId,
    required this.question,
    required this.description,
    required this.order,
    required this.type,
    required this.required,
    required this.validation,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id_pertanyaan'],
      surveyId: json['id_survey'],
      question: json['pertanyaan'],
      description: json['deskripsi'],
      order: int.parse(json['urut']),
      type: json['jenis'],
      required: json['required'],
      validation: List<String>.from(jsonDecode(json['validation'] ?? '[]')),
      options: (json['options'] as List)
          .map((option) => QuestionOption.fromJson(option))
          .toList(),
    );
  }
}
