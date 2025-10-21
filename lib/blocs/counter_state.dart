part of 'counter_bloc.dart';

class CounterState extends Equatable {
  const CounterState({this.count = 0});

  final int count;

  CounterState copyWith({int? count}) {
    return CounterState(
      count: count ?? this.count,
    );
  }

  @override
  List<Object> get props => [count];
}