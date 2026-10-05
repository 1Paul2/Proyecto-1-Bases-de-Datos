import { useEffect, useState } from 'react';
import { pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Paginacion from '../components/Paginacion';
import Factura from '../components/Factura';
import Mapa from '../components/Mapa';

const POR_PAGINA = 10;

const columnas = [
  { clave: 'InvoiceID', titulo: 'Factura' },
  { clave: 'InvoiceDate', titulo: 'Fecha' },
  { clave: 'CustomerName', titulo: 'Cliente' },
  { clave: 'DeliveryMethod', titulo: 'Método de entrega' },
  { clave: 'TotalAmount', titulo: 'Monto' }
];

// [etiqueta, columna que devuelve SP_CLIENTES]
const camposCliente = [
  ['Nombre', 'Nombre'],
  ['Categoría', 'Categoría'],
  ['Grupo de compra', 'Grupo_de_compra'],
  ['Contacto primario', 'Contacto_Primario'],
  ['Contacto alternativo', 'Contacto_Secundario'],
  ['Cliente por facturar', 'Cliente_por_facturar'],
  ['Método de entrega', 'Métodos_de_entrega'],
  ['Ciudad de entrega', 'Ciudad_de_entrega'],
  ['Código postal', 'Código_postal'],
  ['Teléfono', 'Telefono'],
  ['Fax', 'Fax'],
  ['Días de gracia para pagar', 'Días_de_gracia_para_pagar'],
  ['Sitio web', 'Sitio_web'],
  ['Dirección de entrega 1', 'Direccion_Entrega_1'],
  ['Dirección de entrega 2', 'Direccion_Entrega_2'],
  ['Dirección postal 1', 'Direccion_Postal_1'],
  ['Dirección postal 2', 'Direccion_Postal_2']
];

// [etiqueta, columna que devuelve SP_GetStockItemDetails]
const camposProducto = [
  ['Nombre del producto', 'StockItemName'],
  ['Proveedor', 'SupplierName'],
  ['Color', 'ColorName'],
  ['Unidad de empaquetamiento', 'UnitPackageTypeName'],
  ['Empaquetamiento', 'OuterPackageTypeName'],
  ['Cantidad de empaquetamiento', 'QuantityPerOuter'],
  ['Marca', 'Brand'],
  ['Tallas / tamaño', 'Size'],
  ['Impuesto', 'TaxRate'],
  ['Precio unitario', 'UnitPrice'],
  ['Precio de venta recomendado', 'RecommendedRetailPrice'],
  ['Peso', 'TypicalWeightPerUnit'],
  ['Palabras clave', 'SearchDetails'],
  ['Cantidad disponible', 'QuantityOnHand'],
  ['Ubicación', 'BinLocation']
];

const dinero = v =>
  Number(v).toLocaleString('es-CR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

// Solo presentación: no se calcula ni agrupa nada
const FORMATOS_PRODUCTO = {
  TaxRate: v => `${Number(v)} %`,
  UnitPrice: dinero,
  RecommendedRetailPrice: dinero,
  TypicalWeightPerUnit: v => `${Number(v)} kg`
};

const filtrosIniciales = {
  cliente: '',
  desde: '',
  hasta: '',
  min: '',
  max: ''
};

export default function Ventas() {
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [ventas, setVentas] = useState([]);
  const [pagina, setPagina] = useState(1);
  const [detalle, setDetalle] = useState(null);
  const [cliente, setCliente] = useState(null);
  const [producto, setProducto] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    const params = new URLSearchParams();

    if (filtros.cliente) params.append('cliente', filtros.cliente);
    if (filtros.desde) params.append('desde', filtros.desde);
    if (filtros.hasta) params.append('hasta', filtros.hasta);
    if (filtros.min) params.append('min', filtros.min);
    if (filtros.max) params.append('max', filtros.max);

    pedir(`/ventas?${params}`)
      .then(res => {
        setVentas(res.data);
        setError('');
      })
      .catch(err => setError(err.message));
  }, [filtros]);

  const cambiarFiltro = (nombre, valor) => {
    setPagina(1);
    setFiltros(anterior => ({
      ...anterior,
      [nombre]: valor
    }));
  };

  const restaurarFiltros = () => {
    setPagina(1);
    setFiltros(filtrosIniciales);
  };

  const verDetalle = async fila => {
    try {
      const res = await pedir(`/ventas/${fila.InvoiceID}`);
      setDetalle(res);
    } catch (err) {
      setError(err.message);
    }
  };

  // Enlace del nombre del cliente: abre su detalle (el SP lo busca por nombre)
  const verCliente = async encabezado => {
    const nombre = encabezado?.CustomerName ?? encabezado;
    try {
      const res = await pedir(`/clientes/${encodeURIComponent(nombre)}`);
      setCliente(res.data[0]);
    } catch (err) {
      setError(err.message);
    }
  };

  // Enlace del nombre del producto: abre su detalle
  const verProducto = async linea => {
    const id = linea?.StockItemID ?? linea;
    try {
      const res = await pedir(`/productos/${id}`);
      setProducto(res.data[0]);
    } catch (err) {
      setError(err.message);
    }
  };

  const campos = [
    {
      nombre: 'cliente',
      etiqueta: 'Cliente',
      tipo: 'text'
    },
    {
      nombre: 'desde',
      etiqueta: 'Desde',
      tipo: 'date'
    },
    {
      nombre: 'hasta',
      etiqueta: 'Hasta',
      tipo: 'date'
    },
    {
      nombre: 'min',
      etiqueta: 'Monto mínimo',
      tipo: 'number'
    },
    {
      nombre: 'max',
      etiqueta: 'Monto máximo',
      tipo: 'number'
    }
  ];

  const inicio = (pagina - 1) * POR_PAGINA;
  const ventasVisibles = ventas.slice(inicio, inicio + POR_PAGINA).map(v => ({
    ...v,
    InvoiceDate: v.InvoiceDate ? String(v.InvoiceDate).slice(0, 10) : ''
  }));

  return (
    <section className="modulo">
      <div className="modulo-header">
        <div className="modulo-header-texto">
          <p className="modulo-eyebrow">Facturación y Pedidos</p>
          <h1 className="modulo-titulo">Ventas</h1>
          <span className="modulo-contador">
            {ventas.length} {ventas.length === 1 ? 'resultado' : 'resultados'}
          </span>
        </div>
      </div>

      <div className="barra-filtros">
        <Filtros campos={campos} valores={filtros} onCambio={cambiarFiltro} />
        <button type="button" className="btn btn-fantasma" onClick={restaurarFiltros}>
          Restaurar filtros
        </button>
      </div>

      {error && <p className="mensaje mensaje-error">{error}</p>}

      <div className="tabla-wrapper">
        <Tabla
          columnas={columnas}
          filas={ventasVisibles}
          onFila={verDetalle}
          acciones={fila => (
            <div className="acciones-fila">
              <button
                type="button"
                style={{ background: '#16a34a', color: '#fff', borderColor: '#16a34a' }}
                onClick={e => { e.stopPropagation(); verDetalle(fila); }}
              >
                Ver detalles
              </button>
              <span aria-hidden="true" />
            </div>
          )}
        />
      </div>

      <Paginacion
        total={ventas.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />

      {detalle && (
        <div className="fondo" onClick={() => setDetalle(null)}>
          <div className="ventana ventana-factura" onClick={e => e.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setDetalle(null)} aria-label="Cerrar">✕</button>

            <Factura
              encabezado={detalle.encabezado}
              lineas={detalle.lineas || []}
              onVerCliente={verCliente}
              onVerProducto={verProducto}
            />
          </div>
        </div>
      )}

      {cliente && (
        <div className="fondo" onClick={() => setCliente(null)}>
          <div className="ventana" onClick={e => e.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setCliente(null)} aria-label="Cerrar">✕</button>

            <h2>Detalle del cliente</h2>

            <dl>
              {camposCliente.map(([etiqueta, clave]) => {
                const valor = cliente[clave];
                const vacio = valor === null || valor === undefined || valor === '';
                return (
                  <div key={clave}>
                    <dt>{etiqueta}</dt>
                    <dd>
                      {vacio
                        ? 'Vacío'
                        : clave === 'Sitio_web'
                          ? <a href={valor} target="_blank" rel="noreferrer">{valor}</a>
                          : String(valor)}
                    </dd>
                  </div>
                );
              })}
            </dl>

            <h2>Ubicación de entrega</h2>
            <Mapa
              latitud={cliente.Latitud}
              longitud={cliente.Longitud}
              titulo={cliente.Nombre}
              subtitulo={cliente.DeliveryAddressLine1}
            />
          </div>
        </div>
      )}

      {producto && (
        <div className="fondo" onClick={() => setProducto(null)}>
          <div className="ventana" onClick={e => e.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setProducto(null)} aria-label="Cerrar">✕</button>

            <h2>Detalle del producto</h2>

            <dl>
              {camposProducto.map(([etiqueta, clave]) => {
                const valor = producto[clave];
                const vacio = valor === null || valor === undefined || valor === '';
                const formatear = FORMATOS_PRODUCTO[clave];
                return (
                  <div key={clave}>
                    <dt>{etiqueta}</dt>
                    <dd>{vacio ? 'Vacío' : formatear ? formatear(valor) : String(valor)}</dd>
                  </div>
                );
              })}
            </dl>
          </div>
        </div>
      )}
    </section>
  );
}