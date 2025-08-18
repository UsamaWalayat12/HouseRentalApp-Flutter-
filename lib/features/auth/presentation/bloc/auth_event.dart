part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  const SignUpRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [firstName, lastName, email, password, role];
}

class LogoutRequested extends AuthEvent {}

class UpdateUserRequested extends AuthEvent {
  final UserModel user;

  const UpdateUserRequested(this.user);

  @override
  List<Object> get props => [user];
}

class AuthSuccessful extends AuthEvent {
  final UserModel user;

  const AuthSuccessful({required this.user});

  @override
  List<Object> get props => [user];
}
