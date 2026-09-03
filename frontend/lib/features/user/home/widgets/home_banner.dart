import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final banners = [
      'https://tse1.mm.bing.net/th/id/OIP.qA6T3nlQKCI8d3Fe9xIkoQHaEF?pid=Api&P=0&h=180',
      'https://tse3.mm.bing.net/th/id/OIP.2_GTeRin52zH6CGPlQaMYAHaHa?pid=Api&P=0&h=180',
      'https://tse3.mm.bing.net/th/id/OIP.IuVdkVPn87VVkZl8_4UpZwHaHa?pid=Api&P=0&h=180',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 500,
      child: Row(
        children: [
          // ===== LEFT: BANNER LỚN =====
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 500 ,
                  autoPlay: true,
                  viewportFraction: 1,
                ),
                items: banners.map((url) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ===== RIGHT: 2 BANNER NHỎ =====
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: _smallBanner(
                    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _smallBanner(
                    'https://images.unsplash.com/photo-1600891964599-f61ba0e24092',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallBanner(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }
}