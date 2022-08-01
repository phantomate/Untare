import 'package:hive/hive.dart';

part 'keyword.g.dart';

@HiveType(typeId: 13)
class Keyword {

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? label;
  @HiveField(3)
  final String? description;

  Keyword({
    this.id,
    this.name,
    this.label,
    this.description
  });

  Keyword copyWith({
    int? id,
    String? name,
    String? label,
    String? description,
  }) {
    return Keyword(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
        id: json['id'] as int?,
        name: json['name'] as String?,
        label: json['label'] as String?,
        description: json['description'] as String?
    );
  }

  Map<String, dynamic> toJson() => {
    'id': this.id,
    'name': this.name,
    'label': this.label,
    'description': this.description ?? ''
  };

  @override
  String toString() => name ?? label ?? '';
}