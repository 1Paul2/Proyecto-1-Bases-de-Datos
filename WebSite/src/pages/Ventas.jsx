import { useEffect, useState } from 'react';
import { pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Paginacion from '../components/Paginacion';

const POR_PAGINA = 10;

const columnas = [
  { clave: 'InvoiceID', titulo: 'Factura' },
  { clave: 'InvoiceDate', titulo: 'Fecha' },
  { clave: 'CustomerName', titulo: 'Cliente' },
  { clave: 'DeliveryMethod', titulo: 'Método de entrega' },
  { clave: 'TotalAmount', titulo: 'Monto' }
];

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
  const ventasVisibles = ventas.slice(inicio, inicio + POR_PAGINA);

  return (
    <section>
      <h1>Ventas</h1>

      <div className="barra-filtros">
        <Filtros
          campos={campos}
          valores={filtros}
          onCambio={cambiarFiltro}
        />

        <button type="button" onClick={restaurarFiltros}>
          Restaurar filtros
        </button>
      </div>

      {error && <p className="mensaje-error">{error}</p>}

      <p>{ventas.length} resultados</p>

      <Tabla
        columnas={columnas}
        filas={ventasVisibles}
        onFila={verDetalle}
      />
      <Paginacion
        total={ventas.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />

      {detalle && (
        <div className="fondo" onClick={() => setDetalle(null)}>
          <div className="ventana" onClick={evento => evento.stopPropagation()}>
            <button type="button" onClick={() => setDetalle(null)}>
              Cerrar
            </button>

            <h2>Encabezado de factura</h2>

            <dl>
              {Object.entries(detalle.encabezado).map(([clave, valor]) => (
                <div key={clave}>
                  <dt>{clave.replaceAll('_', ' ')}</dt>
                  <dd>{valor ?? '—'}</dd>
                </div>
              ))}
            </dl>

            <h2>Detalle de factura</h2>

            <Tabla
              columnas={[
                { clave: 'StockItemName', titulo: 'Producto' },
                { clave: 'Quantity', titulo: 'Cantidad' },
                { clave: 'UnitPrice', titulo: 'Precio unitario' },
                { clave: 'TaxRate', titulo: 'Impuesto' },
                { clave: 'TaxAmount', titulo: 'Monto impuesto' },
                { clave: 'ExtendedPrice', titulo: 'Total línea' }
              ]}
              filas={detalle.lineas}
            />
          </div>
        </div>
      )}
    </section>
  );
}