import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  ApiService();

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      print('Health Check: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Server Response: ${response.body}');
        return true;
      }
      return false;
    } catch (e) {
      print('Health Check Failed: $e');
      return false;
    }
  }

  Future<List<Report>> fetchIssues({String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/issues?myIssues=true'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['data'];
        return data.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load issues: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching issues: $e');
      rethrow;
    }
  }

  Future<Report> createIssue(
    Map<String, dynamic> issueData, {
    String? imagePath,
    String? token,
  }) async {
    try {
      print('[API] Creating issue at ${ApiService.baseUrl}/issues');
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiService.baseUrl}/issues'));

      // Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      print('[API] Headers: ${request.headers}');

      // Fields
      request.fields['description'] =
          issueData['description']?.toString() ?? '';
      request.fields['category'] =
          issueData['category']?.toString() ?? 'General';

      print('[API] Fields: ${request.fields}');

      // Handle Location
      if (issueData.containsKey('lat')) {
        request.fields['lat'] = issueData['lat'].toString();
      }
      if (issueData.containsKey('lng')) {
        request.fields['lng'] = issueData['lng'].toString();
      }
      if (issueData.containsKey('speechText')) {
        request.fields['speechText'] = issueData['speechText'].toString();
      }

      // File
      if (imagePath != null && imagePath.isNotEmpty) {
        print('[API] Attaching image: $imagePath');
        // Automatically determine content type (image/jpeg etc)
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      } else {
        print('[API] No image path provided');
      }

      // Send
      print('[API] Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('[API] Response Code: ${response.statusCode}');
      print('[API] Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        return Report.fromJson(body['data']);
      } else {
        throw Exception(
            'Failed to create issue: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('[API] Error creating issue: $e');
      rethrow;
    }
  }
}
