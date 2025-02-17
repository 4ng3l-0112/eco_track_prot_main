import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ResidentsRecord extends FirestoreRecord {
  ResidentsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  void _initializeFields() {
    _name = snapshotData['name'] as String?;
    _email = snapshotData['email'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('residents');

  static Stream<ResidentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ResidentsRecord.fromSnapshot(s));

  static Future<ResidentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ResidentsRecord.fromSnapshot(s));

  static ResidentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ResidentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ResidentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ResidentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ResidentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ResidentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createResidentsRecordData({
  String? name,
  String? email,
  String? phoneNumber,
  String? uid,
  DateTime? createdTime,
  String? displayName,
  String? photoUrl,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'uid': uid,
      'created_time': createdTime,
      'display_name': displayName,
      'photo_url': photoUrl,
    }.withoutNulls,
  );

  return firestoreData;
}

class ResidentsRecordDocumentEquality implements Equality<ResidentsRecord> {
  const ResidentsRecordDocumentEquality();

  @override
  bool equals(ResidentsRecord? e1, ResidentsRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.email == e2?.email &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl;
  }

  @override
  int hash(ResidentsRecord? e) => const ListEquality().hash([
        e?.name,
        e?.email,
        e?.phoneNumber,
        e?.uid,
        e?.createdTime,
        e?.displayName,
        e?.photoUrl
      ]);

  @override
  bool isValidKey(Object? o) => o is ResidentsRecord;
}
