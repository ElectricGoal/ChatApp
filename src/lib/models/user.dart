import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserModel with _$UserModel {
  factory UserModel({ String? uid, String? firstName, String? lastName, String? email, String? avatarUrl }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

// class UserModel {
//   final String? uid;
//   final String? firstName;
//   final String? lastName;
//   final String? email;
//   final String? avatarUrl;

//   UserModel({
//     required this.uid,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.avatarUrl,
//   });

//   factory UserModel.fromMap(map) {
//     return UserModel(
//       uid: map['uid'] ?? '',
//       firstName: map['firstName'] ?? '',
//       lastName: map['lastName'] ?? '',
//       email: map['email'] ?? '',
//       avatarUrl: map['avatarUrl'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'firstName': firstName,
//       'lastName': lastName,
//       'avatarUrl': avatarUrl,
//     };
//   }
// }
