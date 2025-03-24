class QuestionOption {
  final String id;
  final String questionID;
  final String label;
  final bool hasOther;
  final int order;

  QuestionOption({
    required this.id,
    required this.questionID,
    required this.label,
    required this.hasOther,
    required this.order,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id_pertanyaan_options'],
      questionID: json['id_pertanyaan'],
      label: json['label'],
      hasOther: json['lainnya'] == "Y",
      order: int.parse(json['urut']),
    );
  }
}