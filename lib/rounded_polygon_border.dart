import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Cubic;
import 'package:m3_expressive_shapes/rounded_polygon_to_path.dart';
import 'package:m3_expressive_shapes/shapes/_shapes.dart';

class RoundedPolygonBorder extends ShapeBorder {
  RoundedPolygonBorder({required this.polygon, this.rotation = 0.0}) : cubics = polygon!.cubics;
  const RoundedPolygonBorder.cubics(this.cubics, this.polygon, this.rotation);

  final RoundedPolygon? polygon;
  final List<Cubic> cubics;
  final double rotation;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final path = roundedPolygonToPath(cubics, rect);
    final rotationMatrix = Matrix4.identity()
      ..translateByDouble(rect.center.dx, rect.center.dy, 0.0, 1.0)
      ..rotateZ(rotation)
      ..translateByDouble(-rect.center.dx, -rect.center.dy, 0.0, 1.0);

    return path.transform(rotationMatrix.storage);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => getInnerPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return RoundedPolygonBorder.cubics(cubics, polygon, rotation);
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is RoundedPolygonBorder && a.polygon != null) {
      final morph = Morph(start: a.polygon!, end: polygon!);
      final rotation = lerpDouble(a.rotation, this.rotation, t)!;
      return RoundedPolygonBorder.cubics(morph.asCubics(t), polygon, rotation);
    }

    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is RoundedPolygonBorder && b.polygon != null) {
      final morph = Morph(start: polygon!, end: b.polygon!);
      final rotation = lerpDouble(this.rotation, b.rotation, t)!;
      return RoundedPolygonBorder.cubics(morph.asCubics(t), polygon, rotation);
    }

    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoundedPolygonBorder) return false;

    return polygon == other.polygon && listEquals(cubics, other.cubics) && rotation == other.rotation;
  }

  @override
  int get hashCode {
    return Object.hash(polygon, Object.hashAll(cubics), rotation);
  }
}
