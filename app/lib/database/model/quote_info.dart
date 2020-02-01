
class QuoteInfo {
  int id;
  String name;
  int favorites;

  QuoteInfo({this.id, this.name, this.favorites});

  factory QuoteInfo.fromMap(Map<String, dynamic> map) => QuoteInfo(
        id: map['id'],
        name: map['name'],
        favorites: map['favorites'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };
}