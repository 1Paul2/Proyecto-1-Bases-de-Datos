const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

// Categorías para el filtro (select) en React
router.get('/categorias', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request().execute('SP_GetSupplierCategories');
    res.json({ total: result.recordset.length, data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Listado con filtros acumulativos
router.get('/', async (req, res) => {
  try {
    const categoria = req.query.categoria ? parseInt(req.query.categoria) : null;

    const pool = await poolPromise;
    const result = await pool.request()
      .input('Name', sql.NVarChar(100), req.query.name || null)
      .input('SupplierCategoryID', sql.Int, categoria)
      .execute('SP_GetSuppliers');

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
      .input('SupplierID', sql.Int, parseInt(req.params.id))
      .execute('SP_GetSupplierDetails');

    res.json({ data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;