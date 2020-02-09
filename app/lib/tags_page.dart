import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'database/tag_repository.dart';
import 'database/quote_repository.dart';
import 'database/model/tag.dart';
import 'quote_provider.dart';
import 'quotes_view.dart';
import 'searchable.dart';

class TagsPage extends StatefulWidget {
  const TagsPage();

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  @override
  void didChangeDependencies() {
    _init();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _tagsPromise?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Searchable(
      title: _title ?? _randomTitle,
      onSearch: _search,
      searchValue: _searchValue,
      records: _records,
      child: _fetching
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              children: _tags.map((t) => ActionChip(
                label: Text(t.name),
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => 
                      QuotesView(quoteProvider: QuoteProvider.fromTag(quoteRepository: Provider.of<QuoteRepository>(context), tag: t))
                    ),
                  );
                },
              )).toList()
            )
          )
    );
  }

  void _init() {
    if (_tagRepository != null) return;
    _tagRepository = Provider.of<TagRepository>(context);
    _fetchCount();
    _search(null);
  }

  void _fetchCount() async {
    if (_tagRepository == null) return;

    final records = await _tagRepository.records;

    if (!mounted) return;
    setState(() {
      _records = records;
    });
  }

  void _search(value) async {
    if (_tagRepository == null) return;

    _tagsPromise?.cancel();

    final tagsPromise = CancelableOperation.fromFuture(value != null
      ? _tagRepository.search(pattern: value, count: _count)
      : _tagRepository.random(count: _count));

    setState(() {
      _fetching = true;
      _tagsPromise = tagsPromise;
      _searchValue = value;
      _title = value?.isNotEmpty ?? false ? 'Result' : _randomTitle;
      _tags.clear();
    });

    final tags = await tagsPromise.value;

    setState(() {
      _fetching = false;
      _tags.addAll(tags);
    });
  }

  String _title;
  String _searchValue;
  TagRepository _tagRepository;
  CancelableOperation<List<Tag>> _tagsPromise;
  int _records;
  var _fetching = false;
  final _tags = List<Tag>();
  final _count = 25;
  static const _randomTitle = 'Random Tags';
}
