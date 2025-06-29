import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/question.dart';

class DataStorage {
  static const String historyKey = 'question_history';

  static Future<void> saveHistory(List<Question> questions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = questions.map((q) => q.toJson()).toList();
    prefs.setString(historyKey, jsonEncode(jsonList));
  }

  static Future<List<Question>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(historyKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map<Question>((json) => Question.fromJson(json)).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey);
  }
} 