class LoginModel {
  final int? id;
  final String? title;
  final String? body;
  final int? userId;

  LoginModel({this.id, this.title, this.body, this.userId});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }
}