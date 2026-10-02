const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

const camposProducto = [
  'StockItemName', 'SupplierID', 'UnitPackageID', 'OuterPackageID',
  'QuantityPerOuter', 'TaxRate', 'UnitPrice'
];

function faltantes(body, campos) {
  return campos.filter(campo => body[campo] === undefined || body[campo] === null || body[campo] === '');
}

function decimalOpcional(valor) {
  if (valor === undefined || valor === null || valor === '') return null;
  const numero = Number(valor);
  return Number.isFinite(numero) ? numero : null;
}

function parametrosProducto(request, body) {
  return request
    .input('StockItemName', sql.NVarChar(100), body.StockItemName)
    .input('SupplierID', sql.Int, body.SupplierID)
    .input('ColorID', sql.Int, body.ColorID ?? null)
    .input('UnitPackageID', sql.Int, body.UnitPackageID)
    .input('OuterPackageID', sql.Int, body.OuterPackageID)
    .input('QuantityPerOuter', sql.Int, body.QuantityPerOuter)
    .input('Brand', sql.NVarChar(50), body.Brand ?? null)
    .input('Size', sql.NVarChar(20), body.Size ?? null)
    .input('TaxRate', sql.Decimal(18, 2), decimalOpcional(body.TaxRate))
    .input('UnitPrice', sql.Decimal(18, 2), decimalOpcional(body.UnitPrice))
    .input('RecommendedRetailPrice', sql.Decimal(18, 2), decimalOpcional(body.RecommendedRetailPrice))
    .input('TypicalWeightPerUnit', sql.Decimal(18, 2), decimalOpcional(body.TypicalWeightPerUnit))
    .input('SearchDetails', sql.NVarChar(sql.MAX), body.SearchDetails ?? null)
    .input('BinLocation', sql.NVarChar(20), body.BinLocation ?? null);
}

function estadoError(err) {
  return err.number >= 50000 || err.code === 'EREQUEST' ? 400 : 500;
}

// Grupos para llenar el filtro (select) en React
router.get('/grupos', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request().execute('SP_GetStockGroups');
    res.json({ total: result.recordset.length, data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Listado con filtros acumulativos
router.get('/', async (req, res) => {
  try {
    const grupo = req.query.grupo ? parseInt(req.query.grupo) : null;

    const pool = await poolPromise;
    const result = await pool.request()
      .input('Name', sql.NVarChar(100), req.query.name || null)
      .input('StockGroupID', sql.Int, grupo)
      .execute('SP_GetStockItems');

    res.json({ total: result.recordset.length, data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get, Post, Put, Delete routes para products
router.post('/', async (req, res) => {
  const requeridos = faltantes(req.body, camposProducto);
  if (requeridos.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${requeridos.join(', ')}` });
  }

  // insert product
  try {
    const pool = await poolPromise;
    const result = await parametrosProducto(pool.request(), req.body)
      .execute('SP_InsertStockItem');
    res.status(201).json({ data: result.recordset[0] });
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  const requeridos = faltantes(req.body, camposProducto);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'StockItemID inválido' });
  }
  if (requeridos.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${requeridos.join(', ')}` });
  }

  // update product por id
  try {
    const pool = await poolPromise;
    await parametrosProducto(pool.request(), req.body)
      .input('StockItemID', sql.Int, id)
      .execute('SP_UpdateStockItem');
    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'StockItemID inválido' });
  }
  
  // delete product por id 
  try {
    const pool = await poolPromise;
    await pool.request().input('StockItemID', sql.Int, id).execute('SP_DeleteStockItem');
    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

// Detalle
router.get('/:id', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('StockItemID', sql.Int, parseInt(req.params.id))
      .execute('SP_GetStockItemDetails');

    res.json({ data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;