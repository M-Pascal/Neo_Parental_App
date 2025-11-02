import '../models/user_profile_model.dart';

class UserProfileService {
  final Map<String, UserProfile> _profiles = {};

  Future<UserProfile?> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profiles[userId];
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profiles[profile.uid] = profile;
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_profiles.containsKey(userId)) {
      final currentProfile = _profiles[userId]!;
      _profiles[userId] = UserProfile(
        uid: currentProfile.uid,
        email: data['email'] ?? currentProfile.email,
        fullName: data['fullName'] ?? currentProfile.fullName,
        phoneNumber: data['phoneNumber'] ?? currentProfile.phoneNumber,
        address: data['address'] ?? currentProfile.address,
        childDateOfBirth:
            data['childDateOfBirth'] ?? currentProfile.childDateOfBirth,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  Stream<UserProfile?> getUserProfileStream(String userId) async* {
    await Future.delayed(const Duration(milliseconds: 300));
    yield _profiles[userId];
  }

  Future<void> deleteUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _profiles.remove(userId);
  }

  Future<bool> profileExists(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _profiles.containsKey(userId);
  }
}
