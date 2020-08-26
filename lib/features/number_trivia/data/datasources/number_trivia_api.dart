import 'dart:convert';

import 'package:clean_course/core/errors/exceptions.dart';
import 'package:clean_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/enteties/number_trivia.dart';

abstract class NumberTriviaApi {
  /// Calls the endpoint.
  ///
  /// Throws a [ServerException] on all errors
  Future<NumberTrivia> getConcreteNumberTrivia(int number);

  /// Calls the endpoint.
  ///
  /// Throws a [ServerException] on all errors
  Future<NumberTrivia> getRandomNumberTrivia();
}

class NumberTriviaApiImpl implements NumberTriviaApi {
  final http.Client client;

  NumberTriviaApiImpl({@required this.client});

  @override
  Future<NumberTrivia> getConcreteNumberTrivia(int number) =>
      _getCall('http:numbersapi.com/$number');

  @override
  Future<NumberTrivia> getRandomNumberTrivia() =>
      _getCall('http:numbersapi.com/random');

  Future<NumberTriviaModel> _getCall(String url) async {
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw ServerException();
    }

    return NumberTriviaModel.fromJson(json.decode(response.body));
  }
}
