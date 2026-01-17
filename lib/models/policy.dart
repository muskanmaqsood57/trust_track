class Policy {
  final String id; // Firestore document ID (same as auth UID if you align them)
  final String name;
  final String description;
  final String price;
  final String paymentCycle;
  final String commission;

  Policy({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.paymentCycle,
    required this.commission
  });

  // From Firestore document
  factory Policy.fromFirestore(Map<String, dynamic> data, String docId) {
    return Policy(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: data['price'] ?? '',
      paymentCycle: data['paymentCycle'] ?? '',
      commission: data['commission']
    );
  }

  // To Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "price": price,
      "paymentCycle": paymentCycle,
      "commission": commission,
    };
  }
}
