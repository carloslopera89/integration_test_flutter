import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:integration_test_flutter/src/auth_helpers_integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 1. Usa group() para agrupar los tests de una misma funcionalidad (Feature).
  group('Feature: Autenticación de Usuario', () {
    testWidgets('Scenario: Inicio de sesión con credenciales válidas',
        (WidgetTester tester) async {
      print('ESCENARIO: Login Exitoso');

      ///Arrange
      const email = 'carlitos@mail.com';
      const password = 'carlitos1';

      ///Act
      await launchApp(tester);
      await loginUser(tester, username: email, password: password);

      /// Assert
      expect(find.byKey(const Key('lbBienvenido')), findsOneWidget);
    });

    testWidgets('Scenario: Falla el inicio de sesión con contraseña incorrecta',
        (WidgetTester tester) async {
      ///Arrange
      const email = 'carlitos@mail.com';
      const password = 'integration-123';
      const messageExpect = 'contraseña no es correcto';

      ///Act
      print('ESCENARIO: Contraseña Incorrecta');
      await launchApp(tester);
      await loginUser(tester, username: email, password: password);

      ///Assert
      expect(find.textContaining(messageExpect), findsOneWidget);
    });

    testWidgets('Scenario: Falla el inicio de sesión con email incorrecto',
        (WidgetTester tester) async {
      ///Arrange
      const email = 'integration_test';
      const password = '123456';
      const messageExpect = 'correo no es correcto';

      ///Act
      print('ESCENARIO: Usuario Inexistente');
      await launchApp(tester);
      await loginUser(tester, username: email, password: password);

      ///Assert
      expect(find.textContaining(messageExpect), findsOneWidget);
      await tester.pumpAndSettle();
    });
  }); // Fin del grupo de autenticación
}
