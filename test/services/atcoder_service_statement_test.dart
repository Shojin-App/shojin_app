import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/atcoder_service.dart';

void main() {
  test('keeps the input explanation outside the format code block', () {
    final content = AtCoderService().extractSectionContentFromHtml(
      '''
      <div id="task-statement">
        <h3>入力</h3>
        <p>入力は以下の形式で標準入力から与えられる。</p>
        <pre>N
A_1 A_2 ... A_N</pre>
        <h3>出力</h3>
      </div>
    ''',
      ['入力', 'Input'],
    );

    expect(content, startsWith('入力は以下の形式で標準入力から与えられる。'));
    expect(content, contains('```\nN\nA_1 A_2 ... A_N\n```'));
    expect(
      content.indexOf('入力は以下の形式で標準入力から与えられる。'),
      lessThan(content.indexOf('```')),
    );
  });
}
