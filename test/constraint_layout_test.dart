import 'package:constraint_layout/constraint_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('api design', (tester) async {
    tester.pumpWidget(
      ConstraintLayout(
        children: [
          Constraint(
            ref: .of('red'),
            child: Container(width: 100, height: 100, color: Colors.red),
          ),
          Constraint(
            ref: .of('green'),
            child: Container(width: 100, height: 100, color: Colors.green),
          ),
          Constraint(
            ref: .of('blue'),
            child: Container(width: 100, height: 100, color: Colors.blue),
          ),
        ],
      ),
    );
  });
}
