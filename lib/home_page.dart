import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'quiz_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'data_storage.dart';
import 'question_list_page.dart';
import 'models/question.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Question> allQuestions = [];

  Future<void> loadExcel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      final bytes = result.files.first.bytes;
      if (bytes != null) {
        final excel = Excel.decodeBytes(bytes);
        final sheet = excel.tables[excel.tables.keys.first];
        if (sheet != null) {
          final loadedQuestions = <Question>[];
          for (var row in sheet.rows) {
            if (row.length >= 2 &&
                row[0] != null &&
                row[1] != null &&
                row[0]!.value != null &&
                row[1]!.value != null) {
              loadedQuestions.add(
                Question(
                  question: row[0]!.value.toString(),
                  answer: row[1]!.value.toString(),
                ),
              );
            }
          }

          // 保存された履歴があれば反映
          final saved = await DataStorage.loadHistory();

          for (var q in loadedQuestions) {
            final matched = saved.firstWhere(
              (s) => s.question == q.question && s.answer == q.answer,
              orElse: () => q,
            );
            q.status = matched.status;
            q.correctCount = matched.correctCount;
            q.wrongCount = matched.wrongCount;
          }

          setState(() {
            allQuestions = loadedQuestions;
          });
        }
      }
    }
  }


  Map<AnswerStatus, int> countAnswers() {
    final counts = {
      AnswerStatus.correct: 0,
      AnswerStatus.wrong: 0,
      AnswerStatus.notAnswered: 0,
    };
    for (var q in allQuestions) {
      counts[q.status] = counts[q.status]! + 1;
    }
    return counts;
  }

  List<PieChartSectionData> buildChartSections(Map<AnswerStatus, int> data) {
    final total = data.values.reduce((a, b) => a + b);
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: const Color.fromARGB(255, 172, 255, 244),
        value: data[AnswerStatus.correct]!.toDouble(),
        title: '正解',
      ),
      PieChartSectionData(
        color: const Color.fromARGB(255, 255, 211, 171),
        value: data[AnswerStatus.wrong]!.toDouble(),
        title: '不正解',
      ),
      PieChartSectionData(
        color: Colors.grey,
        value: data[AnswerStatus.notAnswered]!.toDouble(),
        title: '未回答',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final stats = countAnswers();
    final hasWrong = allQuestions.any((q) => q.status == AnswerStatus.wrong);
    final wrongQuestions =
        allQuestions.where((q) => q.status == AnswerStatus.wrong).toList();
    final weakQuestions = allQuestions.where((q) => q.wrongCount >= 2).toList();
    final hasWeak = weakQuestions.isNotEmpty;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('暗記アプリ ホーム')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                  foregroundColor: Colors.black,     // ボタンの文字色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: loadExcel,
                child: const Text('Excelファイルを読み込む'),
              ),
              const SizedBox(height: 30),
              const Text('▶ ランダム出題'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton( 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                      foregroundColor: Colors.black,     // ボタンの文字色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: allQuestions.isEmpty
                        ? null
                        : () {
                            final randomized =
                                List<Question>.from(allQuestions)..shuffle();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(
                                  questions: randomized,
                                  title: 'ランダム出題',
                                  initialIndex: 0,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          },
                    child: const Text('最初から'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                      foregroundColor: Colors.black,     // ボタンの文字色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: allQuestions.isEmpty
                        ? null
                        : () {
                            final randomized =
                                List<Question>.from(allQuestions)..shuffle();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(
                                  questions: randomized,
                                  title: 'ランダム出題',
                                  initialIndex: randomized.indexWhere(
                                    (q) => q.status == AnswerStatus.notAnswered,
                                  ),
                                ),
                              ),
                            );
                          },
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                      foregroundColor: Colors.black,     // ボタンの文字色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: hasWrong
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(
                                  questions: wrongQuestions,
                                  title: '間違えた問題だけ',
                                  initialIndex: 0,
                                ),
                              ),
                            ).then((_) => setState(() {}));
                          }
                        : null,
                    child: const Text('最初から'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                      foregroundColor: Colors.black,     // ボタンの文字色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: hasWrong
                        ? () {
                            final startIndex = wrongQuestions.indexWhere(
                              (q) => q.status == AnswerStatus.notAnswered,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizPage(
                                  questions: wrongQuestions,
                                  title: '間違えた問題だけ',
                                  initialIndex: startIndex < 0 ? 0 : startIndex,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('続きから'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('⚠️ 苦手な問題だけ'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                      foregroundColor: Colors.black,     // ボタンの文字色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: hasWeak
                      ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              questions: weakQuestions,
                              title: '苦手な問題だけ',
                              initialIndex: 0,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      }
                    : null,
                  child: const Text('最初から'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                    foregroundColor: Colors.black,     // ボタンの文字色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: hasWeak
                    ? () {
                      final startIndex = weakQuestions.indexWhere(
                        (q) => q.status == AnswerStatus.notAnswered,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(
                            questions: weakQuestions,
                            title: '苦手な問題だけ',
                            initialIndex: startIndex < 0 ? 0 : startIndex,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    }
                 : null,
                 child: const Text('続きから'),
                ),
               ],
              ),
              const SizedBox(height: 30),
              if (stats.values.reduce((a, b) => a + b) > 0)
                Column(
                  children: [
                    const Text('📊 学習状況'),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sections: buildChartSections(stats),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    Text(
                      '正解: ${stats[AnswerStatus.correct]}, 不正解: ${stats[AnswerStatus.wrong]}, 未回答: ${stats[AnswerStatus.notAnswered]}',
                    ),
                  ],
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBBDEFB), // ボタンの背景
                  foregroundColor: Colors.black,     // ボタンの文字色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: allQuestions.isEmpty
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionListPage(
                            questions: allQuestions,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                child: const Text('問題一覧'),
            ),

            ],
          ),
        ),
      ),
    );
  }
}
