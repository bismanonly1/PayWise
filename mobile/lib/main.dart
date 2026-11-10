import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'features/dashboard/data/health_repository.dart';
import 'features/dashboard/presentation/cubit/health_cubit.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const PayWiseApp());
}

class PayWiseApp extends StatelessWidget {
  const PayWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          HealthCubit(HealthRepository(http.Client()))..checkConnection(),
      child: MaterialApp(
        title: 'PayWise',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const DashboardScreen(),
      ),
    );
  }
}
