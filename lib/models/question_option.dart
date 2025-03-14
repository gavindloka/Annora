class QuestionOption {
  final String id;
  final String questionId;
  final String label;
  final bool hasOther;
  final int order;

  QuestionOption({
    required this.id,
    required this.questionId,
    required this.label,
    required this.hasOther,
    required this.order,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id_pertanyaan_options'],
      questionId: json['id_pertanyaan'],
      label: json['label'],
      hasOther: json['lainnya'] == "Y",
      order: int.parse(json['urut']),
    );
  }
}