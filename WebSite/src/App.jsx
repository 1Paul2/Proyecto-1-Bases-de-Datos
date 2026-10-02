import { useState } from 'react';
import Clientes from './pages/Clientes';
import './App.css';

const modulos = {
  clientes: "Clientes",
  proveedores: "Proveedores",
  productos: "Productos",
  ventas: "Ventas",
  estadisticas: "Estadísticas",
}

function Test({name}) {
  return (
    <section className='pendiente'>
      <h1>Modulo {name}</h1>
      <p>funciona</p>
    </section>
  )
}

export default function App() {
  const [modulo, setModulo] = useState('clientes');
  return (
    <div className="App">
      <header className="App-header">
        <div>
          <p className='eyebrow'>Wide World Importers</p>
          <h1>Panel de gestion</h1>
        </div>
        <nav className='menu' arial-label='Modulos'>
          {Object.entries(modulos).map(([key, name]) => (
            <button
              key={key}
              className={modulo === key ? 'active' : ''}
              onClick={() => setModulo(key)}
            >
              {name}
            </button>
          ))}
        </nav>
      </header>
      <main className='App-content'>
        {modulo === 'clientes' && <Clientes />}
        {modulo === 'proveedores' && Test({name: modulos.proveedores})}
        {modulo === 'productos' && Test({name: modulos.productos})}
        {modulo === 'ventas' && Test({name: modulos.ventas})}
        {modulo === 'estadisticas' && Test({name: modulos.estadisticas})}
      </main>
    </div>
  )
}