class ApiResponse {
  final dynamic data;
  ApiResponse(this.data);
  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(json);
}