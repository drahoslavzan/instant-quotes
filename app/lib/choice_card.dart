import 'package:flutter/material.dart';

class Choice {
  const Choice({this.title, this.icon, this.page});

  final String title;
  final Widget icon;
  final Widget page;
}

class ChoiceCard extends StatelessWidget {
  final Choice choice;

  const ChoiceCard({Key key, this.choice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return choice.page;
  }
}