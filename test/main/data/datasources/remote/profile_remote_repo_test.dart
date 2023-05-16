import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/src/data/datasources/remote/profile_remote_datasource.dart';
import 'package:pet_match/src/utils/error/failure.dart';
import 'package:pet_match/src/utils/rest_helper.dart';
import 'package:mocktail/mocktail.dart';

class MockRestClient extends Mock implements RestClient {}

void main() {
  test('fetchActiveProfileListAndReturnOK', () async {
    final mockRest = MockRestClient();
    ProfileRemoteDataSource dataSource = ProfileRemoteDataSource(mockRest);
    const userId = "1111";
    const results = '''[
      {
        "id": "cea68a9d-f7c7-4cd3-b567-0780e98ff292",
        "avatar": "link.avatar.com",
        "name": "Doggie"
      },
      {
        "id": "2e80690b-d6d1-44eb-a6f5-38ec0c0b1349",
        "avatar": "link.avatar.com",
        "name": "Doggie"
      },
      {
        "id": "c27992d6-76df-48fe-b177-a876f412360f",
        "avatar": "link.avatar.com",
        "name": "Doggie"
      }
    ]''';
    when(() => mockRest.get('/v1/profiles/user/$userId', headers: {}))
        .thenAnswer(
      (_) => Future<Either<Failure, String>>.value(const Right(results)),
    );
    var value = await dataSource.getProfiles(userId);
    assert(value.isRight());
    var val = value.getOrElse(() => []);
    for (var element in val) {
      dev.log(element.id!);
    }
    assert(val.length == 3);
  });
}
