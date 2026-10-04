import { useEffect, useState } from 'react';
import { enviar, pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Paginacion from '../components/Paginacion';
import Factura from '../components/Factura';

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

const formularioInicial = {
  CustomerID: '',
  DeliveryMethodID: '',
  CustomerPurchaseOrderNumber: '',
  ContactPersonID: '',
  SalespersonPersonID: '',
  InvoiceDate: new Date().toISOString().slice(0, 10),
  DeliveryInstructions: ''
};

export default function Ventas() {
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [ventas, setVentas] = useState([]);
  const [pagina, setPagina] = useState(1);
  const [detalle, setDetalle] = useState(null);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [formulario, setFormulario] = useState(formularioInicial);
  const [modoFormulario, setModoFormulario] = useState(null);
  const [guardando, setGuardando] = useState(false);

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

  const recargar = async () => {
    const params = new URLSearchParams();
    if (filtros.cliente) params.append('cliente', filtros.cliente);
    if (filtros.desde) params.append('desde', filtros.desde);
    if (filtros.hasta) params.append('hasta', filtros.hasta);
    if (filtros.min) params.append('min', filtros.min);
    if (filtros.max) params.append('max', filtros.max);

    const res = await pedir(`/ventas?${params}`);
    setVentas(res.data);
  };

  const verDetalle = async fila => {
    try {
      const res = await pedir(`/ventas/${fila.InvoiceID}`);
      setDetalle(res);
    } catch (err) {
      setError(err.message);
    }
  };

  const abrirNuevo = () => {
    setError('');
    setMensaje('');
    setFormulario(formularioInicial);
    setModoFormulario('nuevo');
  };

  const abrirEdicion = async fila => {
    try {
      const res = await pedir(`/ventas/${fila.InvoiceID}`);
      const datos = res.encabezado;
      setError('');
      setMensaje('');
      setFormulario({
        InvoiceID: datos.InvoiceID,
        CustomerID: datos.CustomerID ?? '',
        DeliveryMethodID: datos.DeliveryMethodID ?? '',
        CustomerPurchaseOrderNumber: datos.CustomerPurchaseOrderNumber ?? '',
        ContactPersonID: datos.ContactPersonID ?? '',
        SalespersonPersonID: datos.SalespersonPersonID ?? '',
        InvoiceDate: datos.InvoiceDate ? String(datos.InvoiceDate).slice(0, 10) : '',
        DeliveryInstructions: datos.DeliveryInstructions ?? ''
      });
      setModoFormulario('editar');
    } catch (err) {
      setError(err.message);
    }
  };

  const cambiarFormulario = evento => {
    const { name, value } = evento.target;
    setFormulario(anterior => ({ ...anterior, [name]: value }));
  };

  const guardar = async evento => {
    evento.preventDefault();
    setGuardando(true);
    setError('');
    setMensaje('');

    try {
      const datos = {
        CustomerID: Number(formulario.CustomerID),
        DeliveryMethodID: Number(formulario.DeliveryMethodID),
        CustomerPurchaseOrderNumber: formulario.CustomerPurchaseOrderNumber.trim(),
        ContactPersonID: Number(formulario.ContactPersonID),
        SalespersonPersonID: Number(formulario.SalespersonPersonID),
        InvoiceDate: formulario.InvoiceDate,
        DeliveryInstructions: formulario.DeliveryInstructions.trim()
      };

      if (modoFormulario === 'nuevo') {
        await enviar('/ventas', 'POST', datos);
        setMensaje('Venta creada correctamente.');
      } else {
        await enviar(`/ventas/${formulario.InvoiceID}`, 'PUT', datos);
        setMensaje('Venta actualizada correctamente.');
      }

      setModoFormulario(null);
      setPagina(1);
      await recargar();
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  };

  const eliminar = async fila => {
    if (!window.confirm(`¿Eliminar la venta con factura #${fila.InvoiceID}?`)) return;
    try {
      await enviar(`/ventas/${fila.InvoiceID}`, 'DELETE');
      setMensaje('Venta eliminada correctamente.');
      setVentas(actuales => actuales.filter(item => item.InvoiceID !== fila.InvoiceID));
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
        <div className="modulo-acciones">
          <button type="button" className="btn btn-primario" onClick={abrirNuevo}>
            + Nueva venta
          </button>
        </div>
      </div>

      <div className="barra-filtros">
        <Filtros campos={campos} valores={filtros} onCambio={cambiarFiltro} />
        <button type="button" className="btn btn-fantasma" onClick={restaurarFiltros}>
          Restaurar filtros
        </button>
      </div>

      {error && <p className="mensaje mensaje-error">{error}</p>}
      {mensaje && <p className="mensaje mensaje-exito">{mensaje}</p>}

      <div className="tabla-wrapper">
        <Tabla
          columnas={columnas}
          filas={ventasVisibles}
          onFila={verDetalle}
          acciones={fila => (
            <div className="acciones-fila">
              <button type="button" onClick={e => { e.stopPropagation(); abrirEdicion(fila); }}>Editar</button>
              <button type="button" onClick={e => { e.stopPropagation(); eliminar(fila); }}>Eliminar</button>
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
              // Cuando tengas la navegación entre módulos, pasa aquí:
              // onVerCliente={h => ...}  onVerProducto={l => ...}
            />
          </div>
        </div>
      )}

      {modoFormulario && (
        <div className="fondo" onClick={() => setModoFormulario(null)}>
          <form className="ventana formulario" onSubmit={guardar} onClick={e => e.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setModoFormulario(null)} aria-label="Cerrar">✕</button>
            <h2>{modoFormulario === 'nuevo' ? 'Nueva venta' : 'Editar venta'}</h2>

            <label>
              ID de cliente
              <input
                name="CustomerID"
                type="number"
                min="1"
                value={formulario.CustomerID}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <label>
              ID de método de entrega
              <input
                name="DeliveryMethodID"
                type="number"
                min="1"
                value={formulario.DeliveryMethodID}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <label>
              Número de orden de compra
              <input
                name="CustomerPurchaseOrderNumber"
                maxLength={20}
                value={formulario.CustomerPurchaseOrderNumber}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <label>
              ID persona de contacto
              <input
                name="ContactPersonID"
                type="number"
                min="1"
                value={formulario.ContactPersonID}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <label>
              ID vendedor
              <input
                name="SalespersonPersonID"
                type="number"
                min="1"
                value={formulario.SalespersonPersonID}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <label>
              Fecha de factura
              <input
                name="InvoiceDate"
                type="date"
                value={formulario.InvoiceDate}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <label>
              Instrucciones de entrega
              <textarea
                name="DeliveryInstructions"
                maxLength={500}
                rows={3}
                value={formulario.DeliveryInstructions}
                onChange={cambiarFormulario}
                required
              />
            </label>

            <button type="submit" disabled={guardando}>
              {guardando ? 'Guardando...' : 'Guardar'}
            </button>
          </form>
        </div>
      )}
    </section>
  );
}