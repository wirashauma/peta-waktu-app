import 'package:flutter/material.dart';
import 'package:peta_waktu/features/auth/screens/login_screen.dart';
import 'package:peta_waktu/features/dashboard/screens/dashboard_screen.dart';
import 'package:peta_waktu/features/auth/services/auth_service.dart';
import 'package:peta_waktu/features/auth/models/user_model.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService.authStateChanges,
      initialData: AuthService.mockUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen(); // Arahkan ke Dasbor baru
        }

        return const LoginScreen();
      },
    );
  }
}