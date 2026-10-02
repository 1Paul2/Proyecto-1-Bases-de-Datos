const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

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