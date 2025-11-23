# CS2 Match Tracker

Aplicación Flutter para registrar y analizar tus partidas de **Counter-Strike 2 (CS2)**  
Permite crear una cuenta, iniciar sesión, añadir partidas con sus estadísticas, ver tus medias y gestionar tu perfil.

---

## Características principales

- Registro e inicio de sesión con **Firebase Authentication**  
- Base de datos en **Firebase Realtime Database**  
- Subida de imagen de perfil con **Firebase Storage**  
- Estadísticas de partidas (kills, deaths, assists, K/D ratio, etc.)  
- Drawer lateral con navegación global  
- Interfaz moderna con **Material 3**  
- Gestión de partidas y estadísticas en tiempo real  

---

## Instalación y configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/tuusuario/flutter_proyecto_cs2tracker.git
cd flutter_proyecto_cs2tracker
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto llamado **CS2 Tracker**
3. Agrega una aplicación **Android** con el ID del paquete (búscalo en `android/app/build.gradle`, algo como `com.example.flutter_proyecto_cs2tracker`)
4. Descarga el archivo `google-services.json` y colócalo en:
   ```
   android/app/google-services.json
   ```
5. (Opcional, si usas iOS) Descarga `GoogleService-Info.plist` y colócalo en:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

6. En la consola de Firebase, habilita:
   - **Authentication → Email/Password**
   - **Realtime Database** (modo test o reglas seguras)
   - **Storage** (para fotos de perfil)

### 4. Inicializar Firebase en Flutter

Asegúrate de tener en `main.dart`:

```dart
await Firebase.initializeApp();
```

> Si el proyecto ya usa `FirebaseOptions(...)`, reemplaza los valores por los de tu proyecto desde la consola de Firebase (Configuración → SDK setup).

---

## Dependencias principales (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.7.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.4.0
  firebase_storage: ^12.3.0
  image_picker: ^1.1.2
  fl_chart: ^0.68.0
```

(Versiones aproximadas — actualiza con `flutter pub upgrade` si hace falta.)

---

## Estructura del proyecto

```
lib/
│
├── main.dart                     # Punto de entrada
├── services/
│   ├── auth_service.dart          # Lógica de autenticación
│   └── match_service.dart         # Manejo de partidas
│
├── pages/
│   ├── login_page.dart            # Pantalla de login/registro
│   ├── home_page.dart             # Pantalla principal (lista de partidas)
│   ├── add_match_page.dart        # Añadir partida nueva
│   ├── stats_page.dart            # Estadísticas del usuario
│   ├── admin_page.dart            # Panel de administrador que se encuentra en el appdrawer al tener rol de administrador
│   └── settings_page.dart         # Pantalla de configuracion del usuario donde puede reguistrar el numero de telefono
│   
│
└── widgets/
    ├── match_card.dart            # Cards donde crean las partidas
    └── app_drawer.dart            # Drawer lateral con foto y navegación
```

---

## Ejecutar la app

```bash
flutter run
```

Para limpiar la caché y evitar errores antiguos:

```bash
flutter clean
flutter pub get
flutter run
```

---

## Funcionalidades del Drawer

- Muestra la **foto y nombre de usuario**
- Si no hay foto, permite subir una desde la galería
- Enlaces a:
  - Inicio
  - Añadir partida
  - Estadísticas
  - Cerrar sesión

---

## Mejoras visuales

- Interfaz con **Material 3**
- Paleta de colores basada en **naranja/negro**
- Login con título de app y diseño centrado
- Formularios con bordes redondeados y estilo moderno

---

## ERRORES COMUNES

| Error | Causa | Solución |
|-------|--------|-----------|
| `firebase_auth/configuration-not-found` | Firebase no configurado correctamente | Revisa `google-services.json` y `Firebase.initializeApp()` |
| `Target of URI doesn't exist` | Faltan dependencias | Ejecuta `flutter pub get` |
| Pantalla en blanco tras guardar partida | No se refresca el estado | Usa `Navigator.pushReplacementNamed(context, '/home')` después de guardar |
| No se puede subir foto | Falta `image_picker` o permisos | Añade `image_picker` en `pubspec.yaml` y revisa permisos en AndroidManifest |

---

**Manuel Moreno Parra**  

---
