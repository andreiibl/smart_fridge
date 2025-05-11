# Smart Fridge

Smart Fridge es una aplicación web y móvil que te ayuda a gestionar los productos de tu nevera, controlar fechas de caducidad y generar recetas con los ingredientes que tienes disponibles gracias a IA (API Gemini).

## Funcionalidades

- **Gestión de productos:** Añade, edita y elimina productos de tu nevera.
- **Control de caducidad:** Visualiza qué productos están a punto de caducar.
- **Generación de recetas:** Obtén recetas realistas solo con los ingredientes que tienes.
- **Actualización de stock:** El stock se actualiza automáticamente al realizar una receta.
- **Historial:** Consulta el historial de recetas y filtra por nombre.
- **Multi-plataforma:** Funciona en Android, Windows, MacOS y Linux.

## Tecnologías

- **Backend:** Java Spring Boot
- **Frontend:** Flutter
- **Base de datos:** PostgreSQL
- **IA:** API Google Gemini

## Instalación

### Backend

1. Clona el repositorio.
2. Configura tu `application.properties` con la base de datos y la clave de Gemini:
    ```
    google.api.key=TU_CLAVE_GEMINI
    spring.datasource.url=jdbc:mysql://localhost:8080/smart_fridge
    spring.datasource.username=tu_usuario
    .passwordspring.datasource=tu_contraseña
    ```
3. Compila y ejecuta la aplicación Spring Boot:
    ```bash
    ./mvnw spring-boot:run
    ```

### Frontend

1. Ve a `lib/config/config.dart` y ajusta la URL del backend si es necesario.
2. Ejecuta la app Flutter:
    ```bash
    flutter pub get
    flutter run
    ```

## Uso

- **Añadir productos:** Desde la pantalla de productos, añade nuevos artículos. Los nombres se normalizan (sin tildes, primera letra en mayúscula).
- **Generar receta:** En la pantalla de recetas, genera una receta con tus productos actuales. Si no hay suficientes ingredientes, recibirás un mensaje de error claro.
- **Actualizar stock:** Al confirmar que has realizado una receta, el stock se actualiza automáticamente.
- **Filtrar:** Puedes filtrar productos y recetas por nombre (ignorando tildes).

## IA y recetas

La IA está configurada para:
- Usar solo los ingredientes y cantidades disponibles.
- No inventar ingredientes ni usar más cantidad de la que hay.
- Responder con un mensaje claro si no se puede generar una receta.

---

**Desarrollado por andreiibl**