import '../../components/list_loader.dart';

class Author implements ListLoaderElem<int> {
  @override final int id;
  final String name;
  final String profession;
  final bool selected;

  const Author({
    required this.id,
    required this.name,
    required this.profession,
    this.selected = false
  });
}