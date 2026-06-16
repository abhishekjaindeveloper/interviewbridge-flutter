import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String email, String password);
  Future<RegisterResponseModel> register(
    String name,
    String email,
    String phoneNumber,
    String password,
    bool termsAccepted,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: LoginRequestModel(email: email, password: password).toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return LoginResponseModel.fromJson(data);
  }

  @override
  Future<RegisterResponseModel> register(
    String name,
    String email,
    String phoneNumber,
    String password,
    bool termsAccepted,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      data: RegisterRequestModel(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        termsAccepted: termsAccepted,
      ).toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return RegisterResponseModel.fromJson(data);
  }
}
