/// CREATING USER TABLE
class User {
  /// TABLE CONTENT
  final int? id;
  final String username;
  final String email;
  final String password;

  User({
  this.id,
  required this.username, 
  required this.email, 
  required this.password});

  /// FROM MAP CONSTRUCTOR
  User.fromMap(Map<String, dynamic> data)
    : id = data["id"],
      username = data["username"],
      email = data["email"],
      password = data["password"];

  /// CONVERTE DATA TO MAP 
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "password": password
    };
  }
}
