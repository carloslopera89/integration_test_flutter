import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_demo/src/main.dart' as app;


Future<void> loginUser(WidgetTester tester, {required String username, required String password}) async {
  await tester.enterText(find.byKey(const Key('txtCorreo')), username);
  await tester.enterText(find.byKey(const Key('txtPassword')), password);
  await tester.tap(find.byKey(const Key('btnContinuar')));
  await tester.pumpAndSettle();
}

// Launch para integration test WEB
Future<void> launchApp(WidgetTester tester) async {
  app.main();
  await tester.pumpAndSettle();
}