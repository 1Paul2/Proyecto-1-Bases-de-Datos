export default function Tabla({ columnas, filas, onFila, acciones }) {
  return (
    <table>
      <thead>
        <tr>
          {columnas.map(c => <th key={c.clave}>{c.titulo}</th>)}
          {acciones && <th>Acciones</th>}
        </tr>
      </thead>
      <tbody>
        {filas.length === 0 ? (
          <tr key="sin-resultados">
            <td className="tabla-vacia" colSpan={columnas.length || 1}>
              No hay resultados.
            </td>
          </tr>
        ) : filas.map((f, i) => (
          <tr key={obtenerClave(f, i)} onClick={() => onFila && onFila(f)}
              style={{ cursor: onFila ? 'pointer' : 'default' }}>
            {columnas.map(c => <td key={c.clave}>{f[c.clave]}</td>)}
            {acciones && <td>{acciones(f)}</td>}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function obtenerClave(fila, indice) {
  const clavesPreferidas = [
    'CustomerID',
    'SupplierID',
    'StockItemID',
    'InvoiceID',
    'Nombre'
  ];
  const clave = clavesPreferidas.find(c => fila[c] !== undefined && fila[c] !== null);

  return clave ? fila[clave] : `fila-${indice}`;
}