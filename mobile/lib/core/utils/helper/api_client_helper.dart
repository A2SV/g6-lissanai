import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lissan_ai/core/utils/constants/auth_constants.dart';

class ApiClientHelper {
  final http.Client client;
  final FlutterSecureStorage storage;

  ApiClientHelper({required this.client, required this.storage});

  Future<http.Response> get(String url) async {
    final val = await storage.read(key: AuthConstants.accessToken);

    return client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        if (val != null) 'Authorization': 'Bearer $val',
      },
    );
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final val = await storage.read(key: AuthConstants.accessToken);

    return client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        if (val != null) 'Authorization': 'Bearer $val',
      },
      body: json.encode(body),
    );
  }

  Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final val = await storage.read(key: AuthConstants.accessToken);

    return client.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        if (val != null) 'Authorization': 'Bearer $val',
      },
      body: json.encode(body),
    );
  }

  Future<http.Response> delete(String url) async {
    final val = await storage.read(key: AuthConstants.accessToken);

    return client.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
        if (val != null) 'Authorization': 'Bearer $val',
      },
    );
  }
}
