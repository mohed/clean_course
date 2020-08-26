import 'dart:convert';

import 'package:clean_course/core/errors/exceptions.dart';
import 'package:clean_course/features/number_trivia/data/datasources/number_trivia_local.dart';
import 'package:clean_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test('should return NumberTrivia when there is on in the cache', () async {
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));

      final result = await dataSource.getLastNumberTrivia();

      verify(mockSharedPreferences.getString(cachedKey));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should thrown CacheException when the cache is empty', () async {
      when(mockSharedPreferences.getString(any)).thenReturn(null);

      final call = (() async => await dataSource.getLastNumberTrivia());

      expect(call, throwsA(isA<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test');
    test('shoud call SharedPreferences to cache the data', () async {
      await dataSource.cacheNumberTrivia(tNumberTriviaModel);

      verify(mockSharedPreferences.setString(
          cachedKey, json.encode(tNumberTriviaModel.toJson())));
    });
  });
}
