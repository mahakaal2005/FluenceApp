import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_login_request.g.dart';

@JsonSerializable()
class AdminLoginRequest extends Equatable {
  final String email;
  final String password;

  const AdminLoginRequest({
    required this.email,
    required this.password,
  });

  factory AdminLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminLoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminLoginRequestToJson(this);

  @override
  List<Object?> get props => [email, password];
}