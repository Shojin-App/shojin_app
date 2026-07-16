import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';
import '../models/contest.dart';
import 'authenticated_contest_cache.dart';

class ContestService {
  ContestService({AuthenticatedContestCache? authenticatedContestCache})
    : _authenticatedContestCache =
          authenticatedContestCache ?? AuthenticatedContestCache();

  final AuthenticatedContestCache _authenticatedContestCache;
  static const String _userAgent =
      'ShojinApp/1.0 (+https://github.com/Shojin-App/Shojin_App)';
  static const _headers = {'User-Agent': _userAgent};
  static const String _contestUrl =
      'https://github.com/Shojin-App/atcoder-contest-info/raw/refs/heads/main/contests.yaml';

  /// すべてのコンテスト情報を取得
  Future<List<Contest>> fetchAllContests() async {
    try {
      final response = await http.get(
        Uri.parse(_contestUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // UTF-8でデコード
        final yamlString = utf8.decode(response.bodyBytes);
        final yamlDoc = loadYaml(yamlString);

        if (yamlDoc is List) {
          final publicContests = yamlDoc
              .map(
                (contestData) =>
                    Contest.fromMap(Map<String, dynamic>.from(contestData)),
              )
              .toList();
          final authenticatedContests = await _authenticatedContestCache.load();
          // 同じコンテストはログインセッション由来の情報を優先する。
          return {
            for (final contest in publicContests) contest.url: contest,
            for (final contest in authenticatedContests) contest.url: contest,
          }.values.toList();
        }
      }

      throw Exception('Failed to load contests: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error fetching contests: $e');
    }
  }

  /// 次回のABCコンテストを取得
  Future<Contest?> getNextABC() async {
    try {
      final contests = await fetchAllContests();

      // 今日の日付を取得
      final now = DateTime.now();

      // 開催予定のABCコンテストを日付順でソート
      final upcomingABCs = contests
          .where((contest) => contest.isABC && contest.startTime.isAfter(now))
          .toList();

      // 開始時刻でソート
      upcomingABCs.sort((a, b) => a.startTime.compareTo(b.startTime));

      return upcomingABCs.isNotEmpty ? upcomingABCs.first : null;
    } catch (e) {
      throw Exception('Error fetching next ABC: $e');
    }
  }

  /// 今後のABCコンテスト一覧を取得
  Future<List<Contest>> getUpcomingABCs() async {
    try {
      final contests = await fetchAllContests();

      // 今日の日付を取得
      final now = DateTime.now();

      // 開催予定のABCコンテストを日付順でソート
      final upcomingABCs = contests
          .where((contest) => contest.isABC && contest.startTime.isAfter(now))
          .toList();

      // 開始時刻でソート
      upcomingABCs.sort((a, b) => a.startTime.compareTo(b.startTime));

      return upcomingABCs;
    } catch (e) {
      throw Exception('Error fetching upcoming ABCs: $e');
    }
  }

  /// すべての開催予定コンテストを取得
  Future<List<Contest>> getUpcomingContests() async {
    try {
      final contests = await fetchAllContests();

      // 今日の日付を取得
      final now = DateTime.now();

      // 開催予定のコンテストを日付順でソート
      final upcomingContests = contests
          .where((contest) => contest.startTime.isAfter(now))
          .toList();

      // 開始時刻でソート
      upcomingContests.sort((a, b) => a.startTime.compareTo(b.startTime));

      return upcomingContests;
    } catch (e) {
      throw Exception('Error fetching upcoming contests: $e');
    }
  }
}
