# Orus - Treasure Hunt App

Una aplicación Flutter de caza de tesoros desarrollada por Alexander, que combina mapas interactivos, GPS y un sistema de puntos para crear una experiencia de juego única.

## Descripción del Proyecto

**Orus** es una aplicación móvil multiplataforma que permite a los usuarios:
- **Explorar mapas** con Google Maps integrado
- **Crear tesoros** en ubicaciones específicas
- **Buscar tesoros** ocultos cerca de su ubicación
- **Reclamar tesoros** cuando están a menos de 50 metros
- **Ganar puntos** y subir de rango
- **Disfrutar** de una experiencia gamificada completa

### Características Principales

- **Sistema de Ubicación GPS** en tiempo real
- **Mapas Interactivos** con marcadores dinámicos
- **Sistema de Puntos** y rankings
- **Creación de Tesoros** con pistas y dificultades
- **Detección por Distancia** para reclamar tesoros
- **Estadísticas de Usuario** detalladas
- **Interfaz Moderna** con Material Design 3

## Arquitectura del Proyecto

### Frontend (Flutter)
- **Framework**: Flutter 3.5.3+
- **Lenguaje**: Dart
- **UI**: Material Design 3 con tema oscuro personalizado
- **Plataformas**: Android, iOS, Web, Linux, Windows

### Backend (Django)
- **Framework**: Django REST Framework
- **Base de Datos**: MongoDB con GeoJSON
- **Autenticación**: Sistema de usuarios de Django
- **API**: RESTful con endpoints JSON

## Dependencias Principales

### Flutter Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  google_fonts: ^6.3.2          # Tipografías modernas
  http: ^1.1.0                  # Cliente HTTP
  permission_handler: ^11.3.1   # Gestión de permisos
  geolocator: ^13.0.1           # GPS y ubicación
  google_maps_flutter: ^2.5.3   # Mapas de Google
  camera: ^0.10.5+9             # Cámara para fotos
  image_picker: ^1.0.7          # Selector de imágenes
  provider: ^6.1.1              # Gestión de estado
```

### Backend Dependencies (Django)
- Django 4.x+
- Django REST Framework
- MongoDB con pymongo
- django-cors-headers (para CORS)
- GeoJSON para consultas geoespaciales

## Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.5.3+
- Dart SDK
- Android Studio / VS Code
- JDK 11+ (para Android)
- Cuenta de Google Maps API

### Configuración del Frontend

1. **Clonar el repositorio**
```bash
git clone https://github.com/Alexjh16/orus.git
cd orus
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar Google Maps API**
   - Obtener API Key de [Google Cloud Console](https://console.cloud.google.com/)
   - Agregar permisos en `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE" />
   ```

4. **Ejecutar la aplicación**
```bash
# Android
flutter run

# iOS (desde macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

### Configuración del Backend (Django)

1. **Instalar Python y dependencias**
```bash
pip install django djangorestframework pymongo django-cors-headers
```

2. **Configurar MongoDB**
   - Instalar MongoDB localmente o usar MongoDB Atlas
   - Crear base de datos `orus_db`

3. **Configurar Django**
```python
# settings.py
DATABASES = {
    'default': {
        'ENGINE': 'djongo',
        'NAME': 'orus_db',
        'CLIENT': {
            'host': 'localhost',  # o tu URI de MongoDB Atlas
            'port': 27017,
        }
    }
}

INSTALLED_APPS = [
    # ... otros apps
    'corsheaders',
    'rest_framework',
    'mongoData',  # Tu app de datos
]

MIDDLEWARE = [
    # ... otros middlewares
    'corsheaders.middleware.CorsMiddleware',
]

# Permitir CORS para Flutter
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",
    "http://192.168.92.178:8000",  # Para desarrollo móvil
    "https://expresate-backend-2024.fly.dev",
    "http://localhost:3000"
]
```

4. **Ejecutar el backend**
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py runserver
```

## API Endpoints (Backend Django)

### Tesoros (`/api/treasures/`)

#### `GET /api/treasures/nearby/?lat={lat}&lng={lng}&radius={radius}`
Obtiene tesoros cercanos a una ubicación específica.

**Parámetros:**
- `lat`: Latitud (float)
- `lng`: Longitud (float)
- `radius`: Radio en kilómetros (float)

**Respuesta:**
```json
{
  "treasures": [
    {
      "id": "string",
      "creator_id": "string",
      "creator_name": "string",
      "title": "string",
      "description": "string",
      "image_url": "string",
      "latitude": "string",
      "longitude": "string",
      "hint": "string",
      "difficulty": 1-5,
      "clues": ["string"],
      "is_found": false,
      "found_by": null,
      "created_at": "2025-10-24T...",
      "found_at": null,
      "points": 10
    }
  ]
}
```

#### `POST /api/treasures/create/`
Crea un nuevo tesoro.

**Body:**
```json
{
  "creator_id": "string",
  "creator_name": "string",
  "title": "string",
  "description": "string",
  "location": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "image_url": null,
  "latitude": "string",
  "longitude": "string",
  "hint": "string",
  "difficulty": 1-5,
  "clues": ["string"],
  "points": 10
}
```

#### `POST /api/treasures/{id}/claim/`
Reclama un tesoro encontrado.

**Body:**
```json
{
  "user_id": "string"
}
```

#### `GET /api/treasures/user/{userId}/`
Obtiene tesoros creados por un usuario específico.

### Usuarios (`/api/users/`)

#### `GET /api/users/{userId}/stats/`
Obtiene estadísticas de un usuario.

**Respuesta:**
```json
{
  "success": true,
  "stats": {
    "treasures_created": 5,
    "treasures_found": 12,
    "total_points": 245,
    "rank": "Explorador Experto"
  }
}
```

## Funcionalidades de la App

### 1. Sistema de Autenticación
- Login con credenciales
- Registro de nuevos usuarios
- Gestión de sesiones

### 2. Mapa Interactivo
- Vista de mapa con Google Maps
- Marcadores dinámicos por distancia:
  - 🟢 **Verde**: Tesoro encontrado
  - 🟠 **Naranja**: Tesoro disponible
  - 🔴 **Rojo**: Tesoro muy cercano (< 50m)
- Información en tiempo real de ubicación

### 3. Creación de Tesoros
- Formulario intuitivo para crear tesoros
- Campos: título, descripción, pistas, dificultad, puntos
- Ubicación automática desde GPS
- Soporte para imágenes (pendiente de implementación completa)

### 4. Búsqueda y Reclamación
- Detección automática de proximidad
- Sistema de pistas progresivo
- Reclamación cuando < 50 metros
- Animaciones de celebración
- Actualización automática de estadísticas

### 5. Sistema de Puntos y Rankings
- Puntos por tesoros encontrados
- Diferentes rangos según puntuación
- Estadísticas detalladas del usuario

## Estructura del Proyecto

```
orus/
├── android/                    # Configuración Android
├── ios/                       # Configuración iOS
├── lib/                       # Código fuente Flutter
│   ├── main.dart             # Punto de entrada
│   ├── models/               # Modelos de datos
│   │   └── treasure_model.dart
│   ├── treasure/             # Módulo de tesoros
│   │   ├── treasure_map_page.dart
│   │   ├── treasure_service.dart
│   │   ├── treasure_details_dialog.dart
│   │   └── create_treasure_dialog.dart
│   ├── login/                # Módulo de autenticación
│   ├── home/                 # Página principal
│   ├── calculator/           # Calculadora (demo)
│   └── weather/              # Clima (demo)
├── test/                     # Tests
├── web/                      # Configuración web
├── windows/                  # Configuración Windows
├── linux/                    # Configuración Linux
├── pubspec.yaml             # Dependencias Flutter
├── analysis_options.yaml    # Configuración de linting
└── README.md                # Esta documentación
```

## Desarrollo y Testing

### Ejecutar Tests
```bash
flutter test
```

### Análisis de Código
```bash
flutter analyze
```

### Formateo de Código
```bash
flutter format lib/
```

### Generar Seeder de Tesoros
```python
# improved_seeder.py (comando Django)
python manage.py improved_seeder --total=30
```

## Configuración de Desarrollo

### Variables de Entorno
Crear archivo `.env` en el directorio del backend:
```env
DEBUG=True
SECRET_KEY=your-secret-key
MONGO_URI=mongodb://localhost:27017/orus_db
GOOGLE_MAPS_API_KEY=your-api-key
```

### Configuración de CORS
Asegurarse de que el backend permita conexiones desde Flutter:
```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8000",      # Web
    "http://192.168.92.178:8000", # Desarrollo móvil
]
```

## Sistema de Rankings

| Puntos | Rango |
|--------|-------|
| 0-49 | Novato |
| 50-149 | Explorador |
| 150-299 | Aventurero |
| 300-499 | Maestro |
| 500+ | Leyenda |

## Próximas Funcionalidades

- [ ] Subida de imágenes para tesoros
- [ ] Sistema de amigos y equipos
- [ ] Logros y medallas
- [ ] Modo multijugador
- [ ] Eventos especiales
- [ ] Integración con redes sociales

## Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## Autor

**Alexander** - *Desarrollo completo*

##  Agradecimientos

- Flutter por el framework increíble
- Google Maps por la API de mapas
- MongoDB por la base de datos NoSQL
- Django REST Framework por la API backend
- Comunidad Flutter por el soporte continuo

---

¡Disfruta cazando tesoros con **Orus**! 🏴‍☠️💎
