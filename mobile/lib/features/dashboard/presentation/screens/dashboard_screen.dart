import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../work_ledger/presentation/screens/add_shift_screen.dart';
import '../../../work_ledger/presentation/screens/saved_shifts_screen.dart';

import '../cubit/health_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PayWise')),
      body: Center(
        child: BlocBuilder<HealthCubit, HealthState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const CircularProgressIndicator();
            }

            if (state.error != null) {
              return Text('Connection failed: ${state.error}');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to PayWise',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Backend: ${state.status ?? "Not checked"}'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<HealthCubit>().checkConnection();
                  },
                  child: const Text('Check Connection'),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Shift'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddShiftScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View Sved Shifts'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedShiftsScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
