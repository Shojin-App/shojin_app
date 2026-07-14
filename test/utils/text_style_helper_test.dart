import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/utils/text_style_helper.dart';

void main() {
  test('uses the bundled code font without an online-font fallback', () {
    final style = getMonospaceTextStyle('HackGen35', fontSize: 13);

    expect(style.fontFamily, 'HackGen35');
    expect(style.fontSize, 13);
  });
}
