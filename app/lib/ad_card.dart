import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'display_card.dart';

class AdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DisplayCard(
      child: NativeAdmobBannerView(
        adUnitID: adUnitID,
        style: BannerStyle.dark, // enum dark or light
        showMedia: true, // whether to show media view or not
        contentPadding: EdgeInsets.all(10), // content padding
        onCreate: (controller) {
          controller.setStyle(BannerStyle.light); // Dynamic update style
        },
      )
    );
  }

  // TODO: replace with real native ID
  static const adUnitID = 'ca-app-pub-3940256099942544/2247696110';
}