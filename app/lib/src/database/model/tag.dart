
class Tag {
  final int id;
  final String name;
  final bool selected;

  const Tag({required this.id, required this.name, this.selected = false});

  Tag.from(Tag tag):
    id = tag.id,
    name = tag.name,
    selected = false;
}