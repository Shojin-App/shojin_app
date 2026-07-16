import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/atcoder_rating_info.dart';

class AtCoderProfileParser {
  static AtcoderRatingInfo? parse(String html) {
    final document = html_parser.parse(html);
    final rating = _readIntegerCell(document, 'Rating');
    final ratedMatches = _readIntegerCell(document, 'Rated Matches');

    if (rating == null || ratedMatches == null) {
      return null;
    }

    return AtcoderRatingInfo(latestRating: rating, contestCount: ratedMatches);
  }

  static int? _readIntegerCell(Document document, String label) {
    for (final row in document.querySelectorAll('tr')) {
      final heading = row.querySelector('th')?.text.trim();
      if (heading == null || !heading.startsWith(label)) {
        continue;
      }

      final value = row.querySelector('td')?.text.replaceAll(',', '');
      final match = RegExp(r'\d+').firstMatch(value ?? '');
      return match == null ? null : int.parse(match.group(0)!);
    }
    return null;
  }
}
