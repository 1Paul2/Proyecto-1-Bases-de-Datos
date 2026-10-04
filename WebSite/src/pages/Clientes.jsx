import { useState, useEffect } from 'react';
import { enviar, pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Detalle from '../components/Detalle';
import Paginacion from '../components/Paginacion';
import Mapa from '../components/Mapa';

const POR_PAGINA = 10;

const columnas = [
  { clave: 'Nombre', titulo: 'Nombre' },
  { clave: 'Categoria', titulo: 'Categoría' },
  { clave: 'Metodo_de_entrega', titulo: 'Método de entrega' }
];

const campos = [{ nombre: 'apodo', etiqueta: 'Nombre' }];

const formularioInicial = {
  CustomerName: '', CustomerCategoryID: '', PrimaryContactPersonID: '',
  AlternateContactPersonID: '', BillToCustomerID: '', BuyingGroupID: '',
  DeliveryMethodID: '', DeliveryCityID: '', PostalCityID: '', DeliveryPostalCode: '', PostalPostalCode: '',
  PhoneNumber: '', FaxNumber: '', PaymentDays: 30, StandardDiscountPercentage: 0, IsStatementSent: false, IsOnCreditHold: false, WebsiteURL: '',
  DeliveryAddressLine1: '', DeliveryAddressLine2: '', PostalAddressLine1: '',
  PostalAddressLine2: '', AccountOpenedDate: new Date().toISOString().slice(0, 10),
  DeliveryLatitude: '', DeliveryLongitude: ''
};

export default function Clientes() {
  const [filtros, setFiltros] = useState({ apodo: '' });
  const [clientes, setClientes] = useState([]);
  const [pagina, setPagina] = useState(1);
  const [detalle, setDetalle] = useState(null);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [formulario, setFormulario] = useState(formularioInicial);
  const [modoFormulario, setModoFormulario] = useState(null);
  const [guardando, setGuardando] = useState(false);

  useEffect(() => {
    const params = new URLSearchParams();
    if (filtros.apodo) params.append('apodo', filtros.apodo);

    pedir(`/clientes?${params}`)
      .then(res => { setClientes(res.data); setError(''); })
      .catch(err => setError(err.message));
  }, [filtros]);

  const abrirNuevo = () => {
    setError('');
    setMensaje('');
    setFormulario(formularioInicial);
    setModoFormulario('nuevo');
  };

  const abrirEdicion = async fila => {
    try {
      const res = await pedir(`/clientes/${encodeURIComponent(fila.Nombre)}`);
      const datos = res.data[0];

      setError('');
      setMensaje('');
      setFormulario({
        ...formularioInicial,
        CustomerID: datos.CustomerID,
        CustomerName: datos.Nombre,
        CustomerCategoryID: datos.CustomerCategoryID ?? '',
        PrimaryContactPersonID: datos.PrimaryContactPersonID ?? '',
        AlternateContactPersonID: datos.AlternateContactPersonID ?? '',
        BillToCustomerID: datos.BillToCustomerID ?? '',
        BuyingGroupID: datos.BuyingGroupID ?? '',
        DeliveryMethodID: datos.DeliveryMethodID ?? '',
        DeliveryCityID: datos.DeliveryCityID ?? '',
        PostalCityID: datos.PostalCityID ?? '',
        DeliveryPostalCode: datos.DeliveryPostalCode ?? '',
        PostalPostalCode: datos.PostalPostalCode ?? '',
        PhoneNumber: datos.PhoneNumber ?? '',
        FaxNumber: datos.FaxNumber ?? '',
        PaymentDays: datos.PaymentDays ?? 30,
        StandardDiscountPercentage: datos.StandardDiscountPercentage ?? 0,
        IsStatementSent: datos.IsStatementSent ?? false,
        IsOnCreditHold: datos.IsOnCreditHold ?? false,
        WebsiteURL: datos.WebsiteURL ?? '',
        DeliveryAddressLine1: datos.DeliveryAddressLine1 ?? '',
        DeliveryAddressLine2: datos.DeliveryAddressLine2 ?? '',
        PostalAddressLine1: datos.PostalAddressLine1 ?? '',
        PostalAddressLine2: datos.PostalAddressLine2 ?? '',
        AccountOpenedDate: datos.AccountOpenedDate ?? '',
        DeliveryLatitude: datos.DeliveryLatitude ?? '',
        DeliveryLongitude: datos.DeliveryLongitude ?? ''
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
      const datos = { ...formulario };
      const id = datos.CustomerID;
      delete datos.CustomerID;

      if (modoFormulario === 'nuevo') {
        await enviar('/clientes', 'POST', datos);
        setMensaje('Cliente creado correctamente.');
      } else {
        await enviar(`/clientes/${id}`, 'PUT', datos);
        setMensaje('Cliente actualizado correctamente.');
      }

      setModoFormulario(null);
      setPagina(1);
      const params = new URLSearchParams();
      if (filtros.apodo) params.append('apodo', filtros.apodo);
      const res = await pedir(`/clientes?${params}`);
      setClientes(res.data);
    } catch (err) {
      setError(err.message);
    } finally {
      setGuardando(false);
    }
  };

  const eliminar = async fila => {
    if (!window.confirm(`¿Eliminar el cliente "${fila.Nombre}"?`)) return;

    try {
      await enviar(`/clientes/${fila.CustomerID}`, 'DELETE');
      setMensaje('Cliente eliminado correctamente.');
      setClientes(actuales => actuales.filter(cliente => cliente.CustomerID !== fila.CustomerID));
    } catch (err) {
      setError(err.message);
    }
  };

  const verDetalle = async (fila) => {
    try {
      const res = await pedir(`/clientes/${encodeURIComponent(fila.Nombre)}`);
      setDetalle(res.data[0]);
    } catch (err) {
      setError(err.message);
    }
  };

  const cambiar = (nombre, valor) => {
    setPagina(1);
    setFiltros(prev => ({ ...prev, [nombre]: valor }));
  };

  const inicio = (pagina - 1) * POR_PAGINA;
  const clientesVisibles = clientes.slice(inicio, inicio + POR_PAGINA);

  return (
    <section className="modulo">
      <div className="modulo-header">
        <div className="modulo-header-texto">
          <p className="modulo-eyebrow">Gestión Comercial</p>
          <h1 className="modulo-titulo">Clientes</h1>
          <span className="modulo-contador">
            {clientes.length} {clientes.length === 1 ? 'resultado' : 'resultados'}
          </span>
        </div>
        <div className="modulo-acciones">
          <button type="button" className="btn btn-primario" onClick={abrirNuevo}>
            + Nuevo cliente
          </button>
        </div>
      </div>

      <div className="barra-filtros">
        <Filtros campos={campos} valores={filtros} onCambio={cambiar} />
        <button type="button" className="btn btn-fantasma" onClick={() => { setFiltros({ apodo: '' }); setPagina(1); }}>
          Restaurar filtros
        </button>
      </div>

      {error && <p className="mensaje mensaje-error">{error}</p>}
      {mensaje && <p className="mensaje mensaje-exito">{mensaje}</p>}

      <div className="tabla-wrapper">
        <Tabla
          columnas={columnas}
          filas={clientesVisibles}
          onFila={verDetalle}
          acciones={fila => (
            <div className="acciones-fila">
              <button type="button" onClick={evento => { evento.stopPropagation(); abrirEdicion(fila); }}>
                Editar
              </button>
              <button type="button" onClick={evento => { evento.stopPropagation(); eliminar(fila); }}>
                Eliminar
              </button>
            </div>
          )}
        />
      </div>

      <Paginacion
        total={clientes.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />

      {detalle && (
  <div className="fondo" onClick={() => setDetalle(null)}>
    <div className="ventana" onClick={e => e.stopPropagation()}>
      <button
        type="button"
        className="btn-cerrar"
        onClick={() => setDetalle(null)}
        aria-label="Cerrar"
      >
        ✕
      </button>

      <h2>Detalle del cliente</h2>

      <dl>
        {Object.entries(detalle)
          .filter(([clave]) => !['DeliveryLatitude', 'DeliveryLongitude'].includes(clave))
          .map(([clave, valor]) => (
            <div key={clave}>
              <dt>{clave.replaceAll('_', ' ')}</dt>
              <dd>
                {valor === null || valor === undefined || valor === ''
                  ? '—'
                  : String(valor)}
              </dd>
            </div>
          ))}
      </dl>

      <h2>Ubicación de entrega</h2>
        <Mapa
          latitud={detalle.Latitud}
          longitud={detalle.Longitud}
          titulo={detalle.Nombre || detalle.CustomerName}
          subtitulo={detalle.DeliveryAddressLine1}
        />
    </div>
  </div>
)}

      {modoFormulario && (
        <div className="fondo" onClick={() => setModoFormulario(null)}>
          <form className="ventana formulario" onSubmit={guardar} onClick={evento => evento.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setModoFormulario(null)} aria-label="Cerrar">✕</button>
            <h2>{modoFormulario === 'nuevo' ? 'Nuevo cliente' : 'Editar cliente'}</h2>

            <label>Nombre<input name="CustomerName" value={formulario.CustomerName} onChange={cambiarFormulario} required /></label>
            <label>Categoría<input name="CustomerCategoryID" type="number" value={formulario.CustomerCategoryID} onChange={cambiarFormulario} required /></label>
            <label>Contacto primario<input name="PrimaryContactPersonID" type="number" value={formulario.PrimaryContactPersonID} onChange={cambiarFormulario} required /></label>
            <label>Contacto alternativo<input name="AlternateContactPersonID" type="number" value={formulario.AlternateContactPersonID} onChange={cambiarFormulario} /></label>
            <label>Método de entrega<input name="DeliveryMethodID" type="number" value={formulario.DeliveryMethodID} onChange={cambiarFormulario} required /></label>
            <label>Grupo de compra<input name="BuyingGroupID" type="number" value={formulario.BuyingGroupID} onChange={cambiarFormulario} /></label>
            <label>Cliente por facturar<input name="BillToCustomerID" type="number" value={formulario.BillToCustomerID} onChange={cambiarFormulario} required /></label>
            <label>Ciudad de entrega<input name="DeliveryCityID" type="number" value={formulario.DeliveryCityID} onChange={cambiarFormulario} required /></label>
            <label>Ciudad postal<input name="PostalCityID" type="number" value={formulario.PostalCityID} onChange={cambiarFormulario} required /></label>
            <label>Código postal de entrega<input name="DeliveryPostalCode" value={formulario.DeliveryPostalCode} onChange={cambiarFormulario} required /></label>
            <label>Código postal<input name="PostalPostalCode" value={formulario.PostalPostalCode} onChange={cambiarFormulario} required /></label>
            <label>Días de pago<input name="PaymentDays" type="number" min="0" value={formulario.PaymentDays} onChange={cambiarFormulario} required /></label>
            <label>Descuento estándar (%)<input name="StandardDiscountPercentage" type="number" min="0" step="0.001" value={formulario.StandardDiscountPercentage} onChange={cambiarFormulario} required /></label>
            <label>
              <input name="IsStatementSent" type="checkbox" checked={formulario.IsStatementSent}
                onChange={e => setFormulario(a => ({ ...a, IsStatementSent: e.target.checked }))} />
              <span>Enviar estado de cuenta</span>
            </label>
            <label>
              <input name="IsOnCreditHold" type="checkbox" checked={formulario.IsOnCreditHold}
                onChange={e => setFormulario(a => ({ ...a, IsOnCreditHold: e.target.checked }))} />
              <span>Cliente en retención de crédito</span>
            </label>
            <label>Teléfono<input name="PhoneNumber" value={formulario.PhoneNumber} onChange={cambiarFormulario} required /></label>
            <label>Fax<input name="FaxNumber" value={formulario.FaxNumber} onChange={cambiarFormulario} required /></label>
            <label className="formulario-ancho">Sitio web<input name="WebsiteURL" type="url" value={formulario.WebsiteURL} onChange={cambiarFormulario} required /></label>
            <label>Dirección de entrega<input name="DeliveryAddressLine1" value={formulario.DeliveryAddressLine1} onChange={cambiarFormulario} required /></label>
            <label>Dirección de entrega adicional<input name="DeliveryAddressLine2" value={formulario.DeliveryAddressLine2} onChange={cambiarFormulario} /></label>
            <label>Dirección postal<input name="PostalAddressLine1" value={formulario.PostalAddressLine1} onChange={cambiarFormulario} required /></label>
            <label>Dirección postal adicional<input name="PostalAddressLine2" value={formulario.PostalAddressLine2} onChange={cambiarFormulario} /></label>
            <label>Fecha de apertura<input name="AccountOpenedDate" type="date" value={formulario.AccountOpenedDate} onChange={cambiarFormulario} required /></label>
            <label>Latitud<input name="DeliveryLatitude" type="number" step="0.000001" value={formulario.DeliveryLatitude} onChange={cambiarFormulario} /></label>
            <label>Longitud<input name="DeliveryLongitude" type="number" step="0.000001" value={formulario.DeliveryLongitude} onChange={cambiarFormulario} /></label>

            <button type="submit" disabled={guardando}>
              {guardando ? 'Guardando...' : 'Guardar'}
            </button>
          </form>
        </div>
      )}
    </section>
  );
}