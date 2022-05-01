import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tare/models/recipe.dart';

Widget buildRecipeImage(Recipe? recipe, BorderRadius borderRadius, double height, {BoxShadow? boxShadow}) {
  if (recipe != null) {
    return Hero(
        tag: recipe.id!,
        child: CachedNetworkImage(
          fadeInDuration: Duration(milliseconds: 0),
          fadeOutDuration: Duration(milliseconds: 0),
          imageUrl: recipe.image ?? '',
          imageBuilder: (context, imageProvider) => Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: borderRadius,
              boxShadow: [
                if (boxShadow != null) boxShadow
              ],
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => Shimmer.fromColors(
            enabled: true,
            baseColor: Colors.white,
            highlightColor: Colors.white,
            child: Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: borderRadius,
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: borderRadius,
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant_menu_outlined,
                  color: Colors.black38,
                ),
              ),
            );
          },
        )
    );
  } else {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_menu_outlined,
          color: Colors.black38,
        ),
      ),
    );
  }
}