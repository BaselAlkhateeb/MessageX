

class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> deletedBy;
  final Map<String, DateTime?> deletedAt;

  final Map<String, DateTime?> lastSeenBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    this.deletedBy = const {},
    this.lastSeenBy = const {},
    this.deletedAt = const {},
    required this.createdAt,
    required this.updatedAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'unreadCount': unreadCount,
      'deletedBy': deletedBy,
      'deletedAt': deletedAt.map(
        (key, value) => MapEntry(key, value?.microsecondsSinceEpoch),
      ),
      'lastSeenBy': lastSeenBy.map(
        (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  static ChatModel fromJson(Map<String, dynamic> map) {
    // lastSeenBy
    Map<String, DateTime?> lastSeenMap = {};
    if (map['lastSeenBy'] != null) {
      Map<String, dynamic> rawLastSeen = Map<String, dynamic>.from(
        map['lastSeenBy'],
      );

      lastSeenMap = rawLastSeen.map(
        (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value) : null,
        ),
      );
    }

    // deletedAt
    Map<String, DateTime?> deletedAtMap = {};
    if (map['deletedAt'] != null) {
      Map<String, dynamic> rawDeletedAt = Map<String, dynamic>.from(
        map['deletedAt'],
      );

      deletedAtMap = rawDeletedAt.map(
        (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMicrosecondsSinceEpoch(value) : null,
        ),
      );
    }

    return ChatModel(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageSenderId: map['lastMessageSenderId'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      deletedBy: Map<String, bool>.from(map['deletedBy'] ?? {}),
      lastSeenBy: lastSeenMap,
      deletedAt: deletedAtMap,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? deletedBy,
    Map<String, DateTime?>? deletedAt,
    Map<String, DateTime?>? lastSeenBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      deletedBy: deletedBy ?? this.deletedBy,
      deletedAt: deletedAt ?? this.deletedAt,
      lastSeenBy: lastSeenBy ?? this.lastSeenBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // يرجّع ID الطرف الآخر في المحادثة (شات خاص)
  String getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  // عدد الرسائل غير المقروءة لمستخدم
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  // هل المحادثة محذوفة للمستخدم؟
  bool isDeletedBy(String userId) {
    return deletedBy[userId] ?? false;
  }

  // وقت حذف المحادثة للمستخدم
  DateTime? getDeletedAt(String userId) {
    return deletedAt[userId];
  }

  // آخر مرة المستخدم شاف المحادثة
  DateTime? getLastSeenBy(String userId) {
    return lastSeenBy[userId];
  }

  bool isMessageSeen(String currentUserId, String otherUserId){
      if (lastMessageSenderId == currentUserId) {
            final otherUserLastSeen = getLastSeenBy(otherUserId);
      if (otherUserLastSeen != null && lastMessageTime != null) {
        return otherUserLastSeen.isAfter(lastMessageTime!) ||
            otherUserLastSeen.isAtSameMomentAs(lastMessageTime!);
      }
    }
    return false;
  }
  
}
