# 🧪 Ejecutar Pruebas de Integración en Flutter

Antes de ejecutar las pruebas, asegúrate de tener **Flutter instalado y configurado correctamente**.

---

## 📱 Android

Para ejecutar las pruebas de integración en un dispositivo o emulador Android, utiliza el siguiente comando:

```bash
flutter test integration_test/autenticacion/autentication_integration_test.dart --machine -r json > lib/src/report/test-results.json -d <Device_id>
```

> 🔁 **Nota:** Reemplaza `<Device_id>` con el nombre o ID del dispositivo (puedes obtenerlo con `flutter devices`).  
> Si tienes un solo dispositivo conectado, puedes omitir `-d`.

### 📌 Ejemplo:

```bash
flutter test integration_test/autenticacion/autentication_integration_test.dart --machine -r json > lib/src/report/test-results.json -d emulator-5554
```

---

## 🍏 iOS

Para ejecutar las pruebas de integración en un simulador o dispositivo iOS:

```bash
flutter test integration_test/autenticacion/autentication_integration_test.dart --machine -r json > lib/src/report/test-results.json -d <DEVICE_ID>
```

> 🔁 **Nota:** Reemplaza `<DEVICE_ID>` con el nombre o ID del simulador (puedes obtenerlo con `flutter devices`).

### 📌 Ejemplo:

```bash
flutter test integration_test/autenticacion/autentication_integration_test.dart --machine -r json > lib/src/report/test-results.json -d "iPhone 15 Pro"
```

---

## 🌐 Pruebas en un Navegador Web

### 1. Instalar y Configurar ChromeDriver

Primero, instala ChromeDriver:

```bash
npx @puppeteer/browsers install chromedriver@stable
```

Luego, añade la ruta de ChromeDriver a tu variable de entorno `$PATH`.

La ubicación puede variar, pero generalmente estará en una de estas rutas:

- `~/.cache/puppeteer/chrome/`
- `node_modules/@puppeteer/browsers/.local-chromedriver/`

Verifica que ChromeDriver está disponible:

```bash
chromedriver --version
```

### ✅ Ejemplo de salida esperada:

```
ChromeDriver 124.0.6367.60 (8771130bd84f76d855ae42fbe02752b03e352f17-refs/branch-heads/6367@{#798})
```

---

### 2. Crear el Archivo del Driver de Integración

Desde la raíz del proyecto:

```bash
mkdir test_driver
touch test_driver/integration_test.dart
```

Luego, pega el siguiente contenido en `test_driver/integration_test.dart`:

```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

---

### 3. Iniciar ChromeDriver

En una terminal separada, ejecuta:

```bash
chromedriver --port=4444
```

> ⚠️ Mantén esta terminal abierta mientras ejecutas las pruebas web.

---

### 4. Ejecutar las Pruebas en el Navegador

Desde la raíz del proyecto:

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/autenticacion/autentication_integration_test.dart -d chrome
```

### 🧾 Ejemplo de salida esperada:

```
Resolving dependencies...
Got dependencies!
Launching integration_test/app_test.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...
Debug service listening on ws://127.0.0.1:51523/...

00:00 +0: end-to-end test tap on the floating action button, verify counter
00:01 +1: (tearDownAll)
00:01 +2: All tests passed!

All tests passed. Application finished.
```

---

### 5. Ejecutar Pruebas Headless en el Navegador

Para ejecutar estas pruebas sin que se abra una ventana del navegador (útil para CI/CD), usa el siguiente comando:

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/autenticacion/autentication_integration_test.dart -d web-server
```

---