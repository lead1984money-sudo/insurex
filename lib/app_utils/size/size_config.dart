import 'dart:math';

import 'package:flutter/cupertino.dart';

/// SizeConfigWidget is used directly under MaterialApp
/// you have to provide draft size and child in this and provide UniqueKey() always.
class SizeConfigWidget extends StatefulWidget {
  const SizeConfigWidget(
      {Key? key, required this.child, required this.draftSize})
      : super(key: key);

  final Widget child;
  final Size draftSize;

  @override
  State<SizeConfigWidget> createState() => _SizeConfigWidgetState();
}

class _SizeConfigWidgetState extends State<SizeConfigWidget> {
  @override
  void didChangeDependencies() {
    debugPrint('Dependency changed!');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SizeConfigWidget oldWidget) {
    debugPrint('Dependency changed!');
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        SizeConfig.initialize(
          context: context,
          draftWidth: widget.draftSize.width,
          draftHeight: widget.draftSize.height,
        );
        return widget.child;
      },
    );
  }
}

/// SizeConfig class is used to calculate h, w, sp & r.
/// To use this you have 2 option:
/// 1. User SizeConfigWidget
/// 2. or you can initialize SizeConfig.initialize once after MaterialApp
/// it uses Singleton feature
class SizeConfig {
  SizeConfig(
      {required double widthScale,
        required double heightScale,
        bool minTextAdapt = false})
      : _widthScale = widthScale,
        _heightScale = heightScale,
        _textScale = minTextAdapt ? min(widthScale, heightScale) : widthScale;
// FONT SIZE
  static late double smallerFontSize = 12.0;
  static late double standardFontSize = 12.0;
  static late double biggerFontSize = 0.0;
  static late double display1FontSize = 0.0;
  static late double headlineFontSize = 0.0;
  static late double titleFontSize = 0.0;
  static late double subTitleFontSize = 0.0;
  static late double body1FontSize = 0.0;
  static late double body2FontSize = 0.0;
  static late double captionFontSize = 0.0;

  // PADDING
  static late double smallerPadding;
  static late double standardPadding;
  static late double biggerPadding;

  // ELEVATION
  static double standardElevation = 0.0;

  //sizes for all screens
  static late double size_1;
  static late double size_2;
  static late double size_3;
  static late double size_4;
  static late double size_5;
  static late double size_6;
  static late double size_7;
  static late double size_8;
  static late double size_9;
  static late double size_10;
  static late double size_12;
  static late double size_12_5;
  static late double size_14;
  static late double size_15;
  static late double size_16;
  static late double size_18;
  static late double size_20;
  static late double size_21;
  static late double size_22;
  static late double size_24;
  static late double size_25;
  static late double size_26;
  static late double size_28;
  static late double size_30;
  static late double size_32;
  static late double size_34;
  static late double size_36;
  static late double size_36_5;
  static late double size_37;
  static late double size_38;
  static late double size_37_5;
  static late double size_40;
  static late double size_42;
  static late double size_43;
  static late double size_44;
  static late double size_45;
  static late double size_50;
  static late double size_52;
  static late double size_54;
  static late double size_56;
  static late double size_60;
  static late double size_65;
  static late double size_70;
  static late double size_75;
  static late double size_80;
  static late double size_85;
  static late double size_90;
  static late double size_95;
  static late double size_93;
  static late double size_100;
  static late double size_110;
  static late double size_120;
  static late double size_125;
  static late double size_130;
  static late double size_140;
  static late double size_145;
  static late double size_150;
  static late double size_160;
  static late double size_170;
  static late double size_175;
  static late double size_180;
  static late double size_200;
  static late double size_220;
  static late double size_240;
  static late double size_230;
  static late double size_250;
  static late double size_280;
  static late double size_290;
  static late double size_300;
  static late double size_340;
  static late double size_320;
  static late double size_360;
  static late double size_380;
  static late double size_370;
  static late double size_400;
  static late double size_420;
  static late double size_440;
  static late double size_460;
  static late double size_480;
  static late double size_500;
  static late double size_540;
  static late double size_560;
  static late double size_580;

  //fonts sizes for all screens
  static late double font_10;
  static late double font_12;
  static late double font_14;
  static late double font_15;
  static late double font_16;
  static late double font_13;
  static late double font_18;
  static late double font_20;
  static late double font_22;
  static late double font_24;
  static late double font_28;
  static late double font_32;
  static late double statusBarHeight;
  static late double font_36;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static MediaQueryData? _mediaQueryData;
  static late double screenWidth;
  static late double pixelRatio;
  static late double screenHeight;
  factory SizeConfig.initialize({
    required BuildContext context,
    required double draftWidth,
    required double draftHeight,
    bool minTextAdapt = false,
  }) {
    _mediaQueryData = MediaQuery.of(context);
    final double actualWidth = MediaQuery.of(context).size.width;
    final double widthScale = actualWidth / draftWidth;

    //height scale calculate
    final double actualHeight = MediaQuery.of(context).size.height;
    final double heightScale = actualHeight / draftHeight;
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;
    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;

    double? deviceWidth =
    (MediaQuery.of(context).orientation == Orientation.portrait
        ? MediaQuery.of(context).size.shortestSide
        : MediaQuery.of(context).size.longestSide);

    if (deviceWidth >= 950) {
      safeBlockHorizontal = safeBlockHorizontal * 0.4;
    } else if (deviceWidth >= 600) {
      safeBlockHorizontal = safeBlockHorizontal * 0.60;
    }
    //sizes for all screens
    size_1 = safeBlockHorizontal * 0.25;
    size_2 = safeBlockHorizontal * 0.5;
    size_3 = safeBlockHorizontal * 0.75;
    size_4 = safeBlockHorizontal * 1;
    size_5 = safeBlockHorizontal * 1.25;
    size_6 = safeBlockHorizontal * 1.5;
    size_7 = safeBlockHorizontal * 1.75;
    size_8 = safeBlockHorizontal * 2.0;
    size_9 = safeBlockHorizontal * 2.25;
    size_10 = safeBlockHorizontal * 2.5;
    size_12 = safeBlockHorizontal * 3;
    size_12_5 = safeBlockHorizontal * 3.125;
    size_14 = safeBlockHorizontal * 3.5;
    size_15 = safeBlockHorizontal * 3.75;
    size_16 = safeBlockHorizontal * 4;
    size_18 = safeBlockHorizontal * 4.5;
    size_20 = safeBlockHorizontal * 5;
    size_21 = safeBlockHorizontal * 5.125;
    size_22 = safeBlockHorizontal * 5.5;
    size_24 = safeBlockHorizontal * 6;
    size_25 = safeBlockHorizontal * 6.25;
    size_26 = safeBlockHorizontal * 6.5;
    size_28 = safeBlockHorizontal * 7;
    size_30 = safeBlockHorizontal * 7.5;
    size_32 = safeBlockHorizontal * 8;
    size_34 = safeBlockHorizontal * 8.5;
    size_36 = safeBlockHorizontal * 9;
    size_36_5 = safeBlockHorizontal * 9.125;
    size_37 = safeBlockHorizontal * 9.25;
    size_37_5 = safeBlockHorizontal * 9.375;
    size_38 = safeBlockHorizontal * 9.5;
    size_40 = safeBlockHorizontal * 10;
    size_42 = safeBlockHorizontal * 10.5;
    size_43 = safeBlockHorizontal * 10.75;
    size_44 = safeBlockHorizontal * 11;
    size_45 = safeBlockHorizontal * 11.25;
    size_50 = safeBlockHorizontal * 12.5;
    size_52 = safeBlockHorizontal * 13;
    size_54 = safeBlockHorizontal * 13.5;
    size_56 = safeBlockHorizontal * 14;
    size_60 = safeBlockHorizontal * 15;
    size_65 = safeBlockHorizontal * 16.25;
    size_70 = safeBlockHorizontal * 17.5;
    size_75 = safeBlockHorizontal * 18.75;
    size_80 = safeBlockHorizontal * 20;
    size_85 = safeBlockHorizontal * 21.25;
    size_90 = safeBlockHorizontal * 22.5;
    size_95 = safeBlockHorizontal * 23.75;
    size_93 = safeBlockHorizontal * 22.75;
    size_100 = safeBlockHorizontal * 25;
    size_110 = safeBlockHorizontal * 27.5;
    size_120 = safeBlockHorizontal * 30;
    size_125 = safeBlockHorizontal * 31.25;
    size_130 = safeBlockHorizontal * 32.5;
    size_140 = safeBlockHorizontal * 35;
    size_145 = safeBlockHorizontal * 36.125;
    size_150 = safeBlockHorizontal * 37.5;
    size_160 = safeBlockHorizontal * 40;
    size_170 = safeBlockHorizontal * 42.5;
    size_175 = safeBlockHorizontal * 43.75;
    size_180 = safeBlockHorizontal * 45;
    size_200 = safeBlockHorizontal * 50;
    size_220 = safeBlockHorizontal * 55;
    size_230 = safeBlockHorizontal * 57.5;
    size_240 = safeBlockHorizontal * 60;
    size_250 = safeBlockHorizontal * 62.5;
    size_280 = safeBlockHorizontal * 70;
    size_290 = safeBlockHorizontal * 72.5;
    size_300 = safeBlockHorizontal * 75;
    size_320 = safeBlockHorizontal * 80;
    size_340 = safeBlockHorizontal * 85;
    size_360 = safeBlockHorizontal * 90;
    size_380 = safeBlockHorizontal * 95;
    size_370 = safeBlockHorizontal * 92.5;
    size_400 = safeBlockHorizontal * 100;
    size_420 = safeBlockHorizontal * 105;
    size_440 = safeBlockHorizontal * 110;
    size_460 = safeBlockHorizontal * 115;
    size_480 = safeBlockHorizontal * 120;
    size_500 = safeBlockHorizontal * 125;
    size_540 = safeBlockHorizontal * 135;
    size_560 = safeBlockHorizontal * 140;
    size_580 = safeBlockHorizontal * 145;

    //fonts sizes for all screens
    font_10 = safeBlockHorizontal * 2.5;
    font_12 = safeBlockHorizontal * 3;
    font_14 = safeBlockHorizontal * 3.5;
    font_15 = safeBlockHorizontal * 3.75;
    font_16 = safeBlockHorizontal * 4;
    font_13 = safeBlockHorizontal * 4.1;
    font_18 = safeBlockHorizontal * 4.5;
    font_20 = safeBlockHorizontal * 5;
    font_22 = safeBlockHorizontal * 5.5;
    font_24 = safeBlockHorizontal * 6;
    font_28 = safeBlockHorizontal * 7;
    font_32 = safeBlockHorizontal * 8;
    font_36 = safeBlockHorizontal * 9;

    //STANDARD FONT SIZE
    smallerFontSize = font_10;
    standardFontSize = font_14;
    biggerFontSize = font_18;
    display1FontSize = font_36;
    headlineFontSize = font_24;
    titleFontSize = font_16;
    subTitleFontSize = font_14;
    body1FontSize = font_16;
    body2FontSize = font_14;
    captionFontSize = font_12;

    // PADDING
    smallerPadding = size_8;
    standardPadding = size_16;
    biggerPadding = size_24;

    // ELEVATION
    standardElevation = size_3;
    instance = SizeConfig(
        heightScale: heightScale,
        widthScale: widthScale,
        minTextAdapt: minTextAdapt);

    if (instance != null) {
      return instance!;
    } else {
      return instance!;
    }

  }

  late final double _widthScale;
  late final double _heightScale;
  late final double _textScale;

  double getHeight(num height) => height * _heightScale;

  double getWidth(num width) => width * _widthScale;

  double getTextSize(num textSize) => textSize * _textScale;

  double getRadius(num r) => r * min(_widthScale, _heightScale);

  static SizeConfig? instance;
}

extension SizeConfigExtension on num {
  double get h => SizeConfig.instance!.getHeight(this);

  double get w => SizeConfig.instance!.getWidth(this);

  double get sp => SizeConfig.instance!.getTextSize(this);

  double get r => SizeConfig.instance!.getRadius(this);

}

/// Get Spaces between layouts
/// Example : 12.sw is equal below code
///  SizedBox(
///     width: 12,
///   )
extension Spaces on num {
  SizedBox get sh => SizedBox(
    /// SizedBox/Space with Height
    height: toDouble(),
  );

  SizedBox get sw => SizedBox(
    /// SizedBox/Space with width
    width: toDouble(),
  );

  SizedBox get shw => SizedBox(
    /// SizedBox/Space with height and width
    width: toDouble(),
    height: toDouble(),
  );
}

extension EdgeInsetsGetter on num {
  EdgeInsets get edgeHor => EdgeInsets.symmetric(horizontal: toDouble());

  EdgeInsets get edgeVer => EdgeInsets.symmetric(vertical: toDouble());

  EdgeInsets get edgeVerHor =>
      EdgeInsets.symmetric(vertical: toDouble(), horizontal: toDouble());
}

extension PaddingOrMargin on Widget {
  Padding pHor(num value) => Padding(
    /// Padding horizontally
    padding: value.edgeHor,
    child: this,
  );

  Padding pVer(num value) => Padding(
    /// Padding with vertically
    padding: value.edgeVer,

    child: this,
  );

  Padding pHorVer(num value) => Padding(
    /// Padding with horizontally and vertically
    padding: value.edgeVerHor,
    child: this,
  );

  Container mHor(num value) => Container(
    /// Margin horizontally
    margin: value.edgeHor,
    child: this,
  );

  Container mVer(num value) => Container(
    /// Margin vertically
    margin: value.edgeVer,

    child: this,
  );

  Container mHorVer(num value) => Container(
    /// Margin horizontally and vertically
    margin: value.edgeVerHor,
    child: this,
  );
}


/// Full width and height of screen from context
/// Example : 'context.width' to get screen width
extension SizeExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;

  double get height => MediaQuery.of(this).size.height;

}
