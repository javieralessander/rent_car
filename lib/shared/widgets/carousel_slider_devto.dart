// Para implementar
// CarouselSliderDevto(sliders: sliders)
// donde sliders es una lista de objetos Slide

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselSliderDevto extends StatelessWidget {
  final List<Slide> sliders;
  const CarouselSliderDevto({super.key, required this.sliders});
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        pauseAutoPlayOnManualNavigate: true,
        autoPlay: true,
        viewportFraction: 0.8,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 1000),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: sliders,
    );
  }
}

class Slide extends StatelessWidget {
  final String? description;
  final String? btnText;
  final dynamic Function()? onPressed;
  final String? imagen;
  final Color? color;

  const Slide({
    super.key,
    this.description,
    this.btnText,
    this.imagen,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: color,
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        wordSpacing: 2.5,
                        height: 1.4,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        btnText ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (imagen != null) ...[
              const SizedBox(width: 10),
              SizedBox(
                width: 130,
                child: Transform.scale(
                  scale: 1.5,
                  child: Image.asset(imagen!, fit: BoxFit.contain),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
