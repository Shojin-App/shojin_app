import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final BuildContext context;

  SettingsService(this.context);

  Future<void> exportSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allSettings = <String, dynamic>{};

      // Get all keys and filter them if necessary
      final keys = prefs.getKeys();
      for (String key in keys) {
        allSettings[key] = prefs.get(key);
      }

      final jsonString = json.encode(allSettings);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/shojin_settings.json');
      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: '精進アプリの設定'),
      );
      _showSnackBar('設定ファイルを共有しました');
    } catch (_) {
      _showSnackBar('設定ファイルを共有できませんでした');
    }
  }

  Future<void> importSettings() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final settings = json.decode(jsonString) as Map<String, dynamic>;

        await _restoreSettings(settings);
        _showSnackBar('設定を復元しました。再起動後に反映されます');
      } else {
        // Androidのファイル選択を閉じる操作はエラーではないため通知しない。
        return;
      }
    } catch (_) {
      _showSnackBar('設定ファイルを読み込めませんでした');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> exportSettingsToClipboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allSettings = <String, dynamic>{};

      final keys = prefs.getKeys();
      for (String key in keys) {
        allSettings[key] = prefs.get(key);
      }

      final jsonString = json.encode(allSettings);
      await Clipboard.setData(ClipboardData(text: jsonString));

      _showSnackBar('設定をコピーしました');
    } catch (_) {
      _showSnackBar('設定をコピーできませんでした');
    }
  }

  Future<void> importSettingsFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null) {
        _showSnackBar('クリップボードに設定がありません');
        return;
      }

      final settings = json.decode(clipboardData.text!) as Map<String, dynamic>;
      await _restoreSettings(settings);
      _showSnackBar('設定を復元しました。再起動後に反映されます');
    } catch (_) {
      _showSnackBar('クリップボードの設定を読み込めませんでした');
    }
  }

  Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in settings.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      } else if (value is List && value.every((item) => item is String)) {
        // jsonDecodeは文字列配列もList<dynamic>として返すため、要素を
        // 検証してからSharedPreferencesが要求する型へ変換する。
        await prefs.setStringList(key, value.cast<String>());
      }
    }
  }
}
