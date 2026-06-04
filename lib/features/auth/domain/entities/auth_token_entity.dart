import 'package:equatable/equatable.dart';

class AuthTokenEntity extends Equatable {
  final String token;

  const AuthTokenEntity({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}
