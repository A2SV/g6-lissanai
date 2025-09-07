import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart'; // for MediaType
import 'package:lissan_ai/features/writting_assistant/data/model/pronunciation_feedback_model.dart';

abstract class PronunciationRemoteDataSource {
  Future<PronunciationFeedbackModel> sendPronunciation(
    String sentence,
    File audioFile,
  );
}

class PronunciationRemoteDataSourceImpl
    implements PronunciationRemoteDataSource {
  final http.Client client;

  PronunciationRemoteDataSourceImpl({required this.client});

  @override
  Future<PronunciationFeedbackModel> sendPronunciation(
    String sentence,
    File audioFile,
  ) async {
    final uri = Uri.parse(
      'https://lissan-ai-backend-dev.onrender.com/api/v1/pronunciation/assess',
    );

    // Detect MIME type based on extension
    String mimeType = 'audio/wav';
    if (audioFile.path.endsWith('.ogg')) mimeType = 'audio/ogg';
    if (audioFile.path.endsWith('.flac')) mimeType = 'audio/flac';

    final request = http.MultipartRequest('POST', uri)
      ..fields['target_text'] = sentence
      ..files.add(
        await http.MultipartFile.fromPath(
          'audio_data',
          audioFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Response status: ${response.body}');
    if (response.statusCode == 200) {
      return PronunciationFeedbackModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Failed to send pronunciation feedback: ${response.body}',
      );
    }
  }
}
