import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'section_page.dart';
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
          for (var row in sheet.rows.skip(1)) {
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
    final totalSections = (allQuestions.length / 20).ceil();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('暗記アプリ ホーム')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: loadExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBBDEFB),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Excelファイルを読み込む'),
              ),
              const SizedBox(height: 30),
              const Text('🧩 セクション別出題'),
              for (int i = 0; i < totalSections; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Builder(
                    builder: (context) {
                      final start = i * 20;
                      final end = ((i + 1) * 20 > allQuestions.length)
                          ? allQuestions.length
                          : (i + 1) * 20;
                      final sectionQuestions = allQuestions.sublist(start, end);

                      final allCorrect = sectionQuestions.isNotEmpty &&
                          sectionQuestions.every((q) => q.status == AnswerStatus.correct);

                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SectionPage(
                                sectionNumber: i + 1,
                                questions: sectionQuestions,
                              ),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFBBDEFB),
                          foregroundColor: Colors.black,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('セクション ${i + 1}'),
                            if (allCorrect)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check_circle, color: Colors.green),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
               ),


              const SizedBox(height: 30),
              const Text('📊 学習状況（全体）'),
              if (stats.values.reduce((a, b) => a + b) > 0)
                Column(
                  children: [
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
              const SizedBox(height: 30),
              ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBBDEFB),
                        foregroundColor: Colors.black,
                      ),
                child: const Text('問題一覧'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
