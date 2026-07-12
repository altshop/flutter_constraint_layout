import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ConstraintLayout extends MultiChildRenderObjectWidget {
  const ConstraintLayout({super.key, super.children});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderConstraintLayout();
  }
}

enum DimensionKind {
  fixed,
  percent,
  matchParent,
  fillToConstraint,
  wrapContent,
}

class Dimension {
  const Dimension(this.kind, {this.size = 0.0, this.percent = 0.0});

  static const Dimension matchParent = Dimension(.matchParent);
  static const Dimension fillToConstraint = Dimension(.fillToConstraint);
  static const Dimension wrapContent = Dimension(.wrapContent);
  const Dimension.fixed(double size) : this(.fixed, size: size);
  const Dimension.percent(double percent) : this(.percent, percent: percent);

  final DimensionKind kind;
  final double size;
  final double percent;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == Dimension &&
            other is Dimension &&
            kind == other.kind &&
            size == other.size &&
            percent == other.percent;
  }

  @override
  int get hashCode => Object.hash(Dimension, kind, size, percent);
}

class Constraint extends ParentDataWidget<ConstraintLayoutParentData> {
  const Constraint({
    super.key,
    required this.ref,
    this.width = .wrapContent,
    this.height = .wrapContent,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.start,
    this.end,
    this.baseline,
    this.verticalBias = 0.5,
    this.horizontalBias = 0.5,
    required super.child,
  });

  final ConstraintRef ref;

  final Dimension width;
  final Dimension height;

  final Dimension? minWidth;
  final Dimension? maxWidth;
  final Dimension? minHeight;
  final Dimension? maxHeight;

  final ConstrainedLink? left;
  final ConstrainedLink? top;
  final ConstrainedLink? right;
  final ConstrainedLink? bottom;

  final ConstrainedLink? start;
  final ConstrainedLink? end;

  final ConstrainedLink? baseline;

  final double verticalBias;
  final double horizontalBias;

  @override
  void applyParentData(RenderObject renderObject) {
    assert(renderObject.parentData is ConstraintLayoutParentData);
    final parentData = renderObject.parentData! as ConstraintLayoutParentData;
    var needsLayout = false;

    final constraint = ChildConstraint(
      ref: ref,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      start: start,
      end: end,
      baseline: baseline,
      verticalBias: verticalBias,
      horizontalBias: horizontalBias,
    );
    if (parentData.constraint != constraint) {
      parentData.constraint = constraint;
      needsLayout = true;
    }

    if (needsLayout) {
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => ConstraintLayout;
}

class ConstraintRef {
  static const ConstraintRef parent = .of('parent');

  const ConstraintRef(this.symbol);

  const factory ConstraintRef.of(Object symbol) = ConstraintRef;

  final Object symbol;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == ConstraintRef &&
            other is ConstraintRef &&
            symbol == other.symbol;
  }

  @override
  int get hashCode => Object.hash(ConstraintRef, symbol);

  @override
  String toString() {
    return symbol.toString();
  }
}

enum Anchor { left, top, right, bottom, start, end, baseline }

class ConstrainedLink {
  const ConstrainedLink(this.reference, this.anchor, {this.margin = 0.0});

  const ConstrainedLink.toLeftOf(this.reference, {this.margin = 0.0})
    : anchor = .left;
  const ConstrainedLink.toTopOf(this.reference, {this.margin = 0.0})
    : anchor = .top;
  const ConstrainedLink.toRightOf(this.reference, {this.margin = 0.0})
    : anchor = .right;
  const ConstrainedLink.toBottomOf(this.reference, {this.margin = 0.0})
    : anchor = .bottom;
  const ConstrainedLink.toStartOf(this.reference, {this.margin = 0.0})
    : anchor = .start;
  const ConstrainedLink.toEndOf(this.reference, {this.margin = 0.0})
    : anchor = .end;
  const ConstrainedLink.toBaselineOf(this.reference, {this.margin = 0.0})
    : anchor = .baseline;

  final ConstraintRef reference;

  final Anchor anchor;

  final double margin;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == ConstrainedLink &&
            other is ConstrainedLink &&
            reference == other.reference &&
            anchor == other.anchor &&
            margin == other.margin;
  }

  @override
  int get hashCode => Object.hash(ConstrainedLink, reference, anchor, margin);
}

class ChildConstraint {
  const ChildConstraint({
    required this.ref,
    this.width = .wrapContent,
    this.height = .wrapContent,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.start,
    this.end,
    this.baseline,
    this.verticalBias = 0.5,
    this.horizontalBias = 0.5,
  });

  final ConstraintRef ref;

  final Dimension width;
  final Dimension height;

  final Dimension? minWidth;
  final Dimension? maxWidth;
  final Dimension? minHeight;
  final Dimension? maxHeight;

  final ConstrainedLink? left;
  final ConstrainedLink? top;
  final ConstrainedLink? right;
  final ConstrainedLink? bottom;

  final ConstrainedLink? start;
  final ConstrainedLink? end;

  final ConstrainedLink? baseline;

  final double verticalBias;
  final double horizontalBias;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == ChildConstraint &&
            other is ChildConstraint &&
            ref == other.ref &&
            width == other.width &&
            height == other.height &&
            minWidth == other.minWidth &&
            maxWidth == other.maxWidth &&
            minHeight == other.minHeight &&
            maxHeight == other.maxHeight &&
            left == other.left &&
            top == other.top &&
            right == other.right &&
            bottom == other.bottom &&
            start == other.start &&
            end == other.end &&
            baseline == other.baseline &&
            verticalBias == other.verticalBias &&
            horizontalBias == other.horizontalBias;
  }

  @override
  int get hashCode => Object.hash(
    ChildConstraint,
    ref,
    width,
    height,
    minWidth,
    maxWidth,
    minHeight,
    maxHeight,
    left,
    top,
    right,
    bottom,
    start,
    end,
    baseline,
    verticalBias,
    horizontalBias,
  );
}

class ConstraintLayoutParentData extends ContainerBoxParentData<RenderBox> {
  ChildConstraint? constraint;
}

class RenderConstraintLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, ConstraintLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, ConstraintLayoutParentData>,
        DebugOverflowIndicatorMixin {
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ConstraintLayoutParentData) {
      child.parentData = ConstraintLayoutParentData();
    }
  }
}
