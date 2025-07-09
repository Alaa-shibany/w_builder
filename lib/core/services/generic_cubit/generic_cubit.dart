// lib/core/cubit/base_cubit.dart

import '../failure_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'generic_state.dart';

class BaseCubit<T> extends Cubit<GenericState<T>> {
  BaseCubit(genericInitial) : super(GenericInitial<T>());

  Future<void> executeRequest(Future<Either<Failure, T>> request) async {
    emit(GenericLoading<T>());
    final result = await request;
    result.fold(
      (failure) => emit(GenericError<T>(failure)),
      (data) => emit(GenericSuccess<T>(data)),
    );
  }
}
