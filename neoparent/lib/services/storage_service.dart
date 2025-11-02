import 'dart:io';

class StorageService {
  final List<Map<String, dynamic>> _audioHistory = [];

  Future<String> uploadAudioFile({
    required String filePath,
    required String userId,
    String? fileName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final File file = File(filePath);
    if (!await file.exists()) {
      throw StorageException('File not found');
    }

    final String uploadFileName =
        fileName ??
        'audio_${DateTime.now().millisecondsSinceEpoch}.${_getFileExtension(filePath)}';

    final String mockUrl = 'file://local/storage/$userId/$uploadFileName';
    return mockUrl;
  }

  Future<String> saveAudioHistory({
    required String userId,
    required String audioUrl,
    required String fileName,
    required Map<String, dynamic> analysisData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final String historyId = DateTime.now().millisecondsSinceEpoch.toString();

    _audioHistory.add({
      'id': historyId,
      'userId': userId,
      'audioUrl': audioUrl,
      'fileName': fileName,
      'analysis': analysisData['analysis'] ?? 'Unknown',
      'confidence': analysisData['confidence'] ?? 0,
      'duration': analysisData['duration'] ?? 0,
      'status': analysisData['status'] ?? 'completed',
      'notes': analysisData['notes'],
      'uploadedAt': DateTime.now(),
      'createdAt': DateTime.now(),
    });

    return historyId;
  }

  Stream<List<Map<String, dynamic>>> getAudioHistory(String userId) async* {
    await Future.delayed(const Duration(milliseconds: 300));

    final userHistory = _audioHistory
        .where((item) => item['userId'] == userId)
        .toList();

    userHistory.sort(
      (a, b) =>
          (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime),
    );

    yield userHistory;
  }

  Future<void> deleteAudioFile(String fileUrl) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> deleteHistoryItem({
    required String userId,
    required String historyId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _audioHistory.removeWhere(
      (item) => item['id'] == historyId && item['userId'] == userId,
    );
  }

  Future<void> updateHistoryNotes({
    required String userId,
    required String historyId,
    required String notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _audioHistory.indexWhere(
      (item) => item['id'] == historyId && item['userId'] == userId,
    );

    if (index != -1) {
      _audioHistory[index]['notes'] = notes;
      _audioHistory[index]['updatedAt'] = DateTime.now();
    }
  }

  String _getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  Stream<double> uploadWithProgress({
    required String filePath,
    required String userId,
    String? fileName,
  }) async* {
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      yield i / 10.0;
    }
  }
}

class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}
