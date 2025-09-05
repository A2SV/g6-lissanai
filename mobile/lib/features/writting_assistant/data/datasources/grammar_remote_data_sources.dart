import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/core/utils/constants/auth_constants.dart';
import 'package:lissan_ai/core/utils/constants/writting_constant.dart';
import 'package:lissan_ai/features/writting_assistant/data/model/grammar_result_model.dart';
import 'package:http/http.dart' as http;

abstract class GrammarRemoteDataSources {
  Future<GrammarResultModel> checkGrammar(String englishText);
}

class GrammarRemoteDataSourcesImpl implements GrammarRemoteDataSources {
  final http.Client client;
  final FlutterSecureStorage storage;

  GrammarRemoteDataSourcesImpl({required this.storage, required this.client});

  @override
  Future<GrammarResultModel> checkGrammar(String englishText) async {
    final token = await storage.read(key: AuthConstants.accessToken);

    if (token == null) {
      throw const ServerException(message: 'No access token found');
    }

    final response = await client.post(
      Uri.parse(
        writting_constant.baseUrl + writting_constant.checkGrammarEndpoint,
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'text': englishText}),
    );

    if (response.statusCode == 200) {
      final result = GrammarResultModel.fromJson(jsonDecode(response.body));
      debugPrint('Parsed result: $result');
      return result;
    } else {
      throw const ServerException(message: 'Failed to check grammar');
    }
  }
}
