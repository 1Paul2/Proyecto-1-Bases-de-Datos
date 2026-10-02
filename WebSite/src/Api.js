export const API = 'http://localhost:3001/api';

export async function pedir(ruta) {
  const r = await fetch(`${API}${ruta}`);
  const json = await r.json();
  if (json.error) throw new Error(json.error);
  return json;
}