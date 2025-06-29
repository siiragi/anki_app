import 'package:flutter/material.dart';
import 'models/question.dart';

class QuestionListPage extends StatefulWidget {
  final List<Question> questions;

  const QuestionListPage({super.key, required this.questions});

  @override
  State<QuestionListPage> createState() => _QuestionListPageState();
}

class _QuestionListPageState extends State<QuestionListPage> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.questions.where((q) {
      final text = (q.question + q.answer).toLowerCase();
      return text.contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('問題一覧'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: '検索',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final q = filtered[index];
                final total = q.correctCount + q.wrongCount;
                final rate = total > 0 ? (q.correctCount / total * 100).toStringAsFixed(1) : '-';

                return ListTile(
                  title: Text(q.question),
                  subtitle: Text('正解率: $rate%（正:${q.correctCount} / 誤:${q.wrongCount}）'),
                  trailing: Icon(
                    q.status == AnswerStatus.correct
                        ? Icons.check_circle
                        : q.status == AnswerStatus.wrong
                            ? Icons.cancel
                            : Icons.help_outline,
                    color: q.status == AnswerStatus.correct
                        ? Colors.green
                        : q.status == AnswerStatus.wrong
                            ? Colors.red
                            : Colors.grey,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
