import '../../components/list_loader.dart';

class Author implements ListLoaderElem<int> {
  final int id;
  final String name;
  final String profession;

  const Author({required this.id, required this.name, required this.profession});
}