class SignInRequest {
  final String email;
  final String password;
  
  SignInRequest({required this.email, required this.password});
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class SignInResponse {
  final String id;
  final String email;
  final String name;
  final String token;
  
  SignInResponse({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });
  
  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      token: json['token'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String token;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  });

  factory User.fromSignInResponse(SignInResponse response) {
    return User(
      id: response.id,
      email: response.email,
      name: response.name,
      token: response.token,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'token': token,
  };
}