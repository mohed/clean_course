import 'package:flutter/foundation.dart';

import '../../domain/enteties/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  NumberTriviaModel({@required int number, @required String text})
      : super(number: number, text: text);

  @override
  List<Object> get props => [number, text];

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(
        number: (json['number'] as num).toInt(), text: json['text']);
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'number': number};
  }
}
