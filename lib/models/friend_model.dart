class Friend {
  final String userId;
  final String username;
  final String? avatarId;
  final DateTime addedAt;
  final double? compatibilityScore;

  Friend({
    required this.userId,
    required this.username,
    this.avatarId,
    required this.addedAt,
    this.compatibilityScore,
  });

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      avatarId: map['avatarId'],
      addedAt: map['addedAt']?.toDate() ?? DateTime.now(),
      compatibilityScore: map['compatibilityScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'avatarId': avatarId,
      'addedAt': addedAt,
      'compatibilityScore': compatibilityScore,
    };
  }
}

class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String toUserId;
  final String fromUsername;
  final String toUsername;
  final String? fromAvatarId;
  final String? toAvatarId;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  FriendRequest({
    required this.requestId,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUsername,
    required this.toUsername,
    this.fromAvatarId,
    this.toAvatarId,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromMap(String id, Map<String, dynamic> map) {
    return FriendRequest(
      requestId: id,
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      fromUsername: map['fromUsername'] ?? '',
      toUsername: map['toUsername'] ?? '',
      fromAvatarId: map['fromAvatarId'],
      toAvatarId: map['toAvatarId'],
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUsername': fromUsername,
      'toUsername': toUsername,
      'fromAvatarId': fromAvatarId,
      'toAvatarId': toAvatarId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
