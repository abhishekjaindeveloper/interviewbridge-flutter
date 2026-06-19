import 'package:equatable/equatable.dart';
import '../entities/admin_entity.dart';

class PaginatedUsersEntity extends Equatable {
  final List<AdminEntity> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const PaginatedUsersEntity({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  @override
  List<Object?> get props => [content, pageNumber, pageSize, totalElements, totalPages, last];
}
