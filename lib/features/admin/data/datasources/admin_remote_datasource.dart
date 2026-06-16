import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/admin_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminModel>> getPendingUsers();
  Future<void> approveUser(String id);
  Future<void> rejectUser(String id);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final ApiClient _apiClient;

  AdminRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<AdminModel>> getPendingUsers() async {
    final response = await _apiClient.get(ApiConstants.adminPendingUsers);
    final dataList = response.data['data'] as List<dynamic>? ?? [];
    return dataList
        .map((json) => AdminModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> approveUser(String id) async {
    await _apiClient.put('${ApiConstants.adminApproveUser}/$id/approve');
  }

  @override
  Future<void> rejectUser(String id) async {
    await _apiClient.put('${ApiConstants.adminRejectUser}/$id/reject');
  }
}
