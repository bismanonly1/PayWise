
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/health_repository.dart';

class HealthState {
  final bool isLoading;
  final String? status;
  final String? error;

  const HealthState({
    this.isLoading = false,
    this.status,
    this.error,
  });
}

class HealthCubit extends Cubit<HealthState> {
  final HealthRepository repository;

  HealthCubit(this.repository) : super(const HealthState());

  Future<void> checkConnection() async {
    emit(const HealthState(isLoading: true));

    try {
      final status = await repository.checkHealth();
      emit(HealthState(status: status));
    } catch (e) {
      emit(HealthState(error: e.toString()));
    }
  }
}
