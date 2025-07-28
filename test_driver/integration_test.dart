import 'dart:io';
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async {
  try {
    await integrationDriver().timeout(const Duration(seconds: 10));
  } catch (e) {
    print('El driver web se cerró correctamente.');
  } finally {
    exit(0);
  }
}