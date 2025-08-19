import 'dart:convert';
import '../../../models/model.dart';
import '../../api_client.dart';

class ModelEndpoints {
  static Future<List<Model>> getModels() async {
    final response = await ApiClient.instance.get('/api/models');
    final modelListResponse = ModelListResponse.fromJson(jsonDecode(response.body));
    return modelListResponse.data;
  }
}
