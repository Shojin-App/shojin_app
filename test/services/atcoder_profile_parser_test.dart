import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/atcoder_profile_parser.dart';

void main() {
  test('parses algorithm rating and rated match count', () {
    const html = '''
      <table>
        <tr><th>Rating</th><td><span>2,958</span></td></tr>
        <tr><th>Rated Matches <span>?</span></th><td>37</td></tr>
      </table>
    ''';

    final result = AtCoderProfileParser.parse(html);

    expect(result?.latestRating, 2958);
    expect(result?.contestCount, 37);
  });

  test('returns null when profile has no contest status', () {
    expect(AtCoderProfileParser.parse('<html></html>'), isNull);
  });
}
