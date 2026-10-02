export default function Detalle({ titulo, datos, onCerrar }) {
  if (!datos) return null;

  return (
    <div className="fondo" onClick={onCerrar}>
      <div className="ventana" onClick={e => e.stopPropagation()}>
        <button onClick={onCerrar}>Cerrar</button>
        <h2>{titulo}</h2>
        <dl>
          {Object.entries(datos).map(([k, v]) => (
            <div key={k}>
              <dt>{k.replaceAll('_', ' ')}</dt>
              <dd>{v ?? '—'}</dd>
            </div>
          ))}
        </dl>
      </div>
    </div>
  );
}