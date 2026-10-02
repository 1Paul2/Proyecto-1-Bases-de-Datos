import { useState, useEffect } from 'react';
import { pedir } from '../Api';
import Filtros from '../components/Filtros';
import Tabla from '../components/Tabla';
import Detalle from '../components/Detalle';

const columnas = [
  { clave: 'Nombre', titulo: 'Nombre' },
  { clave: 'Categoria', titulo: 'Categoría' },
  { clave: 'Metodo_de_entrega', titulo: 'Método de entrega' }
];

const campos = [{ nombre: 'apodo', etiqueta: 'Nombre' }];

export default function Clientes() {
  const [filtros, setFiltros] = useState({ apodo: '' });
  const [clientes, setClientes] = useState([]);
  const [detalle, setDetalle] = useState(null);
  const [error, setError] = useState('');

  useEffect(() => {
    const params = new URLSearchParams();
    if (filtros.apodo) params.append('apodo', filtros.apodo);

    pedir(`/clientes?${params}`)
      .then(res => { setClientes(res.data); setError(''); })
      .catch(err => setError(err.message));
  }, [filtros]);

  const verDetalle = async (fila) => {
    try {
      const res = await pedir(`/clientes/${encodeURIComponent(fila.Nombre)}`);
      setDetalle(res.data[0]);
    } catch (err) {
      setError(err.message);
    }
  };

  const cambiar = (nombre, valor) =>
    setFiltros(prev => ({ ...prev, [nombre]: valor }));

  return (
    <div>
      <h1>Clientes</h1>
      <Filtros campos={campos} valores={filtros} onCambio={cambiar} />
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <p>{clientes.length} resultados</p>
      <Tabla columnas={columnas} filas={clientes} onFila={verDetalle} />
      <Detalle titulo="Detalle del cliente" datos={detalle}
               onCerrar={() => setDetalle(null)} />
    </div>
  );
}