import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_match/src/presentation/provider/swipe_provider.dart';
import 'package:provider/provider.dart';

class SwipeCard extends StatefulWidget {
  const SwipeCard({Key? key}) : super(key: key);

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final provider = Provider.of<SwipeProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return buildFrontCard();
  }

  Widget buildFrontCard() => GestureDetector(
        onPanStart: (details) {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          provider.onStartDrag(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          provider.onDragUpdate(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<SwipeProvider>(context, listen: false);
          provider.onDragEnd(details);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final provider = Provider.of<SwipeProvider>(context);
            final position = provider.position;
            final maxHeight = constraints.maxHeight;
            final maxWidth = constraints.maxWidth;
            var transform = Matrix4.identity()
              ..translate(maxWidth / 2, maxHeight)
              ..rotateZ(provider.angle * pi / 180)
              ..translate(-(maxWidth / 2), -(maxHeight));

            return AnimatedContainer(
              duration: const Duration(milliseconds: 0),
              curve: Curves.linear,
              transform: transform..translate(position.dx, 0),
              child: buildCard(),
            );
          },
        ),
      );

  Widget buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.network(
                "https://demostore.properlife.vn/wp-content/uploads/2023/02/dog.jpg",
                fit: BoxFit.fitHeight,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 83,
                color: Colors.black.withOpacity(0.3),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: 83,
                child: ClipRRect(
                  clipBehavior: Clip.antiAlias,
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Cho, 2",
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Text(
                            "Poodle",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 25,
              left: 25,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/images/svgs/location.svg"),
                    const Text(
                      "1km",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
