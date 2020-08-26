import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  /// Gets cached [NumberTriviaModel]
  ///
  /// Throws [CacheException]
  Future<NumberTriviaModel> getLastNumberTrivia();

  /// Caches the latest [NumberTrivia]
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const cachedKey = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({@required this.sharedPreferences});

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) async {
    sharedPreferences.setString(cachedKey, json.encode(triviaToCache.toJson()));
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() async {
    final jsonString = sharedPreferences.getString(cachedKey);
    if (jsonString == null) {
      throw CacheException();
    }

    return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
  }
}
