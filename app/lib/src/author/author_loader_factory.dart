import '../components/list_loader.dart';
import '../components/infinite_list_loader.dart';
import '../database/author_repository.dart';
import '../database/model/author.dart';

typedef AuthorListLoader = ListLoader<Author, int>;

abstract class AuthorLoaderFactory {
  AuthorListLoader search({String? pattern, String? startsWith});
}

class AuthorLoaderFactoryImpl implements AuthorLoaderFactory {
  final AuthorRepository repo;

  const AuthorLoaderFactoryImpl(this.repo);

  @override
  AuthorListLoader search({
    String? pattern,
    String? startsWith,
  }) {
    return InfiniteListLoader<Author, int>(
      fetchCount: 50,
      bufferSize: 1000000, // NOTE: infinity like
      fetch: (count, { var skip = 0 }) => repo.search(
        startsWith: startsWith,
        pattern: pattern,
        count: count,
        skip: skip,
      )
    );
  }
}