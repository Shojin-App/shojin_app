import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/browser_site.dart';

/// ブラウザサイトの管理を行うサービス
class BrowserSiteService {
  static const String _storageKey = 'homeSites';

  /// サイトリストを読み込み
  static Future<List<BrowserSite>> loadSites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sitesJson = prefs.getStringList(_storageKey) ?? [];

      return sitesJson.map((jsonString) {
        final map = Map<String, String?>.from(jsonDecode(jsonString));
        final site = BrowserSite.fromLegacyMap(map);
        // faviconUrlは設定ファイルから復元できるため、保持するとアプリ起動時の
        // Image.networkが任意の宛先へ通信する。カスタムサイトは汎用アイコンで
        // 表示し、明示的なWebView操作以外の通信を発生させない。
        return BrowserSite(title: site.title, url: site.url);
      }).toList();
    } catch (e) {
      developer.log('Error loading sites: $e', name: 'BrowserSiteService');
      return [];
    }
  }

  /// サイトリストを保存
  static Future<void> saveSites(List<BrowserSite> sites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sitesJson = sites
          .map(
            (site) => jsonEncode(
              BrowserSite(title: site.title, url: site.url).toJson(),
            ),
          )
          .toList();
      await prefs.setStringList(_storageKey, sitesJson);
    } catch (e) {
      developer.log('Error saving sites: $e', name: 'BrowserSiteService');
      rethrow;
    }
  }

  /// URLの妥当性を検証
  static bool isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.hasAuthority &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }

  /// デフォルトサイトかどうかを判定
  static bool isDefaultSite(String url, List<String> defaultUrls) {
    return defaultUrls.contains(url);
  }

  /// 既存サイトとの重複をチェック
  static bool isDuplicateSite(
    String title,
    String url,
    List<BrowserSite> existingSites,
    List<DefaultSite> defaultSites,
  ) {
    // デフォルトサイトとの重複チェック
    for (final defaultSite in defaultSites) {
      if (title == defaultSite.title && url == defaultSite.url) {
        return true;
      }
    }

    // 既存サイトとの重複チェック
    for (final site in existingSites) {
      if (site.title == title && site.url == url) {
        return true;
      }
    }

    return false;
  }
}

/// デフォルトサイト情報
class DefaultSite {
  final String title;
  final String url;
  final String faviconUrl;
  final String colorHex;

  const DefaultSite({
    required this.title,
    required this.url,
    required this.faviconUrl,
    required this.colorHex,
  });
}
