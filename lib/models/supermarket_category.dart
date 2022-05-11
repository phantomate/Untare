class SupermarketCategory {

  final int? id;
  final String name;
  final String? description;

  SupermarketCategory({
    this.id,
    required this.name,
    this.description
  });

  SupermarketCategory copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return SupermarketCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  factory SupermarketCategory.fromJson(Map<String, dynamic> json) {
    return SupermarketCategory(
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