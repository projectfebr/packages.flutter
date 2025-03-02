class EpubViewChapter {
  EpubViewChapter(this.title, this.startIndex);

  final String? title;
  final int startIndex;

  String get type => this is EpubViewSubChapter ? 'subchapter' : 'chapter';

  @override
  String toString() => '$type: {title: $title, startIndex: $startIndex}';
}

class EpubViewSubChapter extends EpubViewChapter {
  EpubViewSubChapter(String? title, int startIndex,
      {required this.level, required this.parentTitle, required this.parentStartIndex})
      : super(title, startIndex);

  final int level;
  final String? parentTitle;
  final int parentStartIndex;
}
