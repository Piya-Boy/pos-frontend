import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.small = false, this.logoUrl = '', this.logoText = 'ผ'});

  final bool small;
  final String logoUrl;
  final String logoText;

  @override
  Widget build(BuildContext context) {
    final size = small ? 44.0 : 64.0;
    final fallback = Center(
      child: Text(
        logoText,
        style: TextStyle(color: Colors.white, fontSize: small ? 24 : 34, fontWeight: FontWeight.w700),
      ),
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: PhiusTokens.primary, borderRadius: BorderRadius.circular(small ? 14 : 22)),
      child: logoUrl.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
