// Archivo: generate_report.dart (Versión Final con Grupos Desplegables)
import 'dart:convert';
import 'dart:io';

void main() async {
  final inputFile = File('lib/src/report/test-results.json');
  final outputFile = File('lib/src/report/report.html');

  if (!await inputFile.exists()) {
    print('Error: El archivo de resultados build/test-results.json no existe.');
    return;
  }

  final Map<int, Map<String, dynamic>> testResults = {};

  // ... (El código para leer el JSON no cambia)
  final lines = inputFile.readAsLinesSync();
  for (var line in lines) {
    try {
      final json = jsonDecode(line);
      if (json['type'] == 'testStart' && json['test']['name'] != null) {
        final test = json['test'];
        final String fullTestName = (test['name'] as String).replaceAll('loading', '').trim();
        if (fullTestName.contains('Feature')) {
          final int testId = test['id'];
          String groupName = 'General';
          String scenarioName = fullTestName;
          if (fullTestName.contains('Scenario:')) {
            final parts = fullTestName.split('Scenario:');
            groupName = parts[0].trim();
            scenarioName = parts[1].trim();
          }
          testResults[testId] = {
            'groupName': groupName, 'scenarioName': scenarioName, 'success': false, 'error': 'El test no finalizó correctamente.', 'stackTrace': '', 'startTime': json['time'] as int, 'duration': 0,
          };
        }
      } else if (json['type'] == 'error') {
        final int testId = json['testID'];
        if (testResults.containsKey(testId)) {
          testResults[testId]!['error'] = json['error'] ?? 'Fallo sin mensaje.';
          testResults[testId]!['stackTrace'] = json['stackTrace'] ?? '';
        }
      } else if (json['type'] == 'testDone' && json['hidden'] != true) {
        final int testId = json['testID'];
        if (testResults.containsKey(testId)) {
          testResults[testId]!['success'] = json['result'] == 'success';
          final int endTime = json['time'] as int;
          final int startTime = testResults[testId]!['startTime'] as int;
          testResults[testId]!['duration'] = endTime - startTime;
        }
      }
    } catch (e) {}
  }

  // --- 1. NUEVO: Agrupamos los tests por el nombre del grupo (Feature) ---
  final Map<String, List<Map<String, dynamic>>> groupedResults = {};
  for (var test in testResults.values) {
    final groupName = test['groupName'] as String;
    if (!groupedResults.containsKey(groupName)) {
      groupedResults[groupName] = [];
    }
    groupedResults[groupName]!.add(test);
  }
  // --------------------------------------------------------------------

  final testCount = testResults.length;
  final failureCount = testResults.values.where((test) => !test['success']).length;

  final htmlContent = '''
  <!DOCTYPE html>
  <html>
  <head>
    <title>Reporte de Pruebas de Integración</title>
    <meta charset="UTF-8">
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; line-height: 1.6; padding: 20px; color: #24292e; }
      table { border-collapse: collapse; width: 100%; margin: 20px 0; }
      th, td { border: 1px solid #dfe2e5; text-align: left; padding: 12px; }
      th { background-color: #f6f8fa; }
      .summary { display: flex; gap: 20px; margin-bottom: 20px; }
      .summary-box { padding: 15px; border-radius: 6px; text-align: center; }
      .summary-box h2 { margin: 0; font-size: 2em; }
      .summary-box p { margin: 0; }
      .total { background-color: #f1f8ff; border: 1px solid #c8e1ff; }
      .failures { background-color: #ffeef0; border: 1px solid #ffdce0; }
      .success { color: #28a745; font-weight: bold; }
      .failure { color: #cb2431; font-weight: bold; }
      h1 { border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; }
      pre { background-color: #f6f8fa; padding: 16px; overflow-x: auto; border-radius: 6px; white-space: pre-wrap; word-wrap: break-word; }
      /* --- 2. NUEVO: Estilos para el grupo desplegable --- */
      .group-header { cursor: pointer; background-color: #f6f8fa; font-weight: bold; }
      .group-header:hover { background-color: #f1f8ff; }
      .arrow { display: inline-block; transition: transform 0.2s; }
      .arrow.open { transform: rotate(90deg); }
      .scenario-row { display: none; } /* Ocultos por defecto */
    </style>
  </head>
  <body>
    <h1>Reporte de Pruebas de Integración Lulo</h1>
    <div class="summary">
      <div class="summary-box total"><h2>$testCount</h2><p>Tests Totales</p></div>
      <div class="summary-box failures"><h2>$failureCount</h2><p>Fallos</p></div>
    </div>
    <table>
      <thead>
        <tr>
          <th>Grupo (Feature)</th>
          <th>Escenario</th>
          <th>Duración</th>
          <th>Resultado</th>
        </tr>
      </thead>
      <tbody>
        ${groupedResults.entries.map((entry) {
    final groupName = entry.key;
    final scenarios = entry.value;
    final groupId = groupName.hashCode; // ID único para el grupo

    final groupHeader = '''
            <tr class="group-header" onclick="toggleGroup('$groupId')">
              <td colspan="4">
                <span id="arrow-$groupId" class="arrow">▶</span> ${groupName} (${scenarios.length} escenarios)
              </td>
            </tr>
          ''';

    final scenarioRows = scenarios.map((test) => '''
            <tr class="scenario-row group-$groupId">
              <td></td> <td>${test['scenarioName']}</td>
              <td>${(test['duration'] / 1000).toStringAsFixed(2)} s</td>
              <td class="${test['success'] ? 'success' : 'failure'}">
                ${test['success'] ? 'EXITOSO' : 'FALLIDO'}
                ${!test['success'] ? '<pre>${test['error'].replaceAll('<', '&lt;').replaceAll('>', '&gt;')}\\n\\n${test['stackTrace'].replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</pre>' : ''}
              </td>
            </tr>
          ''').join('');

    return groupHeader + scenarioRows;
  }).join('')}
      </tbody>
    </table>

    <script>
      function toggleGroup(groupId) {
        const rows = document.querySelectorAll('.scenario-row.group-' + groupId);
        const arrow = document.getElementById('arrow-' + groupId);
        arrow.classList.toggle('open');
        for (const row of rows) {
          row.style.display = row.style.display === 'none' ? 'table-row' : 'none';
        }
      }
    </script>
  </body>
  </html>
  ''';

  await outputFile.writeAsString(htmlContent);
  print('✅ Reporte generado exitosamente en: ${outputFile.path}');
}