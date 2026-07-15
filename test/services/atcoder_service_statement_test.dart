import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/atcoder_service.dart';

void main() {
  test('keeps the input explanation outside the format code block', () {
    final content = AtCoderService().extractSectionContentFromHtml(
      '''
      <div id="task-statement">
        <h3>入力</h3>
        <p>入力は以下の形式で標準入力から与えられる。</p>
        <pre><var>N</var>
<var>A_1</var> <var>A_2</var> ... <var>A_N</var></pre>
        <h3>出力</h3>
      </div>
    ''',
      ['入力', 'Input'],
    );

    expect(content, startsWith('入力は以下の形式で標準入力から与えられる。'));
    expect(
      content,
      contains(r'''```
$N$
$A_1$ $A_2$ ... $A_N$
```'''),
    );
    expect(
      content.indexOf('入力は以下の形式で標準入力から与えられる。'),
      lessThan(content.indexOf('```')),
    );
  });

  test('preserves details and summary boundaries', () {
    final content = AtCoderService().extractSectionContentFromHtml(
      '''
      <div id="task-statement">
        <h3>問題文</h3>
        <p>通常の問題文です。</p>
        <details>
          <summary>補足説明</summary>
          <p>折りたたまれた内容です。</p>
          <pre>example</pre>
        </details>
        <h3>制約</h3>
      </div>
    ''',
      ['問題文', 'Problem'],
    );

    expect(content, contains('[[[DETAILS:補足説明]]]'));
    expect(content, contains('折りたたまれた内容です。'));
    expect(content, contains('```\nexample\n```'));
    expect(content, contains('[[[/DETAILS]]]'));
  });

  test('preserves semantic emphasis and list markers', () {
    final content = AtCoderService().extractSectionContentFromHtml(
      '''
      <div id="task-statement">
        <h3>問題文</h3>
        <p><strong>重要</strong>な条件です。</p>
        <ul><li>最初の条件</li><li><var>A_i</var> の条件</li></ul>
        <h3>制約</h3>
      </div>
    ''',
      ['問題文', 'Problem'],
    );

    expect(content, contains('**重要**な条件です。'));
    expect(content, contains('- 最初の条件'));
    expect(content, contains(r'- $A_i$ の条件'));
  });
}
