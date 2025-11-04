/// User model representing authenticated user data
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? telephone;
  final String? address;
  final String? role;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.username,
    this.firstName,
    this.lastName,
    this.telephone,
    this.address,
    this.role,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'telephone': telephone,
      'address': address,
      'role': role,
    };
  }

  /// Create from JSON - handles both backend response formats
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['id'] ?? json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName:
          json['displayName'] ??
          (json['first_name'] != null && json['last_name'] != null
              ? '${json['first_name']} ${json['last_name']}'
              : json['username']),
      photoUrl: json['photoUrl'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      telephone: json['telephone'],
      address: json['address'],
      role: json['role'],
    );
  }

  /// Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? username,
    String? firstName,
    String? lastName,
    String? telephone,
    String? address,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      telephone: telephone ?? this.telephone,
      address: address ?? this.address,
      role: role ?? this.role,
    );
  }
}
