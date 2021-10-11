import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Constant Shapes

const cardRadius = Radius.circular(12);
const modalRadius = Radius.circular(24);

const cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(cardRadius),
);

const modalShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(topLeft: modalRadius, topRight: modalRadius),
);

const dialogShape = cardShape;
const menuShape = cardShape;

const topCardShape = RoundedRectangleBorder(
  borderRadius:
      BorderRadius.only(bottomLeft: cardRadius, bottomRight: cardRadius),
);
