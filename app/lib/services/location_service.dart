import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  String? _currentAddress;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location service is enabled
      if (!await isLocationServiceEnabled()) {
        if (kDebugMode) {
          print('Location services are disabled.');
        }
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permissions are denied');
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permissions are permanently denied, cannot request permissions.');
        }
        // Open app settings for user to manually enable permissions
        await openAppSettings();
        return false;
      }

      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting location permission: $e');
      }
      return false;
    }
  }

  /// Get current position with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      if (!await requestLocationPermission()) {
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return _currentPosition;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current position: $e');
      }
      return null;
    }
  }

  /// Get current address from coordinates
  Future<String?> getCurrentAddress() async {
    try {
      if (_currentPosition == null) {
        await getCurrentPosition();
      }

      if (_currentPosition == null) return null;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        
        return _currentAddress;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current address: $e');
      }
    }
    return null;
  }

  /// Get location data ready to send to backend
  Future<Map<String, dynamic>?> getLocationDataForBackend() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return null;

      String? address = await getCurrentAddress();

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'timestamp': position.timestamp.toIso8601String(),
        'address': address,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location data for backend: $e');
      }
      return null;
    }
  }

  /// Send location data to backend (placeholder function)
  Future<bool> sendLocationToBackend(Map<String, dynamic> locationData) async {
    try {
      // TODO: Implement actual API call to backend
      // Example:
      // final response = await http.post(
      //   Uri.parse('https://your-backend-api.com/location'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode(locationData),
      // );
      // return response.statusCode == 200;
      
      // For now, just simulate success
      if (kDebugMode) {
        print('Location data ready to send to backend: $locationData');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending location to backend: $e');
      }
      return false;
    }
  }

  /// Clear cached location data
  void clearLocationData() {
    _currentPosition = null;
    _currentAddress = null;
  }
}