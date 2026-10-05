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

- **Sinónimos:** se crearon sinónimos para todas las tablas utilizadas (`Syn_Customers`, `Syn_Suppliers`, `Syn_StockItems`, `Syn_Invoices`, etc.) y los stored procedures acceden a las tablas únicamente a través de ellos.
- **Transacciones:** todos los procedimientos de inserción, actualización y eliminación usan `BEGIN TRANSACTION`, `COMMIT` y `ROLLBACK` con manejo de errores mediante `TRY/CATCH`. Si algo falla no se guarda nada.
- **Procesamiento en la base de datos:** todo el filtrado, agrupación y cálculo se hace en stored procedures. La API y la web solo reciben y muestran resultados.
- **Stored Procedures de gestión (CRUD):**
  - Clientes: `SP_LISTA_CLIENTES`, `SP_CLIENTES`, `SP_InsertCustomer`, `SP_UpdateCustomer`, `SP_DeleteCustomer`.
  - Proveedores: `SP_GetSuppliers`, `SP_GetSupplierDetails`, `SP_GetSupplierCategories`, `SP_InsertSupplier`, `SP_UpdateSupplier`, `SP_DeleteSupplier`.
  - Productos: `SP_GetStockItems`, `SP_GetStockItemDetails`, `SP_GetStockGroups`, `SP_InsertStockItem`, `SP_UpdateStockItem`, `SP_DeleteStockItem`.
  - Ventas: `SP_GetSales`, `SP_GetSaleHeader`, `SP_GetSaleDetails`, `SP_InsertSale`, `SP_UpdateSale`, `SP_DeleteSale`.
- **Stored Procedures de estadísticas y reportes (10 en total):**
  1. `sp_estadistica_proveedor`: monto mínimo, máximo y promedio de los pedidos a proveedores, por proveedor y categoría, con `ROLLUP`. Filtrable por proveedor y categoría.
  2. `sp_estadistica_cliente`: monto mínimo, máximo y promedio de las facturas de los clientes, por cliente y categoría, con `ROLLUP`. Filtrable por cliente y categoría.
  3. `sp_top5_productos_ganancia`: top 5 de productos con más ganancia por año, con `DENSE_RANK` y `PARTITION BY`. Filtrable por año.
  4. `sp_top5_clientes_facturas`: top 5 de clientes con más facturas por año y su monto total, con `DENSE_RANK` y `PARTITION BY`. Filtrable por rango de años.
  5. `sp_top5_proveedores_ordenes`: top 5 de proveedores con más órdenes por año y su monto total, con `DENSE_RANK` y `PARTITION BY`. Filtrable por rango de años.
  6. `sp_matriz_ventas_categoria_anio`: matriz de ventas por categoría de producto (filas) y año (columnas), con `PIVOT`.
  7. `sp_seguimiento_compras_cliente`: resumen mensual por cliente con monto total, primera y última factura, cantidad total, mínima y máxima. Filtrable por año, mes y categoría.
  8. `sp_seguimiento_compras_proveedor`: lo mismo por proveedor, con sus órdenes de compra. Filtrable por año, mes y categoría.
  9. `sp_rotacion_inventario`: rotación de inventario y promedio de días de rotación por producto y año. Filtrable por año, categoría y proveedor.
  10. `sp_metodo_envio_favorito`: método de envío favorito según el lugar al que se envió la venta, ordenado por cantidad de ventas. Filtrable por año, mes, categoría de cliente, categoría de producto y producto.
- **Ejemplos de ejecución:** `Script/ejemplo_ejecucion.sql` ejecuta los reportes, las consultas de cada módulo, el ciclo crear / cambiar / borrar de productos y ventas, y una prueba de `ROLLBACK`.

#### API (Node.js + Express)

- API REST con Express y conexión a SQL Server mediante `mssql`.
- Una ruta por módulo: `/api/clientes`, `/api/proveedores`, `/api/productos`, `/api/ventas` y `/api/estadisticas`.
- Todas las consultas se hacen mediante stored procedures; la API no agrupa ni calcula datos.
- Validación de campos obligatorios antes de ejecutar los procedimientos.
- Manejo de errores con códigos HTTP apropiados (400 para errores de validación, 500 para errores internos).
- Al arrancar, `init.js` carga automáticamente todos los scripts de `Script/` en la base de datos.

#### Aplicación web (React + Vite)

- **Clientes:** tabla con filtro por nombre (texto libre), restaurar filtros y orden alfabético. Detalle en ventana aparte con mapa de la ubicación. Crear, editar y eliminar.
- **Proveedores:** tabla con filtro por nombre y por categoría, restaurar filtros y orden alfabético. Detalle en ventana aparte. Crear, editar y eliminar.
- **Productos:** tabla con filtro por nombre y por grupo, con la cantidad disponible. Restaurar filtros y orden alfabético. Detalle en ventana aparte. Crear, editar y eliminar.
- **Ventas:** tabla con filtros acumulativos por cliente, rango de fechas y rango de montos. Restaurar filtros. Detalle en ventana aparte con la factura completa (encabezado, líneas, impuesto y total). Desde la factura se puede abrir el detalle del cliente y de cada producto.
- **Estadísticas:** selector con los 10 reportes, cada uno con sus filtros. Resultados en tabla con paginación.
- **General:** botón «Ver detalles» en cada fila, paginación, mensajes de éxito y error, y los campos sin dato se muestran como «Vacío». En los reportes con `ROLLUP`, las filas de subtotal dicen «Total».

### Objetivos no alcanzados y decisiones

- **Filtro por subcategoría en los reportes 7 y 8:** la base de datos solo tiene un nivel de categoría (categorías de cliente, de proveedor y grupos de producto). No existen subcategorías, así que esos reportes se filtran por año, mes y categoría.
- **Ventas sin crear, editar ni eliminar desde la web:** una factura emitida no debe alterarse. La interfaz solo consulta ventas. Los procedimientos `SP_InsertSale`, `SP_UpdateSale` y `SP_DeleteSale` existen con su transacción y están disponibles en la API y en `ejemplo_ejecucion.sql`.
- **Impuesto en las ventas:** `ExtendedPrice` de cada línea ya incluye el impuesto (cantidad × precio + impuesto), igual que en la base original. El encabezado de la factura calcula subtotal, impuestos y total a partir de las líneas.
- **Matriz de ventas (reporte 6):** se agrupa por categoría de producto, una fila por categoría. Los datos terminan en mayo de 2016, por eso 2016 aparece incompleto.
- **Rotación de inventario (reporte 9):** la base no trae saldo de apertura y los movimientos de compra y venta no cuadran con la existencia actual. Se parte de la existencia actual, se retrocede con los movimientos y, si aun así el resultado fuera negativo, se usa el saldo inicial mínimo que evita inventarios negativos (nunca menor que cero). Rotación = unidades vendidas ÷ inventario promedio, con inventario promedio = (inicial + final) ÷ 2. Con estos datos la rotación sale baja en muchos productos y el inventario final de algunos supera la existencia real; es una limitación de los datos de WideWorldImporters, no del cálculo.
- **Borrado de productos y clientes con historial:** un producto con ventas, compras o movimientos no se puede eliminar; el procedimiento revierte todo y devuelve un mensaje claro.

---

## Instalación y ejecución

1. **Base de datos.** Restaurar `WideWorldImporters-Full.bak` en SQL Server.
2. **API.** Crear el archivo `Api/.env` (se puede copiar de `Api/.env.example`):

   ```
   DB_USER=sa
   DB_PASSWORD=<su clave>
   DB_SERVER=localhost
   DB_NAME=WideWorldImporters
   PORT=3000
   ```

   Luego, desde la carpeta `Api`:

   ```bash
   npm install
   node index.js
   ```

   Al iniciar, la API crea los sinónimos y los stored procedures. No hace falta ejecutar los scripts a mano.
3. **Web.** Desde la carpeta `WebSite`:

   ```bash
   npm install
   npm run dev
   ```

4. **Ejemplos de ejecución (opcional):**

   ```bash
   sqlcmd -S localhost -U sa -P '<clave>' -d WideWorldImporters -C -I -i Script/ejemplo_ejecucion.sql
   ```

   La opción `-I` es necesaria para los procedimientos de ventas.

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
├── Script/                      # Todo el código SQL
│   ├── ejemplo_ejecucion.sql    # Ejemplos de ejecución
│   ├── sql/                     # Sinónimos y consultas de cada módulo
│   ├── CRUD/                    # Insert, Update y Delete
│   │   ├── CLIENTES/
│   │   ├── PROVEEDORES/
│   │   ├── PRODUCTOS/
│   │   └── VENTAS/
│   └── estadisticas/            # Los 10 reportes
├── Api/                         # Servidor API (Express.js)
│   ├── index.js
│   ├── db.js
│   ├── init.js
│   └── routes/
└── WebSite/                     # Aplicación web (React)
    └── src/
        ├── pages/               # Módulos principales
        ├── components/          # Componentes reutilizables
        └── styles/              # Hojas de estilo
```