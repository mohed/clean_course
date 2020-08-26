import 'dart:convert';

import 'package:clean_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_course/features/number_trivia/domain/enteties/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test');

  test(
    'shoud be a subclass of NumberTrivia',
    () async {
      // assert
      expect(tNumberTriviaModel, isA<NumberTrivia>());
    },
  );

  group('fromJson', () {
    test('should return a valid modil when JSON number is an integer',
        () async {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));

      // act
      var result = NumberTriviaModel.fromJson(jsonMap);

      // assert
      expect(result, tNumberTriviaModel);
    });

    test('should return a valid modil when JSON number is a double', () async {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));

      // act
      var result = NumberTriviaModel.fromJson(jsonMap);

      // assert
      expect(result, tNumberTriviaModel);
    });
  });

  group('toJson', () {
    test('should return JSON map containing the proper data', () async {
      // act
      var result = tNumberTriviaModel.toJson();

      // assert
      final expected = {
        "text": "Test",
        "number": 1,
      };
      expect(result, expected);
    });
  });
}
