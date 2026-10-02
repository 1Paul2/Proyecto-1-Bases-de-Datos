export default function Filtros({ campos, valores, onCambio }) {
  return (
    <div className="filtros">
      {campos.map(c => (
        <label key={c.nombre}>
          {c.etiqueta}
          {c.opciones ? (
            <select value={valores[c.nombre] || ''}
                    onChange={e => onCambio(c.nombre, e.target.value)}>
              <option value="">Todos</option>
              {c.opciones.map(o => (
                <option key={o.valor} value={o.valor}>{o.texto}</option>
              ))}
            </select>
          ) : (
            <input type={c.tipo || 'text'}
                   value={valores[c.nombre] || ''}
                   onChange={e => onCambio(c.nombre, e.target.value)} />
          )}
        </label>
      ))}
    </div>
  );
}