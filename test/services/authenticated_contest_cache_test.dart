import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/services/authenticated_contest_cache.dart';

void main() {
  test('stores contest metadata without storing session cookies', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = AuthenticatedContestCache();
    await cache.saveJson(
      jsonEncode([
        {
          'name_ja': '限定コンテスト',
          'name_en': 'Private Contest',
          'url': 'https://atcoder.jp/contests/private-test',
          'start_time': '2026-07-05T21:00:00+09:00',
          'duration_min': 100,
          'rated_range': '-',
          'status': 'Upcoming',
        },
      ]),
    );

    final contests = await cache.load();
    expect(contests.single.nameJa, '限定コンテスト');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'authenticated_atcoder_contests'});
    expect(
      prefs.getString('authenticated_atcoder_contests'),
      isNot(contains('cookie')),
    );
  });

  test('ignores a broken cache', () async {
    SharedPreferences.setMockInitialValues({
      'authenticated_atcoder_contests': 'not-json',
    });
    expect(await AuthenticatedContestCache().load(), isEmpty);
  });
}
