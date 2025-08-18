import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/mongodb_image_service.dart';
import 'shared/models/user_model.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/landlord/presentation/bloc/landlord_booking_bloc.dart';
import 'features/landlord/data/landlord_booking_repository.dart';
import 'features/tenant/presentation/bloc/tenant_booking_bloc.dart';
import 'features/tenant/presentation/providers/booking_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/property/presentation/pages/home_page.dart';
import 'features/landlord/presentation/pages/landlord_home_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize MongoDB Image Service
  try {
    await MongoDBImageService.initialize();
    print('✅ MongoDB Image Service initialized successfully');
  } catch (e) {
    print('⚠️ MongoDB Image Service initialization failed: $e');
    // Continue without MongoDB - app can still function with Firebase
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(authService: AuthService())
            ..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => PropertyBloc(),
        ),
        BlocProvider(
          create: (context) => LandlordBookingBloc(LandlordBookingRepository()),
        ),
        BlocProvider(
          create: (context) => TenantBookingBloc(bookingProvider: BookingProvider()),
        ),
      ],
      child: MaterialApp(
        title: 'Rent a Home',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is Authenticated) {
              if (state.user.role == 'landlord') {
                return const LandlordHomePage();
              } else {
                return const HomePage();
              }
            } else {
              return const SplashPage();
            }
          },
        ),
      ),
    );
  }
}

