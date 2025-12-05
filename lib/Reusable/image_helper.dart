import 'package:dio/dio.dart';

DioMediaType getMediaType(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();

  switch (ext) {
    case 'png':
      return DioMediaType('image', 'png');
    case 'jpg':
    case 'jpeg':
      return DioMediaType('image', 'jpeg');
    case 'webp':
      return DioMediaType('image', 'webp');
    case 'svg':
      return DioMediaType('image', 'svg+xml');
    default:
      return DioMediaType('application', 'octet-stream'); // fallback
  }
}
