import 'package:constraint_layout/constraint_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('basic structure', () {
    testWidgets('lays out with no children', (tester) async {
      await _pumpConstraintLayout(tester, children: []);

      expect(_layoutSize(tester), _defaultCanvasSize);
    });

    testWidgets('lays out an unconstrained child at zero size', (tester) async {
      final childKey = GlobalKey();

      await _pumpRawConstraintLayout(
        tester,
        children: [SizedBox(key: childKey, width: 100, height: 80)],
      );

      expect(_offsetOf(tester, childKey), Offset.zero);
      expect(tester.getSize(find.byKey(childKey)), Size.zero);
    });

    testWidgets('throws when refs are duplicated', (tester) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('duplicate'),
            child: const SizedBox(width: 10, height: 10),
          ),
          Constraint(
            ref: .of('duplicate'),
            child: const SizedBox(width: 10, height: 10),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('throws when a referenced child does not exist', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            left: .toRightOf(.of('missing')),
            child: const SizedBox(width: 10, height: 10),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('throws when start/end cannot resolve direction', (
      tester,
    ) async {
      await _pumpRawConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            start: .toStartOf(.parent),
            child: const SizedBox(width: 10, height: 10),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('container size', () {
    testWidgets('uses the test view size as tight parent constraints', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        canvasSize: const Size(420, 240),
        children: [],
      );

      expect(_layoutSize(tester), const Size(420, 240));
    });

    testWidgets('uses wrap content fallback when width is unbounded', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpRawWidget(
        tester,
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: UnconstrainedBox(
            constrainedAxis: Axis.vertical,
            alignment: Alignment.topLeft,
            child: ConstraintLayout(
              children: [
                Constraint(
                  ref: .of('child'),
                  child: SizedBox(key: childKey, width: 70, height: 30),
                ),
              ],
            ),
          ),
        ),
      );

      expect(_layoutSize(tester), const Size(70, 200));
      expect(tester.getSize(find.byKey(childKey)), const Size(70, 30));
    });
  });

  group('dimension', () {
    testWidgets('supports fixed dimensions', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(40, 30));
    });

    testWidgets('supports wrap content dimensions', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            child: SizedBox(key: childKey, width: 70, height: 45),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(70, 45));
    });

    testWidgets('expands wrap content dimensions to min limits', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            minWidth: .fixed(100),
            minHeight: .fixed(60),
            child: SizedBox(key: childKey, width: 70, height: 45),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(100, 60));
    });

    testWidgets('shrinks wrap content dimensions to max limits', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            maxWidth: .fixed(50),
            maxHeight: .fixed(30),
            child: SizedBox(key: childKey, width: 70, height: 45),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(50, 30));
    });

    testWidgets('supports percent dimensions', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .percent(0.25),
            height: .percent(0.5),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(75, 100));
    });

    testWidgets('supports match parent dimensions', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .matchParent,
            height: .matchParent,
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), Offset.zero);
      expect(tester.getSize(find.byKey(childKey)), _defaultCanvasSize);
    });

    testWidgets('supports fill to horizontal constraints', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fillToConstraint,
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            right: .toRightOf(.parent, margin: 20),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(10, 0));
      expect(tester.getSize(find.byKey(childKey)), const Size(270, 30));
    });

    testWidgets('supports fill to vertical constraints', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fillToConstraint,
            top: .toTopOf(.parent, margin: 15),
            bottom: .toBottomOf(.parent, margin: 25),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(0, 15));
      expect(tester.getSize(find.byKey(childKey)), const Size(40, 160));
    });

    testWidgets('shrinks fillToConstraint width to max and applies bias', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fillToConstraint,
            height: .fixed(30),
            maxWidth: .fixed(100),
            left: .toLeftOf(.parent, margin: 10),
            right: .toRightOf(.parent, margin: 20),
            horizontalBias: 0.25,
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(52.5, 0));
      expect(tester.getSize(find.byKey(childKey)), const Size(100, 30));
    });

    testWidgets('shrinks fillToConstraint height to max and applies bias', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fillToConstraint,
            maxHeight: .fixed(80),
            top: .toTopOf(.parent, margin: 15),
            bottom: .toBottomOf(.parent, margin: 25),
            verticalBias: 0.75,
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(0, 75));
      expect(tester.getSize(find.byKey(childKey)), const Size(40, 80));
    });

    testWidgets('throws when fillToConstraint min exceeds available space', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fillToConstraint,
            height: .fixed(30),
            minWidth: .fixed(280),
            left: .toLeftOf(.parent, margin: 10),
            right: .toRightOf(.parent, margin: 20),
            child: const SizedBox(),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('applies min constraints when they do not conflict', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(60),
            height: .fixed(40),
            minWidth: .fixed(50),
            minHeight: .fixed(30),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(60, 40));
    });

    testWidgets('applies max constraints when they do not conflict', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(60),
            height: .fixed(40),
            maxWidth: .fixed(70),
            maxHeight: .fixed(50),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(60, 40));
    });

    testWidgets('throws when fixed dimensions conflict with min or max', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(60),
            height: .fixed(40),
            maxWidth: .fixed(50),
            child: const SizedBox(),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('combines percent dimensions with non-conflicting limits', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .percent(0.5),
            height: .percent(0.5),
            minWidth: .fixed(100),
            maxHeight: .fixed(120),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(tester.getSize(find.byKey(childKey)), const Size(150, 100));
    });
  });

  group('parent anchors', () {
    testWidgets('anchors to parent left and top with margins', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(10, 20));
    });

    testWidgets('anchors to parent right and bottom with margins', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            right: .toRightOf(.parent, margin: 10),
            bottom: .toBottomOf(.parent, margin: 20),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(250, 150));
    });

    testWidgets('uses vertical bias between parent top and bottom', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(40),
            top: .toTopOf(.parent),
            bottom: .toBottomOf(.parent),
            verticalBias: 0.25,
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(0, 40));
    });
  });

  group('sibling anchors', () {
    testWidgets('connects left to another child right', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: SizedBox(key: firstKey),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(50),
            height: .fixed(30),
            left: .toRightOf(.of('first'), margin: 8),
            top: .toTopOf(.of('first')),
            child: SizedBox(key: secondKey),
          ),
        ],
      );

      expect(_offsetOf(tester, firstKey), const Offset(10, 20));
      expect(_offsetOf(tester, secondKey), const Offset(58, 20));
    });

    testWidgets('connects right to another child left', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 80),
            top: .toTopOf(.parent, margin: 20),
            child: SizedBox(key: firstKey),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(50),
            height: .fixed(30),
            right: .toLeftOf(.of('first'), margin: 8),
            top: .toTopOf(.of('first')),
            child: SizedBox(key: secondKey),
          ),
        ],
      );

      expect(_offsetOf(tester, firstKey), const Offset(80, 20));
      expect(_offsetOf(tester, secondKey), const Offset(22, 20));
    });

    testWidgets('connects top to another child bottom', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: SizedBox(key: firstKey),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(40),
            height: .fixed(50),
            left: .toLeftOf(.of('first')),
            top: .toBottomOf(.of('first'), margin: 8),
            child: SizedBox(key: secondKey),
          ),
        ],
      );

      expect(_offsetOf(tester, secondKey), const Offset(10, 58));
    });

    testWidgets('connects bottom to another child top', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 80),
            child: SizedBox(key: firstKey),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(40),
            height: .fixed(50),
            left: .toLeftOf(.of('first')),
            bottom: .toTopOf(.of('first'), margin: 8),
            child: SizedBox(key: secondKey),
          ),
        ],
      );

      expect(_offsetOf(tester, secondKey), const Offset(10, 22));
    });

    testWidgets('solves multi-level dependencies in any declaration order', (
      tester,
    ) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();
      final thirdKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('third'),
            width: .fixed(20),
            height: .fixed(20),
            left: .toRightOf(.of('second'), margin: 5),
            top: .toTopOf(.of('second')),
            child: SizedBox(key: thirdKey),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(30),
            height: .fixed(20),
            left: .toRightOf(.of('first'), margin: 5),
            top: .toTopOf(.of('first')),
            child: SizedBox(key: secondKey),
          ),
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(20),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 15),
            child: SizedBox(key: firstKey),
          ),
        ],
      );

      expect(_offsetOf(tester, firstKey), const Offset(10, 15));
      expect(_offsetOf(tester, secondKey), const Offset(55, 15));
      expect(_offsetOf(tester, thirdKey), const Offset(90, 15));
    });
  });

  group('start and end anchors', () {
    testWidgets('resolves start and end in LTR', (tester) async {
      final startKey = GlobalKey();
      final endKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        textDirection: TextDirection.ltr,
        children: [
          Constraint(
            ref: .of('start'),
            width: .fixed(40),
            height: .fixed(20),
            start: .toStartOf(.parent, margin: 10),
            child: SizedBox(key: startKey),
          ),
          Constraint(
            ref: .of('end'),
            width: .fixed(40),
            height: .fixed(20),
            end: .toEndOf(.parent, margin: 10),
            child: SizedBox(key: endKey),
          ),
        ],
      );

      expect(_offsetOf(tester, startKey), const Offset(10, 0));
      expect(_offsetOf(tester, endKey), const Offset(250, 0));
    });

    testWidgets('resolves start and end in RTL', (tester) async {
      final startKey = GlobalKey();
      final endKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        textDirection: TextDirection.rtl,
        children: [
          Constraint(
            ref: .of('start'),
            width: .fixed(40),
            height: .fixed(20),
            start: .toStartOf(.parent, margin: 10),
            child: SizedBox(key: startKey),
          ),
          Constraint(
            ref: .of('end'),
            width: .fixed(40),
            height: .fixed(20),
            end: .toEndOf(.parent, margin: 10),
            child: SizedBox(key: endKey),
          ),
        ],
      );

      expect(_offsetOf(tester, startKey), const Offset(250, 0));
      expect(_offsetOf(tester, endKey), const Offset(10, 0));
    });

    testWidgets('gives explicit left priority over start', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(20),
            left: .toLeftOf(.parent, margin: 30),
            start: .toStartOf(.parent, margin: 10),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(30, 0));
    });
  });

  group('bias', () {
    testWidgets('supports horizontal bias values', (tester) async {
      final leftKey = GlobalKey();
      final centerKey = GlobalKey();
      final rightKey = GlobalKey();
      final quarterKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          _biasedChild('left', leftKey, 0),
          _biasedChild('center', centerKey, 0.5),
          _biasedChild('right', rightKey, 1),
          _biasedChild('quarter', quarterKey, 0.25),
        ],
      );

      expect(_offsetOf(tester, leftKey).dx, 0);
      expect(_offsetOf(tester, centerKey).dx, 125);
      expect(_offsetOf(tester, rightKey).dx, 250);
      expect(_offsetOf(tester, quarterKey).dx, 62.5);
    });

    testWidgets('clamps horizontal bias outside zero to one', (tester) async {
      final negativeKey = GlobalKey();
      final aboveOneKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          _biasedChild('negative', negativeKey, -1),
          _biasedChild('aboveOne', aboveOneKey, 2),
        ],
      );

      expect(_offsetOf(tester, negativeKey).dx, 0);
      expect(_offsetOf(tester, aboveOneKey).dx, 250);
    });

    testWidgets('supports vertical bias values', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(50),
            height: .fixed(40),
            top: .toTopOf(.parent),
            bottom: .toBottomOf(.parent),
            verticalBias: 0.75,
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(0, 120));
    });
  });

  group('baseline', () {
    testWidgets('aligns child baselines', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            top: .toTopOf(.parent, margin: 40),
            left: .toLeftOf(.parent),
            child: _BaselineBox(
              key: firstKey,
              size: const Size(40, 30),
              baseline: 20,
            ),
          ),
          Constraint(
            ref: .of('second'),
            baseline: .toBaselineOf(.of('first')),
            left: .toRightOf(.of('first'), margin: 8),
            child: _BaselineBox(
              key: secondKey,
              size: const Size(50, 20),
              baseline: 8,
            ),
          ),
        ],
      );

      expect(_offsetOf(tester, firstKey), const Offset(0, 40));
      expect(_offsetOf(tester, secondKey), const Offset(48, 52));
      expect(
        _baselineY(tester, firstKey, 20),
        _baselineY(tester, secondKey, 8),
      );
    });

    testWidgets('applies baseline margin', (tester) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            top: .toTopOf(.parent, margin: 40),
            child: _BaselineBox(
              key: firstKey,
              size: const Size(40, 30),
              baseline: 20,
            ),
          ),
          Constraint(
            ref: .of('second'),
            baseline: .toBaselineOf(.of('first'), margin: 6),
            left: .toRightOf(.of('first'), margin: 8),
            child: _BaselineBox(
              key: secondKey,
              size: const Size(50, 20),
              baseline: 8,
            ),
          ),
        ],
      );

      expect(_offsetOf(tester, secondKey), const Offset(48, 58));
      expect(
        _baselineY(tester, secondKey, 8),
        _baselineY(tester, firstKey, 20) + 6,
      );
    });

    testWidgets(
      'treats target children without a baseline as baseline at top',
      (tester) async {
        final firstKey = GlobalKey();
        final secondKey = GlobalKey();

        await _pumpConstraintLayout(
          tester,
          children: [
            Constraint(
              ref: .of('first'),
              width: .fixed(30),
              height: .fixed(30),
              top: .toTopOf(.parent, margin: 40),
              child: _BaselineBox(key: firstKey, size: const Size(30, 30)),
            ),
            Constraint(
              ref: .of('second'),
              baseline: .toBaselineOf(.of('first')),
              child: _BaselineBox(
                key: secondKey,
                size: const Size(30, 30),
                baseline: 10,
              ),
            ),
          ],
        );

        expect(_offsetOf(tester, secondKey).dy, 30);
        expect(
          _baselineY(tester, secondKey, 10),
          _offsetOf(tester, firstKey).dy,
        );
      },
    );

    testWidgets(
      'treats current children without a baseline as baseline at top',
      (tester) async {
        final firstKey = GlobalKey();
        final secondKey = GlobalKey();

        await _pumpConstraintLayout(
          tester,
          children: [
            Constraint(
              ref: .of('first'),
              top: .toTopOf(.parent, margin: 40),
              child: _BaselineBox(
                key: firstKey,
                size: const Size(30, 30),
                baseline: 20,
              ),
            ),
            Constraint(
              ref: .of('second'),
              baseline: .toBaselineOf(.of('first')),
              child: _BaselineBox(key: secondKey, size: const Size(30, 30)),
            ),
          ],
        );

        expect(_offsetOf(tester, secondKey).dy, 60);
        expect(
          _offsetOf(tester, secondKey).dy,
          _baselineY(tester, firstKey, 20),
        );
      },
    );

    testWidgets('allows consistent baseline and top constraints', (
      tester,
    ) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            top: .toTopOf(.parent, margin: 40),
            child: _BaselineBox(
              key: firstKey,
              size: const Size(30, 30),
              baseline: 20,
            ),
          ),
          Constraint(
            ref: .of('second'),
            top: .toTopOf(.parent, margin: 52),
            baseline: .toBaselineOf(.of('first')),
            child: _BaselineBox(
              key: secondKey,
              size: const Size(30, 30),
              baseline: 8,
            ),
          ),
        ],
      );

      expect(_offsetOf(tester, secondKey).dy, 52);
      expect(
        _baselineY(tester, firstKey, 20),
        _baselineY(tester, secondKey, 8),
      );
    });

    testWidgets('throws when baseline and top constraints conflict', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            top: .toTopOf(.parent, margin: 40),
            child: const _BaselineBox(size: Size(30, 30), baseline: 20),
          ),
          Constraint(
            ref: .of('second'),
            top: .toTopOf(.parent, margin: 50),
            baseline: .toBaselineOf(.of('first')),
            child: const _BaselineBox(size: Size(30, 30), baseline: 8),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });

  group('margin', () {
    testWidgets('applies positive margins on parent and sibling anchors', (
      tester,
    ) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: SizedBox(key: firstKey),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toRightOf(.of('first'), margin: 12),
            top: .toBottomOf(.of('first'), margin: 6),
            child: SizedBox(key: secondKey),
          ),
        ],
      );

      expect(_offsetOf(tester, secondKey), const Offset(62, 56));
    });

    testWidgets('allows negative margins', (tester) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: -5),
            top: .toTopOf(.parent, margin: -7),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(-5, -7));
    });
  });

  group('composed layouts', () {
    testWidgets('lays out a small product card shape', (tester) async {
      final imageKey = GlobalKey();
      final titleKey = GlobalKey();
      final priceKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('image'),
            width: .fixed(80),
            height: .fixed(80),
            left: .toLeftOf(.parent, margin: 12),
            top: .toTopOf(.parent, margin: 12),
            child: SizedBox(key: imageKey),
          ),
          Constraint(
            ref: .of('title'),
            width: .fillToConstraint,
            height: .fixed(24),
            left: .toRightOf(.of('image'), margin: 10),
            right: .toRightOf(.parent, margin: 12),
            top: .toTopOf(.of('image')),
            child: SizedBox(key: titleKey),
          ),
          Constraint(
            ref: .of('price'),
            width: .fixed(70),
            height: .fixed(20),
            left: .toLeftOf(.of('title')),
            top: .toBottomOf(.of('title'), margin: 8),
            child: SizedBox(key: priceKey),
          ),
        ],
      );

      expect(_offsetOf(tester, imageKey), const Offset(12, 12));
      expect(_offsetOf(tester, titleKey), const Offset(102, 12));
      expect(tester.getSize(find.byKey(titleKey)), const Size(186, 24));
      expect(_offsetOf(tester, priceKey), const Offset(102, 44));
    });

    testWidgets('keeps results stable when children order changes', (
      tester,
    ) async {
      final firstKey = GlobalKey();
      final secondKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('second'),
            width: .fixed(30),
            height: .fixed(30),
            left: .toRightOf(.of('first'), margin: 8),
            child: SizedBox(key: secondKey),
          ),
          Constraint(
            ref: .of('first'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            child: SizedBox(key: firstKey),
          ),
        ],
      );

      expect(_offsetOf(tester, firstKey), const Offset(10, 0));
      expect(_offsetOf(tester, secondKey), const Offset(58, 0));
    });
  });

  group('render lifecycle', () {
    testWidgets('computes dry layout from the supplied constraints', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        canvasSize: const Size(320, 180),
        children: [
          Constraint(
            ref: .of('child'),
            child: const SizedBox(width: 70, height: 45),
          ),
        ],
      );

      final renderObject = _layoutRenderObject(tester);

      expect(
        renderObject.getDryLayout(BoxConstraints.tight(const Size(320, 180))),
        const Size(320, 180),
      );
      expect(
        renderObject.getDryLayout(const BoxConstraints(maxHeight: 180)),
        const Size(70, 180),
      );
    });

    testWidgets('computes intrinsic size from constrained children', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('first'),
            child: const SizedBox(width: 70, height: 45),
          ),
          Constraint(
            ref: .of('second'),
            width: .fixed(90),
            height: .fixed(30),
            child: const SizedBox(width: 20, height: 20),
          ),
        ],
      );

      final renderObject = _layoutRenderObject(tester);

      expect(renderObject.getMaxIntrinsicWidth(double.infinity), 90);
      expect(renderObject.getMaxIntrinsicHeight(double.infinity), 45);
    });

    testWidgets('hit tests positioned children', (tester) async {
      var tapped = false;
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: GestureDetector(
              key: childKey,
              behavior: HitTestBehavior.opaque,
              onTap: () => tapped = true,
              child: const SizedBox.expand(),
            ),
          ),
        ],
      );

      await tester.tap(find.byKey(childKey));

      expect(tapped, isTrue);
    });

    testWidgets('paints positioned children', (tester) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: const _PaintBox(),
          ),
        ],
      );

      expect(
        _layoutFinder,
        paints..rect(rect: const Rect.fromLTWH(10, 20, 40, 30)),
      );
    });

    testWidgets('applies child paint transform from parent data offset', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            left: .toLeftOf(.parent, margin: 10),
            top: .toTopOf(.parent, margin: 20),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      final childBox = tester.renderObject<RenderBox>(find.byKey(childKey));

      expect(
        childBox.localToGlobal(Offset.zero) - tester.getTopLeft(_layoutFinder),
        const Offset(10, 20),
      );
    });
  });

  group('errors and conflicts', () {
    testWidgets('throws on required constraint conflicts', (tester) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fixed(40),
            height: .fixed(30),
            maxWidth: .fixed(30),
            child: const SizedBox(),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('single-sided fillToConstraint collapses to zero size', (
      tester,
    ) async {
      final childKey = GlobalKey();

      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fillToConstraint,
            height: .fixed(20),
            left: .toLeftOf(.parent, margin: 10),
            child: SizedBox(key: childKey),
          ),
        ],
      );

      expect(_offsetOf(tester, childKey), const Offset(10, 0));
      expect(tester.getSize(find.byKey(childKey)), const Size(0, 20));
    });

    testWidgets('throws when fillToConstraint would require negative size', (
      tester,
    ) async {
      await _pumpConstraintLayout(
        tester,
        children: [
          Constraint(
            ref: .of('child'),
            width: .fillToConstraint,
            height: .fixed(20),
            left: .toRightOf(.parent, margin: 10),
            right: .toLeftOf(.parent, margin: 10),
            child: const SizedBox(),
          ),
        ],
      );

      expect(tester.takeException(), isA<FlutterError>());
    });
  });
}

Constraint _biasedChild(String ref, Key key, double bias) {
  return Constraint(
    ref: .of(ref),
    width: .fixed(50),
    height: .fixed(20),
    left: .toLeftOf(.parent),
    right: .toRightOf(.parent),
    horizontalBias: bias,
    child: SizedBox(key: key),
  );
}

Future<void> _pumpConstraintLayout(
  WidgetTester tester, {
  Size canvasSize = _defaultCanvasSize,
  TextDirection textDirection = TextDirection.ltr,
  required List<Widget> children,
}) {
  return _pumpRawWidget(
    tester,
    Directionality(
      textDirection: textDirection,
      child: ConstraintLayout(children: children),
    ),
    canvasSize: canvasSize,
  );
}

Future<void> _pumpRawConstraintLayout(
  WidgetTester tester, {
  Size canvasSize = _defaultCanvasSize,
  required List<Widget> children,
}) {
  return _pumpRawWidget(
    tester,
    ConstraintLayout(children: children),
    canvasSize: canvasSize,
  );
}

Future<void> _pumpRawWidget(
  WidgetTester tester,
  Widget widget, {
  Size canvasSize = _defaultCanvasSize,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = canvasSize;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(widget);
}

Size _layoutSize(WidgetTester tester) {
  return tester.getSize(_layoutFinder);
}

RenderConstraintLayout _layoutRenderObject(WidgetTester tester) {
  return tester.renderObject<RenderConstraintLayout>(_layoutFinder);
}

Offset _offsetOf(WidgetTester tester, Key key) {
  return tester.getTopLeft(find.byKey(key)) - tester.getTopLeft(_layoutFinder);
}

double _baselineY(WidgetTester tester, Key key, double baseline) {
  return _offsetOf(tester, key).dy + baseline;
}

const _defaultCanvasSize = Size(300, 200);

final _layoutFinder = find.byType(ConstraintLayout);

class _BaselineBox extends LeafRenderObjectWidget {
  const _BaselineBox({super.key, required this.size, this.baseline});

  final Size size;
  final double? baseline;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderBaselineBox(size, baseline);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderBaselineBox renderObject,
  ) {
    renderObject
      ..preferredSize = size
      ..baseline = baseline;
  }
}

class _RenderBaselineBox extends RenderBox {
  _RenderBaselineBox(this._preferredSize, this._baseline);

  Size get preferredSize => _preferredSize;
  Size _preferredSize;

  set preferredSize(Size value) {
    if (_preferredSize == value) {
      return;
    }
    _preferredSize = value;
    markNeedsLayout();
  }

  double? get baseline => _baseline;
  double? _baseline;

  set baseline(double? value) {
    if (_baseline == value) {
      return;
    }
    _baseline = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    size = constraints.constrain(preferredSize);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return _baseline;
  }
}

class _PaintBox extends LeafRenderObjectWidget {
  const _PaintBox();

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderPaintBox();
  }
}

class _RenderPaintBox extends RenderBox {
  @override
  void performLayout() {
    size = constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size, Paint());
  }
}
