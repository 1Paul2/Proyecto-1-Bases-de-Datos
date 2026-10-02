export default function Paginacion({
  total,
  pagina,
  porPagina = 10,
  onCambio
}) {
  const totalPaginas = Math.ceil(total / porPagina);

  if (totalPaginas <= 1) return null;

  return (
    <div className="paginacion">
      <button
        type="button"
        disabled={pagina === 1}
        onClick={() => onCambio(pagina - 1)}
      >
        Anterior
      </button>

      <span>
        Página {pagina} de {totalPaginas}
      </span>

      <button
        type="button"
        disabled={pagina === totalPaginas}
        onClick={() => onCambio(pagina + 1)}
      >
        Siguiente
      </button>
    </div>
  );
}