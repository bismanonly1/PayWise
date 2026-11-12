
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/shift_repository.dart';
import '../cubit/shift_cubit.dart';
import 'add_shift_screen.dart';

class SavedShiftsScreen extends StatelessWidget {
  const SavedShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<http.Client>(
      create: (_) => http.Client(),
      dispose: (client) => client.close(),
      child: BlocProvider(
        create: (context) => ShiftCubit(
          ShiftRepository(context.read<http.Client>()),
        )..loadShifts(),
        child: const _SavedShiftsView(),
      ),
    );
  }
}

class _SavedShiftsView extends StatelessWidget {
  const _SavedShiftsView();

  Future<void> _openAddShift(BuildContext context) async {
    final cubit = context.read<ShiftCubit>();

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddShiftScreen(),
      ),
    );

    if (saved == true && !cubit.isClosed) {
      await cubit.loadShifts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Shifts'),
        actions: [
          IconButton(
            tooltip: 'Refresh shifts',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<ShiftCubit>().loadShifts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddShift(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
      ),
      body: BlocBuilder<ShiftCubit, ShiftState>(
        builder: (context, state) {
          if (state.isLoading && state.shifts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null && state.shifts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Unable to load shifts: ${state.error}'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<ShiftCubit>().loadShifts(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<ShiftCubit>().loadShifts(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${state.shifts.length} saved shifts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (state.isLoading)
                  const LinearProgressIndicator(),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Refresh failed: ${state.error}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (state.shifts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No shifts saved yet. Tap Add Shift to begin.',
                      ),
                    ),
                  ),
                for (final shift in state.shifts)
                  Card(
                    child: ListTile(
                      title: Text(
                        shift['location']?.toString() ??
                            'Unknown location',
                      ),
                      subtitle: Text(
                        'Start: ${shift['start_time']}\n'
                        'Paid hours: '
                        '${(shift['paid_hours'] as num).toStringAsFixed(2)}',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        '\$${(shift['gross_base_pay'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
