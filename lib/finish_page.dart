import 'package:flutter/material.dart';

class FinishPage extends StatelessWidget {
  final int? sectionNumber;

  const FinishPage({super.key, this.sectionNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('お疲れ様！')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('すべての問題を解き終わりました！', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFBBDEFB),
                foregroundColor: Colors.black,
              ),
              child: const Text('ホームに戻る'),
            ),
            const SizedBox(height: 20),
            if (sectionNumber != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // FinishPage を閉じる
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBBDEFB),
                  foregroundColor: Colors.black,
                ),
                child: Text('セクション ${sectionNumber!} に戻る'),
              ),
          ],
        ),
      ),
    );
  }
}
