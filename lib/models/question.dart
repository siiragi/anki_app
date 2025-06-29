enum AnswerStatus { correct, wrong, notAnswered }

class Question {
  final String question;
  final String answer;
  AnswerStatus status;
  int correctCount;
  int wrongCount;

  Question({
    required this.question,
    required this.answer,
    this.status = AnswerStatus.notAnswered,
    this.correctCount = 0,
    this.wrongCount = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      answer: json['answer'],
      status: AnswerStatus.values[json['status']],
      correctCount: json['correctCount'],
      wrongCount: json['wrongCount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'status': status.index,
        'correctCount': correctCount,
        'wrongCount': wrongCount,
      };
}
