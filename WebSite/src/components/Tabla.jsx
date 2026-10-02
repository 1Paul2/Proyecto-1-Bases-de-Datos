export default function Tabla({ columnas, filas, onFila }) {
  return (
    <table>
      <thead>
        <tr>
          {columnas.map(c => <th key={c.clave}>{c.titulo}</th>)}
        </tr>
      </thead>
      <tbody>
        {filas.map((f, i) => (
          <tr key={i} onClick={() => onFila && onFila(f)}
              style={{ cursor: onFila ? 'pointer' : 'default' }}>
            {columnas.map(c => <td key={c.clave}>{f[c.clave]}</td>)}
          </tr>
        ))}
      </tbody>
    </table>
  );
}