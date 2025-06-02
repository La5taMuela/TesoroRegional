# TesoroRegional - App de Descubrimiento Cultural para Ñuble

TesoroRegional es una aplicación móvil que permite a los usuarios descubrir el patrimonio cultural de la región de Ñuble, Chile, a través de una experiencia gamificada basada en la metáfora de un rompecabezas cultural.

## Arquitectura y Decisiones Técnicas

### Clean Architecture + BLoC

La aplicación está estructurada siguiendo los principios de Clean Architecture, separando claramente las capas de:

- **Presentación**: UI, widgets, páginas y gestión de estado con Riverpod
- **Dominio**: Entidades de negocio, casos de uso e interfaces de repositorios
- **Datos**: Implementaciones de repositorios, fuentes de datos y DTOs

Esta separación permite:
- Testabilidad independiente de cada capa
- Cambios en la UI sin afectar la lógica de negocio
- Sustitución de fuentes de datos sin modificar la lógica de la aplicación

### Feature-First vs Layer-First

Hemos optado por una estructura **Feature-First** en lugar de Layer-First para:
- Facilitar la navegación del código por funcionalidad
- Permitir que diferentes equipos trabajen en features distintas
- Mejorar la cohesión del código relacionado

### Gestión de Estado con Riverpod

Elegimos Riverpod sobre otros gestores de estado por:
- Seguridad de tipos en tiempo de compilación
- Facilidad para combinar y derivar estados
- Integración natural con Flutter Hooks
- Mejor testabilidad que Provider tradicional

### Navegación con GoRouter

GoRouter fue seleccionado por:
- Soporte nativo para rutas anidadas
- Integración con deep linking
- Transiciones personalizables
- Redirecciones basadas en estado (autenticación, etc.)

### Inmutabilidad con Freezed

Utilizamos Freezed para:
- Garantizar la inmutabilidad de los modelos
- Reducir el código boilerplate (equals, hashCode, toString)
- Facilitar la serialización/deserialización JSON
- Implementar pattern matching para estados

## Estructura del Proyecto

\`\`\`
lib/
├── app/                  # Punto de entrada de la aplicación
├── core/                 # Componentes compartidos
│   ├── di/               # Inyección de dependencias
│   ├── router/           # Configuración de rutas
│   ├── services/         # Servicios core (storage, network, etc.)
│   ├── theme/            # Temas y estilos
│   ├── utils/            # Utilidades y helpers
│   └── widgets/          # Widgets reutilizables
└── features/             # Módulos funcionales
├── puzzle/           # Feature de rompecabezas cultural
│   ├── data/         # Capa de datos
│   ├── domain/       # Capa de dominio
│   └── presentation/ # Capa de presentación
├── map/              # Feature de mapa interactivo
├── missions/         # Feature de misiones
├── stories/          # Feature de historias culturales
└── recommendations/  # Feature de recomendaciones
\`\`\`

## Patrones Implementados

1. **Repository Pattern**: Abstracción de fuentes de datos
2. **Use Case Pattern**: Encapsulación de lógica de negocio
3. **State Notifier Pattern**: Gestión de estado con inmutabilidad
4. **Dependency Injection**: Inversión de control para testing
5. **Builder Pattern**: Construcción de objetos complejos
6. **Factory Pattern**: Creación de objetos relacionados

## Seguridad

- **Encriptación AES**: Para datos sensibles almacenados localmente
- **Certificate Pinning**: Prevención de ataques MITM
- **Sanitización de Inputs**: Prevención de inyección de código
- **Validación con Either**: Manejo seguro de errores y validaciones

## Performance

- **Lazy Loading**: Carga diferida de imágenes y recursos pesados
- **Isolates**: Procesamiento en segundo plano para tareas intensivas
- **LRU Cache**: Caché de imágenes con política de menos usados recientemente
- **Paginación**: Carga incremental de datos en listas largas

## Configuración del Entorno de Desarrollo

### Requisitos

- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Git

### Instalación

1. Clonar el repositorio:
   \`\`\`bash
   git clone https://github.com/tu-organizacion/tesoro-regional.git
   cd tesoro-regional
   \`\`\`

2. Instalar dependencias:
   \`\`\`bash
   flutter pub get
   \`\`\`

3. Generar código:
   \`\`\`bash
   flutter pub run build_runner build --delete-conflicting-outputs
   \`\`\`

4. Configurar variables de entorno:
    - Crear archivo `.env` en la raíz del proyecto
    - Añadir las claves necesarias (ver `.env.example`)

5. Ejecutar la aplicación:
   \`\`\`bash
   flutter run --flavor dev
   \`\`\`

## CI/CD

El proyecto utiliza GitHub Actions para:
- Lint y análisis estático
- Ejecución de tests unitarios e integración
- Generación de builds para diferentes entornos
- Despliegue automático a TestFlight/Firebase App Distribution

## Convenciones de Código

- **Naming**: camelCase para variables y funciones, PascalCase para clases
- **Formatting**: Dart formatter con 80 caracteres por línea
- **Imports**: Agrupados por tipo (dart, flutter, paquetes, proyecto)
- **Documentation**: Documentación de Dart para clases y métodos públicos

## Contribución

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para detalles sobre el proceso de contribución al proyecto.

## Licencia

Este proyecto está licenciado bajo [MIT License](LICENSE).
\`\`\`

## Wireframes Interactivos

Para los wireframes interactivos, se recomienda utilizar Figma o Adobe XD para crear las siguientes pantallas:

1. **Pantalla de Onboarding**
    - Introducción a la metáfora del rompecabezas cultural
    - Explicación de cómo descubrir piezas
    - Configuración inicial de preferencias

2. **Pantalla Principal (Home)**
    - Grid de iconos para acceder a los módulos
    - Barra de progreso visual del puzzle general
    - Resumen de estadísticas (piezas descubiertas, categorías)

3. **Pantalla de Puzzle**
    - Visualización isométrica de piezas colectadas
    - Selector de categorías
    - Detalles de piezas al seleccionarlas

4. **Pantalla de Mapa**
    - Mapa interactivo con capas temáticas
    - Marcadores de piezas por descubrir
    - Panel de información al seleccionar un punto

5. **Pantalla de Misiones**
    - Listado de misiones disponibles
    - Filtros por ubicación, dificultad y recompensa
    - Detalles de misión al seleccionarla

6. **Pantalla de Historias**
    - Lector de tarjetas culturales
    - Modo noche para lectura
    - Navegación entre tarjetas relacionadas

7. **Pantalla de Recomendaciones**
    - Quiz inicial para personalización
    - Listado de recomendaciones basadas en preferencias
    - Detalles de cada recomendación

## Conclusión

La aplicación TesoroRegional implementa una arquitectura limpia y modular que facilita el mantenimiento y la escalabilidad. El uso de patrones como Repository, Use Case y State Notifier, junto con herramientas como Freezed para inmutabilidad y Riverpod para gestión de estado, proporciona una base sólida para el desarrollo.

La estructura feature-first permite que el equipo trabaje de manera más eficiente, centrándose en funcionalidades completas en lugar de capas tecnológicas. Además, las prácticas de seguridad y rendimiento implementadas garantizan una experiencia de usuario fluida y segura.

El proyecto está configurado para facilitar la contribución de nuevos desarrolladores y para mantener un alto estándar de calidad a través de CI/CD y análisis estático de código.

