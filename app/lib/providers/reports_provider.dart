import 'package:flutter/material.dart';
import '../models/report.dart';
import '../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ReportsProvider extends ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Report> get recentReports => _reports.take(5).toList();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  ReportsProvider() {
    // Listen to auth state to automatically load/clear reports
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadReports();
      } else {
        _reports = [];
        notifyListeners();
      }
    });

    // Test Health Check on Init
    _apiService.checkHealth();
  }

  Future<void> loadReports() async {
    // For now, ignoring user check for public issues, or assume mock auth handles it.
    // In real app, get token: await user.getIdToken();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch from Backend
      // Pass a dummy token or real one if available
      String? token = "mock-token";
      if (_auth.currentUser != null) {
        // token = await _auth.currentUser!.getIdToken();
      }

      _reports = await _apiService.fetchIssues(token: token);
    } catch (e) {
      _error = 'Failed to load reports from Backend: $e';
      print(_error);
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addReport(Report report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  Future<void> submitNewReport({
    required String title,
    required String category,
    required String description,
    String? location,
    bool hasAttachments = false,
    List<dynamic>? images,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Construct mock request body
      // In real implementation, handle image upload via multipart
      final reportData = {
        'description':
            description, // title is mapped to description in backend if missing
        'category': category,
        'lat': 0.0, // Placeholder
        'lng': 0.0, // Placeholder
        'speechText': title, // Using title as speechText just to pass it
      };

      String? imagePath;
      if (images != null && images.isNotEmpty) {
        // Extract path from first image (assuming File object)
        dynamic firstImage = images.first;
        if (firstImage is File) {
          imagePath = firstImage.path;
        } else if (firstImage is String) {
          imagePath = firstImage;
        }
      }

      final newReport = await _apiService.createIssue(reportData,
          imagePath: imagePath, token: "mock-token");
      addReport(newReport);
    } catch (e) {
      _error = 'Failed to submit report: $e';
      print(_error);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
