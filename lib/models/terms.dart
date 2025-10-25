import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'terms.g.dart';

@JsonSerializable()
class Terms extends Equatable {
  final String id;
  final String title;
  final String content;
  final String version;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'effective_date')
  final DateTime effectiveDate;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Terms({
    required this.id,
    required this.title,
    required this.content,
    required this.version,
    required this.isActive,
    required this.effectiveDate,
    required this.createdAt,
  });

  factory Terms.fromJson(Map<String, dynamic> json) => _$TermsFromJson(json);

  Map<String, dynamic> toJson() => _$TermsToJson(this);

  @override
  List<Object?> get props => [id, title, content, version, isActive, effectiveDate, createdAt];
}
