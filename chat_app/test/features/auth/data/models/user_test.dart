import 'dart:convert';
import 'package:chat_app/features/auth/data/models/user.dart';
import 'package:chat_app/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const tUserModel = UserModel(
    id: '66bde36e9bbe07fc39034cdd',
    name: 'Mr. User',
    email: 'user@gmail.com',
  );
  final String userJson = fixture('user.json');
  test('should be a subclass of User entity', () async {
    expect(tUserModel, isA<User>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is valid', () async {
      final Map<String, dynamic> jsonMap = json.decode(userJson);
      final result = UserModel.fromJson(jsonMap);
      expect(result, tUserModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      final result = tUserModel.toJson();
      final expectedMap = {
        '_id': '66bde36e9bbe07fc39034cdd',
        'name': 'Mr. User',
        'email': 'user@gmail.com',
      };
      expect(result, expectedMap);
    });
  });
}
