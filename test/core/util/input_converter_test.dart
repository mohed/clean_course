import 'package:clean_course/core/util/input_converter.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInteger', () {
    test('should return an integer for a positive string number', () async {
      final string = '123';

      final result = inputConverter.stringToUnsignedInteger(string);

      expect(result, equals(Right(123)));
    });

    test('should return an InvalidInputFailure for non integer valued strings',
        () {
      final string = 'ABC';

      final result = inputConverter.stringToUnsignedInteger(string);

      expect(result, equals(Left(InvalidInputFailure())));
    });

    test('should return an InvalidInputFailure for negative numbers',
        () {
      final string = '-123';

      final result = inputConverter.stringToUnsignedInteger(string);

      expect(result, equals(Left(InvalidInputFailure())));
    });
  });
}
