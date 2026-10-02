import { useState, useEffect } from 'react';
import { enviar, pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Detalle from '../components/Detalle';
import Paginacion from '../components/Paginacion';

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
  DeliveryMethodID: '', DeliveryCityID: '', PostalPostalCode: '',
  PhoneNumber: '', FaxNumber: '', PaymentDays: 30, WebsiteURL: '',
  DeliveryAddressLine1: '', DeliveryAddressLine2: '', PostalAddressLine1: '',
  PostalAddressLine2: '', DeliveryLatitude: '', DeliveryLongitude: ''
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
        PostalPostalCode: datos.PostalPostalCode ?? '',
        PhoneNumber: datos.PhoneNumber ?? '',
        FaxNumber: datos.FaxNumber ?? '',
        PaymentDays: datos.PaymentDays ?? 30,
        WebsiteURL: datos.WebsiteURL ?? '',
        DeliveryAddressLine1: datos.DeliveryAddressLine1 ?? '',
        DeliveryAddressLine2: datos.DeliveryAddressLine2 ?? '',
        PostalAddressLine1: datos.PostalAddressLine1 ?? '',
        PostalAddressLine2: datos.PostalAddressLine2 ?? '',
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
    <div>
      <div className="encabezado-modulo">
        <h1>Clientes</h1>
        <button type="button" onClick={abrirNuevo}>Nuevo cliente</button>
      </div>
      <Filtros campos={campos} valores={filtros} onCambio={cambiar} />
      {error && <p style={{ color: 'red' }}>{error}</p>}
      {mensaje && <p className="mensaje-exito">{mensaje}</p>}
      <p>{clientes.length} resultados</p>
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
      <Paginacion
        total={clientes.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />
      <Detalle titulo="Detalle del cliente" datos={detalle}
               onCerrar={() => setDetalle(null)} />

      {modoFormulario && (
        <div className="fondo" onClick={() => setModoFormulario(null)}>
          <form className="ventana formulario" onSubmit={guardar} onClick={evento => evento.stopPropagation()}>
            <button type="button" onClick={() => setModoFormulario(null)}>Cerrar</button>
            <h2>{modoFormulario === 'nuevo' ? 'Nuevo cliente' : 'Editar cliente'}</h2>

            <label>Nombre<input name="CustomerName" value={formulario.CustomerName} onChange={cambiarFormulario} required /></label>
            <label>Categoría<input name="CustomerCategoryID" type="number" value={formulario.CustomerCategoryID} onChange={cambiarFormulario} required /></label>
            <label>Contacto primario<input name="PrimaryContactPersonID" type="number" value={formulario.PrimaryContactPersonID} onChange={cambiarFormulario} required /></label>
            <label>Contacto alternativo<input name="AlternateContactPersonID" type="number" value={formulario.AlternateContactPersonID} onChange={cambiarFormulario} /></label>
            <label>Método de entrega<input name="DeliveryMethodID" type="number" value={formulario.DeliveryMethodID} onChange={cambiarFormulario} required /></label>
            <label>Días de pago<input name="PaymentDays" type="number" min="0" value={formulario.PaymentDays} onChange={cambiarFormulario} required /></label>
            <label>Teléfono<input name="PhoneNumber" value={formulario.PhoneNumber} onChange={cambiarFormulario} /></label>
            <label>Sitio web<input name="WebsiteURL" type="url" value={formulario.WebsiteURL} onChange={cambiarFormulario} /></label>

            <button type="submit" disabled={guardando}>
              {guardando ? 'Guardando...' : 'Guardar'}
            </button>
          </form>
        </div>
      )}
    </div>
  );
}