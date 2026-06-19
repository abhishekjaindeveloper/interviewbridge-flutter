import '../../domain/entities/paginated_users_entity.dart';
import 'admin_model.dart';

class PaginatedUsersModel extends PaginatedUsersEntity {
  const PaginatedUsersModel({
    required super.content,
    required super.pageNumber,
    required super.pageSize,
    required super.totalElements,
    required super.totalPages,
    required super.last,
  });

  factory PaginatedUsersModel.fromJson(Map<String, dynamic> json) {
    final list = json['content'] as List<dynamic>? ?? [];
    final content = list.map((item) => AdminModel.fromJson(item as Map<String, dynamic>)).toList();
    return PaginatedUsersModel(
      content: content,
      pageNumber: json['number'] as int? ?? 0,
      pageSize: json['size'] as int? ?? 10,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? true,
    );
  }
}
