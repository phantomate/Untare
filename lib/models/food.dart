class Food {

  final int? id;
  final String name;
  final String? description;

  Food({
    this.id,
    required this.name,
    this.description
  });

  Food copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?
    );
  }

  Map<String, dynamic> toJson() => {
    'id': this.id,
    'name': this.name,
    'description': this.description ?? ''
  };

  @override
  String toString() => name;
}