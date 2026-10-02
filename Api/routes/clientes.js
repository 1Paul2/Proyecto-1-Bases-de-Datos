const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');


router.get('/', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('Apodo', sql.VarChar(100), req.query.apodo || '')
      .execute('SP_LISTA_CLIENTES');

    res.json({ total: result.recordset.length, data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


router.get('/:nombre', async (req, res) => {
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('Nombre', sql.VarChar(100), req.params.nombre)
      .execute('SP_CLIENTES');

    res.json({ data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;