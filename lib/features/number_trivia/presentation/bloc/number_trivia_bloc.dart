import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:clean_course/core/errors/failures.dart';
import 'package:clean_course/core/usecases/usecase.dart';
import 'package:clean_course/core/util/input_converter.dart';
import 'package:clean_course/features/number_trivia/domain/enteties/number_trivia.dart';
import 'package:clean_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid input - the number should be a positive integer';
const String unexpectedFailureMessage = 'Unexpected error';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  NumberTriviaBloc(
      {@required GetConcreteNumberTrivia concrete,
      @required GetRandomNumberTrivia random,
      @required this.inputConverter})
      : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        _getConcreteNumberTrivia = concrete,
        _getRandomNumberTrivia = random;

  final GetConcreteNumberTrivia _getConcreteNumberTrivia;
  final GetRandomNumberTrivia _getRandomNumberTrivia;
  final InputConverter inputConverter;

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    yield Loading();

    switch (event.runtimeType) {
      case GetTriviaForConcreteNumberEvent:
        yield* _handleConcreteEvent(event);
        break;
      case GetTriviaForRandomNumberEvent:
        yield* _handleRandomEvent();
        break;
    }
  }

  @override
  NumberTriviaState get initialState => Empty();

  Stream<NumberTriviaState> _handleConcreteEvent(
      GetTriviaForConcreteNumberEvent event) async* {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    yield* inputEither.fold(
      (failure) async* {
        yield Error(message: invalidInputFailureMessage);
      },
      (integer) async* {
        final triviaEither =
            await _getConcreteNumberTrivia(Params(number: integer));
        yield* _getOrError(triviaEither);
      },
    );
  }

  Stream<NumberTriviaState> _handleRandomEvent() async* {
    final triviaEither = await _getRandomNumberTrivia(NoParams());
    yield* _getOrError(triviaEither);
  }

  Stream<NumberTriviaState> _getOrError(
      Either<Failure, NumberTrivia> trivia) async* {
    yield trivia.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (trivia) => Loaded(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return serverFailureMessage;
      default:
        return unexpectedFailureMessage;
    }
  }
}
