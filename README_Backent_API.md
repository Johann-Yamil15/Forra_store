# ForraControl — Backend API

API REST para la aplicación móvil **Forra Store** (gestión de tienda de forrajes y alimentos para animales).

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Framework | ASP.NET Web API 2 (.NET Framework 4.8) |
| ORM | Entity Framework 6 Code First |
| Base de datos | SQL Server — base de datos `ForraStore` |
| Serialización | Newtonsoft.Json (camelCase, sin nulls) |
| Inyección de dependencias | Microsoft.Extensions.DependencyInjection 8.0 |
| Documentación interactiva | Swagger UI (Swashbuckle) |
| CORS | Habilitado globalmente via `Application_BeginRequest` |

---

## Estructura del proyecto

```
ForraControl/
├── App_Start/
│   ├── WebApiConfig.cs          # Rutas, JSON camelCase, sin XML formatter
│   └── AutoMapperConfig.cs      # Configuración AutoMapper (legado, no se usa en nuevos servicios)
│
├── Controllers/
│   ├── BaseApiController.cs     # Envelope { ok, data } / { ok, error }
│   ├── AuthController.cs        # POST /api/auth/login
│   ├── ProductoController.cs    # GET  /api/productos
│   ├── ClientesController.cs    # GET  /api/clientes
│   ├── VentasController.cs      # POST/GET /api/ventas
│   ├── Admin/
│   │   ├── ProductosAdminController.cs      # CRUD /api/admin/productos
│   │   ├── PresentacionesAdminController.cs # /api/admin/presentaciones
│   │   ├── ClientesAdminController.cs       # CRUD /api/admin/clientes
│   │   ├── DashboardController.cs           # GET /api/admin/dashboard
│   │   └── ReportesController.cs            # GET /api/admin/reportes
│   └── Config/
│       └── ConfigController.cs  # GET/POST /api/config/categorias|subcategorias|unidades
│
├── Data/
│   ├── Entities/
│   │   └── ForraEntities.cs     # Entidades EF Code First (10 clases)
│   └── ForraDb.cs               # DbContext → connection string "ForraDb"
│
├── Infrastructure/
│   └── AppDependencyResolver.cs # IDependencyResolver para Web API 2 + MS.DI
│
├── Models/
│   └── AppDtos.cs               # Todos los DTOs de request/response
│
├── Services/
│   ├── AuthService.cs
│   ├── ProductoService.cs
│   ├── ClienteService.cs
│   ├── VentaService.cs
│   ├── AdminService.cs
│   └── ConfigService.cs
│
├── Infraestructur/
│   └── IProductoService.cs      # Todas las interfaces de servicios (IAuthService, IProductoService, ...)
│
├── Global.asax.cs               # DI registration + CORS handler
└── Web.config                   # Connection strings
```

---

## Base de datos

**SQL Server** · Base de datos: `ForraStore`

### Tablas principales

| Tabla | Descripción |
|---|---|
| `usuarios` | Usuarios del sistema (admin / trabajador) |
| `productos` | Catálogo de productos con categoría, subcategoría y uso |
| `presentaciones` | Variantes de un producto: unidad, tamaño, precio, stock |
| `clientes` | Clientes con precios especiales |
| `precios_especiales` | Precio por cliente por presentación |
| `ventas` | Cabecera de cada venta |
| `detalle_ventas` | Líneas de cada venta (cantidad, precio unitario, subtotal) |

### Columnas clave a tener en cuenta

- `presentaciones.tamano` — `DECIMAL(10,2)`. Representa el tamaño de la presentación (ej. `50` para "Bulto 50 kg").
- `detalle_ventas` — **no tiene** columna `nombre_producto`. El nombre se obtiene via join `presentaciones → productos`.
- No existen tablas `cat_categorias`, `cat_subcategorias` ni `cat_unidades` — los catálogos se leen como valores `DISTINCT` de `productos` y `presentaciones`.

---

## Configuración inicial

### 1. Requisitos

- Visual Studio 2022
- SQL Server (cualquier edición, local)
- .NET Framework 4.8

### 2. Connection string

En `Web.config`, sección `<connectionStrings>`:

```xml
<add name="ForraDb"
     connectionString="data source=TU_SERVIDOR;initial catalog=ForraStore;user id=sa;password=TU_PASSWORD;encrypt=False;MultipleActiveResultSets=True"
     providerName="System.Data.SqlClient" />
```

Cambiar `TU_SERVIDOR` y `TU_PASSWORD` según el entorno.

### 3. Base de datos

Ejecutar el script SQL del proyecto para crear tablas y datos iniciales en `ForraStore`.

Los passwords del seed son comparados como texto plano (no BCrypt). Para desarrollo:

```sql
USE ForraStore;
UPDATE usuarios SET password_hash = '123456789';
```

### 4. Correr

Abrir `ForraControl.sln` en Visual Studio → **F5** (IIS Express).

Swagger UI disponible en: `https://localhost:44310/swagger`

---

## Respuesta estándar

Todos los endpoints usan el mismo sobre:

```json
// Éxito
{ "ok": true, "data": { ... } }

// Error
{ "ok": false, "error": "Descripción del error" }
```

Códigos HTTP utilizados:

| Código | Cuándo |
|---|---|
| 200 | GET exitoso |
| 201 | POST exitoso (recurso creado) |
| 204 | DELETE exitoso |
| 400 | Datos inválidos / campo requerido faltante |
| 401 | Credenciales incorrectas |
| 404 | Recurso no encontrado |
| 500 | Error interno del servidor |

---

## Endpoints

### Auth
| Método | Ruta | Descripción |
|---|---|---|
| POST | `/api/auth/login` | Login de usuario |

### Trabajador (app móvil)
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/productos` | Catálogo de productos activos con presentaciones |
| GET | `/api/clientes` | Dropdown de clientes con precios especiales |
| POST | `/api/ventas` | Registrar venta (descuenta stock) |
| GET | `/api/ventas` | Historial (`?idUsuario=&periodo=hoy\|semana\|mes`) |
| GET | `/api/ventas/{id}` | Detalle de una venta |

### Admin — Productos
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/admin/productos` | Todos los productos (activos e inactivos) |
| POST | `/api/admin/productos` | Crear producto con presentaciones iniciales |
| PUT | `/api/admin/productos/{id}` | Actualizar datos generales |
| DELETE | `/api/admin/productos/{id}` | Desactivar producto (soft delete) |
| POST | `/api/admin/productos/{id}/presentaciones` | Agregar presentación |

### Admin — Presentaciones
| Método | Ruta | Descripción |
|---|---|---|
| PUT | `/api/admin/presentaciones/{id}` | Actualizar presentación |
| DELETE | `/api/admin/presentaciones/{id}` | Eliminar presentación |
| PATCH | `/api/admin/presentaciones/{id}/stock` | Agregar stock |

### Admin — Clientes
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/admin/clientes` | Todos los clientes con precios especiales |
| POST | `/api/admin/clientes` | Crear cliente |
| PUT | `/api/admin/clientes/{id}` | Actualizar cliente |
| DELETE | `/api/admin/clientes/{id}` | Eliminar cliente |
| PUT | `/api/admin/clientes/{id}/precios` | Reemplazar precios especiales |

### Admin — Dashboard y Reportes
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/admin/dashboard` | KPIs: ventas hoy, semana, alertas stock, top productos |
| GET | `/api/admin/reportes?periodo=hoy` | Reporte con desglose (`hoy`/`semana`/`mes`) |

### Config (catálogos)
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/config/categorias` | Lista de categorías únicas |
| POST | `/api/config/categorias` | Agregar categoría |
| GET | `/api/config/subcategorias` | Lista de subcategorías únicas |
| POST | `/api/config/subcategorias` | Agregar subcategoría |
| GET | `/api/config/unidades` | Lista de unidades únicas |
| POST | `/api/config/unidades` | Agregar unidad |

**Total: 27 endpoints**

---

## Inyección de dependencias

Se usa `Microsoft.Extensions.DependencyInjection` con un `IDependencyResolver` personalizado (`AppDependencyResolver`). El registro se hace en `Global.asax.cs`:

```csharp
services.AddScoped<ForraDb>();
services.AddScoped<IAuthService, AuthService>();
services.AddScoped<IProductoService, ProductoService>();
// ...
```

Cada request de Web API obtiene un scope propio — `ForraDb` (y su conexión SQL) se crea y destruye por request.

---

## CORS

Configurado en `Global.asax.cs` via `Application_BeginRequest`:

```
Access-Control-Allow-Origin:  *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

Las peticiones `OPTIONS` (preflight) se responden con `200` y se cortan antes de llegar a los controladores.

---

## Notas de desarrollo

- **Passwords:** El sistema compara texto plano. Para producción se debe integrar BCrypt u otro hash.
- **Auth:** No hay JWT implementado actualmente. El frontend gestiona la sesión localmente con los datos devueltos por `/api/auth/login`.
- **Stock negativo:** El servicio no valida que haya stock suficiente al registrar una venta. Agregar validación si se requiere.
- **Soft delete:** Los productos se desactivan (`activo = false`), no se borran. Los clientes sí se borran (hard delete).
- **Vistas SQL** (`vw_catalogo`, `vw_stock_bajo`, `vw_ventas_detalle`): existen en la BD pero no se usan desde el código Code First. Son parte del modelo EDMX legacy.
