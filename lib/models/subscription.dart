class Subscription {
  final String id;
  final String userId;
  final String policyId;
  final bool isSubscribed;
  final bool isPaid;
  final DateTime timestamp;

  Subscription({
    required this.id,
    required this.userId,
    required this.policyId,
    required this.isSubscribed,
    required this.isPaid,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "policyId": policyId,
      "isSubscribed": isSubscribed,
      "isPaid": isPaid,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  factory Subscription.fromFirestore(Map<String, dynamic> data, String docId) {
    return Subscription(
      id: docId,
      userId: data["userId"] ?? "",
      policyId: data["policyId"] ?? "",
      isSubscribed: data["isSubscribed"] ?? false,
      isPaid: data["isPaid"] ?? false,
      timestamp: DateTime.tryParse(data["timestamp"] ?? "") ?? DateTime.now(),
    );
  }
}
