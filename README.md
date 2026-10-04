# Sistema de Gestión WideWorldImporters

Proyecto 1 – Bases de Datos 2

---

## Nombre y carné de los integrantes

- Poll Garro Vargas – 2024129001
- Angelo Piedra Castro – 2024101262

---

## Estado del proyecto

### Objetivos alcanzados

#### SQL Server

- **Sinónimos:** se crearon sinónimos para todas las tablas utilizadas (`Syn_Customers`, `Syn_Suppliers`, `Syn_StockItems`, `Syn_Invoices`, etc.) y los stored procedures acceden a las tablas a través de estos sinónimos.
- **Transacciones:** todos los procedimientos almacenados de inserción, actualización y eliminación implementan `BEGIN TRANSACTION`, `COMMIT` y `ROLLBACK` con manejo de errores mediante `TRY/CATCH`.
- **Stored Procedures de gestión (CRUD):**
  - Clientes: `SP_LISTA_CLIENTES`, `SP_CLIENTES`, `SP_InsertCustomer`, `SP_UpdateCustomer`, `SP_DeleteCustomer`.
  - Proveedores: `SP_GetSuppliers`, `SP_GetSupplierDetails`, `SP_GetSupplierCategories`, `SP_InsertSupplier`, `SP_UpdateSupplier`, `SP_DeleteSupplier`.
  - Productos: `SP_GetStockItems`, `SP_GetStockItemDetails`, `SP_GetStockGroups`, `SP_InsertStockItem`, `SP_UpdateStockItem`, `SP_DeleteStockItem`.
  - Ventas: `SP_GetSales`, `SP_GetSaleHeader`, `SP_GetSaleDetails`, `SP_InsertSale`, `SP_UpdateSale`, `SP_DeleteSale`.
- **Stored Procedures de estadísticas y reportes (10 en total):**
  1. Montos altos, bajos y promedio de compras a proveedores agrupados por proveedor y categoría usando `ROLLUP`. Filtrable por categoría y nombre del proveedor.
  2. Montos altos, bajos y promedio de ventas a clientes agrupados por cliente y categoría usando `ROLLUP`. Filtrable por nombre del cliente y categoría.
  3. Top 5 productos con mayor ganancia en ventas por año usando `DENSE_RANK` y `PARTITION BY`. Filtrable por año.
  4. Top 5 clientes con mayor cantidad de facturas emitidas por año y monto total facturado usando `DENSE_RANK` y `PARTITION BY`. Filtrable por rango de años.
  5. Top 5 proveedores con mayor cantidad de órdenes de compra por año y monto total usando `DENSE_RANK` y `PARTITION BY`. Filtrable por rango de años.
  6. Matriz resumen de ventas de categorías de productos por año.
  7. Seguimiento de compras a clientes: resumen mensual con monto total, primera y última factura, cantidad total, mínima y máxima. Filtrable por año, mes, categoría y subcategoría.
  8. Seguimiento de compras a proveedores: resumen mensual con monto total, primera y última factura, cantidad total, mínima y máxima. Filtrable por año, mes, categoría y subcategoría.
  9. Promedio de días de rotación de inventario por producto. Filtrable por categoría, año y proveedor.
  10. Método de envío favorito según lugar de remisión de la venta, ordenado por cantidad de ventas. Filtrable por año, mes, categoría de cliente, categoría de producto y producto.

#### API (Node.js + Express)

- API REST desarrollada con Express.js y conexión a SQL Server mediante `mssql`.
- Rutas organizadas por módulo: `/api/clientes`, `/api/proveedores`, `/api/productos`, `/api/ventas`, `/api/estadisticas`.
- Todas las consultas se realizan exclusivamente mediante stored procedures; no hay manipulación ni agrupación de datos en la API.
- Validación de campos obligatorios del lado del servidor antes de ejecutar los stored procedures.
- Manejo de errores con códigos HTTP apropiados (400 para errores de validación del SP, 500 para errores internos).

#### Aplicación Web (React + Vite)

- **Módulo de clientes:** tabla con filtro por nombre (texto libre), restaurar filtros, orden alfabético ascendente. Detalle en ventana modal con todos los campos requeridos. Mapa de ubicación con Leaflet. CRUD completo (crear, editar, eliminar).
- **Módulo de proveedores:** tabla con filtro por nombre (texto libre) y categoría (select). Restaurar filtros, orden alfabético ascendente. Detalle en ventana modal con todos los campos requeridos. CRUD completo.
- **Módulo de productos:** tabla con filtro por nombre (texto libre) y grupo (select), mostrando cantidad disponible (Holdings). Restaurar filtros, orden alfabético ascendente. Detalle en ventana modal con todos los campos requeridos. CRUD completo.
- **Módulo de ventas:** tabla con filtro por nombre de cliente, rango de fechas y rango de montos. Restaurar filtros, orden por nombre de cliente. Detalle con encabezado y líneas de factura en ventana modal. CRUD completo.
- **Módulo de estadísticas:** selector de reporte con los 10 reportes implementados, cada uno con sus filtros correspondientes. Resultados en tabla con paginación.
- **Características generales:** paginación en todos los módulos, mensajes de éxito y error, diseño responsivo, validación de formularios, componentes reutilizables.

### Objetivos no alcanzados

- Ninguno. Todos los módulos y funcionalidades solicitadas fueron implementados.

---

## Enlace del video

[Video de demostración](https://youtube.com)

> El video está configurado como **público** para que pueda ser visto.

---

## Tecnologías utilizadas

| Capa | Tecnología |
|------|-----------|
| Base de datos | SQL Server – WideWorldImporters |
| Backend / API | Node.js, Express.js, mssql |
| Frontend | React 18, Vite |
| Mapas | Leaflet + React-Leaflet |
| Estilos | CSS personalizado |

## Estructura del repositorio

```
├── Script/                  # Procedimientos almacenados y objetos SQL
│   ├── sinonimos.sql        # Creación de sinónimos
│   ├── sp_clientes.sql      # SPs de consulta de clientes
│   ├── sp_proveedores.sql   # SPs de consulta de proveedores
│   ├── sp_productos.sql     # SPs de consulta de productos
│   ├── sp_ventas.sql        # SPs de consulta de ventas
│   ├── ejemplo_ejecucion.sql# Ejemplos de ejecución de SPs
│   ├── CRUD/                # SPs de Insert, Update, Delete
│   │   ├── CLIENTES/
│   │   ├── PROVEEDORES/
│   │   ├── PRODUCTOS/
│   │   └── VENTAS/
│   └── estadisticas/        # 10 SPs de reportes y estadísticas
├── Api/                     # Código del servidor API (Express.js)
│   ├── index.js
│   ├── db.js
│   └── routes/
└── WebSite/                 # Código de la aplicación web (React)
    └── src/
        ├── pages/           # Módulos principales
        ├── components/      # Componentes reutilizables
        └── styles/          # Hojas de estilo
```