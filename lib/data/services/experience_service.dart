import 'package:dio/dio.dart';
import '../models/experience.dart';

class ExperienceService {
  final Dio _dio;
  ExperienceService([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            ));

  Future<List<Experience>> getExperiences() async {
    final res = await _dio.get(
      'https://staging.chamberofsecrets.8club.co/v1/experiences',
      queryParameters: {'active': true},
    );
    final list = (res.data?['data']?['experiences'] as List?) ?? [];
    return list.map((e) => Experience.fromJson(e)).toList();
  }
}
