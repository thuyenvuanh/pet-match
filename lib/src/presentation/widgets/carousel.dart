import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:pet_match/src/presentation/widgets/indicator.dart';
import 'package:pet_match/src/utils/constant.dart';

class Carousel extends StatefulWidget {
  const Carousel({super.key});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  static const int _itemCount = 3;
  static const double _carouselHeight = 400;
  final controller = CarouselController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  double _getScale(index) => _selectedIndex == index ? 1.0 : 0.8;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: _carouselHeight,
            width: MediaQuery.of(context).size.width,
            child: FlutterCarousel(
              options: CarouselOptions(
                controller: controller,
                showIndicator: false,
                onPageChanged: (index, reason) =>
                    setState(() => _selectedIndex = index),
                slideIndicator: const CircularSlideIndicator(),
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 350),
                autoPlayCurve: Curves.ease,
                enableInfiniteScroll: true,
                height: _carouselHeight,
                viewportFraction: 0.65,
              ),
              items: List.generate(
                  _itemCount,
                  (index) => TweenAnimationBuilder(
                        tween: Tween(
                            begin: _getScale(index), end: _getScale(index)),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.ease,
                        child: Container(
                          // margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/welcome_images/$index.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        builder: (context, value, child) => Transform.scale(
                          scale: value,
                          child: child,
                        ),
                      )),
            )),
        Stack(
          children: Resource.welcomeLeading
              .map((leading) => AnimatedOpacity(
                  opacity:
                      _selectedIndex == Resource.welcomeLeading.indexOf(leading)
                          ? 1
                          : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40)
                        .copyWith(top: 44),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(leading['Heading']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Resource.primaryColor,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 10),
                        Text(
                          leading['Content']!,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )))
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Indicator(isActive: _selectedIndex == index),
            ),
          ),
        )
      ],
    );
  }
}
