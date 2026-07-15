import 'package:cassowary/cassowary.dart' as cw;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ConstraintLayout extends MultiChildRenderObjectWidget {
  const ConstraintLayout({super.key, this.textDirection, super.children});

  final TextDirection? textDirection;

  @override
  RenderConstraintLayout createRenderObject(BuildContext context) {
    return RenderConstraintLayout(
      textDirection: textDirection ?? Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstraintLayout renderObject,
  ) {
    renderObject.textDirection =
        textDirection ?? Directionality.maybeOf(context);
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
  const Dimension(this.kind, {this.size = 0.0, this.fraction = 0.0});

  static const Dimension matchParent = Dimension(.matchParent);
  static const Dimension fillToConstraint = Dimension(.fillToConstraint);
  static const Dimension wrapContent = Dimension(.wrapContent);
  const Dimension.fixed(double size) : this(.fixed, size: size);
  const Dimension.percent(double percent) : this(.percent, fraction: percent);

  final DimensionKind kind;
  final double size;
  final double fraction;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == Dimension &&
            other is Dimension &&
            kind == other.kind &&
            size == other.size &&
            fraction == other.fraction;
  }

  @override
  int get hashCode => Object.hash(Dimension, kind, size, fraction);
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
    this.centerX,
    this.centerY,
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

  final ConstrainedLink? centerX;
  final ConstrainedLink? centerY;

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
      width: width,
      height: height,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      start: start,
      end: end,
      baseline: baseline,
      centerX: centerX,
      centerY: centerY,
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

enum Anchor { left, top, right, bottom, start, end, baseline, centerX, centerY }

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
  const ConstrainedLink.toCenterXOf(this.reference)
    : anchor = .centerX,
      margin = 0;
  const ConstrainedLink.toCenterYOf(this.reference)
    : anchor = .centerY,
      margin = 0;

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
    this.centerX,
    this.centerY,
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

  final ConstrainedLink? centerX;
  final ConstrainedLink? centerY;

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
            centerX == other.centerX &&
            centerY == other.centerY &&
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
    centerX,
    centerY,
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
  RenderConstraintLayout({TextDirection? textDirection}) {
    _textDirection = textDirection;
  }

  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;

  set textDirection(TextDirection? value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ConstraintLayoutParentData) {
      child.parentData = ConstraintLayoutParentData();
    }
  }

  @override
  void performLayout() {
    final inputs = <_ChildLayoutInput>[];
    var child = firstChild;

    while (child != null) {
      final parentData = child.parentData! as ConstraintLayoutParentData;
      final constraint = parentData.constraint;

      if (constraint != null) {
        final wrapContentConstraints = constraints.loosen();
        child.layout(wrapContentConstraints, parentUsesSize: true);
        inputs.add(
          _ChildLayoutInput(
            renderBox: child,
            constraint: constraint,
            wrapContentSize: child.size,
            baselineDistance: child.getDistanceToBaseline(
              TextBaseline.alphabetic,
              onlyReal: true,
            ),
          ),
        );
      } else {
        child.layout(BoxConstraints.tight(Size.zero), parentUsesSize: true);
      }

      child = parentData.nextSibling;
    }

    final result = _calculateLayout(
      constraints: constraints,
      children: inputs,
      textDirection: textDirection,
    );

    size = result.size;

    for (final input in inputs) {
      final childLayout = result.children[input.renderBox]!;
      input.renderBox.layout(
        BoxConstraints.tight(childLayout.size),
        parentUsesSize: true,
      );
      final parentData =
          input.renderBox.parentData! as ConstraintLayoutParentData;
      parentData.offset = childLayout.offset;
    }
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final inputs = <_ChildLayoutInput>[];
    var child = firstChild;

    while (child != null) {
      final parentData = child.parentData! as ConstraintLayoutParentData;
      final constraint = parentData.constraint;

      if (constraint != null) {
        final wrapContentConstraints = constraints.loosen();
        inputs.add(
          _ChildLayoutInput(
            renderBox: child,
            constraint: constraint,
            wrapContentSize: child.getDryLayout(wrapContentConstraints),
            baselineDistance: child.getDryBaseline(
              wrapContentConstraints,
              TextBaseline.alphabetic,
            ),
          ),
        );
      }

      child = parentData.nextSibling;
    }

    return _calculateLayout(
      constraints: constraints,
      children: inputs,
      textDirection: textDirection,
    ).size;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _computeIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _computeIntrinsicHeight(width);
  }

  double _computeIntrinsicWidth(double height) {
    var child = firstChild;
    var width = 0.0;

    while (child != null) {
      final parentData = child.parentData! as ConstraintLayoutParentData;
      final constraint = parentData.constraint;

      if (constraint != null) {
        final childWidth = _resolveIntrinsicDimension(
          dimension: constraint.width,
          minDimension: constraint.minWidth,
          maxDimension: constraint.maxWidth,
          childExtent: child.getMaxIntrinsicWidth(height),
        );
        width = width < childWidth ? childWidth : width;
      }

      child = parentData.nextSibling;
    }

    return width;
  }

  double _computeIntrinsicHeight(double width) {
    var child = firstChild;
    var height = 0.0;

    while (child != null) {
      final parentData = child.parentData! as ConstraintLayoutParentData;
      final constraint = parentData.constraint;

      if (constraint != null) {
        final childHeight = _resolveIntrinsicDimension(
          dimension: constraint.height,
          minDimension: constraint.minHeight,
          maxDimension: constraint.maxHeight,
          childExtent: child.getMaxIntrinsicHeight(width),
        );
        height = height < childHeight ? childHeight : height;
      }

      child = parentData.nextSibling;
    }

    return height;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final parentData = child.parentData! as ConstraintLayoutParentData;
    transform.translateByDouble(
      parentData.offset.dx,
      parentData.offset.dy,
      0,
      1,
    );
  }
}

class _ChildLayoutInput {
  const _ChildLayoutInput({
    required this.renderBox,
    required this.constraint,
    required this.wrapContentSize,
    required this.baselineDistance,
  });

  final RenderBox renderBox;
  final ChildConstraint constraint;
  final Size wrapContentSize;
  final double? baselineDistance;
}

class _LayoutResult {
  const _LayoutResult({required this.size, required this.children});

  final Size size;
  final Map<RenderBox, _ChildLayout> children;
}

class _ChildLayout {
  const _ChildLayout({required this.offset, required this.size});

  final Offset offset;
  final Size size;
}

class _ChildVariables {
  _ChildVariables(String name)
    : left = cw.Param.withContext('$name.left'),
      top = cw.Param.withContext('$name.top'),
      right = cw.Param.withContext('$name.right'),
      bottom = cw.Param.withContext('$name.bottom'),
      centerX = cw.Param.withContext('$name.centerX'),
      centerY = cw.Param.withContext('$name.centerY'),
      width = cw.Param.withContext('$name.width'),
      height = cw.Param.withContext('$name.height'),
      baseline = cw.Param.withContext('$name.baseline') {
    left.name = '$name.left';
    top.name = '$name.top';
    right.name = '$name.right';
    bottom.name = '$name.bottom';
    centerX.name = '$name.centerX';
    centerY.name = '$name.centerY';
    width.name = '$name.width';
    height.name = '$name.height';
    baseline.name = '$name.baseline';
  }

  final cw.Param left;
  final cw.Param top;
  final cw.Param right;
  final cw.Param bottom;
  final cw.Param centerX;
  final cw.Param centerY;
  final cw.Param width;
  final cw.Param height;
  final cw.Param baseline;
}

_LayoutResult _calculateLayout({
  required BoxConstraints constraints,
  required List<_ChildLayoutInput> children,
  required TextDirection? textDirection,
}) {
  final fallbackSize = _estimateFallbackSize(children);
  final layoutSize = Size(
    constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(fallbackSize.width),
    constraints.hasBoundedHeight
        ? constraints.maxHeight
        : constraints.constrainHeight(fallbackSize.height),
  );

  final solver = cw.Solver();
  final parent = _ChildVariables('parent');
  final variablesByRef = <ConstraintRef, _ChildVariables>{
    ConstraintRef.parent: parent,
  };
  final variablesByChild = <RenderBox, _ChildVariables>{};

  void add(cw.Constraint constraint) {
    final result = solver.addConstraint(constraint);
    if (result != cw.Result.success) {
      throw FlutterError(
        'ConstraintLayout could not add constraint: '
        '${result.message}\n$constraint',
      );
    }
  }

  add(parent.left.equals(cw.cm(0)));
  add(parent.top.equals(cw.cm(0)));
  add(parent.width.equals(cw.cm(layoutSize.width)));
  add(parent.height.equals(cw.cm(layoutSize.height)));
  add(parent.right.equals(parent.left + parent.width));
  add(parent.bottom.equals(parent.top + parent.height));
  add(parent.centerX.equals(parent.left + parent.width * cw.cm(0.5)));
  add(parent.centerY.equals(parent.top + parent.height * cw.cm(0.5)));
  add(parent.baseline.equals(parent.top));

  for (final input in children) {
    final variables = _ChildVariables(input.constraint.ref.toString());
    if (variablesByRef.containsKey(input.constraint.ref)) {
      throw FlutterError(
        'ConstraintLayout found duplicate ref: ${input.constraint.ref}.',
      );
    }
    variablesByRef[input.constraint.ref] = variables;
    variablesByChild[input.renderBox] = variables;

    add(variables.right.equals(variables.left + variables.width));
    add(variables.bottom.equals(variables.top + variables.height));
    add(
      variables.centerX.equals(variables.left + variables.width * cw.cm(0.5)),
    );
    add(
      variables.centerY.equals(variables.top + variables.height * cw.cm(0.5)),
    );
    add(
      variables.baseline.equals(
        variables.top + cw.cm(input.baselineDistance ?? 0),
      ),
    );
    add(variables.right <= parent.right);
    add(variables.bottom <= parent.bottom);

    _addDimensionConstraints(
      add: add,
      dimension: input.constraint.width,
      minDimension: input.constraint.minWidth,
      maxDimension: input.constraint.maxWidth,
      variable: variables.width,
      wrapContentSize: input.wrapContentSize.width,
      parentSize: layoutSize.width,
    );
    _addDimensionConstraints(
      add: add,
      dimension: input.constraint.height,
      minDimension: input.constraint.minHeight,
      maxDimension: input.constraint.maxHeight,
      variable: variables.height,
      wrapContentSize: input.wrapContentSize.height,
      parentSize: layoutSize.height,
    );
  }

  for (final input in children) {
    final variables = variablesByChild[input.renderBox]!;
    final constraint = input.constraint;

    _addHorizontalConstraints(
      add: add,
      variables: variables,
      constraint: constraint,
      variablesByRef: variablesByRef,
      textDirection: textDirection,
    );
    _addVerticalConstraints(
      add: add,
      variables: variables,
      constraint: constraint,
      variablesByRef: variablesByRef,
    );
  }

  solver.flushUpdates();

  return _LayoutResult(
    size: layoutSize,
    children: {
      for (final input in children)
        input.renderBox: _ChildLayout(
          offset: Offset(
            _cleanPixelValue(variablesByChild[input.renderBox]!.left.value),
            _cleanPixelValue(variablesByChild[input.renderBox]!.top.value),
          ),
          size: Size(
            _cleanDimensionValue(
              variablesByChild[input.renderBox]!.width.value,
            ),
            _cleanDimensionValue(
              variablesByChild[input.renderBox]!.height.value,
            ),
          ),
        ),
    },
  );
}

Size _estimateFallbackSize(List<_ChildLayoutInput> children) {
  var width = 0.0;
  var height = 0.0;
  for (final input in children) {
    width = width < input.wrapContentSize.width
        ? input.wrapContentSize.width
        : width;
    height = height < input.wrapContentSize.height
        ? input.wrapContentSize.height
        : height;
  }
  return Size(width, height);
}

void _addDimensionConstraints({
  required void Function(cw.Constraint) add,
  required Dimension dimension,
  required Dimension? minDimension,
  required Dimension? maxDimension,
  required cw.Param variable,
  required double wrapContentSize,
  required double parentSize,
}) {
  final bounds = _DimensionBounds.resolve(
    minDimension: minDimension,
    maxDimension: maxDimension,
    parentSize: parentSize,
    wrapContentSize: wrapContentSize,
  );

  add(variable >= cw.cm(0));

  switch (dimension.kind) {
    case DimensionKind.fixed:
      add(variable.equals(cw.cm(dimension.size)));
    case DimensionKind.percent:
      add(variable.equals(cw.cm(parentSize * dimension.fraction)));
    case DimensionKind.matchParent:
      add(variable.equals(cw.cm(parentSize)));
    case DimensionKind.fillToConstraint:
      break;
    case DimensionKind.wrapContent:
      add(
        variable.equals(cw.cm(bounds.constrain(wrapContentSize))) |
            cw.Priority.strong,
      );
  }

  if (bounds.min != null) {
    add(variable >= cw.cm(bounds.min!));
  }
  if (bounds.max != null) {
    add(variable <= cw.cm(bounds.max!));
  }
}

double _resolveLimitDimension(
  Dimension dimension,
  double parentSize,
  double wrapContentSize,
) {
  return switch (dimension.kind) {
    DimensionKind.fixed => dimension.size,
    DimensionKind.percent => parentSize * dimension.fraction,
    DimensionKind.matchParent => parentSize,
    DimensionKind.fillToConstraint => parentSize,
    DimensionKind.wrapContent => wrapContentSize,
  };
}

class _DimensionBounds {
  const _DimensionBounds({this.min, this.max});

  factory _DimensionBounds.resolve({
    required Dimension? minDimension,
    required Dimension? maxDimension,
    required double parentSize,
    required double wrapContentSize,
  }) {
    final min = minDimension == null
        ? null
        : _resolveLimitDimension(minDimension, parentSize, wrapContentSize);
    final max = maxDimension == null
        ? null
        : _resolveLimitDimension(maxDimension, parentSize, wrapContentSize);

    if (min != null && max != null && min > max) {
      throw FlutterError(
        'ConstraintLayout received min dimension greater than max dimension: '
        'min=$min, max=$max.',
      );
    }

    return _DimensionBounds(min: min, max: max);
  }

  final double? min;
  final double? max;

  double constrain(double value) {
    var result = value;
    if (min != null && result < min!) {
      result = min!;
    }
    if (max != null && result > max!) {
      result = max!;
    }
    return result;
  }
}

double _resolveIntrinsicDimension({
  required Dimension dimension,
  required Dimension? minDimension,
  required Dimension? maxDimension,
  required double childExtent,
}) {
  var extent = switch (dimension.kind) {
    DimensionKind.fixed => dimension.size,
    DimensionKind.wrapContent => childExtent,
    DimensionKind.percent ||
    DimensionKind.matchParent ||
    DimensionKind.fillToConstraint => childExtent,
  };

  final min = _resolveIntrinsicLimitDimension(minDimension, childExtent);
  final max = _resolveIntrinsicLimitDimension(maxDimension, childExtent);
  if (min != null && max != null && min > max) {
    throw FlutterError(
      'ConstraintLayout received min intrinsic dimension greater than '
      'max intrinsic dimension: min=$min, max=$max.',
    );
  }
  if (min != null && extent < min) {
    extent = min;
  }
  if (max != null && extent > max) {
    extent = max;
  }

  return extent;
}

double? _resolveIntrinsicLimitDimension(
  Dimension? dimension,
  double childExtent,
) {
  if (dimension == null) {
    return null;
  }
  return switch (dimension.kind) {
    DimensionKind.fixed => dimension.size,
    DimensionKind.wrapContent => childExtent,
    DimensionKind.percent ||
    DimensionKind.matchParent ||
    DimensionKind.fillToConstraint => null,
  };
}

void _addHorizontalConstraints({
  required void Function(cw.Constraint) add,
  required _ChildVariables variables,
  required ChildConstraint constraint,
  required Map<ConstraintRef, _ChildVariables> variablesByRef,
  required TextDirection? textDirection,
}) {
  _checkLink(
    source: Anchor.left,
    link: constraint.left,
    allowedTargets: const {Anchor.left, Anchor.right},
  );
  _checkLink(
    source: Anchor.right,
    link: constraint.right,
    allowedTargets: const {Anchor.left, Anchor.right},
  );
  _checkLink(
    source: Anchor.start,
    link: constraint.start,
    allowedTargets: const {Anchor.start, Anchor.end},
  );
  _checkLink(
    source: Anchor.end,
    link: constraint.end,
    allowedTargets: const {Anchor.start, Anchor.end},
  );
  _checkLink(
    source: Anchor.centerX,
    link: constraint.centerX,
    allowedTargets: const {Anchor.centerX},
  );

  final left =
      constraint.left ??
      _directionalLink(
        start: constraint.start,
        end: constraint.end,
        targetAnchor: Anchor.left,
        textDirection: textDirection,
      );
  final right =
      constraint.right ??
      _directionalLink(
        start: constraint.start,
        end: constraint.end,
        targetAnchor: Anchor.right,
        textDirection: textDirection,
      );

  if (constraint.width.kind == DimensionKind.matchParent) {
    add(variables.left.equals(cw.cm(0)));
    return;
  }

  if (constraint.centerX != null) {
    final anchor = _targetAnchor(
      variablesByRef,
      constraint.centerX!.reference,
      _resolveDirectionalAnchor(constraint.centerX!.anchor, textDirection),
    );
    add(variables.centerX.equals(anchor + cw.cm(constraint.centerX!.margin)));
    return;
  }

  if (left != null && right != null) {
    final leftAnchor = _targetAnchor(
      variablesByRef,
      left.reference,
      _resolveDirectionalAnchor(left.anchor, textDirection),
    );
    final rightAnchor = _targetAnchor(
      variablesByRef,
      right.reference,
      _resolveDirectionalAnchor(right.anchor, textDirection),
    );

    if (constraint.width.kind == DimensionKind.fillToConstraint) {
      _addFillToConstraintConstraints(
        add: add,
        position: variables.left,
        size: variables.width,
        end: variables.right,
        startAnchor: leftAnchor,
        endAnchor: rightAnchor,
        startMargin: left.margin,
        endMargin: right.margin,
        bias: constraint.horizontalBias,
      );
    } else {
      _addBiasConstraint(
        add: add,
        position: variables.left,
        size: variables.width,
        startAnchor: leftAnchor,
        endAnchor: rightAnchor,
        startMargin: left.margin,
        endMargin: right.margin,
        bias: constraint.horizontalBias,
      );
    }
  } else if (left != null) {
    final anchor = _targetAnchor(
      variablesByRef,
      left.reference,
      _resolveDirectionalAnchor(left.anchor, textDirection),
    );
    add(variables.left.equals(anchor + cw.cm(left.margin)));
  } else if (right != null) {
    final anchor = _targetAnchor(
      variablesByRef,
      right.reference,
      _resolveDirectionalAnchor(right.anchor, textDirection),
    );
    add(variables.right.equals(anchor - cw.cm(right.margin)));
  } else {
    add(variables.left.equals(cw.cm(0)) | cw.Priority.weak);
  }
}

void _addVerticalConstraints({
  required void Function(cw.Constraint) add,
  required _ChildVariables variables,
  required ChildConstraint constraint,
  required Map<ConstraintRef, _ChildVariables> variablesByRef,
}) {
  _checkLink(
    source: Anchor.top,
    link: constraint.top,
    allowedTargets: const {Anchor.top, Anchor.bottom},
  );
  _checkLink(
    source: Anchor.bottom,
    link: constraint.bottom,
    allowedTargets: const {Anchor.top, Anchor.bottom},
  );
  _checkLink(
    source: Anchor.baseline,
    link: constraint.baseline,
    allowedTargets: const {Anchor.baseline},
  );
  _checkLink(
    source: Anchor.centerY,
    link: constraint.centerY,
    allowedTargets: const {Anchor.centerY},
  );

  if (constraint.baseline != null) {
    final link = constraint.baseline!;
    add(
      variables.baseline.equals(
        _targetAnchor(variablesByRef, link.reference, link.anchor) +
            cw.cm(link.margin),
      ),
    );
  }

  if (constraint.height.kind == DimensionKind.matchParent) {
    add(variables.top.equals(cw.cm(0)));
    return;
  }

  if (constraint.centerY != null) {
    final anchor = _targetAnchor(
      variablesByRef,
      constraint.centerY!.reference,
      constraint.centerY!.anchor,
    );
    add(variables.centerY.equals(anchor + cw.cm(constraint.centerY!.margin)));
    return;
  }

  if (constraint.top != null && constraint.bottom != null) {
    final topAnchor = _targetAnchor(
      variablesByRef,
      constraint.top!.reference,
      constraint.top!.anchor,
    );
    final bottomAnchor = _targetAnchor(
      variablesByRef,
      constraint.bottom!.reference,
      constraint.bottom!.anchor,
    );

    if (constraint.height.kind == DimensionKind.fillToConstraint) {
      _addFillToConstraintConstraints(
        add: add,
        position: variables.top,
        size: variables.height,
        end: variables.bottom,
        startAnchor: topAnchor,
        endAnchor: bottomAnchor,
        startMargin: constraint.top!.margin,
        endMargin: constraint.bottom!.margin,
        bias: constraint.verticalBias,
      );
    } else {
      _addBiasConstraint(
        add: add,
        position: variables.top,
        size: variables.height,
        startAnchor: topAnchor,
        endAnchor: bottomAnchor,
        startMargin: constraint.top!.margin,
        endMargin: constraint.bottom!.margin,
        bias: constraint.verticalBias,
      );
    }
  } else if (constraint.top != null) {
    final anchor = _targetAnchor(
      variablesByRef,
      constraint.top!.reference,
      constraint.top!.anchor,
    );
    add(variables.top.equals(anchor + cw.cm(constraint.top!.margin)));
  } else if (constraint.bottom != null) {
    final anchor = _targetAnchor(
      variablesByRef,
      constraint.bottom!.reference,
      constraint.bottom!.anchor,
    );
    add(variables.bottom.equals(anchor - cw.cm(constraint.bottom!.margin)));
  } else if (constraint.baseline == null) {
    add(variables.top.equals(cw.cm(0)) | cw.Priority.weak);
  }
}

void _checkLink({
  required Anchor source,
  required ConstrainedLink? link,
  required Set<Anchor> allowedTargets,
}) {
  if (link == null || allowedTargets.contains(link.anchor)) {
    return;
  }

  throw FlutterError(
    'ConstraintLayout cannot connect $source to ${link.anchor}. '
    'Allowed target anchors: ${allowedTargets.join(', ')}.',
  );
}

void _addFillToConstraintConstraints({
  required void Function(cw.Constraint) add,
  required cw.Param position,
  required cw.Param size,
  required cw.Param end,
  required cw.Param startAnchor,
  required cw.Param endAnchor,
  required double startMargin,
  required double endMargin,
  required double bias,
}) {
  add(position >= startAnchor + cw.cm(startMargin));
  add(end <= endAnchor - cw.cm(endMargin));
  add(
    size.equals(endAnchor - startAnchor - cw.cm(startMargin + endMargin)) |
        cw.Priority.strong,
  );
  _addBiasConstraint(
    add: add,
    position: position,
    size: size,
    startAnchor: startAnchor,
    endAnchor: endAnchor,
    startMargin: startMargin,
    endMargin: endMargin,
    bias: bias,
  );
}

void _addBiasConstraint({
  required void Function(cw.Constraint) add,
  required cw.Param position,
  required cw.Param size,
  required cw.Param startAnchor,
  required cw.Param endAnchor,
  required double startMargin,
  required double endMargin,
  required double bias,
}) {
  final clampedBias = bias.clamp(0.0, 1.0);
  final expression =
      startAnchor * cw.cm(1 - clampedBias) +
      endAnchor * cw.cm(clampedBias) -
      size * cw.cm(clampedBias) +
      cw.cm((1 - clampedBias) * startMargin - clampedBias * endMargin);
  add(position.equals(expression));
}

ConstrainedLink? _directionalLink({
  required ConstrainedLink? start,
  required ConstrainedLink? end,
  required Anchor targetAnchor,
  required TextDirection? textDirection,
}) {
  if (start == null && end == null) {
    return null;
  }
  if (textDirection == null) {
    throw FlutterError(
      'ConstraintLayout needs a TextDirection to resolve start/end anchors.',
    );
  }

  return switch (textDirection) {
    TextDirection.ltr => targetAnchor == Anchor.left ? start : end,
    TextDirection.rtl => targetAnchor == Anchor.left ? end : start,
  };
}

Anchor _resolveDirectionalAnchor(Anchor anchor, TextDirection? textDirection) {
  return switch (anchor) {
    Anchor.start => switch (textDirection) {
      TextDirection.rtl => Anchor.right,
      TextDirection.ltr || null => Anchor.left,
    },
    Anchor.end => switch (textDirection) {
      TextDirection.rtl => Anchor.left,
      TextDirection.ltr || null => Anchor.right,
    },
    _ => anchor,
  };
}

cw.Param _targetAnchor(
  Map<ConstraintRef, _ChildVariables> variablesByRef,
  ConstraintRef reference,
  Anchor anchor,
) {
  final variables = variablesByRef[reference];
  if (variables == null) {
    throw FlutterError('ConstraintLayout could not find ref: $reference.');
  }

  return switch (anchor) {
    Anchor.left || Anchor.start => variables.left,
    Anchor.top => variables.top,
    Anchor.right || Anchor.end => variables.right,
    Anchor.bottom => variables.bottom,
    Anchor.centerX => variables.centerX,
    Anchor.centerY => variables.centerY,
    Anchor.baseline => variables.baseline,
  };
}

double _cleanPixelValue(double value) {
  if (value.abs() < 0.0001) {
    return 0;
  }
  return value;
}

double _cleanDimensionValue(double value) {
  final clean = _cleanPixelValue(value);
  return clean < 0 ? 0 : clean;
}
