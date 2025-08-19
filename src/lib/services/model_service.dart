import 'package:flutter/foundation.dart';
import '../api/endpoints/models/model_endpoints.dart';
import '../models/model.dart';
import '../utils/logger.dart';

class ModelService extends ChangeNotifier {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal();

  List<Model> _availableModels = [];
  bool _modelsLoaded = false;

  List<Model> get availableModels => _availableModels;
  bool get modelsLoaded => _modelsLoaded;

  Model? get defaultModel => _availableModels.isNotEmpty ? _availableModels.first : null;

  Future<void> fetchModels() async {
    if (_modelsLoaded) return;

    await AppLogger.wrapOperation(
      'ModelService.fetchModels',
      () async {
        _availableModels = await ModelEndpoints.getModels();
        _modelsLoaded = true;
        notifyListeners();
      },
      startMessage: '📥 Fetching available models...',
      successMessage: '✅ Models loaded successfully',
    );
  }

  Model? getModelById(String id) {
    try {
      return _availableModels.firstWhere((model) => model.id == id);
    } catch (e) {
      return null;
    }
  }
}
