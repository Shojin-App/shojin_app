import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/models/browser_site.dart';
import 'package:shojin_app/services/browser_site_service.dart';

void main() {
  group('BrowserSiteService', () {
    test('accepts browser URLs but rejects active-content URI schemes', () {
      expect(BrowserSiteService.isValidUrl('https://example.com/path'), isTrue);
      expect(BrowserSiteService.isValidUrl('http://example.com/path'), isTrue);
      expect(BrowserSiteService.isValidUrl('javascript:alert(1)'), isFalse);
      expect(BrowserSiteService.isValidUrl('file:///etc/passwd'), isFalse);
      expect(
        BrowserSiteService.isValidUrl('https://user@example.com'),
        isFalse,
      );
    });

    test('drops imported favicon URLs before they can be fetched', () async {
      SharedPreferences.setMockInitialValues({
        'homeSites': <String>[
          jsonEncode({
            'title': 'Imported',
            'url': 'https://example.com',
            'faviconUrl': 'http://127.0.0.1/private',
            'colorHex': '#ffffff',
          }),
        ],
      });

      final sites = await BrowserSiteService.loadSites();

      expect(sites, [
        const BrowserSite(title: 'Imported', url: 'https://example.com'),
      ]);
      expect(sites.single.faviconUrl, isNull);
      expect(sites.single.colorHex, isNull);
    });

    test('does not persist custom network metadata', () async {
      SharedPreferences.setMockInitialValues({});

      await BrowserSiteService.saveSites(const [
        BrowserSite(
          title: 'Custom',
          url: 'https://example.com',
          faviconUrl: 'https://other.example/favicon.ico',
          colorHex: '#ffffff',
        ),
      ]);

      final sites = await BrowserSiteService.loadSites();
      expect(sites.single.faviconUrl, isNull);
      expect(sites.single.colorHex, isNull);
    });
  });
}
