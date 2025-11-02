import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Provider for managing audio file uploads and history
class AudioProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  List<Map<String, dynamic>> _audioHistory = [];

  /// Upload state
  bool get isUploading => _isUploading;

  /// Upload progress (0.0 to 1.0)
  double get uploadProgress => _uploadProgress;

  /// Error message
  String? get errorMessage => _errorMessage;

  /// Audio history list
  List<Map<String, dynamic>> get audioHistory => _audioHistory;

  Future<bool> uploadAudioFile({
    required String filePath,
    required String userId,
    String? fileName,
    Map<String, dynamic>? analysisData,
  }) async {
    _setUploading(true);
    _clearError();
    _uploadProgress = 0.0;

    try {
      final String downloadUrl = await _storageService.uploadAudioFile(
        filePath: filePath,
        userId: userId,
        fileName: fileName,
      );

      // Save history if analysis data is provided
      if (analysisData != null) {
        await _storageService.saveAudioHistory(
          userId: userId,
          audioUrl: downloadUrl,
          fileName: fileName ?? filePath.split('/').last,
          analysisData: analysisData,
        );
      }

      _uploadProgress = 1.0;
      _setUploading(false);
      notifyListeners();
      return true;
    } on StorageException catch (e) {
      _setError(e.message);
      _setUploading(false);
      return false;
    } catch (e) {
      _setError('Failed to upload audio: ${e.toString()}');
      _setUploading(false);
      return false;
    }
  }

  /// Upload audio file with progress tracking
  Future<bool> uploadAudioFileWithProgress({
    required String filePath,
    required String userId,
    String? fileName,
    Map<String, dynamic>? analysisData,
  }) async {
    _setUploading(true);
    _clearError();
    _uploadProgress = 0.0;

    try {
      // Listen to upload progress
      _storageService
          .uploadWithProgress(
            filePath: filePath,
            userId: userId,
            fileName: fileName,
          )
          .listen((progress) {
            _uploadProgress = progress;
            notifyListeners();
          });

      // Upload file
      final String downloadUrl = await _storageService.uploadAudioFile(
        filePath: filePath,
        userId: userId,
        fileName: fileName,
      );

      // Save history if analysis data is provided
      if (analysisData != null) {
        await _storageService.saveAudioHistory(
          userId: userId,
          audioUrl: downloadUrl,
          fileName: fileName ?? filePath.split('/').last,
          analysisData: analysisData,
        );
      }

      _uploadProgress = 1.0;
      _setUploading(false);
      return true;
    } on StorageException catch (e) {
      _setError(e.message);
      _setUploading(false);
      return false;
    } catch (e) {
      _setError('Failed to upload audio: ${e.toString()}');
      _setUploading(false);
      return false;
    }
  }

  /// Load audio history for a user
  void loadAudioHistory(String userId) {
    _storageService
        .getAudioHistory(userId)
        .listen(
          (history) {
            _audioHistory = history;
            notifyListeners();
          },
          onError: (error) {
            _setError('Failed to load history: ${error.toString()}');
          },
        );
  }

  /// Delete audio file and history item
  Future<bool> deleteAudioItem({
    required String userId,
    required String historyId,
    required String audioUrl,
  }) async {
    _clearError();

    try {
      await _storageService.deleteAudioFile(audioUrl);

      await _storageService.deleteHistoryItem(
        userId: userId,
        historyId: historyId,
      );

      return true;
    } on StorageException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to delete audio: ${e.toString()}');
      return false;
    }
  }

  /// Update notes for a history item
  Future<bool> updateHistoryNotes({
    required String userId,
    required String historyId,
    required String notes,
  }) async {
    _clearError();

    try {
      await _storageService.updateHistoryNotes(
        userId: userId,
        historyId: historyId,
        notes: notes,
      );
      return true;
    } on StorageException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to update notes: ${e.toString()}');
      return false;
    }
  }

  /// Set uploading state
  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Clear all errors
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Reset upload progress
  void resetUploadProgress() {
    _uploadProgress = 0.0;
    notifyListeners();
  }
}
