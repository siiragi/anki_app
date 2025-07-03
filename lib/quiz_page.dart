import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'finish_page.dart';
import 'data_storage.dart';
import 'models/question.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final String title;
  final int initialIndex;

  const QuizPage({
    super.key,
    required this.questions,
    required this.title,
    this.initialIndex = 0,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late int currentIndex;
  bool showAnswer = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void markAnswer(AnswerStatus status) {
    final currentQuestion = widget.questions[currentIndex];
    setState(() {
      currentQuestion.status = status;
      if (status == AnswerStatus.correct) {
        currentQuestion.correctCount++;
      } else if (status == AnswerStatus.wrong) {
        currentQuestion.wrongCount++;
      }
      DataStorage.saveHistory(widget.questions);
      showAnswer = false;

      if (currentIndex < widget.questions.length - 1) {
        currentIndex++;
      } else {
        Future.microtask(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FinishPage(
                sectionNumber: int.tryParse(widget.title.replaceAll(RegExp(r'\D'), '')),
              ),
            ),
          );
        });
      }
    });
  }

  Map<AnswerStatus, int> countAnswers() {
    final counts = {
      AnswerStatus.correct: 0,
      AnswerStatus.wrong: 0,
      AnswerStatus.notAnswered: 0,
    };
    for (var q in widget.questions) {
      counts[q.status] = counts[q.status]! + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.questions[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    final stats = countAnswers();
    final total = widget.questions.length.toDouble();
    final correct = stats[AnswerStatus.correct]!.toDouble();
    final wrong = stats[AnswerStatus.wrong]!.toDouble();
    final unanswered = stats[AnswerStatus.notAnswered]!.toDouble();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 50, // 高さは低く
                  child: RotatedBox(
                    quarterTurns: 1, // 90度回転（横向きにする）
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.center,
                        maxY: 1,
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: 1,
                                rodStackItems: [
                                  BarChartRodStackItem(0, correct / total, Color.fromARGB(255, 172, 255, 244)),
                                  BarChartRodStackItem(correct / total, (correct + wrong) / total, Color.fromARGB(255, 255, 211, 171)),
                                  BarChartRodStackItem((correct + wrong) / total, 1, Colors.grey),
                                ],
                                width: 30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ],
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: false,
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        groupsSpace: 4,
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 8),
                Text('正解: ${correct.toInt()}    不正解: ${wrong.toInt()}    未回答: ${unanswered.toInt()}'),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    current.question,
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAnswer = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBBDEFB),
                    foregroundColor: Colors.black,
                    minimumSize: Size(screenWidth * 0.3, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('答えを見る'),
                ),
                const SizedBox(height: 20),
                if (showAnswer)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      current.answer,
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => markAnswer(AnswerStatus.correct),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 172, 255, 244),
                    foregroundColor: Colors.black,
                    minimumSize: Size(screenWidth * 0.3, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('正解'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => markAnswer(AnswerStatus.wrong),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 211, 171),
                    foregroundColor: Colors.black,
                    minimumSize: Size(screenWidth * 0.3, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('不正解'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

