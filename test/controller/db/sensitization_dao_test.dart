// import 'package:flutter_test/flutter_test.dart';
// import 'package:human_rights_monitor/controller/db/db.dart';
// import 'package:human_rights_monitor/controller/db/daos/sensitization_dao.dart';
// import 'package:human_rights_monitor/controller/models/household_models.dart';

// void main() {
//   late LocalDBHelper dbHelper;
//   late SensitizationDao sensitizationDao;

//   setUp(() async {
//     // Initialize in-memory database for testing
//     dbHelper = await LocalDBHelper.initInMemory();
//     sensitizationDao = SensitizationDao(dbHelper: dbHelper);
//   });

//   tearDown(() async {
//     await dbHelper.close();
//   });

//   group('SensitizationDao Tests', () {
//     test('should save sensitization with valid data', () async {
//       // Arrange
//       final sensitization = SensitizationData(
//         coverPageId: 1,
//         farmIdentificationId: 1,
//         isAcknowledged: true,
//       );

//       // Act
//       final id = await sensitizationDao.insert(sensitization, 1);

//       // Assert
//       expect(id, isNotNull);
//       final saved = await sensitizationDao.getById(id);
//       expect(saved, isNotNull);
//       expect(saved?.farmIdentificationId, 1);
//     });

//     test('should throw when saving with null farmIdentificationId', () async {
//       // Arrange
//       final sensitization = SensitizationData(
//         coverPageId: 1,
//         farmIdentificationId: null,
//         isAcknowledged: true,
//       );

//       // Act & Assert
//       expect(
//         () => sensitizationDao.insert(sensitization, 1),
//         throwsA(isA<ArgumentError>()),
//       );
//     });

//     test('should update sensitization with new farmIdentificationId', () async {
//       // Arrange
//       final sensitization = SensitizationData(
//         coverPageId: 1,
//         farmIdentificationId: 1,
//         isAcknowledged: true,
//       );
//       final id = await sensitizationDao.insert(sensitization, 1);

//       // Act
//       final updated = sensitization.copyWith(farmIdentificationId: 2);
//       await sensitizationDao.update(updated, id);

//       // Assert
//       final saved = await sensitizationDao.getById(id);
//       expect(saved?.farmIdentificationId, 2);
//     });
//   });
// }
