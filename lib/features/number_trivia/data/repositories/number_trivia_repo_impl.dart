import 'package:clean_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/enteties/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../datasources/number_trivia_api.dart';
import '../datasources/number_trivia_local.dart';

typedef _Strategy = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImplementation implements NumberTriviaRepository {
  final NumberTriviaApi remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImplementation(
      {@required this.remoteDataSource,
      @required this.localDataSource,
      @required this.networkInfo});

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
        () => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _Strategy strategy) async {
    try {
      if (await networkInfo.isConnected) {
        final trivia = await strategy();
        localDataSource.cacheNumberTrivia(trivia);

        return Right(trivia);
      }

      return Right(await localDataSource.getLastNumberTrivia());
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return Left(CacheFailure());
    }
  }
}
