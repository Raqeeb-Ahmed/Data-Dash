import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_dash/main.dart';

void main() {
  testWidgets('App loads login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the login screen elements are present.
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(
      find.text('Welcome back. Login to view dashboard data.'),
      findsOneWidget,
    );
  });
}
