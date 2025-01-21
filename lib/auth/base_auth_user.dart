abstract class BaseAuthUser {
  BaseAuthUser(this.uid);
  final String uid;
  
  bool get emailVerified;
  bool get loggedIn;
  String? get email;
  String? get displayName;
  String? get photoUrl;
  bool get isAnonymous;
  
  Map<String, dynamic> get authUserInfo;
  
  Future? delete();
  Future? sendEmailVerification();
  Future<bool> updateEmail(String email);
  Future<bool> updatePassword(String password);
} 