# Forra Store 🌾

**Forra Store** es una aplicación móvil desarrollada en Flutter diseñada para la gestión integral de forrajeras, almacenes de semillas o cualquier establecimiento de venta de productos agrícolas y ganaderos.

## 🚀 Características Principales

- **Gestión de Inventario**: Control detallado de productos, categorías, subcategorías y presentaciones.
- **Sistema de Ventas**: Carrito de compras integrado con soporte para múltiples unidades de medida.
- **Arquitectura Robusta**: Separación clara de responsabilidades (Clean-ish architecture).
- **Diseño Vanguardista**: Interfaz **Neumórfica** (soft UI) que ofrece una experiencia moderna y fluida.
- **Modo Oscuro Integrado**: Adaptación automática o manual entre temas claro y oscuro.
- **Multi-Rol**: Acceso diferenciado para Administradores y Trabajadores.

## 🛠 Stack Tecnológico

- **Framework**: [Flutter](https://flutter.dev/)
- **Lenguaje**: [Dart](https://dart.dev/)
- **Gestión de Estado**: [Provider](https://pub.dev/packages/provider)
- **Persistencia**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Fuentes**: [Google Fonts (Outfit/Inter)](https://pub.dev/packages/google_fonts)
- **Estilo**: Custom Neumorphic Design System.

## 📂 Estructura del Proyecto

```text
lib/
├── core/               # Núcleo de la aplicación
│   ├── constants/      # Constantes globales
│   ├── theme/          # Sistema de temas y colores neumórficos
│   └── utils/          # Utilidades (Auth, Helpers)
├── data/               # Capa de Datos
│   └── models/         # Modelos de datos (Producto, Venta, etc.)
├── presentation/       # Capa de Presentación (UI)
│   ├── providers/      # Lógica de negocio (CartProvider, etc.)
│   ├── screens/        # Pantallas completas
│   └── widgets/        # Componentes reutilizables
└── main.dart           # Punto de entrada
```

## ⚙️ Instalación

1. Clona el repositorio.
2. Asegúrate de tener Flutter instalado (`flutter doctor`).
3. Ejecuta `flutter pub get` para instalar dependencias.
4. Lanza la aplicación con `flutter run`.

## 📌 Estado del Desarrollo

- [x] Estructura base y navegación.
- [x] Lógica de Autenticación.
- [x] Exploración de Productos.
- [x] Lógica del Carrito (`CartProvider`).
- [/] **Vista de Carrito** (En desarrollo).
- [ ] Historial de Ventas.
- [ ] Panel de Administración completo.

---
*Desarrollado con ❤️ para la eficiencia en el campo.*
