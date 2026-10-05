import { useEffect, useState } from 'react';
import { pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Paginacion from '../components/Paginacion';

const reportes = {
  proveedor: {
    titulo: 'Estadística de proveedores',
    endpoint: '/estadisticas/proveedor',
    campos: [
      { nombre: 'proveedor', etiqueta: 'Proveedor', tipo: 'text' },
      { nombre: 'categoria', etiqueta: 'Categoría', tipo: 'text' }
    ]
  },

  cliente: {
    titulo: 'Estadística de clientes',
    endpoint: '/estadisticas/cliente',
    campos: [
      { nombre: 'cliente', etiqueta: 'Cliente', tipo: 'text' },
      { nombre: 'categoria', etiqueta: 'Categoría', tipo: 'text' }
    ]
  },

  productos: {
    titulo: 'Top 5 productos por ganancia',
    endpoint: '/estadisticas/top-productos',
    campos: [
      { nombre: 'anio', etiqueta: 'Año', tipo: 'number' }
    ]
  },

  topClientes: {
    titulo: 'Top 5 clientes por facturas',
    endpoint: '/estadisticas/top-clientes',
    campos: [
      { nombre: 'anioInicio', etiqueta: 'Año inicial', tipo: 'number' },
      { nombre: 'anioFin', etiqueta: 'Año final', tipo: 'number' }
    ]
  },

  topProveedores: {
    titulo: 'Top 5 proveedores por órdenes',
    endpoint: '/estadisticas/top-proveedores',
    campos: [
      { nombre: 'anioInicio', etiqueta: 'Año inicial', tipo: 'number' },
      { nombre: 'anioFin', etiqueta: 'Año final', tipo: 'number' }
    ]
  },

  matriz: {
    titulo: 'Matriz de ventas por categoría y año',
    endpoint: '/estadisticas/matriz',
    campos: []
  },

  // La base solo tiene grupos de productos planos (StockGroups), sin subcategorías,
  // por eso estos reportes se filtran por año, mes y categoría.
  seguimientoClientes: {
    titulo: 'Seguimiento de compras a clientes',
    endpoint: '/estadisticas/seguimiento-clientes',
    campos: [
      { nombre: 'anio', etiqueta: 'Año', tipo: 'number' },
      { nombre: 'mes', etiqueta: 'Mes', tipo: 'number' },
      { nombre: 'categoria', etiqueta: 'Categoría', tipo: 'text' }
    ]
  },

  seguimientoProveedores: {
    titulo: 'Seguimiento de compras a proveedores',
    endpoint: '/estadisticas/seguimiento-proveedores',
    campos: [
      { nombre: 'anio', etiqueta: 'Año', tipo: 'number' },
      { nombre: 'mes', etiqueta: 'Mes', tipo: 'number' },
      { nombre: 'categoria', etiqueta: 'Categoría', tipo: 'text' }
    ]
  },

  rotacion: {
    titulo: 'Rotación de inventario',
    endpoint: '/estadisticas/rotacion',
    campos: [
      { nombre: 'anio', etiqueta: 'Año', tipo: 'number' },
      { nombre: 'categoria', etiqueta: 'Categoría', tipo: 'text' },
      { nombre: 'proveedor', etiqueta: 'Proveedor', tipo: 'text' }
    ]
  },

  envioFavorito: {
    titulo: 'Método de envío favorito',
    endpoint: '/estadisticas/envio-favorito',
    campos: [
      { nombre: 'anio', etiqueta: 'Año', tipo: 'number' },
      { nombre: 'mes', etiqueta: 'Mes', tipo: 'number' },
      { nombre: 'catCliente', etiqueta: 'Categoría cliente', tipo: 'text' },
      { nombre: 'catProducto', etiqueta: 'Categoría producto', tipo: 'text' },
      { nombre: 'producto', etiqueta: 'Producto', tipo: 'text' }
    ]
  }
};

// Todos los filtros que usa algún reporte, para que los campos siempre estén controlados
const filtrosIniciales = {
  proveedor: '',
  cliente: '',
  categoria: '',
  anio: '',
  anioInicio: '',
  anioFin: '',
  mes: '',
  catCliente: '',
  catProducto: '',
  producto: ''
};

const POR_PAGINA = 10;

function tituloColumna(clave) {
  return clave
    .replaceAll('_', ' ')
    .replace(/([a-z])([A-Z])/g, '$1 $2');
}

export default function Estadisticas() {
  const [pagina, setPagina] = useState(1);
  const [reporte, setReporte] = useState('proveedor');
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [filas, setFilas] = useState([]);
  const [error, setError] = useState('');

  const configuracion = reportes[reporte];

  useEffect(() => {
    const params = new URLSearchParams();

    configuracion.campos.forEach(campo => {
      const valor = filtros[campo.nombre];

      if (valor) {
        params.append(campo.nombre, valor);
      }
    });

    pedir(`${configuracion.endpoint}?${params}`)
      .then(res => {
        setFilas(res.data);
        setError('');
      })
      .catch(err => {
        setFilas([]);
        setError(err.message);
      });
  }, [reporte, filtros, configuracion]);

  const cambiarReporte = evento => {
    setReporte(evento.target.value);
    setFiltros(filtrosIniciales);
    setFilas([]);
    setPagina(1);
  };

  const cambiarFiltro = (nombre, valor) => {
    setFiltros(anterior => ({
      ...anterior,
      [nombre]: valor
    }));
    setPagina(1);
  };

  const restaurarFiltros = () => {
    setFiltros(filtrosIniciales);
    setPagina(1);
  };

  const columnas = filas.length > 0
    ? Object.keys(filas[0]).map(clave => ({
        clave,
        titulo: tituloColumna(clave)
      }))
    : [];

  const inicio = (pagina - 1) * POR_PAGINA;
  const filasVisibles = filas.slice(inicio, inicio + POR_PAGINA);

  return (
    <section className="modulo">
      <div className="modulo-header">
        <div className="modulo-header-texto">
          <p className="modulo-eyebrow">Reportes y Métricas</p>
          <h1 className="modulo-titulo">Estadísticas</h1>
          <span className="modulo-contador">
            {filas.length} {filas.length === 1 ? 'resultado' : 'resultados'}
          </span>
        </div>
      </div>

      <label className="selector-reporte">
        Reporte
        <select value={reporte} onChange={cambiarReporte}>
          {Object.entries(reportes).map(([clave, valor]) => (
            <option key={clave} value={clave}>
              {valor.titulo}
            </option>
          ))}
        </select>
      </label>

      <div className="barra-filtros">
        <Filtros campos={configuracion.campos} valores={filtros} onCambio={cambiarFiltro} />
        <button type="button" className="btn btn-fantasma" onClick={restaurarFiltros}>
          Restaurar filtros
        </button>
      </div>

      {error && <p className="mensaje mensaje-error">{error}</p>}

      <div className="tabla-wrapper">
        <Tabla columnas={columnas} filas={filasVisibles} />
      </div>

      <Paginacion
        total={filas.length}
        pagina={pagina}
        porPagina={POR_PAGINA}
        onCambio={setPagina}
      />
    </section>
  );
}