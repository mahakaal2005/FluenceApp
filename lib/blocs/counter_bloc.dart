import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterState()) {
    on<CounterIncremented>(_onCounterIncremented);
    on<CounterDecremented>(_onCounterDecremented);
    on<CounterReset>(_onCounterReset);
  }

  void _onCounterIncremented(
    CounterIncremented event,
    Emitter<CounterState> emit,
  ) {
    emit(state.copyWith(count: state.count + 1));
  }

  void _onCounterDecremented(
    CounterDecremented event,
    Emitter<CounterState> emit,
  ) {
    emit(state.copyWith(count: state.count - 1));
  }

  void _onCounterReset(
    CounterReset event,
    Emitter<CounterState> emit,
  ) {
    emit(state.copyWith(count: 0));
  }
}