import 'package:hive/hive.dart';

part 'unit.g.dart';

@HiveType(typeId: 7)
class Unit {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
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