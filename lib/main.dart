// @dart=2.9

import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart' as Vector;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => new _DemoPageState();

  DemoPage() {
    timeDilation = 1.0;
  }
}

class _DemoPageState extends State<DemoPage> {
  double widgetHeight = 400.0;
  double sliderValue = 400;

  @override
  Widget build(BuildContext context) {
    Size size = new Size(MediaQuery.of(context).size.width, widgetHeight);
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new DemoBody(
            size: size,
            xOffset: 0,
            yOffset: 0,
            color: Colors.redAccent.withOpacity(0.2),
            duration: 1400,
          ),
          new DemoBody(
              size: size,
              xOffset: 0,
              yOffset: 0,
              color: Colors.redAccent.withOpacity(0.2),
              duration: 1600),
          new DemoBody(
              size: size,
              xOffset: 0,
              yOffset: 0,
              color: Colors.redAccent.withOpacity(0.2),
              duration: 1800),

          RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: sliderValue,
              min: 0,
              max: MediaQuery.of(context).size.height,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                  widgetHeight = value.round() * 1.0;
                  print(value);
                });
              },
            ),
          )
          // new Opacity(
          //   opacity: 0.3,
          //   child: new DemoBody(
          //     size: size,
          //     xOffset: 50,
          //     yOffset: 10,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class DemoBody extends StatefulWidget {
  final Size size;
  final int xOffset;
  final int yOffset;
  final Color color;
  final int duration;

  DemoBody(
      {Key key,
      @required this.size,
      this.xOffset,
      this.yOffset,
      this.color,
      this.duration = 2})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _DemoBodyState();
  }
}

class _DemoBodyState extends State<DemoBody> with TickerProviderStateMixin {
  AnimationController animationController;
  List<Offset> animList1 = [];

  @override
  void initState() {
    super.initState();

    animationController = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: widget.duration));

    animationController.addListener(() {
      animList1.clear();
      for (int i = -2 - widget.xOffset;
          i <= widget.size.width.toInt() + 2;
          i++) {
        animList1.add(new Offset(
            i.toDouble() + widget.xOffset,
            sin((animationController.value * 360 - i) %
                        360 *
                        Vector.degrees2Radians) *
                    20 +
                50 +
                widget.yOffset));
      }
    });
    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.bottomCenter,
      child: new AnimatedBuilder(
        animation: new CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) => new ClipPath(
          child: new Container(
            width: widget.size.width,
            height: widget.size.height,
            color: widget.color,
          ),
          clipper: new WaveClipper(animationController.value, animList1),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}
