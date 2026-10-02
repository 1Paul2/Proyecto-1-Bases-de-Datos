import { useEffect, useState } from 'react';
import { pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Detalle from '../components/Detalle';

const columnas = [
  { clave: 'SupplierName', titulo: 'Proveedor' },
  { clave: 'SupplierCategoryName', titulo: 'Categoría' },
  { clave: 'DeliveryMethodName', titulo: 'Método de entrega' }
];

const filtrosIniciales = {
  name: '',
  categoria: ''
};

export default function Proveedores() {
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [categorias, setCategorias] = useState([]);
  const [proveedores, setProveedores] = useState([]);
  const [detalle, setDetalle] = useState(null);
  const [error, setError] = useState('');

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
    setFiltros(anterior => ({
      ...anterior,
      [nombre]: valor
    }));
  };

  const restaurarFiltros = () => {
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

  return (
    <section>
      <h1>Proveedores</h1>

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

      <p>{proveedores.length} resultados</p>

      <Tabla
        columnas={columnas}
        filas={proveedores}
        onFila={verDetalle}
      />

      <Detalle
        titulo="Detalle del proveedor"
        datos={detalle}
        onCerrar={() => setDetalle(null)}
      />
    </section>
  );
}