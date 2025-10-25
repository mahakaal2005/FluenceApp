import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [id, name, email, phone, role, status, createdAt, updatedAt];
}

// Admin user management model
@JsonSerializable()
class AdminUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final DateTime joinDate;
  final String? company;
  final String? businessType;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.joinDate,
    this.company,
    this.businessType,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);

  Map<String, dynamic> toJson() => _$AdminUserToJson(this);

  @override
  List<Object?> get props => [id, name, email, phone, status, joinDate, company, businessType];
}
