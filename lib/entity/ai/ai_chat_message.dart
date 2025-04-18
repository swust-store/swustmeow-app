enum MessageRole {
  user,
  assistant,
  system,
}

class AIChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isComplete;
  final bool isReceiving;

  AIChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isComplete = true,
    this.isReceiving = true,
  });

  factory AIChatMessage.user({
    required String content,
  }) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  factory AIChatMessage.assistant({
    required String content,
    bool isComplete = false,
    bool isReceiving = false,
  }) {
    return AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      content: content,
      timestamp: DateTime.now(),
      isComplete: isComplete,
      isReceiving: isReceiving,
    );
  }

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.byName(json['role'] as String),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isComplete: json['isComplete'] as bool? ?? true,
      isReceiving: json['isReceiving'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isComplete': isComplete,
      'isReceiving': isReceiving,
    };
  }

  AIChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isComplete,
    bool? isReceiving,
  }) {
    return AIChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isComplete: isComplete ?? this.isComplete,
      isReceiving: isReceiving ?? this.isReceiving,
    );
  }
}
