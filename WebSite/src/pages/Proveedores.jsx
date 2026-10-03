import { useEffect, useState } from 'react';
import { enviar, pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Detalle from '../components/Detalle';
import Paginacion from '../components/Paginacion';

const POR_PAGINA = 10;

const columnas = [
  { clave: 'SupplierName', titulo: 'Proveedor' },
  { clave: 'SupplierCategoryName', titulo: 'Categoría' },
  { clave: 'DeliveryMethodName', titulo: 'Método de entrega' }
];

const filtrosIniciales = {
  name: '',
  categoria: ''
};

const formularioInicial = {
  SupplierReference: '', SupplierName: '', SupplierCategoryID: '',
  PrimaryContactPersonID: '', AlternateContactPersonID: '', DeliveryMethodID: '',
  DeliveryCityID: '', PostalCityID: '', DeliveryPostalCode: '', PostalPostalCode: '',
  PhoneNumber: '', FaxNumber: '', WebsiteURL: '', DeliveryAddressLine1: '',
  DeliveryAddressLine2: '', PostalAddressLine1: '', PostalAddressLine2: '',
  DeliveryLatitude: '', DeliveryLongitude: '', BankAccountBranch: '',
  BankAccountName: '', BankAccountNumber: '', PaymentDays: 30, LastEditedBy: ''
};

export default function Proveedores() {
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [categorias, setCategorias] = useState([]);
  const [proveedores, setProveedores] = useState([]);
  const [pagina, setPagina] = useState(1);
  const [detalle, setDetalle] = useState(null);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [formulario, setFormulario] = useState(formularioInicial);
  const [modoFormulario, setModoFormulario] = useState(null);
  const [guardando, setGuardando] = useState(false);

  useEffect(() => {
    pedir('/proveedores/categorias')
      .then(res => setCategorias(res.data))
      .catch(err => setError(err.message));
  }, []);

  useEffect(() => {
    const params = new URLSearchParams();

    if (filtros.name) params.append('name', filtros.name);
    if (filtros.categoria) params.append('categoria', filtros.categoria);

    pedir(`/proveedores?${params}`)
      .then(res => {
        setProveedores(res.data);
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
      const res = await pedir(`/proveedores/${fila.SupplierID}`);
      setDetalle(res.data[0]);
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
      const res = await pedir(`/proveedores/${fila.SupplierID}`);
      const datos = res.data[0];
      setFormulario({
        ...formularioInicial,
        SupplierID: fila.SupplierID,
        SupplierReference: datos.SupplierReference ?? '',
        SupplierName: datos.SupplierName ?? '',
        SupplierCategoryID: datos.SupplierCategoryID ?? '',
        PrimaryContactPersonID: datos.PrimaryContactPersonID ?? '',
        AlternateContactPersonID: datos.AlternateContactPersonID ?? '',
        DeliveryMethodID: datos.DeliveryMethodID ?? '',
        DeliveryCityID: datos.DeliveryCityID ?? '',
        PostalCityID: datos.PostalCityID ?? '',
        DeliveryPostalCode: datos.DeliveryPostalCode ?? '',
        PostalPostalCode: datos.PostalPostalCode ?? '',
        PhoneNumber: datos.PhoneNumber ?? '', FaxNumber: datos.FaxNumber ?? '',
        WebsiteURL: datos.WebsiteURL ?? '',
        DeliveryAddressLine1: datos.DeliveryAddressLine1 ?? '',
        DeliveryAddressLine2: datos.DeliveryAddressLine2 ?? '',
        PostalAddressLine1: datos.PostalAddressLine1 ?? '',
        PostalAddressLine2: datos.PostalAddressLine2 ?? '',
        DeliveryLatitude: datos.DeliveryLatitude ?? '',
        DeliveryLongitude: datos.DeliveryLongitude ?? '',
        BankAccountBranch: datos.BankAccountBranch ?? '',
        BankAccountName: datos.BankAccountName ?? '',
        BankAccountNumber: datos.BankAccountNumber ?? '',
        PaymentDays: datos.PaymentDays ?? 30,
        LastEditedBy: datos.LastEditedBy ?? ''
      });
      setError('');
      setMensaje('');
      setModoFormulario('editar');
    } catch (err) {
      setError(err.message);
    }
  };

  const cambiarFormulario = evento => {
    const { name, value } = evento.target;
    setFormulario(anterior => ({ ...anterior, [name]: value }));
  };

  const recargar = async () => {
    const params = new URLSearchParams();
    if (filtros.name) params.append('name', filtros.name);
    if (filtros.categoria) params.append('categoria', filtros.categoria);
    const res = await pedir(`/proveedores?${params}`);
    setProveedores(res.data);
  };

  const guardar = async evento => {
    evento.preventDefault();
    setGuardando(true);
    setError('');
    setMensaje('');
    try {
      const datos = { ...formulario };
      const id = datos.SupplierID;
      delete datos.SupplierID;
      if (modoFormulario === 'nuevo') {
        await enviar('/proveedores', 'POST', datos);
        setMensaje('Proveedor creado correctamente.');
      } else {
        await enviar(`/proveedores/${id}`, 'PUT', datos);
        setMensaje('Proveedor actualizado correctamente.');
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
    if (!window.confirm(`¿Eliminar el proveedor "${fila.SupplierName}"?`)) return;
    try {
      await enviar(`/proveedores/${fila.SupplierID}`, 'DELETE');
      setMensaje('Proveedor eliminado correctamente.');
      setProveedores(actuales => actuales.filter(item => item.SupplierID !== fila.SupplierID));
    } catch (err) {
      setError(err.message);
    }
  };

  const campos = [
    {
      nombre: 'name',
      etiqueta: 'Nombre',
      tipo: 'text'
    },
    {
      nombre: 'categoria',
      etiqueta: 'Categoría',
      opciones: categorias.map(categoria => ({
        valor: categoria.SupplierCategoryID,
        texto: categoria.SupplierCategoryName
      }))
    }
  ];
  const inicio = (pagina - 1) * POR_PAGINA;
  const proveedoresVisibles = proveedores.slice(inicio, inicio + POR_PAGINA);

  return (
    <section className="modulo">
      <div className="modulo-header">
        <div className="modulo-header-texto">
          <p className="modulo-eyebrow">Compras y Suministro</p>
          <h1 className="modulo-titulo">Proveedores</h1>
          <span className="modulo-contador">
            {proveedores.length} {proveedores.length === 1 ? 'resultado' : 'resultados'}
          </span>
        </div>
        <div className="modulo-acciones">
          <button type="button" className="btn btn-primario" onClick={abrirNuevo}>
            + Nuevo proveedor
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
          filas={proveedoresVisibles}
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
        total={proveedores.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />

      <Detalle
        titulo="Detalle del proveedor"
        datos={detalle}
        onCerrar={() => setDetalle(null)}
      />

      {modoFormulario && (
        <div className="fondo" onClick={() => setModoFormulario(null)}>
          <form className="ventana formulario" onSubmit={guardar} onClick={e => e.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setModoFormulario(null)} aria-label="Cerrar">✕</button>
            <h2>{modoFormulario === 'nuevo' ? 'Nuevo proveedor' : 'Editar proveedor'}</h2>
            <label>Referencia<input name="SupplierReference" value={formulario.SupplierReference} onChange={cambiarFormulario} required /></label>
            <label>Nombre<input name="SupplierName" value={formulario.SupplierName} onChange={cambiarFormulario} required /></label>
            <label>Categoría<input name="SupplierCategoryID" type="number" value={formulario.SupplierCategoryID} onChange={cambiarFormulario} required /></label>
            <label>Contacto primario<input name="PrimaryContactPersonID" type="number" value={formulario.PrimaryContactPersonID} onChange={cambiarFormulario} required /></label>
            <label>Contacto alternativo<input name="AlternateContactPersonID" type="number" value={formulario.AlternateContactPersonID} onChange={cambiarFormulario} required /></label>
            <label>Método de entrega<input name="DeliveryMethodID" type="number" value={formulario.DeliveryMethodID} onChange={cambiarFormulario} required /></label>
            <label>Ciudad de entrega<input name="DeliveryCityID" type="number" value={formulario.DeliveryCityID} onChange={cambiarFormulario} required /></label>
            <label>Ciudad postal<input name="PostalCityID" type="number" value={formulario.PostalCityID} onChange={cambiarFormulario} required /></label>
            <label>Código postal entrega<input name="DeliveryPostalCode" value={formulario.DeliveryPostalCode} onChange={cambiarFormulario} required /></label>
            <label>Código postal<input name="PostalPostalCode" value={formulario.PostalPostalCode} onChange={cambiarFormulario} required /></label>
            <label>Teléfono<input name="PhoneNumber" value={formulario.PhoneNumber} onChange={cambiarFormulario} required /></label>
            <label>Fax<input name="FaxNumber" value={formulario.FaxNumber} onChange={cambiarFormulario} required /></label>
            <label>Sitio web<input name="WebsiteURL" type="url" value={formulario.WebsiteURL} onChange={cambiarFormulario} required /></label>
            <label>Dirección entrega<input name="DeliveryAddressLine1" value={formulario.DeliveryAddressLine1} onChange={cambiarFormulario} required /></label>
            <label>Dirección postal<input name="PostalAddressLine1" value={formulario.PostalAddressLine1} onChange={cambiarFormulario} required /></label>
            <label>Sucursal bancaria<input name="BankAccountBranch" value={formulario.BankAccountBranch} onChange={cambiarFormulario} required /></label>
            <label>Nombre de cuenta<input name="BankAccountName" value={formulario.BankAccountName} onChange={cambiarFormulario} required /></label>
            <label>Número de cuenta<input name="BankAccountNumber" value={formulario.BankAccountNumber} onChange={cambiarFormulario} required /></label>
            <label>Días de pago<input name="PaymentDays" type="number" min="0" value={formulario.PaymentDays} onChange={cambiarFormulario} required /></label>
            <label>Usuario que edita<input name="LastEditedBy" type="number" value={formulario.LastEditedBy} onChange={cambiarFormulario} required /></label>
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