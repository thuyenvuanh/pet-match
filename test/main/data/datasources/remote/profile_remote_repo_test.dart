// import 'dart:developer' as dev;
// import 'package:dartz/dartz.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:pet_match/src/data/datasources/remote/profile_remote_datasource.dart';
// import 'package:pet_match/src/domain/models/profile_model.dart';
// import 'package:pet_match/src/utils/error/failure.dart';
// import 'package:pet_match/src/utils/rest_helper.dart';
// import 'package:mocktail/mocktail.dart';

// class MockRestClient extends Mock implements RestClient {}

// void main() {
//   test('fetchActiveProfileListAndReturnOK', () async {
//     final mockRest = MockRestClient();
//     ProfileRemoteDataSource dataSource = ProfileRemoteDataSource(mockRest);
//     const userId = "1111";
//     const results = '''[
//       {
//         "id": "cea68a9d-f7c7-4cd3-b567-0780e98ff292",
//         "avatar": "link.avatar.com",
//         "name": "Doggie"
//       },
//       {
//         "id": "2e80690b-d6d1-44eb-a6f5-38ec0c0b1349",
//         "avatar": "link.avatar.com",
//         "name": "Doggie"
//       },
//       {
//         "id": "c27992d6-76df-48fe-b177-a876f412360f",
//         "avatar": "link.avatar.com",
//         "name": "Doggie"
//       }
//     ]''';
//     when(() => mockRest.get('/v1/profiles/user/$userId', headers: {}))
//         .thenAnswer(
//       (_) => Future<Either<Failure, String>>.value(const Right(results)),
//     );
//     var value = await dataSource.getProfiles(userId);
//     assert(value.isRight());
//     var val = value.getOrElse(() => []);
//     for (var element in val) {
//       dev.log(element.id!);
//     }
//     assert(val.length == 3);
//   });

//   test('fetch profile detail information', () async {
//     const String resData = '''
//       {
//           "name": "Lola",
//           "breed": {
//               "id": "b2a0db24-f577-11ed-a05b-0242ac120003",
//               "name": "Mèo ta",
//               "species": {
//                   "id": "d5652b1a-f36f-11ed-a05b-0242ac120003",
//                   "name": "Mèo"
//               }
//           },
//           "height": 68.0,
//           "avatar": "https://images.pexels.com/photos/3643714/pexels-photo-3643714.jpeg?auto=compress&cs=tinysrgb&w=1600",
//           "weight": 3.0,
//           "gender": "FEMALE",
//           "description": "Short description",
//           "birthday": "11/06/2022 17:00:00",
//           "gallery": [],
//           "interests": [],
//           "id": "21b351b8-f578-11ed-a05b-0242ac120003"
//       }
//       ''';
//     final mockRest = MockRestClient();
//     ProfileRemoteDataSource dataSource = ProfileRemoteDataSource(mockRest);
//     when(() => mockRest.get(
//             '/pet-match/v1/profiles/21b351b8-f578-11ed-a05b-0242ac120003',
//             headers: any(named: 'headers'),
//             queryParams: any(named: 'queryParams')))
//         .thenAnswer(
//             (_) => Future<Either<Failure, String>>.value(const Right(resData)));
//     var res =
//         await dataSource.getProfileById('21b351b8-f578-11ed-a05b-0242ac120003');
//     assert(res.isRight());
//     var profile = res.getOrElse(() => Profile());
//     assert(profile!.id != null &&
//         profile.id == '21b351b8-f578-11ed-a05b-0242ac120003');
//   });
// }
