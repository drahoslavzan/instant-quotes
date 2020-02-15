import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

class AdDisplay {
  void load() {
    if (_ad != null || _context != null) return;
    _loading = true;
    _ad = _createAd();
  }

  void show(BuildContext context, Function action) async {
    if (++_count % 2 == 0) {
      await action();
      return;
    }

    _context = context;
    _action = action;

    if (!_loading && _ad == null) {
      await _loadFailed();
      return;
    }

    await _ad.show();
  }

  void _cancel() {
    _ad?.dispose();
    _ad = null;
    _loading = false;
  }

  Future<void> _showFallbackImage() async {
    if (_context == null) return;
    await Navigator.of(_context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (context, _, __) => _FallbackImage()
    ));
  }

  Future<void> _doAction() async {
    if (_action == null) return;
    await _action();
    _action = null;
    _context = null;
    _cancel();
    load();
  }

  Future<void> _loadFailed() async {
    _cancel();
    if (_action == null) {
      await Future.delayed(Duration(minutes: 1));
      load();
      return;
    }
    await _showFallbackImage();
    await _doAction();
  }

  InterstitialAd _createAd() {
    return InterstitialAd(
      adUnitId: kReleaseMode ? _intAdUnitId : InterstitialAd.testAdUnitId,
      targetingInfo: _targetingInfo,
      listener: _onAddEvent
    )..load();
  }

  void _onAddEvent(MobileAdEvent event) async {
    switch(event) {
      case MobileAdEvent.loaded:
        _loading = false;
        break;
      case MobileAdEvent.failedToLoad:
        await _loadFailed();
        break;
      case MobileAdEvent.closed:
        await _doAction();
        break;
      default:
        break;
    }
  }

  MobileAd _ad;
  Function _action;
  BuildContext _context;
  bool _loading = false;
  int _count = 0;
  static const _intAdUnitId = 'ca-app-pub-9328030072300045/4854298639';
  static const _testDevice = '2A54B77CB09A19B5B0C7EC5DB89400E3';
  static const MobileAdTargetingInfo _targetingInfo = MobileAdTargetingInfo(
    testDevices: _testDevice != null ? <String>[_testDevice] : null,
    nonPersonalizedAds: true,
    keywords: <String>['Quote', 'Quotes', 'Quotation', 'Quotations', 'Famous people'],
  );
}

class _FallbackImage extends StatefulWidget {
  @override
  _FallbackImageState createState() => _FallbackImageState();
}

class _FallbackImageState extends State<_FallbackImage> with TickerProviderStateMixin {
  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: _seconds),
    )
    ..forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          child: Center(
            child: _Countdown(
              animation: StepTween(
                begin: _seconds + 1,
                end: 1,
              ).animate(_controller)..addStatusListener((status) {
                if (status != AnimationStatus.completed) return;
                Navigator.of(context).pop();
              }),
            )
          )
        )
      )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  AnimationController _controller;
  static const int _seconds = 5;
}

class _Countdown extends AnimatedWidget {
  _Countdown({Key key, this.animation}) : super(key: key, listenable: animation);

  @override
  build(BuildContext context){
    return new Text(
      animation.value.toString(),
      style: new TextStyle(fontSize: 150.0),
    );
  }

  final Animation<int> animation;
}