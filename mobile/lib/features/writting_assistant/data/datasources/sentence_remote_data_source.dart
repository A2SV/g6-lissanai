import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lissan_ai/core/error/exceptions.dart';
import 'package:lissan_ai/features/writting_assistant/data/model/sentence_model_model.dart';

abstract class SentenceRemoteDataSource {
  Future<SentenceModel> getSentence();
}

class SentenceRemoteDataSourceImpl extends SentenceRemoteDataSource {
  final http.Client client;

  SentenceRemoteDataSourceImpl({required this.client});

  @override
  Future<SentenceModel> getSentence() async {
    final response = await client.get(
      Uri.parse(
        'https://lissan-ai-backend-dev.onrender.com/api/v1/pronunciation/sentence',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return SentenceModel.fromJson(json.decode(response.body));
    } else {
      throw const ServerException(message: 'Failed to load sentence');
    }
  }
}
