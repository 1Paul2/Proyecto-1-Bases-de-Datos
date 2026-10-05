import { useEffect, useState } from 'react';
import { enviar, pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Paginacion from '../components/Paginacion';
import ConfirmarEliminar from '../components/ConfirmarEliminar';

const POR_PAGINA = 10;

const columnas = [
  { clave: 'StockItemName', titulo: 'Producto' },
  { clave: 'StockGroupNames', titulo: 'Grupo' },
  { clave: 'QuantityOnHand', titulo: 'Cantidad disponible' }
];

// [etiqueta que se muestra, columna que devuelve SP_GetStockItemDetails]
const camposDetalle = [
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

// [etiqueta, columna que devuelve SP_GetSupplierDetails]
const camposProveedor = [
  ['Código del proveedor', 'SupplierReference'],
  ['Nombre del proveedor', 'SupplierName'],
  ['Categoría', 'SupplierCategoryName'],
  ['Contacto primario', 'PrimaryContactName'],
  ['Contacto alternativo', 'AlternateContactName'],
  ['Método de entrega', 'DeliveryMethodName'],
  ['Ciudad de entrega', 'DeliveryCityName'],
  ['Código postal de entrega', 'DeliveryPostalCode'],
  ['Teléfono', 'PhoneNumber'],
  ['Fax', 'FaxNumber'],
  ['Sitio web', 'WebsiteURL'],
  ['Días de gracia para pagar', 'PaymentDays']
];

const dinero = v =>
  Number(v).toLocaleString('es-CR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

// Solo presentación: no se calcula ni agrupa nada
const FORMATOS = {
  TaxRate: v => `${Number(v)} %`,
  UnitPrice: dinero,
  RecommendedRetailPrice: dinero,
  TypicalWeightPerUnit: v => `${Number(v)} kg`
};

const filtrosIniciales = {
  name: '',
  grupo: ''
};

// SearchDetails no se edita: en la base es una columna calculada
const formularioInicial = {
  StockItemName: '', SupplierID: '', LeadTimeDays: 1, ColorID: '', UnitPackageID: '',
  OuterPackageID: '', QuantityPerOuter: 1, Brand: '', Size: '', TaxRate: 0, IsChillerStock: false,
  UnitPrice: '', RecommendedRetailPrice: '', TypicalWeightPerUnit: '',
  BinLocation: '',
  // Dato de auditoría: no se pide en pantalla. Lo ideal es que lo asigne la API.
  LastEditedBy: 1
};

export default function Productos() {
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [grupos, setGrupos] = useState([]);
  const [productos, setProductos] = useState([]);
  const [pagina, setPagina] = useState(1);
  const [detalle, setDetalle] = useState(null);
  const [proveedor, setProveedor] = useState(null);
  const [error, setError] = useState('');
  const [mensaje, setMensaje] = useState('');
  const [porEliminar, setPorEliminar] = useState(null);
  const [formulario, setFormulario] = useState(formularioInicial);
  const [modoFormulario, setModoFormulario] = useState(null);
  const [guardando, setGuardando] = useState(false);

  useEffect(() => {
    pedir('/productos/grupos')
      .then(res => setGrupos(res.data))
      .catch(err => setError(err.message));
  }, []);

  useEffect(() => {
    const params = new URLSearchParams();

    if (filtros.name) params.append('name', filtros.name);
    if (filtros.grupo) params.append('grupo', filtros.grupo);

    pedir(`/productos?${params}`)
      .then(res => {
        setProductos(res.data);
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
      const res = await pedir(`/productos/${fila.StockItemID}`);
      setDetalle(res.data[0]);
    } catch (err) {
      setError(err.message);
    }
  };

  const verProveedor = async id => {
    try {
      const res = await pedir(`/proveedores/${id}`);
      setProveedor(res.data[0]);
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
      const res = await pedir(`/productos/${fila.StockItemID}`);
      const datos = res.data[0];
      setFormulario({
        ...formularioInicial,
        StockItemID: datos.StockItemID,
        StockItemName: datos.StockItemName ?? '',
        SupplierID: datos.SupplierID ?? '',
        LeadTimeDays: datos.LeadTimeDays ?? 1,
        ColorID: datos.ColorID ?? '',
        UnitPackageID: datos.UnitPackageID ?? '',
        OuterPackageID: datos.OuterPackageID ?? '',
        QuantityPerOuter: datos.QuantityPerOuter ?? 1,
        Brand: datos.Brand ?? '',
        Size: datos.Size ?? '',
        TaxRate: datos.TaxRate ?? 0,
        UnitPrice: datos.UnitPrice ?? '',
        IsChillerStock: datos.IsChillerStock ?? false,
        RecommendedRetailPrice: datos.RecommendedRetailPrice ?? '',
        TypicalWeightPerUnit: datos.TypicalWeightPerUnit ?? '',
        BinLocation: datos.BinLocation ?? ''
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
    if (filtros.grupo) params.append('grupo', filtros.grupo);
    const res = await pedir(`/productos?${params}`);
    setProductos(res.data);
  };

  const guardar = async evento => {
    evento.preventDefault();
    setGuardando(true);
    setError('');
    setMensaje('');
    try {
      const datos = { ...formulario };
      const id = datos.StockItemID;
      delete datos.StockItemID;
      if (modoFormulario === 'nuevo') {
        await enviar('/productos', 'POST', datos);
        setMensaje('Producto creado correctamente.');
      } else {
        await enviar(`/productos/${id}`, 'PUT', datos);
        setMensaje('Producto actualizado correctamente.');
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

  const eliminar = fila => {
    setError('');
    setMensaje('');
    setPorEliminar(fila);
  };

  // Si falla, el error sube a la ventana de confirmación y se muestra ahí
  const confirmarEliminar = async () => {
    const fila = porEliminar;
    await enviar(`/productos/${fila.StockItemID}`, 'DELETE');
    setPorEliminar(null);
    setMensaje('Producto eliminado correctamente.');
    setProductos(actuales => actuales.filter(item => item.StockItemID !== fila.StockItemID));
  };

  const campos = [
    {
      nombre: 'name',
      etiqueta: 'Nombre',
      tipo: 'text'
    },
    {
      nombre: 'grupo',
      etiqueta: 'Grupo',
      opciones: grupos.map(grupo => ({
        valor: grupo.StockGroupID,
        texto: grupo.StockGroupName
      }))
    }
  ];
  const inicio = (pagina - 1) * POR_PAGINA;
  const productosVisibles = productos.slice(inicio, inicio + POR_PAGINA);

  return (
    <section className="modulo">
      <div className="modulo-header">
        <div className="modulo-header-texto">
          <p className="modulo-eyebrow">Inventario y Almacén</p>
          <h1 className="modulo-titulo">Productos</h1>
          <span className="modulo-contador">
            {productos.length} {productos.length === 1 ? 'resultado' : 'resultados'}
          </span>
        </div>
        <div className="modulo-acciones">
          <button type="button" className="btn btn-primario" onClick={abrirNuevo}>
            + Nuevo producto
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
          filas={productosVisibles}
          onFila={verDetalle}
          acciones={fila => (
            <div className="acciones-fila">
              <button type="button" onClick={e => { e.stopPropagation(); verDetalle(fila); }}>Ver detalles</button>
              <button type="button" onClick={e => { e.stopPropagation(); abrirEdicion(fila); }}>Editar</button>
              <button type="button" onClick={e => { e.stopPropagation(); eliminar(fila); }}>Eliminar</button>
            </div>
          )}
        />
      </div>

      <Paginacion
        total={productos.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />

      {porEliminar && (
        <ConfirmarEliminar
          tipo="producto"
          nombre={porEliminar.StockItemName}
          onConfirmar={confirmarEliminar}
          onCancelar={() => setPorEliminar(null)}
        />
      )}

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

            <h2>Detalle del producto</h2>

            <dl>
              {camposDetalle.map(([etiqueta, clave]) => {
                const valor = detalle[clave];
                const vacio = valor === null || valor === undefined || valor === '';
                const formatear = FORMATOS[clave];
                return (
                  <div key={clave}>
                    <dt>{etiqueta}</dt>
                    <dd>
                      {vacio
                        ? 'Vacío'
                        : clave === 'SupplierName' && detalle.SupplierID
                          ? (
                            <a
                              href="#"
                              onClick={e => { e.preventDefault(); verProveedor(detalle.SupplierID); }}
                            >
                              {valor}
                            </a>
                          )
                          : formatear ? formatear(valor) : String(valor)}
                    </dd>
                  </div>
                );
              })}
            </dl>
          </div>
        </div>
      )}

      {proveedor && (
        <div className="fondo" onClick={() => setProveedor(null)}>
          <div className="ventana" onClick={e => e.stopPropagation()}>
            <button
              type="button"
              className="btn-cerrar"
              onClick={() => setProveedor(null)}
              aria-label="Cerrar"
            >
              ✕
            </button>

            <h2>Detalle del proveedor</h2>

            <dl>
              {camposProveedor.map(([etiqueta, clave]) => {
                const valor = proveedor[clave];
                const vacio = valor === null || valor === undefined || valor === '';
                return (
                  <div key={clave}>
                    <dt>{etiqueta}</dt>
                    <dd>
                      {vacio
                        ? 'Vacío'
                        : clave === 'WebsiteURL'
                          ? <a href={valor} target="_blank" rel="noreferrer">{valor}</a>
                          : String(valor)}
                    </dd>
                  </div>
                );
              })}
            </dl>
          </div>
        </div>
      )}

      {modoFormulario && (
        <div className="fondo" onClick={() => setModoFormulario(null)}>
          <form className="ventana formulario" onSubmit={guardar} onClick={e => e.stopPropagation()}>
            <button type="button" className="btn-cerrar" onClick={() => setModoFormulario(null)} aria-label="Cerrar">✕</button>
            <h2>{modoFormulario === 'nuevo' ? 'Nuevo producto' : 'Editar producto'}</h2>
            <label>Nombre<input name="StockItemName" value={formulario.StockItemName} onChange={cambiarFormulario} required /></label>
            <label>Proveedor<input name="SupplierID" type="number" value={formulario.SupplierID} onChange={cambiarFormulario} required /></label>
            <label>Días de entrega<input name="LeadTimeDays" type="number" min="0" value={formulario.LeadTimeDays} onChange={cambiarFormulario} required /></label>
            <label>Color<input name="ColorID" type="number" value={formulario.ColorID} onChange={cambiarFormulario} /></label>
            <label>Paquete unitario<input name="UnitPackageID" type="number" value={formulario.UnitPackageID} onChange={cambiarFormulario} required /></label>
            <label>Paquete exterior<input name="OuterPackageID" type="number" value={formulario.OuterPackageID} onChange={cambiarFormulario} required /></label>
            <label>Cantidad por paquete<input name="QuantityPerOuter" type="number" min="1" value={formulario.QuantityPerOuter} onChange={cambiarFormulario} required /></label>
            <label>Marca<input name="Brand" value={formulario.Brand} onChange={cambiarFormulario} /></label>
            <label>Tamaño<input name="Size" value={formulario.Size} onChange={cambiarFormulario} /></label>
            <label>Impuesto<input name="TaxRate" type="number" step="0.01" min="0" value={formulario.TaxRate} onChange={cambiarFormulario} required /></label>
            <label>Precio unitario<input name="UnitPrice" type="number" step="0.01" min="0" value={formulario.UnitPrice} onChange={cambiarFormulario} required /></label>
            <label>Refrigerado<input name="IsChillerStock" type="checkbox" checked={formulario.IsChillerStock} onChange={evento => cambiarFormulario({ target: { name: 'IsChillerStock', value: evento.target.checked } })} /></label>
            <label>Precio recomendado<input name="RecommendedRetailPrice" type="number" step="0.01" min="0" value={formulario.RecommendedRetailPrice} onChange={cambiarFormulario} /></label>
            <label>Peso típico<input name="TypicalWeightPerUnit" type="number" step="0.01" min="0" value={formulario.TypicalWeightPerUnit} onChange={cambiarFormulario} /></label>
            <label>Ubicación<input name="BinLocation" value={formulario.BinLocation} onChange={cambiarFormulario} /></label>
            <button type="submit" disabled={guardando}>
              {guardando ? 'Guardando...' : 'Guardar'}
            </button>
          </form>
        </div>
      )}
    </section>
  );
}