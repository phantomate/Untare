import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:untare/extensions/double_extension.dart';

String doubleToFractionString(double rawAmount) {
  // If we have a complex decimal we build a "simple" fraction. Otherwise we do the normal one
  if ((((rawAmount % 1) * 100) % 5) != 0) {
    // Use this crap because we can't change precision programmatically
    if (rawAmount.toInt() < 1) {
      return '${MixedFraction.fromDouble(rawAmount % 1, precision: 1.0e-1).reduce()} ';
    } else if (rawAmount.toInt() < 10) {
      return '${MixedFraction.fromDouble(rawAmount % 1, precision: 1.0e-2).reduce()} ';
    } else if (rawAmount.toInt() < 100) {
      return '${MixedFraction.fromDouble(rawAmount % 1, precision: 1.0e-3).reduce()} ';
    } else if (rawAmount.toInt() < 1000) {
      return '${MixedFraction.fromDouble(rawAmount % 1, precision: 1.0e-4).reduce()} ';
    } else {
      return '${MixedFraction.fromDouble(rawAmount % 1, precision: 1.0e-5).reduce()} ';
    }
  } else {
    return '${MixedFraction.fromDouble(rawAmount % 1)} ';
  }
}

Wrap amountWrap(double rawAmount, bool useFractions) {
  List<Widget> child = [];

  if (rawAmount == 0) {
    // nothing to do
    return Wrap();
  }

  if (useFractions == true && (rawAmount % 1) != 0) {
    if (rawAmount >= 1.0) {
      child.add(Text(
        '${rawAmount.toInt().toString()} ',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ));
    }
    child.add(Text(
      '${doubleToFractionString(rawAmount % 1)} ',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        fontFeatures: <FontFeature>[FontFeature.fractions()],
      ),
    ));
  } else {
    child.add(Text(
      '${rawAmount.toFormattedString()} ',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    ));
  }

  return Wrap(
    children: child,
  );
}
