class Option {
  final int id;
  final String name;

  Option({
    required this.id,
    required this.name,
  });

  // Factory constructor to parse JSON
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      name: json['name'],
    );
  }

  // Convert Option object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
    );
  }
}
