import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'faq.g.dart';

@JsonSerializable()
class FAQ extends Equatable {
  final String id;
  final String question;
  final String answer;
  final String category;

  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) => _$FAQFromJson(json);

  Map<String, dynamic> toJson() => _$FAQToJson(this);

  @override
  List<Object?> get props => [id, question, answer, category];
}
