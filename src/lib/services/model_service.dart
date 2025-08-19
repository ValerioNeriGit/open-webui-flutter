import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/endpoints/models/model_endpoints.dart';
import '../models/model.dart';
import '../utils/logger.dart';

class ModelService extends ChangeNotifier {
  static final ModelService _instance = ModelService._internal();
  factory ModelService() => _instance;
  ModelService._internal() {
    _loadLastSelectedModelId();
  }

  List<Model> _availableModels = [];
  bool _modelsLoaded = false;
  String? _lastSelectedModelId;

  List<Model> get availableModels => _availableModels;
  bool get modelsLoaded => _modelsLoaded;

  Model? get defaultModel {
    if (_lastSelectedModelId != null) {
      final lastSelected = getModelById(_lastSelectedModelId!);
      if (lastSelected != null) {
        return lastSelected;
      }
    }
    return _availableModels.isNotEmpty ? _availableModels.first : null;
  }

  Future<void> _loadLastSelectedModelId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastSelectedModelId = prefs.getString('last_selected_model_id');
      AppLogger.info('💾 Loaded last selected model ID: $_lastSelectedModelId');
    } catch (e) {
      AppLogger.error('Failed to load last selected model ID', e);
    }
  }

  Future<void> saveSelectedModel(Model model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_selected_model_id', model.id);
      _lastSelectedModelId = model.id;
      AppLogger.info('💾 Saved last selected model ID: ${model.id}');
    } catch (e) {
      AppLogger.error('Failed to save last selected model ID', e);
    }
  }

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