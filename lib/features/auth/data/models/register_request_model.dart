class RegisterRequestModel {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final bool termsAccepted;

  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.termsAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'termsAccepted': termsAccepted,
    };
  }
}
