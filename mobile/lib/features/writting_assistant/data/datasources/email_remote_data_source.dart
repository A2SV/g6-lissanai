import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/utils/constants/writting_constant.dart';
import 'package:lissan_ai/features/writting_assistant/data/model/email_draft_model.dart';
import 'package:lissan_ai/features/writting_assistant/data/model/improved_email_model.dart';

abstract class EmailRemoteDataSource {
  Future<EmailDraftModel> getDraftedEmail(
    String amharicPrompt,
    String tone,
    String type,
  );
  Future<ImprovedEmailModel> getImprovedEmail(
    String userEmail,
    String tone,
    String type,
  );
}

class EmailRemoteDataSourceImpl implements EmailRemoteDataSource {
  final http.Client client;

  EmailRemoteDataSourceImpl({required this.client});

  @override
  Future<EmailDraftModel> getDraftedEmail(
    String amharicPrompt,
    String tone,
    String type,
  ) async {
    try {
      final response = await client.post(
        Uri.parse(
          writting_constant.baseUrl + writting_constant.draftEmailEndpoint,
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prompt': amharicPrompt,
          'tone': tone,
          'template_type': type,
        }),
      );

      if (response.statusCode == 200) {
        return EmailDraftModel.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message: 'Failed to generate email: ${errorBody['error']}',
        );
      }
    } on SocketException {
      throw const ServerException(message: 'No Internet connection');
    } on http.ClientException {
      throw const ServerException(message: 'Could not connect to server');
    }
  }

  @override
  Future<ImprovedEmailModel> getImprovedEmail(
    String userEmail,
    String tone,
    String type,
  ) async {
    try {
      final response = await client.post(
        Uri.parse(
          writting_constant.baseUrl + writting_constant.improveEmailEndpoint,
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'draft': userEmail,
          'tone': tone,
          'template_type': type,
        }),
      );

      if (response.statusCode == 200) {
        return ImprovedEmailModel.fromJson(json.decode(response.body));
      } else {
        final errorBody = json.decode(response.body);
        throw ServerException(
          message: 'Failed to generate email: ${errorBody['error']}',
        );
      }
    } on SocketException {
      throw const ServerException(message: 'No Internet connection');
    } on http.ClientException {
      throw const ServerException(message: 'Could not connect to server');
    }
  }
}
