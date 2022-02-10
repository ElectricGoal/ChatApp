class UserModel {
  String? uid;
  String? firstName;
  String? lastName;
  String? email;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
