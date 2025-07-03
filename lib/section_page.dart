import 'package:flutter/material.dart';
import 'models/question.dart';
import 'quiz_page.dart';

class SectionPage extends StatelessWidget {
  final int sectionNumber;
  final List<Question> questions;

  const SectionPage({
    super.key,
    required this.sectionNumber,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final hasWrong = questions.any((q) => q.status == AnswerStatus.wrong);
    final wrongQuestions = questions.where((q) => q.status == AnswerStatus.wrong).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('セクション$sectionNumber')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('▶ ランダム出題'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                  
                    final randomized = List<Question>.from(questions)..shuffle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          questions: randomized,
                          title: 'セクション$sectionNumber：ランダム出題',
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBBDEFB),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('最初から'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final randomized = List<Question>.from(questions)..shuffle();
                    final startIndex = randomized.indexWhere((q) => q.status == AnswerStatus.notAnswered);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          questions: randomized,
                          title: 'セクション${sectionNumber + 1}：ランダム出題',
                          initialIndex: startIndex < 0 ? 0 : startIndex,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBBDEFB),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('続きから'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('❌ 間違えた問題だけ'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: hasWrong
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(
                                questions: wrongQuestions,
                                title: 'セクション${sectionNumber + 1}：間違えた問題',
                                initialIndex: 0,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBBDEFB),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('最初から'),
                ),
                ElevatedButton(
                  onPressed: hasWrong
                      ? () {
                          final startIndex = wrongQuestions.indexWhere((q) => q.status == AnswerStatus.notAnswered);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(
                                questions: wrongQuestions,
                                title: 'セクション${sectionNumber + 1}：間違えた問題',
                                initialIndex: startIndex < 0 ? 0 : startIndex,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBBDEFB),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('続きから'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}