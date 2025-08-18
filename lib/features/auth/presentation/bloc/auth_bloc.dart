import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rent_a_home/core/services/auth_service.dart';
import 'package:rent_a_home/shared/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UpdateUserRequested>(_onUpdateUserRequested);
    on<AuthSuccessful>(_onAuthSuccessful);
  }

  Future<void> _onUpdateUserRequested(
      UpdateUserRequested event, Emitter<AuthState> emit) async {
    try {
      await _authService.updateUser(event.user);
      emit(Authenticated(user: event.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    print('🔍 AuthBloc: Starting authentication check...');
    emit(AuthLoading());
    
    try {
      final userStream = _authService.user;
      await emit.forEach(userStream, onData: (user) {
        print('🔍 AuthBloc: Received user data - ID: ${user.id}, Role: ${user.role}');
        
        if (user.id.isNotEmpty) {
          print('✅ AuthBloc: User authenticated as ${user.role}');
          return Authenticated(user: user);
        } else {
          print('❌ AuthBloc: User not authenticated');
          return Unauthenticated();
        }
      });
    } catch (e) {
      print('❌ AuthBloc: Error during auth check: $e');
      emit(AuthError(message: 'Authentication check failed: $e'));
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    print('Login requested for email: ${event.email}');
    emit(AuthLoading());
    try {
      print('Attempting to sign in with email and password...');
      final user = await _authService.signInWithEmailAndPassword(
          event.email, event.password);
      
      print('Sign in successful. User ID: ${user?.uid}');
      
      if (user != null) {
        print('Fetching user details from Firestore...');
        final userModel = await _authService.getUserDetails(user.uid);
        if (userModel != null) {
          print('User details fetched successfully. Role: ${userModel.role}');
          emit(Authenticated(user: userModel));
        } else {
          final errorMsg = 'Could not fetch user details. User might not exist in Firestore.';
          print(errorMsg);
          emit(AuthError(message: errorMsg));
        }
      } else {
        final errorMsg = 'Login failed. Please check your credentials.';
        print(errorMsg);
        emit(AuthError(message: errorMsg));
      }
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      if (user != null) {
        final userModel = await _authService.getUserDetails(user.uid);
        if (userModel != null) {
          emit(Authenticated(user: userModel));
        } else {
          emit(AuthError(message: 'Could not fetch user details.'));
        }
      } else {
        emit(AuthError(message: 'Sign up failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onAuthSuccessful(
      AuthSuccessful event, Emitter<AuthState> emit) async {
    emit(Authenticated(user: event.user));
  }
}




