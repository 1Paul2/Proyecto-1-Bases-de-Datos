const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

// Listado con filtros acumulativos
router.get('/', async (req, res) => {
  try {
    const { cliente, desde, hasta, min, max } = req.query;

    const pool = await poolPromise;
    const result = await pool.request()
      .input('CustomerName', sql.NVarChar(100), cliente || null)
      .input('InvoiceDateFrom', sql.Date, desde ? new Date(desde) : null)
      .input('InvoiceDateTo', sql.Date, hasta ? new Date(hasta) : null)
      .input('MinTotalAmount', sql.Decimal(18, 2), min ? parseFloat(min) : null)
      .input('MaxTotalAmount', sql.Decimal(18, 2), max ? parseFloat(max) : null)
      .execute('SP_GetSales');

    res.json({ total: result.recordset.length, data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Detalle: encabezado y líneas de la factura
router.get('/:id', async (req, res) => {
  try {
    const id = parseInt(req.params.id);
    const pool = await poolPromise;

    const encabezado = await pool.request()
      .input('InvoiceID', sql.Int, id)
      .execute('SP_GetSaleHeader');

    if (encabezado.recordset.length === 0) {
      return res.status(404).json({ error: 'Venta no encontrada' });
    }

    const lineas = await pool.request()
      .input('InvoiceID', sql.Int, id)
      .execute('SP_GetSaleDetails');

    res.json({
      encabezado: encabezado.recordset[0],
      lineas: lineas.recordset
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;