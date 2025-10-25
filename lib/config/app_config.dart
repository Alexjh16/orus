// Configuración de la aplicación
class AppConfig {
  // API Keys
  static const String googleMapsApiKey = 'AIzaSyBMW8U1mXm15Mqw5t5B6pLSpyCFItD6UOg';

  // URLs del backend
  static const String localhostUrl = 'http://localhost:8000';
  static const String localNetworkUrl = 'http://192.168.92.178:8000';
  //ahora la api backend esta en https://expresate-backend-2024.fly.dev
  static const String productionUrl = 'https://expresate-backend-2024.fly.dev';

  // Configuración del mapa
  static const double defaultMapZoom = 16.0;
  static const double treasureSearchRadius = 5.0; // km

  // Límites de dificultad
  static const int minDifficulty = 1;
  static const int maxDifficulty = 5;

  // Puntos base por dificultad
  static const int basePointsPerDifficulty = 10;
}
