import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

typedef ItemWidgetBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

// ignore: must_be_immutable
class GenericPageList<T> extends StatelessWidget {
  final PagingController<int, T> pagingController;

  Widget Function(BuildContext, T, int) itemBuilder;

  final EdgeInsetsGeometry padding;

  final Widget? noItemsFoundIndicator;

  final bool applyAnimation;

  GenericPageList({
    super.key,
    required this.pagingController,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.noItemsFoundIndicator,
    this.applyAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final pagedListView = PagingListener(
      controller: pagingController,

      // ignore: unnecessary_constructor_name
      builder: (context, state, fetchNextPage) => PagedListView<int, T>.new(
        state: state,
        padding: padding,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<T>(
          itemBuilder: itemBuilder,

          noItemsFoundIndicatorBuilder: noItemsFoundIndicator != null
              ? (context) => noItemsFoundIndicator!
              : null,
        ),
      ),
    );

    final Widget list = applyAnimation
        ? pagedListView.animate().fade(
            duration: const Duration(milliseconds: 500),
          )
        : pagedListView;

    return Expanded(child: list);
  }
}
