import 'package:flutter/material.dart';
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
  bool isLast = currentIndex == widget.questions.length - 1;

  setState(() {
    currentQuestion.status = status;
      if (status == AnswerStatus.correct) {
        currentQuestion.correctCount++;
      } else if (status == AnswerStatus.wrong) {
        currentQuestion.wrongCount++;
      }
      DataStorage.saveHistory(widget.questions);
      showAnswer = false;
      if (!isLast) {
        currentIndex++;
      }
    });

    if (isLast) {
      // setState の外で画面遷移を実行
      Future.microtask(() {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const FinishPage(),
          ),
        );
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final current = widget.questions[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;

    final total = widget.questions.length.toDouble();
    final correct = widget.questions.where((q) => q.status == AnswerStatus.correct).length.toDouble();
    final wrong = widget.questions.where((q) => q.status == AnswerStatus.wrong).length.toDouble();
    final unanswered = total - correct - wrong;

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
                ProgressBar(
                  correctRatio: correct / total,
                  wrongRatio: wrong / total,
                  unansweredRatio: unanswered / total,
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

class ProgressBar extends StatelessWidget {
  final double correctRatio;
  final double wrongRatio;
  final double unansweredRatio;

  const ProgressBar({
    super.key,
    required this.correctRatio,
    required this.wrongRatio,
    required this.unansweredRatio,
  });

  @override
  Widget build(BuildContext context) {
    // 3つの割合を合計して1.0になるように調整（念のため）
    final totalRatio = correctRatio + wrongRatio + unansweredRatio;
    final cRatio = correctRatio / totalRatio;
    final wRatio = wrongRatio / totalRatio;
    final uRatio = unansweredRatio / totalRatio;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          Expanded(
            flex: (cRatio * 1000).round(),
            child: Container(color: Color.fromARGB(255, 172, 255, 244)),
          ),
          Expanded(
            flex: (wRatio * 1000).round(),
            child: Container(color: Color.fromARGB(255, 255, 211, 171)),
          ),
          Expanded(
            flex: (uRatio * 1000).round(),
            child: Container(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
