// lib/core/cubit/generic_state.dart
import '../failure_services.dart';
import 'package:equatable/equatable.dart';

abstract class GenericState<T> extends Equatable {
  const GenericState();
  @override
  List<Object?> get props => [];
}

class GenericInitial<T> extends GenericState<T> {}

class GenericLoading<T> extends GenericState<T> {}

class GenericSuccess<T> extends GenericState<T> {
  final T data;
  const GenericSuccess(this.data);
  @override
  List<Object?> get props => [data];
}

class GenericPaginationSuccess<T> extends GenericState<T> {
  final List<T> data;
  const GenericPaginationSuccess(this.data);
  @override
  List<Object?> get props => [data];
}

class GenericError<T> extends GenericState<T> {
  final Failure failure;
  const GenericError(this.failure);
  @override
  List<Object?> get props => [failure];
}
