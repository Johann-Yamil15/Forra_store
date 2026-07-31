# Forra Store

Aplicación móvil para la gestión integral de una forrajería o almacén agropecuario. Permite a los trabajadores consultar el catálogo y registrar ventas, y al administrador gestionar toda la operación: productos, clientes, precios especiales, inventario y reportes.

---

## Índice

1. [Visión del producto](#1-visión-del-producto)
2. [Roles y permisos](#2-roles-y-permisos)
3. [Módulos y estado actual](#3-módulos-y-estado-actual)
4. [Modelos de datos](#4-modelos-de-datos)
5. [Arquitectura](#5-arquitectura)
6. [Stack tecnológico](#6-stack-tecnológico)
7. [Estructura del proyecto](#7-estructura-del-proyecto)
8. [Instalación](#8-instalación)
9. [Diseño de base de datos (SQL Server)](#9-diseño-de-base-de-datos-sql-server)
10. [Roadmap](#10-roadmap)

---

## 1. Visión del producto

Forra Store digitaliza la operación de un negocio que vende productos agrícolas, ganaderos y maquinaria de campo. Los productos tienen múltiples presentaciones (distintos tamaños, unidades y precios), y los clientes recurrentes reciben precios especiales definidos por el administrador por cada presentación.

**Problemas que resuelve:**

- Registro ágil de ventas con soporte para precio de lista y precio especial por cliente.
- Historial trazable con detalle exacto de lo cobrado por producto.
- Alertas de stock bajo antes de que un artículo se agote.
- Reportes de ventas por día, semana o mes sin hojas de cálculo.
- Control de acceso por rol: los trabajadores solo consultan y venden; el admin gestiona todo.

---

## 2. Roles y permisos

| Capacidad                            | Trabajador | Administrador |
|--------------------------------------|:----------:|:-------------:|
| Ver catálogo de productos            | ✅         | ✅            |
| Ver detalle y presentaciones         | ✅         | ✅            |
| Agregar al carrito                   | ✅         | ✅            |
| Seleccionar cliente y precio esp.    | ✅         | ✅            |
| Finalizar venta                      | ✅         | ✅            |
| Ver historial propio de ventas       | ✅         | ✅            |
| CRUD de productos y presentaciones   | ❌         | ✅            |
| Reabastecer stock por presentación   | ❌         | ✅            |
| CRUD de clientes                     | ❌         | ✅            |
| Configurar descuentos por cliente    | ❌         | ✅            |
| Dashboard con KPIs y alertas         | ❌         | ✅            |
| Reportes de ventas por período       | ❌         | ✅            |

**Credenciales de prueba:**

| Usuario   | Contraseña   | Rol           |
|-----------|--------------|---------------|
| `usuario` | `123456789`  | Trabajador    |
| `admin`   | `123456789`  | Administrador |

---

## 3. Módulos y estado actual

### Vista Trabajador — `MainScreenTrabajador`

Navegación de 4 pestañas con `PageView` deslizable (Facebook-style) más barra flotante con indicador animado. El badge del carrito refleja el total de items en tiempo real.

#### Pestaña 1 — Tienda (`ProductosScreen`) ✅
- Grid de productos con imagen, categoría, badge de stock y precio mínimo.
- Datos cargados desde JSON simulado (preparado para conectar a API REST).
- Navega a `ProductDetailScreen` al tocar una tarjeta.

#### `ProductDetailScreen` ✅
- Hero con imagen, descripción completa y etiquetas de categoría / subcategoría / uso.
- Selector de presentación (unidad + tamaño + precio de lista + stock).
- Control de cantidad con validación de stock disponible.
- Botón "Agregar al carrito" con snackbar de confirmación.

#### Pestaña 2 — Carrito (`CartScreen`) ✅
- Dropdown modal en la parte superior para seleccionar cliente.
- Cuando hay cliente con descuento: precio de lista tachado + precio especial en verde.
- Ajuste de cantidad (+/−) por item y eliminación individual.
- Footer: subtotal original, descuento aplicado y total a cobrar.
- "Finalizar Compra": crea un `Pedido`, guarda en historial, limpia el carrito.

#### Pestaña 3 — Pedidos (`PedidosScreen`) ✅
- Historial de ventas ordenado por fecha descendente.
- Cada tarjeta: fecha, nombre del cliente, número de productos y total cobrado.
- Navega a `PedidoDetailScreen` al tocar.

#### `PedidoDetailScreen` ✅
- Cabecera: ID (8 chars), fecha y hora completa, nombre del cliente.
- Líneas de producto con `precioEfectivo` real cobrado (tachado si hubo descuento).
- Bloque de resumen: subtotal original, descuento y total final.

#### Pestaña 4 — Perfil (`ProfileScreen`) ✅
- Información de sesión activa y botón de cierre de sesión.

---

### Vista Administrador — `MainScreenAdmin`

Navegación de 4 pestañas con `PageView` + barra flotante idéntica a la del trabajador. AppBar fija muestra el branding y el rol "Admin".

#### Pestaña 1 — Dashboard ✅
- Saludo dinámico (buenos días / tardes / noches) con fecha actual.
- 3 KPI cards: ventas del día, total del día, total de la semana.
- Sección de alertas de stock bajo (solo aparece si hay productos en alerta).
- Top 3 productos más vendidos con barra de progreso proporcional y medalla de posición.
- 4 ventas recientes con cliente, hora y monto.

#### Pestaña 2 — Reportes ✅
- Selector de período: Hoy / Semana / Mes.
- Card hero con total y número de ventas del período seleccionado.
- Gráfico de barras horizontal con desglose diario.
- Lista de pedidos del período con cliente, productos y total.

#### Pestaña 3 — Tienda ✅

**Tab Productos:**
- Lista de todos los productos del `AdminProvider`.
- Cada tarjeta muestra categoría, nombre y el detalle de cada presentación con su precio, stock y estado de alerta.
- Menú de acciones (⋮): **Editar** → `ProductoFormScreen`, **Reabastecer** → `ProductoRestockSheet`, **Eliminar** con diálogo de confirmación.
- FAB "Nuevo Producto" navega a `ProductoFormScreen` vacío.

**Tab Clientes:**
- Lista de todos los clientes del `AdminProvider`.
- Muestra el resumen de precios especiales activos con precio de lista tachado y precio especial.
- Tap en tarjeta → `ClienteDescuentosScreen` para gestionar descuentos.
- Menú de acciones (⋮): **Descuentos**, **Editar datos** → `ClienteFormScreen`, **Eliminar** con confirmación.
- FAB "Nuevo Cliente" navega a `ClienteFormScreen` vacío.

#### `ProductoFormScreen` ✅
- Campos: nombre + dropdown de categoría (Alimento / Accesorios / Maquinaria / Semillas / Veterinario).
- Lista dinámica de presentaciones: descripción, precio, stock inicial, stock mínimo.
- Agregar / quitar presentaciones en el mismo formulario.
- Crea o actualiza en `AdminProvider` (detecta automáticamente si es nuevo o edición).

#### `ProductoRestockSheet` ✅
- Bottom sheet con todas las presentaciones del producto.
- Contador +/− por presentación, también editable directamente.
- "Aplicar" suma las cantidades al stock actual vía `AdminProvider.addStock`.

#### `ClienteFormScreen` ✅
- Campos: nombre y teléfono.
- Crea o actualiza en `AdminProvider`.
- Botón "Eliminar cliente" en modo edición con confirmación.

#### `ClienteDescuentosScreen` ✅
- Lista todos los productos y sus presentaciones con el precio de lista.
- Permite ingresar un precio especial menor al de lista por cada presentación.
- Filas válidas se resaltan en verde de forma reactiva al escribir.
- "Guardar precios" reemplaza todo el conjunto de precios del cliente.

#### Pestaña 4 — Perfil ✅
- Mismo `ProfileScreen` que la vista trabajador.

---

## 4. Modelos de datos

### `ProductoPreview`
Resumen para el grid del catálogo del trabajador.

```dart
class ProductoPreview {
  int idProducto;
  String nombreProducto;
  String descripcionProducto;
  String categoria;
  String subcategoria;
  String uso;
  String imagenUrl;
  List<PresentacionProducto> presentaciones;
}

class PresentacionProducto {
  String unidad;
  int tamano;
  double precio;
  int stock;
}
```

### `CartItem`
Item del carrito. Separa precio de lista del precio real cobrado.

```dart
class CartItem {
  int idProducto;
  String nombreProducto;
  String? imagenUrl;
  String unidad;
  int tamano;
  double precioUnitario;  // precio de lista del catálogo
  double? precioEfectivo; // precio real cobrado (null = igual al de lista)
  int cantidad;

  double get subtotal => (precioEfectivo ?? precioUnitario) * cantidad;
}
```

> `precioEfectivo` se asigna al finalizar la venta si el cliente tiene precio especial en esa presentación, preservando el dato exacto cobrado para auditoría.

### `Pedido`
Registro inmutable de una venta completada.

```dart
class Pedido {
  String id;             // timestamp en milisegundos
  DateTime fecha;
  int? idCliente;        // null = venta al público general
  String nombreCliente;
  double totalOriginal;  // suma a precios de lista
  double descuento;      // diferencia entre original y final
  double totalFinal;     // lo que se cobró
  List<CartItem> items;  // snapshot con precioEfectivo asignado
}
```

### Modelos del `AdminProvider`
Gestión de inventario y clientes en el panel de administración.

```dart
class PresentacionAdmin {
  int id;
  String descripcion;  // ej. "Bulto 50 kg", "Kg suelto"
  double precio;
  int stock;
  int stockMinimo;

  bool get enAlerta => stock <= stockMinimo;
}

class ProductoAdmin {
  int id;
  String nombre;
  String categoria;
  List<PresentacionAdmin> presentaciones;

  bool get tieneAlerta => presentaciones.any((p) => p.enAlerta);
  String get stockStatus; // 'ok' | 'alerta' | 'critico'
}

class PrecioEspecialAdmin {
  int idProducto;
  int idPresentacion;
  String productoNombre;
  String presentacionDesc;
  double precioLista;
  double precioEspecial;
}

class ClienteAdmin {
  int id;
  String nombre;
  String telefono;
  List<PrecioEspecialAdmin> precios;
}
```

---

## 5. Arquitectura

```
Capa de Presentación
  ├── Screens          → Pantallas, consumen Providers vía context.watch / context.read
  ├── Widgets          → Componentes reutilizables (ProductGridCard, NeumorphicButton…)
  └── Providers        → Estado y lógica de negocio (ChangeNotifier)
        ├── CartProvider      → Items, cliente activo, cálculo de precios, persistencia
        ├── PedidosProvider   → Historial de ventas, persistencia
        ├── AdminProvider     → Productos, clientes, precios especiales (CRUD completo)
        └── AuthProvider      → Sesión activa, rol del usuario

Capa de Datos
  └── Models           → Clases Dart con fromJson / toJson (preparadas para API REST)

Persistencia local
  └── SharedPreferences → carrito activo (cart_items_v1) · historial (pedidos_history_v1)

Datos simulados
  └── JSON estáticos   → catálogo de productos y clientes (reemplazarán con llamadas HTTP)
```

**Flujo de una venta:**

```
ProductosScreen → ProductDetailScreen
  └─ CartProvider.addItem(CartItem)
       └─ CartScreen muestra items con getItemPrice(item) según cliente seleccionado
            └─ "Finalizar Compra"
                 ├─ Snapshot: asigna precioEfectivo a cada CartItem
                 ├─ PedidosProvider.agregarPedido(pedido)
                 ├─ CartProvider.clear()
                 └─ Diálogo de confirmación con totales
```

**Flujo de administración de stock:**

```
_TiendaAdminScreen
  ├─ Tab Productos → _ProductosAdminList (AdminProvider.productos)
  │    ├─ Editar → ProductoFormScreen → AdminProvider.updateProducto / updatePresentacion
  │    ├─ Reabastecer → ProductoRestockSheet → AdminProvider.addStock
  │    └─ Eliminar → AdminProvider.deleteProducto (cascada a precios especiales)
  └─ Tab Clientes → _ClientesAdminList (AdminProvider.clientes)
       ├─ Descuentos → ClienteDescuentosScreen → AdminProvider.saveDescuentosCliente
       ├─ Editar → ClienteFormScreen → AdminProvider.updateCliente
       └─ Eliminar → AdminProvider.deleteCliente
```

---

## 6. Stack tecnológico

| Capa             | Tecnología                              |
|------------------|-----------------------------------------|
| Framework        | Flutter 3.x                             |
| Lenguaje         | Dart                                    |
| Estado           | Provider (`ChangeNotifier`)             |
| Persistencia     | `shared_preferences`                    |
| Fechas / i18n    | `intl` + `initializeDateFormatting`     |
| Diseño           | Sistema Neumórfico custom (soft UI)     |
| Backend (futuro) | API REST + SQL Server (ver sección 9)   |

---

## 7. Estructura del proyecto

```
lib/
├── core/
│   ├── constants/
│   │   └── strings.dart
│   ├── theme/
│   │   ├── dark_theme.dart
│   │   ├── light_theme.dart
│   │   ├── neumorphic_colors.dart    # Paletas claro / oscuro
│   │   └── theme_provider.dart
│   └── utils/
│       ├── auth_provider.dart        # Sesión y rol del usuario
│       ├── neumorphic_style.dart     # BoxDecoration elevated / inset
│       └── validators.dart
│
├── data/
│   └── models/
│       ├── almacen.dart
│       ├── cart_item.dart            # Item del carrito con precioEfectivo
│       ├── categoria.dart
│       ├── cliente.dart              # Cliente con descuentos (vista trabajador)
│       ├── detalle_venta.dart
│       ├── movimiento.dart
│       ├── pedido.dart               # Registro de venta completada
│       ├── presentacion.dart
│       ├── producto.dart
│       ├── producto_preview.dart     # Catálogo + PresentacionProducto
│       ├── rol.dart
│       ├── stock.dart
│       ├── subcategoria.dart
│       ├── sucursal.dart
│       ├── uso_producto.dart
│       ├── usuario.dart
│       └── venta.dart
│
├── presentation/
│   ├── providers/
│   │   ├── admin_provider.dart       # CRUD productos, clientes, precios especiales
│   │   ├── cart_provider.dart        # Carrito, cliente activo, cálculo de precios
│   │   └── pedidos_provider.dart     # Historial de ventas
│   │
│   ├── screens/
│   │   ├── admin/
│   │   │   ├── cliente_admin_screen.dart   # ClienteFormScreen + ClienteDescuentosScreen
│   │   │   └── producto_admin_screen.dart  # ProductoFormScreen + ProductoRestockSheet
│   │   ├── home/
│   │   │   ├── cart_screen.dart
│   │   │   ├── pedido_detail_screen.dart
│   │   │   ├── pedidos_screen.dart
│   │   │   ├── product_detail_screen.dart
│   │   │   └── productos_screen.dart
│   │   ├── main/
│   │   │   ├── main_admin.dart       # Shell admin: Dashboard, Reportes, Tienda, Perfil
│   │   │   └── main_trabajador.dart  # Shell trabajador: Tienda, Carrito, Pedidos, Perfil
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   ├── login_screen.dart
│   │   └── splash_screen.dart
│   │
│   └── widgets/
│       ├── neumorphic_button.dart
│       ├── product_card.dart         # Selector de presentaciones en detalle
│       ├── product_grid_card.dart    # Tarjeta del grid de catálogo
│       └── product_pagination.dart
│
└── main.dart                         # MultiProvider + initializeDateFormatting
```

---

## 8. Instalación

```bash
# 1. Clonar el repositorio
git clone <url-del-repo>
cd forra_store

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en dispositivo o emulador
flutter run

# 4. Verificar análisis estático
flutter analyze
```

**Credenciales de prueba:**

| Usuario   | Contraseña   | Pantalla de inicio     |
|-----------|--------------|------------------------|
| `usuario` | `123456789`  | `MainScreenTrabajador` |
| `admin`   | `123456789`  | `MainScreenAdmin`      |

> Los datos de productos y clientes son JSON simulados. Para conectar al backend real, reemplazar los loaders en `ProductosScreen` y `AdminProvider` con llamadas HTTP.

---

## 9. Diseño de base de datos (SQL Server)

Schema relacional T-SQL para el backend REST que reemplazará los datos simulados. El script completo está en `database/forra_store_sqlserver.sql`.

### Tablas principales

```sql
-- Usuarios del sistema
CREATE TABLE usuarios (
  id            INT IDENTITY(1,1) PRIMARY KEY,
  nombre        NVARCHAR(100) NOT NULL,
  username      NVARCHAR(50)  NOT NULL UNIQUE,
  password_hash NVARCHAR(255) NOT NULL,
  rol           NVARCHAR(20)  NOT NULL DEFAULT 'trabajador', -- 'admin' | 'trabajador'
  activo        BIT           NOT NULL DEFAULT 1,
  created_at    DATETIME2     NOT NULL DEFAULT GETDATE()
);

-- Catálogo de productos
CREATE TABLE productos (
  id          INT IDENTITY(1,1) PRIMARY KEY,
  nombre      NVARCHAR(150) NOT NULL,
  descripcion NVARCHAR(MAX),
  categoria   NVARCHAR(80),
  subcategoria NVARCHAR(80),
  uso         NVARCHAR(80),
  imagen_url  NVARCHAR(500),
  activo      BIT NOT NULL DEFAULT 1
);

-- Presentaciones (tamaño, unidad, precio, stock)
CREATE TABLE presentaciones (
  id           INT IDENTITY(1,1) PRIMARY KEY,
  id_producto  INT NOT NULL REFERENCES productos(id),
  descripcion  NVARCHAR(100) NOT NULL,  -- ej. "Bulto 50 kg", "Kg suelto"
  precio       DECIMAL(10,2) NOT NULL,
  stock        INT NOT NULL DEFAULT 0,
  stock_minimo INT NOT NULL DEFAULT 5
);

-- Clientes con precios especiales
CREATE TABLE clientes (
  id       INT IDENTITY(1,1) PRIMARY KEY,
  nombre   NVARCHAR(150) NOT NULL,
  telefono NVARCHAR(20),
  activo   BIT NOT NULL DEFAULT 1
);

-- Precios especiales: cliente × presentación
CREATE TABLE precios_especiales (
  id               INT IDENTITY(1,1) PRIMARY KEY,
  id_cliente       INT NOT NULL REFERENCES clientes(id),
  id_presentacion  INT NOT NULL REFERENCES presentaciones(id),
  precio_especial  DECIMAL(10,2) NOT NULL,
  CONSTRAINT UQ_precio UNIQUE (id_cliente, id_presentacion)
);

-- Cabecera de venta
CREATE TABLE ventas (
  id             INT IDENTITY(1,1) PRIMARY KEY,
  id_usuario     INT NOT NULL REFERENCES usuarios(id),
  id_cliente     INT REFERENCES clientes(id),  -- NULL = público general
  fecha          DATETIME2    NOT NULL DEFAULT GETDATE(),
  total_original DECIMAL(10,2) NOT NULL,
  descuento      DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_final    DECIMAL(10,2) NOT NULL
);

-- Detalle de cada línea de venta
CREATE TABLE detalle_ventas (
  id              INT IDENTITY(1,1) PRIMARY KEY,
  id_venta        INT NOT NULL REFERENCES ventas(id),
  id_presentacion INT NOT NULL REFERENCES presentaciones(id),
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,  -- precio de lista al momento de la venta
  precio_efectivo DECIMAL(10,2) NOT NULL,  -- precio real cobrado
  subtotal        DECIMAL(10,2) NOT NULL
);
```

### Relaciones clave

```
productos    (1) ──< (N) presentaciones
clientes     (1) ──< (N) precios_especiales >── (1) presentaciones
ventas       (1) ──< (N) detalle_ventas     >── (1) presentaciones
usuarios     (1) ──< (N) ventas
```

### Consultas del panel de admin

```sql
-- KPI: ventas del día
SELECT COUNT(*) AS num_ventas, SUM(total_final) AS total_hoy
FROM ventas
WHERE CAST(fecha AS DATE) = CAST(GETDATE() AS DATE);

-- Productos más vendidos
SELECT p.nombre, pr.descripcion,
       SUM(dv.cantidad) AS total_vendido,
       SUM(dv.subtotal) AS ingreso_total
FROM detalle_ventas dv
JOIN presentaciones pr ON dv.id_presentacion = pr.id
JOIN productos p       ON pr.id_producto = p.id
GROUP BY p.id, p.nombre, pr.id, pr.descripcion
ORDER BY total_vendido DESC;

-- Alertas de stock bajo
SELECT p.nombre, pr.descripcion, pr.stock, pr.stock_minimo
FROM presentaciones pr
JOIN productos p ON pr.id_producto = p.id
WHERE pr.stock <= pr.stock_minimo AND p.activo = 1
ORDER BY pr.stock ASC;

-- Ventas por día (últimos 7 días)
SELECT CAST(fecha AS DATE) AS dia, SUM(total_final) AS total
FROM ventas
WHERE fecha >= DATEADD(DAY, -7, GETDATE())
GROUP BY CAST(fecha AS DATE)
ORDER BY dia;
```

---

## 10. Roadmap

### Completado ✅

**Vista Trabajador**
- [x] Autenticación con roles (trabajador / admin)
- [x] Catálogo de productos con presentaciones (JSON simulado)
- [x] Detalle de producto y selector de presentación
- [x] Carrito con ajuste de cantidad y eliminación
- [x] Precios especiales por cliente (dropdown modal)
- [x] Finalizar venta → Pedido con `precioEfectivo` guardado
- [x] Historial de ventas con detalle completo
- [x] Persistencia local (SharedPreferences)
- [x] Navegación por deslizamiento (PageView) entre pestañas
- [x] Badge de items activos en la barra de navegación
- [x] Diseño neumórfico con soporte dark / light mode

**Vista Administrador**
- [x] Login diferenciado por rol (`admin` / `123456789`)
- [x] Dashboard con KPIs del día y la semana
- [x] Alertas de stock bajo en dashboard
- [x] Ranking de productos más vendidos (top 3)
- [x] Reportes de ventas por período (Hoy / Semana / Mes) con gráfico
- [x] CRUD completo de productos con gestión de presentaciones
- [x] Reabastecimiento de stock por presentación
- [x] CRUD completo de clientes
- [x] Configuración de precios especiales por cliente y presentación

### Próximas mejoras — Trabajador

- [ ] Búsqueda y filtro de productos por categoría
- [ ] Swipe-to-delete en historial de pedidos
- [ ] Filtro de historial por rango de fechas

### Próximas mejoras — Administrador

- [ ] Gestión de trabajadores (crear, activar, desactivar)
- [ ] Exportar reportes a PDF o CSV
- [ ] Foto del producto (cámara o galería)
- [ ] Historial de movimientos de stock (quién abasteció, cuándo)

### Fase siguiente — Backend y sincronización

- [ ] API REST (Node.js / Laravel / FastAPI — por definir)
- [ ] Migración de SharedPreferences y JSON simulados a llamadas HTTP
- [ ] Autenticación con JWT
- [ ] Sincronización offline-first (cola de operaciones sin internet)
- [ ] Notificaciones push para alertas de stock bajo

---

*Desarrollado con Flutter · Gestión eficiente del campo.*
