import { useEffect, useState } from 'react';
import { pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Detalle from '../components/Detalle';

const columnas = [
  { clave: 'StockItemName', titulo: 'Producto' },
  { clave: 'StockGroupNames', titulo: 'Grupo' },
  { clave: 'QuantityOnHand', titulo: 'Cantidad disponible' }
];

const filtrosIniciales = {
  name: '',
  grupo: ''
};

export default function Productos() {
  const [filtros, setFiltros] = useState(filtrosIniciales);
  const [grupos, setGrupos] = useState([]);
  const [productos, setProductos] = useState([]);
  const [detalle, setDetalle] = useState(null);
  const [error, setError] = useState('');

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
      const res = await pedir(`/productos/${fila.StockItemID}`);
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
      nombre: 'grupo',
      etiqueta: 'Grupo',
      opciones: grupos.map(grupo => ({
        valor: grupo.StockGroupID,
        texto: grupo.StockGroupName
      }))
    }
  ];

  return (
    <section>
      <h1>Productos</h1>

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

      <p>{productos.length} resultados</p>

      <Tabla
        columnas={columnas}
        filas={productos}
        onFila={verDetalle}
      />

      <Detalle
        titulo="Detalle del producto"
        datos={detalle}
        onCerrar={() => setDetalle(null)}
      />
    </section>
  );
}