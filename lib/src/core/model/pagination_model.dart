class PaginationModel<T> {
  final List<T> items;
  final bool isReachMax;
  final int pageSize;

  PaginationModel({
    required this.items,
    required this.isReachMax,
    required this.pageSize,
  });
}
