import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef LetterCallback = void Function(String letter);

class AlphabetBar extends StatefulWidget {
  final Widget child;
  final String initLetter;
  final LetterCallback onLetter;
  final Widget? lead;

  const AlphabetBar({
    required this.child,
    required this.initLetter,
    required this.onLetter,
    this.lead,
  });

  @override
  State<AlphabetBar> createState() => _AlphabetBarState();
}

class _AlphabetBarState extends State<AlphabetBar> {
  @override
  void initState() {
    _letter = widget.initLetter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.lead != null) widget.lead!,
            Expanded(
              child: GestureDetector(
                key: _key,
                behavior: HitTestBehavior.translucent,
                onHorizontalDragStart: _setLetter,
                onHorizontalDragUpdate: _setLetter,
                onPanStart: _setLetter,
                onPanUpdate: _setLetter,
                onHorizontalDragEnd: (details) => _update(),
                onPanEnd: (details) => _update(),
                onTapUp: (details) {
                  _setLetter(details);
                  _update();
                },
                child: Wrap(
                  children: _alphabet.map((a) => MetaData(
                    metaData: a,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: a == _letter
                        ? Text(a,
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w900
                            )
                          )
                        : Text(a)
                    )
                  )).toList()
                )
              ),
            )
          ]
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              widget.child,
              if (_working) Center(
                child: Container(
                  color: Colors.grey.withAlpha(128),
                  padding: const EdgeInsets.all(50),
                  child: Text(_letter,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    )
                  )
                )
              )
            ]
          )
        )
      ]
    );
  }

  void _update() {
    widget.onLetter(_letter);

    setState(() {
      _working = false;
    });
  }

  void _setLetter(details) {
    final lp = details.localPosition;
    if (lp.dx < 0 || lp.dy < 0) return;

    final obj = _key.currentContext?.findRenderObject();
    if (obj == null) return;
    final size = (obj as RenderBox).size;
    if (lp.dx >= size.width || lp.dy >= size.height) return;

    final res = BoxHitTestResult();
    if (!obj.hitTest(res, position: lp)) return;

    final meta = res.path.firstWhereOrNull((p) => p.target is RenderMetaData);
    if (meta == null) return;

    final letter = (meta.target as RenderMetaData).metaData;

    setState(() {
      _working = true;
      _letter = letter;
    });
  }

  late String _letter;
  var _working = false;
  final GlobalKey _key = GlobalKey();
  static const _alphabet = [
    'A','B','C','D','E','F','G','H','I','J',
    'K','L','M','N','O','P','Q','R','S','T',
    'U','V','W','X','Y','Z'
  ];
}
