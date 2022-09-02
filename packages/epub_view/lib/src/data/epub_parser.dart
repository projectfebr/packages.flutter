import 'package:collection/collection.dart';
import 'package:epub_view/src/data/epub_cfi_reader.dart';
import 'package:html/dom.dart' as dom;

import 'models/paragraph.dart';

export 'package:epubx/epubx.dart' hide Image;

List<EpubChapter> parseChapters(EpubBook epubBook) =>
    epubBook.Chapters!.fold<List<EpubChapter>>(
      [],
      (acc, next) {
        acc.add(next);
        next.SubChapters!.forEach(acc.add);
        return acc;
      },
    );

List<dom.Element> convertDocumentToElements(dom.Document document) =>
    document.getElementsByTagName('body').first.children;

List<dom.Element> _removeAllDiv(List<dom.Element> elements) {
  final List<dom.Element> result = [];

  for (final node in elements) {
    if (node.localName == 'div' && node.children.length > 1) {
      result.addAll(_removeAllDiv(node.children));
    } else {
      result.add(node);
    }
  }
  return result;
}

ParseParagraphsResult parseParagraphs(
  List<EpubChapter> chapters,
  EpubContent? content,
) {
  final List<int> chapterIndexes = [];
  List<dom.Element> elmList = [];
  var lastIndex = 0;

  final document = EpubCfiReader().chapterDocument(chapters.first);
  if (document != null) {
    final result = convertDocumentToElements(document);
    elmList = _removeAllDiv(result);
    lastIndex = elmList.length;
  }

  for (var chapter in chapters) {
    int index;
    if (chapter.Anchor == null) {
      index = 0;
    } else {
      index = elmList.indexWhere(
        (elm) => elm.outerHtml.contains(
          'id="${chapter.Anchor}"',
        ),
      );
    }
    chapterIndexes.add(index);
  }

  final paragraphs = elmList.mapIndexed<Paragraph>((elmIndex, elm) {
    return Paragraph(
      elm,
      chapterIndexes.lastIndexWhere((chapterIndex) => chapterIndex <= elmIndex),
    );
  }).toList();

  return ParseParagraphsResult(paragraphs, chapterIndexes, lastIndex);
}

class ParseParagraphsResult {
  ParseParagraphsResult(
      this.flatParagraphs, this.chapterIndexes, this.lastIndex);

  final List<Paragraph> flatParagraphs;
  final List<int> chapterIndexes;
  final int lastIndex;
}
