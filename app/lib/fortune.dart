import 'package:flutter/material.dart';
import 'package:myapp/database/quote_repository.dart';
import 'package:myapp/database/model/quote.dart';
import 'package:swipedetector/swipedetector.dart';
import 'quote_card.dart';

class Fortune extends StatefulWidget {
  Fortune(this.repo);

  @override
  _FortuneState createState() => _FortuneState();

  final QuoteRepository repo;
}

typedef void _OnShare();

class _Actions extends StatelessWidget {
  _Actions({@required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20.0),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.repo.name),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SwipeDetector(
                onSwipeLeft: _onSwipeLeft,
                onSwipeRight: _onSwipeRight,
                child: SlideTransition(
                  position: _animation == null || _animation.isCompleted ? _defaultAnimation : _animation,
                  child: Container(
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

                        print('next = ${quote.id}');

                        return QuoteCard(quote);
                      }
                    )
                  )
                )
              )
            ),
            _Actions(onShare: _onShare)
          ]
        )
      )
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