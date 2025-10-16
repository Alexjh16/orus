// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orus/main.dart';
import 'package:orus/calculator/calculator_view.dart';
import 'package:orus/weather/weather_service.dart';
import 'package:orus/weather/weather_view.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    print('TEST: Verificando carga correcta de la aplicación');
    print('- Iniciando aplicación OrusApp...');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const OrusApp());

    print('- Esperando que las animaciones se completen...');
    // Wait for animations to complete
    await tester.pumpAndSettle();

    print('- Verificando texto esperado: "Rápido Y Fluido"');
    // Verify that the app loads with the home screen showing the first page
    expect(find.text('Rápido Y Fluido'), findsOneWidget);

    print('- Verificando texto esperado: "Una aplicación para el climita"');
    expect(
        find.textContaining('Una aplicación para el climita'), findsOneWidget);

    print('- Verificando componente PageView existe');
    // Verify navigation elements exist
    expect(find.byType(PageView), findsOneWidget);

    print('- RESULTADO: EXITOSO - La aplicación se carga correctamente');
  });

  testWidgets('Calculator performs basic addition correctly',
      (WidgetTester tester) async {
    print('TEST: Probando operación de suma en calculadora');
    print('- Valores de prueba: 15 + 25');
    print('- Resultado esperado: 40');

    // Build our app and navigate to calculator
    await tester.pumpWidget(const OrusApp());
    await tester.pumpAndSettle();

    print('- Navegando al menú drawer...');
    // Navigate to calculator by tapping drawer menu
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    print('- Seleccionando opción Calculadora...');
    // Tap on calculator option
    await tester.tap(find.text('Calculadora'));
    await tester.pumpAndSettle();

    print('- Verificando que estamos en la página de calculadora...');
    // Verify we're on calculator page
    expect(find.text('Realiza operaciones matemáticas básicas y avanzadas'),
        findsOneWidget);

    print('- Ingresando primer número: 15');
    // Enter first number
    await tester.enterText(find.byType(TextField).first, '15');
    await tester.pumpAndSettle();

    print('- Ingresando segundo número: 25');
    // Enter second number
    await tester.enterText(find.byType(TextField).last, '25');
    await tester.pumpAndSettle();

    print('- Presionando botón Sumar...');
    // Tap the sum button
    await tester.tap(find.text('Sumar'));
    await tester.pumpAndSettle();

    // Wait for animation to complete
    await tester.pump(const Duration(milliseconds: 500));

    print('- Verificando resultado mostrado: debe contener "40"');
    // Verify result is shown (40.0)
    expect(find.textContaining('40'), findsOneWidget);

    print('- RESULTADO: EXITOSO - Suma calculada correctamente (15 + 25 = 40)');
  });

  testWidgets('Calculator widget loads correctly', (WidgetTester tester) async {
    print('TEST: Verificando carga de elementos UI de calculadora');
    print('- Elementos esperados: título, descripción, campos, botones');

    // Test the calculator widget directly
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CalculatorView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    print('- Verificando título: "Calculadora"');
    // Verify calculator elements are present
    expect(find.text('Calculadora'), findsOneWidget);

    print('- Verificando descripción de la calculadora');
    expect(find.text('Realiza operaciones matemáticas básicas y avanzadas'),
        findsOneWidget);

    print('- Verificando labels de campos: "Primer número", "Segundo número"');
    expect(find.text('Primer número'), findsOneWidget);
    expect(find.text('Segundo número'), findsOneWidget);

    print(
        '- Verificando botones de operaciones: Sumar, Restar, Multiplicar, Dividir');
    // Verify operation buttons exist
    expect(find.text('Sumar'), findsOneWidget);
    expect(find.text('Restar'), findsOneWidget);
    expect(find.text('Multiplicar'), findsOneWidget);
    expect(find.text('Dividir'), findsOneWidget);

    print('- Verificando botón de limpiar: "Limpiar Todo"');
    // Verify clear button exists
    expect(find.text('Limpiar Todo'), findsOneWidget);

    print('- RESULTADO: EXITOSO - Todos los elementos UI están presentes');
  });

  testWidgets('Calculator shows all required elements',
      (WidgetTester tester) async {
    print('TEST: Verificando estructura de widgets de calculadora');
    print('- Elementos a verificar: widgets base, campos de texto, botones');

    // Test calculator widget elements without interactions
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CalculatorView(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    print('- Verificando elementos básicos de texto');
    // Verify all basic elements exist
    expect(find.text('Calculadora'), findsOneWidget);
    expect(find.text('Realiza operaciones matemáticas básicas y avanzadas'),
        findsOneWidget);
    expect(find.text('Primer número'), findsOneWidget);
    expect(find.text('Segundo número'), findsOneWidget);

    print('- Verificando cantidad de TextFields: esperados 2');
    expect(find.byType(TextField), findsNWidgets(2));

    print('- Verificando botones de operaciones visibles: Sumar, Restar');
    // Verify at least the visible operation buttons exist
    expect(find.text('Sumar'), findsOneWidget);
    expect(find.text('Restar'), findsOneWidget);

    print('- Verificando estructura de widgets: Container, ElevatedButton');
    // Verify the widget structure is correct
    expect(find.byType(Container), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);

    print('- RESULTADO: EXITOSO - Estructura de widgets correcta');
  });

  testWidgets('Weather service can be created and configured',
      (WidgetTester tester) async {
    print('TEST: Probando configuración de WeatherService');
    print('- Estados a probar: inicial, simulado, real');

    // Test weather service initialization
    final weatherService = WeatherService();

    print('- Verificando estado inicial: datos reales (false)');
    // Verify initial state
    expect(weatherService.isUsingSimulatedData, false);

    print('- Cambiando a modo simulado: toggleDataMode(true)');
    // Test toggle to simulated data
    weatherService.toggleDataMode(true);
    expect(weatherService.isUsingSimulatedData, true);

    print('- Regresando a modo real: toggleDataMode(false)');
    // Test toggle back to real data
    weatherService.toggleDataMode(false);
    expect(weatherService.isUsingSimulatedData, false);

    print(
        '- RESULTADO: EXITOSO - Configuración de servicio funciona correctamente');
  });

  testWidgets('Weather service returns simulated data when configured',
      (WidgetTester tester) async {
    print('TEST: Probando datos simulados del WeatherService');
    print('- Ciudad de prueba: Madrid');
    print(
        '- Campos a verificar: cityName, temperature, description, humidity, windSpeed, visibility');

    // Test weather service with simulated data
    final weatherService = WeatherService();

    print('- Configurando servicio para usar datos simulados');
    weatherService.toggleDataMode(true); // Enable simulated data

    print('- Solicitando clima para: Madrid');
    // Test getting weather for a city
    final weather = await weatherService.getCurrentWeather('Madrid');

    print('- Verificando campo cityName: debe contener "Madrid"');
    // Verify we get a weather model back
    expect(weather.cityName, contains('Madrid'));

    print(
        '- Verificando tipos de datos: temperature, description, humidity, windSpeed, visibility');
    expect(weather.temperature, isA<double>());
    expect(weather.description, isA<String>());
    expect(weather.humidity, isA<double>());
    expect(weather.windSpeed, isA<double>());
    expect(weather.visibility, isA<int>());

    print('- Verificando rango de temperatura: entre -10°C y 45°C');
    // Verify temperature is in a reasonable range for simulated data
    expect(weather.temperature, greaterThanOrEqualTo(-10));
    expect(weather.temperature, lessThanOrEqualTo(45));

    print('- RESULTADO: EXITOSO - Datos simulados devueltos correctamente');
    print('  * Ciudad: ${weather.cityName}');
    print('  * Temperatura: ${weather.temperature}°C');
    print('  * Descripción: ${weather.description}');
  });
}
