import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/screens/submit_screen.dart';

void main() {
  group('SubmitNavigationPolicy', () {
    test('allows only the exact AtCoder HTTPS origin', () {
      expect(
        SubmitNavigationPolicy.isAllowedAtCoderUrl('https://atcoder.jp/login'),
        isTrue,
      );
      expect(
        SubmitNavigationPolicy.isAllowedAtCoderUrl(
          'https://evil.example/collect',
        ),
        isFalse,
      );
      expect(
        SubmitNavigationPolicy.isAllowedAtCoderUrl(
          'https://atcoder.jp.evil.example/collect',
        ),
        isFalse,
      );
      expect(
        SubmitNavigationPolicy.isAllowedAtCoderUrl(
          'http://atcoder.jp/contests/abc123/submit',
        ),
        isFalse,
      );
    });

    test('injects code only into contest submission pages', () {
      expect(
        SubmitNavigationPolicy.isSubmissionPage(
          'https://atcoder.jp/contests/abc123/submit?taskScreenName=abc123_a',
        ),
        isTrue,
      );
      expect(
        SubmitNavigationPolicy.isSubmissionPage('https://atcoder.jp/login'),
        isFalse,
      );
      expect(
        SubmitNavigationPolicy.isSubmissionPage(
          'https://evil.example/contests/abc123/submit',
        ),
        isFalse,
      );
    });
  });
}
