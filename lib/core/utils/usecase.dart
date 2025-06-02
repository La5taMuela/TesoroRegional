import 'package:dartz/dartz.dart';
import 'package:tesoro_regional/core/utils/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
