import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/shift_repository.dart';

class ShiftState{
    final bool isLoading;
    final List<Map<String, dynamic>> shifts;
    final String? error;

    const ShiftState({
        this.isLoading = false,
        this.shifts = const [],
        this.error
    });
}

class ShiftCubit extends Cubit<ShiftState> {
    ShiftCubit(this.repository) : super(const ShiftState());
    final ShiftRepository repository;

    Future<void> loadShifts() async {
        emit(ShiftState(
            isLoading: true,
            shifts: state.shifts,
        ));

        try {
            final shifts = await repository.getShifts();
            if (isClosed) return;
            emit(ShiftState(shifts: shifts));
        } catch (error) {
            if (isClosed) return;

            emit(ShiftState(
                shifts: state.shifts,
                error: error.toString()
            ));
        }
    }
}