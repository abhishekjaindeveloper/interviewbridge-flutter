import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/admin_model.dart';
import '../models/admin_user_statistics_model.dart';
import '../models/paginated_users_model.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminModel>> getPendingUsers();
  Future<void> approveUser(String id);
  Future<void> rejectUser(String id, String reason);
  Future<AdminUserStatisticsModel> getUserStatistics();
  Future<PaginatedUsersModel> getUsers(int page, int size, {String? search, String? approvalStatus, bool? isActive});
  Future<void> activateUser(String id);
  Future<void> deactivateUser(String id);
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
  Future<void> rejectUser(String id, String reason) async {
    await _apiClient.put(
      '${ApiConstants.adminRejectUser}/$id/reject',
      data: {'reason': reason},
    );
  }

  @override
  Future<AdminUserStatisticsModel> getUserStatistics() async {
    final response = await _apiClient.get(ApiConstants.adminUsersStatistics);
    final data = response.data['data'] as Map<String, dynamic>;
    return AdminUserStatisticsModel.fromJson(data);
  }

  @override
  Future<PaginatedUsersModel> getUsers(
    int page,
    int size, {
    String? search,
    String? approvalStatus,
    bool? isActive,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'size': size,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (approvalStatus != null && approvalStatus.isNotEmpty) {
      queryParameters['approvalStatus'] = approvalStatus;
    }
    if (isActive != null) {
      queryParameters['isActive'] = isActive;
    }

    final response = await _apiClient.get(
      ApiConstants.adminUsers,
      queryParameters: queryParameters,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return PaginatedUsersModel.fromJson(data);
  }

  @override
  Future<void> activateUser(String id) async {
    await _apiClient.patch('${ApiConstants.adminUsers}/$id/activate');
  }

  @override
  Future<void> deactivateUser(String id) async {
    await _apiClient.patch('${ApiConstants.adminUsers}/$id/deactivate');
  }
}
