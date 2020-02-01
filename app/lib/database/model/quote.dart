
class Quote {
  int id;
  int infoId;
  String quote;
  String author;
  bool seen;
  bool favorite;

  Quote({this.id, this.infoId, this.quote, this.author, this.seen, this.favorite});

  factory Quote.fromMap(Map<String, dynamic> map) => Quote(
        id: map['id'],
        infoId: map['info_id'],
        quote: map['quote'],
        author: map['author'],
        seen: map['seen'] == 1,
        favorite: map['favorite'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'info_id': infoId,
        'quote': quote,
        'author': author,
        'seen': seen,
        'favorite': favorite,
      };
}