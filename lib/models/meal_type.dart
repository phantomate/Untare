class MealType {

  final int? id;
  final String name;
  final int order;
  final String? icon;
  final String? color;
  final bool defaultType;
  final int createdBy;

  MealType({
    this.id,
    required this.name,
    required this.order,
    this.icon,
    this.color,
    required this.defaultType,
    required this.createdBy
  });

  MealType copyWith({
    int? id,
    String? name,
    int? order,
    String? icon,
    String? color,
    bool? defaultType,
    int? createdBy
  }) {
    return MealType(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      defaultType: defaultType ?? this.defaultType,
      createdBy: createdBy ?? this.createdBy
    );
  }

  factory MealType.fromJson(Map<String, dynamic> json) {
    return MealType(
      id: json['id'] as int,
      name: json['name'] as String,
      order: json['order'] as int,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      defaultType: json['default'] as bool,
      createdBy: json['created_by'] as int
    );
  }

  Map<String, dynamic> toJson() => {
    'id': this.id,
    'name': this.name,
    'order': this.order,
    'icon': this.icon,
    'color': this.color,
    'default': this.defaultType
  };
}