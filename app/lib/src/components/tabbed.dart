import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

typedef TabbedTabs = List<BottomNavigationBarItem> Function(BuildContext);

class Tabbed extends StatefulWidget {
  final List<Widget> children;
  final List<String> titles;
  final TabbedTabs tabs;

  const Tabbed({
    Key? key,
    required this.titles,
    required this.children,
    required this.tabs,
  })
    : super(key: key);

  @override
  State<Tabbed> createState() => _TabbedState();
}

class _TabbedState extends State<Tabbed> {
  @override
  void initState() {
    super.initState();
    _title = widget.titles[0];
    _tabController = PlatformTabController();
    _tabController.addListener(() {
      _title = widget.titles[_tabController.index(context)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlatformTabScaffold(
      iosContentPadding: true,
      tabController: _tabController,
      appBarBuilder: (_, index) => PlatformAppBar(
        title: Text(_title),
        trailingActions: <Widget>[
          PlatformIconButton(
            padding: EdgeInsets.zero,
            icon: Icon(context.platformIcons.share),
            onPressed: () {},
          ),
        ],
        cupertino: (_, __) => CupertinoNavigationBarData(
          title: Text(_title),
        ),
      ),
      bodyBuilder: (context, index) => IndexedStack(
        index: index,
        children: widget.children,
      ),
      items: widget.tabs(context),
    );
  }

  late String _title;
  late PlatformTabController _tabController;
}
