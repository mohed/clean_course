import 'dart:convert';

import 'package:clean_course/core/errors/exceptions.dart';
import 'package:clean_course/features/number_trivia/data/datasources/number_trivia_api.dart';
import 'package:clean_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matcher/matcher.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaApi dataSource;
  http.Client mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaApiImpl(client: mockHttpClient);
  });

  void setUpMockClientSuccessResponse() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockClientNotFountResponse() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Not found', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should do GET request on a URL to /number and
         with application/json header''', () async {
      setUpMockClientSuccessResponse();

      await dataSource.getConcreteNumberTrivia(tNumber);

      verify(mockHttpClient.get(
        'http:numbersapi.com/$tNumber',
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });

    test('should return NumberTrivia when the response code is 200', () async {
      setUpMockClientSuccessResponse();

      final result = await dataSource.getConcreteNumberTrivia(tNumber);

      expect(result, equals(tNumberModel));
    });

    test('should throw ServerException when status code is not 200', () async {
      setUpMockClientNotFountResponse();

      final call = dataSource.getConcreteNumberTrivia;

      expect(call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test('''should do GET request on a URL to /random and
         with application/json header''', () async {
      setUpMockClientSuccessResponse();

      await dataSource.getRandomNumberTrivia();

      verify(mockHttpClient.get(
        'http:numbersapi.com/random',
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });

    test('should return NumberTrivia when the response code is 200', () async {
      setUpMockClientSuccessResponse();

      final result = await dataSource.getRandomNumberTrivia();

      expect(result, equals(tNumberModel));
    });

    test('should throw ServerException when status code is not 200', () async {
      setUpMockClientNotFountResponse();

      final call = dataSource.getRandomNumberTrivia;

      expect(call(), throwsA(TypeMatcher<ServerException>()));
    });
  });
}
