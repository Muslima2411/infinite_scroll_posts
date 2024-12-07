import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        title: Container(
          height: 20,
          width: double.infinity,
          color: Colors.grey[300],
        ),
        subtitle: Container(
          height: 14,
          width: double.infinity,
          color: Colors.grey[300],
          margin: const EdgeInsets.only(top: 8),
        ),
      ),
    );
  }
}
