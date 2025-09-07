import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lissan_ai/features/writting_assistant/data/model/saved_email_model.dart';

abstract class SavedEmailLocalDataSource {
  Future<void> saveEmail(SavedEmailModel email);
  Future<List<SavedEmailModel>> getSavedEmails();
  Future<void> deleteSavedEmail(String id);
  Future<void> clearAllEmails();
}

class SavedEmailLocalDataSourceImpl implements SavedEmailLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _savedEmailsKey = 'saved_emails';

  SavedEmailLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveEmail(SavedEmailModel email) async {
    final List<SavedEmailModel> emails = await getSavedEmails();
    emails.insert(0, email); // Insert at beginning for newest first

    final List<String> emailsJson = emails
        .map((email) => jsonEncode(email.toJson()))
        .toList();

    await sharedPreferences.setStringList(_savedEmailsKey, emailsJson);
  }

  @override
  Future<List<SavedEmailModel>> getSavedEmails() async {
    final List<String>? emailsJson = sharedPreferences.getStringList(
      _savedEmailsKey,
    );

    if (emailsJson == null || emailsJson.isEmpty) {
      return [];
    }

    return emailsJson
        .map((emailJson) => SavedEmailModel.fromJson(jsonDecode(emailJson)))
        .toList();
  }

  @override
  Future<void> deleteSavedEmail(String id) async {
    final List<SavedEmailModel> emails = await getSavedEmails();
    emails.removeWhere((email) => email.id == id);

    final List<String> emailsJson = emails
        .map((email) => jsonEncode(email.toJson()))
        .toList();

    await sharedPreferences.setStringList(_savedEmailsKey, emailsJson);
  }

  @override
  Future<void> clearAllEmails() async {
    await sharedPreferences.remove(_savedEmailsKey);
  }
}
