import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'database/tag_repository.dart';
import 'database/model/tag.dart';

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
  Widget build(BuildContext context) {
    return Searchable(
      title: _title ?? _randomTitle,
      onSearch: _search,
      searching: _searching,
      searchValue: _searchValue,
      records: _records,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          children: <Widget>[
            ..._tags.map((t) => ActionChip(
              label: Text(t.name),
              onPressed: () {
              },
            ))
          ]
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

    final count = await _tagRepository.count;

    if (!mounted) return;
    setState(() {
      _records = count;
    });
  }

  void _search(value) async {
    if (_tagRepository == null) return;

    setState(() {
      _searchValue = value;
      _searching = true;
      _title = value?.isNotEmpty ?? false ? 'Result' : _randomTitle;
      _tags.clear();
    });

    final tags = value != null
      ? await _tagRepository.search(pattern: value)
      : await _tagRepository.random();

    if (!mounted) return;
    setState(() {
      _searching = false;
      _tags.addAll(tags);
    });
  }

  String _title;
  String _searchValue;
  TagRepository _tagRepository;
  int _records;
  var _searching = true;
  final _tags = List<Tag>();
  static const _randomTitle = 'Random Tags';
}

// TODO: text field loosing focus
class Searchable extends StatelessWidget {
  final String title;
  final Widget child;
  final Function onSearch;
  final bool searching;
  final String searchValue;
  final int records;

  Searchable({@required this.title, @required this.child, @required this.onSearch, @required this.searching, @required this.searchValue, this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            enabled: !searching,
            onChanged: onSearch,
            initialValue: searchValue,
            decoration: InputDecoration(
              labelText: 'Search',
              hintText: records == null ? null : '$records records',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))
              ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: searching ? Center(child: CircularProgressIndicator()) : child
        )
      ]
    );
  }
}