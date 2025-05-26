import 'package:flutter/foundation.dart';

/// Modelo de usuário para autenticação e dados do perfil
@immutable
class User {
  final String id;
  final String name;
  final String email;
  final String? partnerCode;
  final String? partnerId;
  final String? partnerName;
  final bool isEmailVerified;
  final DateTime? emailVerifiedAt;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.partnerCode,
    this.partnerId,
    this.partnerName,
    this.isEmailVerified = false,
    this.emailVerifiedAt,
    this.lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// Cria um User a partir de um Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      partnerCode: json['partnerCode'] as String?,
      partnerId: json['partnerId'] as String?,
      partnerName: json['partnerName'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      emailVerifiedAt: json['emailVerifiedAt'] != null 
          ? DateTime.parse(json['emailVerifiedAt'] as String) 
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : DateTime.now(),
    );
  }

  /// Converte o User para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'partnerCode': partnerCode,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  /// Cria uma cópia do User com campos atualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
    DateTime? lastLoginAt,
    String? partnerCode,
    String? partnerId,
    String? partnerName,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      partnerCode: partnerCode ?? this.partnerCode,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.partnerCode == partnerCode &&
      other.partnerId == partnerId &&
      other.partnerName == partnerName &&
      other.isEmailVerified == isEmailVerified &&
      other.emailVerifiedAt == emailVerifiedAt &&
      other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      partnerCode.hashCode ^
      partnerId.hashCode ^
      partnerName.hashCode ^
      isEmailVerified.hashCode ^
      emailVerifiedAt.hashCode ^
      lastLoginAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, isEmailVerified: $isEmailVerified, partnerCode: $partnerCode, partnerId: $partnerId, partnerName: $partnerName, lastLoginAt: $lastLoginAt, emailVerifiedAt: $emailVerifiedAt)';
  }
}
