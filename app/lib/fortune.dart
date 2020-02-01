import 'package:flutter/material.dart';
import 'package:myapp/database/quote_repository.dart';
import 'package:myapp/database/model/quote.dart';
import 'package:swipedetector/swipedetector.dart';

class Fortune extends StatefulWidget {
  Fortune(this.repo);

  @override
  _FortuneState createState() => _FortuneState();

  final QuoteRepository repo;
}

class _Quote extends StatelessWidget {
  _Quote(this._quote);

  @override
  Widget build(BuildContext context) {
    return Text('„$_quote”',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 33
      )
    );
  }

  final String _quote;
}

class _Author extends StatelessWidget {
  _Author(this._author);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Text('-- $_author',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 23
        )
      )
    );
  }

  final String _author;
}

typedef void _OnShare();

class _Actions extends StatelessWidget {
  _Actions({@required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: onShare
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: onShare
          ),
        ],
      )
    );
  }

  final _OnShare onShare;
}

class _FortuneState extends State<Fortune> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    _quote = widget.repo.nextUnseen;
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _defaultAnimation = _createAnimation(0);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SwipeDetector(
      child: SlideTransition(
        position: _animation == null || _animation.isCompleted ? _defaultAnimation : _animation,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.repo.name),
          ),
          body: Container(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<Quote>(
              future: _quote,
              builder: (BuildContext context, AsyncSnapshot<Quote> snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  // TODO: busy indicator
                  return Text('working');
                }

                final quote = snapshot.data;
                if (quote == null) {
                  // TODO: busy indicator
                  return Text('predefined text - last shit there');
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _Quote(snapshot.data.quote),
                    _Author(snapshot.data.author),
                    _Actions(onShare: _onShare),
                  ]
                );
              }
            )
          )
        ),
      ),
      onSwipeLeft: _onSwipeLeft,
      onSwipeRight: _onSwipeRight,
    );
  }

  @override
  void dispose() async {
    final save = widget.repo.save();
    _controller.dispose();
    super.dispose();
    await save;
  }

  void _onShare() {
    print('share');
    _quote = widget.repo.nextUnseen;
    _animation = _createAnimation(-1);
    _controller.reset();
    _controller.forward();
  }

  void _onSwipeLeft() {
    print('left');
    _animation = _createAnimation(-1);
    _controller.reset();
    _controller.forward();
  }

  void _onSwipeRight() {
    print('right');
    _animation = _createAnimation(1);
    _controller.reset();
    _controller.forward();
  }

  Animation<Offset> _createAnimation(double dx) {
    return Tween<Offset>(
      begin: Offset.zero,
      end: Offset(dx, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ))..addListener(() {
      setState(() {}); 
    });
  }

  AnimationController _controller;
  Animation<Offset> _animation;
  Animation<Offset> _defaultAnimation;
  Future<Quote> _quote;
}