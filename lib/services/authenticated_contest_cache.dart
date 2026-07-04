import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contest.dart';

/// AtCoder WebViewのログインセッションでのみ見えるコンテストを保持する。
/// Cookie自体はアプリへ取り出さず、セッション内で取得した公開可能な予定情報だけを保存する。
class AuthenticatedContestCache {
  static const _cacheKey = 'authenticated_atcoder_contests';

  Future<void> saveJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! List) return;

    final contests = decoded
        .whereType<Map>()
        .map((item) => Contest.fromMap(Map<String, dynamic>.from(item)))
        .toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(contests.map((contest) => contest.toMap()).toList()),
    );
  }

  Future<List<Contest>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_cacheKey);
    if (encoded == null) return [];
    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) => Contest.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      // 古い・破損したキャッシュで公開コンテストの表示まで失敗させない。
      return [];
    }
  }
}
