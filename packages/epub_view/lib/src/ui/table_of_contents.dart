import 'package:epub_view/src/data/models/chapter.dart';
import 'package:epub_view/src/ui/epub_view.dart';
import 'package:flutter/material.dart';

class EpubViewTableOfContents extends StatelessWidget {
  const EpubViewTableOfContents({
    required this.controller,
    this.padding,
    this.itemBuilder,
    this.loader,
    this.currentChapterKey,
    Key? key,
  }) : super(key: key);

  final EdgeInsetsGeometry? padding;
  final EpubController controller;
  final GlobalKey? currentChapterKey;

  final Widget Function(
    BuildContext context,
    int index,
    EpubViewChapter chapter,
    int itemCount,
  )? itemBuilder;
  final Widget? loader;

  void _scrollByContext(BuildContext? context) {
    if (context != null) {
      Scrollable.ensureVisible(context,
          alignment: 0.5, duration: const Duration(milliseconds: 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollByContext(currentChapterKey?.currentContext);
    });
    return ValueListenableBuilder<List<EpubViewChapter>>(
      valueListenable: controller.tableOfContentsListenable,
      builder: (_, data, child) {
        Widget content;

        if (data.isNotEmpty) {
          content = ListView.builder(
            padding: padding,
            key: Key('$runtimeType.content'),
            itemBuilder: (context, index) =>
                itemBuilder?.call(context, index, data[index], data.length) ??
                ListTile(
                  title: Text(data[index].title!.trim()),
                  onTap: () =>
                      controller.scrollTo(index: data[index].startIndex),
                ),
            itemCount: data.length,
          );
        } else {
          content = KeyedSubtree(
            key: Key('$runtimeType.loader'),
            child: loader ?? const Center(child: CircularProgressIndicator()),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              FadeTransition(opacity: animation, child: child),
          child: content,
        );
      },
    );
  }
}
