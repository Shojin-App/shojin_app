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

      await Share.shareXFiles([XFile(file.path)], text: 'Shojin App Settings');
      _showSnackBar('Settings exported successfully.');
    } catch (e) {
      _showSnackBar('Failed to export settings: $e', isError: true);
    }
  }

  Future<void> importSettings() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final settings = json.decode(jsonString) as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        for (var key in settings.keys) {
          final value = settings[key];
          if (value is bool) {
            await prefs.setBool(key, value);
          } else if (value is int) {
            await prefs.setInt(key, value);
          } else if (value is double) {
            await prefs.setDouble(key, value);
          } else if (value is String) {
            await prefs.setString(key, value);
          } else if (value is List<String>) {
            await prefs.setStringList(key, value);
          }
        }
        _showSnackBar('Settings imported successfully.');
      } else {
        _showSnackBar('File selection cancelled.');
      }
    } catch (e) {
      _showSnackBar('Failed to import settings: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
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

      _showSnackBar('Settings copied to clipboard.');
    } catch (e) {
      _showSnackBar('Failed to copy settings: $e', isError: true);
    }
  }

  Future<void> importSettingsFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null) {
        _showSnackBar('Clipboard is empty.');
        return;
      }

      final settings = json.decode(clipboardData.text!) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      for (var key in settings.keys) {
        final value = settings[key];
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List<String>) {
          await prefs.setStringList(key, value);
        }
      }

      _showSnackBar('Settings imported from clipboard.');
    } catch (e) {
      _showSnackBar('Failed to import from clipboard: $e', isError: true);
    }
  }
}