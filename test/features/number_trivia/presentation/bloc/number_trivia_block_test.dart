import 'package:clean_course/core/errors/failures.dart';
import 'package:clean_course/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:clean_course/core/util/input_converter.dart';
import 'package:clean_course/features/number_trivia/domain/enteties/number_trivia.dart';
import 'package:clean_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initial state should be empty', () async {
    expect(bloc.initialState, equals(Empty()));
  });

  group('getTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test');
    test(
        'should call the input converter to validate and convert the string to an integer',
        () async {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(Right(tNumberParsed));

      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

      await untilCalled(
          mockInputConverter.stringToUnsignedInteger(tNumberString));
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

      final expected = [
        Empty(),
        Loading(),
        Error(message: invalidInputFailureMessage),
      ];
      expectLater(bloc, emitsInOrder(expected));
    });

    test(
      'should get data from the concrete use case',
      () async {
        when(mockInputConverter.stringToUnsignedInteger(tNumberString))
            .thenReturn(Right(tNumberParsed));
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));

        bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));

        verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    test('should emit [Loading, Loaded] when data is gotten succesfully',
        () async {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(Right(tNumberParsed));
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc, emitsInOrder(expected));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(Right(tNumberParsed));
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));

      final expected = [
        Empty(),
        Loading(),
        Error(message: serverFailureMessage),
      ];
      expectLater(bloc, emitsInOrder(expected));
    });

    test(
        'should emit [Loading, Error] with correct error message when getting data fails',
        () async {
      when(mockInputConverter.stringToUnsignedInteger(tNumberString))
          .thenReturn(Right(tNumberParsed));
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: cacheFailureMessage),
      ];
      expectLater(bloc, emitsInOrder(expected));

      bloc.add(GetTriviaForConcreteNumberEvent(tNumberString));
    });
  });

  group('getTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test');

    test(
      'should get data from the concrete use case',
      () async {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));

        bloc.add(GetTriviaForRandomNumberEvent());
        await untilCalled(mockGetRandomNumberTrivia(any));

        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test('should emit [Loading, Loaded] when data is gotten succesfully',
        () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));

      bloc.add(GetTriviaForRandomNumberEvent());

      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc, emitsInOrder(expected));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      bloc.add(GetTriviaForRandomNumberEvent());

      final expected = [
        Empty(),
        Loading(),
        Error(message: serverFailureMessage),
      ];
      expectLater(bloc, emitsInOrder(expected));
    });

    test(
        'should emit [Loading, Error] with correct error message when getting data fails',
        () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));

      final expected = [
        Empty(),
        Loading(),
        Error(message: cacheFailureMessage),
      ];
      expectLater(bloc, emitsInOrder(expected));

      bloc.add(GetTriviaForRandomNumberEvent());
    });
  });
}
