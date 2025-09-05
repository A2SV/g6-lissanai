import 'package:lissan_ai/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    super.id,
    super.name,
    super.email,
    super.password,
    super.imagePath,
    super.skills,
    super.experiences,
    super.careerGoals,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'], // will be null in response (that’s fine)
      imagePath: json['imagePath'], // null
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      experiences:
          (json['experiences'] as List<dynamic>?)?.cast<String>() ?? [],
      careerGoals:
          (json['careerGoals'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'imagePath': imagePath,
      'skills': skills,
      'experiences': experiences,
      'careerGoals': careerGoals,
    };
  }
}
