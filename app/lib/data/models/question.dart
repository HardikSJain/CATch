class Question {
  final int id;
  final int? setId;
  final String section; // 'DILR', 'QA', 'VARC'
  final String? subsection; // 'LR', 'DI', 'RC', 'VA'
  final String topic;
  final String difficulty;
  final String questionText;
  final String questionType; // 'MCQ', 'TITA'
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final String? optionE;
  final String correctAnswer;
  final String? explanation;
  final String? imagePath;
  final String? explanationImagePath;
  final String? sourceBook;
  final int? sourcePage;

  Question({
    required this.id,
    this.setId,
    required this.section,
    this.subsection,
    required this.topic,
    this.difficulty = 'Medium',
    required this.questionText,
    this.questionType = 'MCQ',
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.optionE,
    required this.correctAnswer,
    this.explanation,
    this.imagePath,
    this.explanationImagePath,
    this.sourceBook,
    this.sourcePage,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      setId: map['set_id'] as int?,
      section: map['section'] as String,
      subsection: map['subsection'] as String?,
      topic: map['topic'] as String,
      difficulty: map['difficulty'] as String? ?? 'Medium',
      questionText: map['question_text'] as String,
      questionType: map['question_type'] as String? ?? 'MCQ',
      optionA: map['option_a'] as String?,
      optionB: map['option_b'] as String?,
      optionC: map['option_c'] as String?,
      optionD: map['option_d'] as String?,
      optionE: map['option_e'] as String?,
      correctAnswer: map['correct_answer'] as String,
      explanation: map['explanation'] as String?,
      imagePath: map['image_path'] as String?,
      explanationImagePath: map['explanation_image_path'] as String?,
      sourceBook: map['source_book'] as String?,
      sourcePage: map['source_page'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'set_id': setId,
      'section': section,
      'subsection': subsection,
      'topic': topic,
      'difficulty': difficulty,
      'question_text': questionText,
      'question_type': questionType,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'option_e': optionE,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'image_path': imagePath,
      'explanation_image_path': explanationImagePath,
      'source_book': sourceBook,
      'source_page': sourcePage,
    };
  }
}
