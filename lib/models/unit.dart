class Unit {

  final int? id;
  final String name;
  final String? description;

  Unit({
    this.id,
    required this.name,
    this.description
  });

  Unit copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
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