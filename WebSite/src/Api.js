export const API = 'http://localhost:3001/api';

export async function pedir(ruta) {
  const r = await fetch(`${API}${ruta}`);
  const json = await r.json();
  if (json.error) throw new Error(json.error);
  return json;
}

export async function enviar(ruta, metodo, datos) {
  const r = await fetch(`${API}${ruta}`, {
    method: metodo,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(datos)
  });

  const texto = await r.text();
  const json = texto ? JSON.parse(texto) : {};

  if (!r.ok || json.error) {
    throw new Error(json.error || 'La operación no pudo completarse');
  }

  return json;
}