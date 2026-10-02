const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

const camposVenta = [
  'CustomerID', 'DeliveryMethodID', 'CustomerPurchaseOrderNumber',
  'ContactPersonID', 'SalespersonPersonID', 'InvoiceDate', 'DeliveryInstructions'
];

function faltantes(body, campos) {
  return campos.filter(campo => body[campo] === undefined || body[campo] === null || body[campo] === '');
}

function parametrosVenta(request, body) {
  return request
    .input('CustomerID', sql.Int, body.CustomerID)
    .input('DeliveryMethodID', sql.Int, body.DeliveryMethodID)
    .input('CustomerPurchaseOrderNumber', sql.NVarChar(20), body.CustomerPurchaseOrderNumber)
    .input('ContactPersonID', sql.Int, body.ContactPersonID)
    .input('SalespersonPersonID', sql.Int, body.SalespersonPersonID)
    .input('InvoiceDate', sql.Date, body.InvoiceDate)
    .input('DeliveryInstructions', sql.NVarChar(500), body.DeliveryInstructions);
}

function estadoError(err) {
  return err.number >= 50000 || err.code === 'EREQUEST' ? 400 : 500;
}

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

router.post('/', async (req, res) => {
  const requeridos = faltantes(req.body, camposVenta);
  if (requeridos.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${requeridos.join(', ')}` });
  }

  try {
    const pool = await poolPromise;
    const result = await parametrosVenta(pool.request(), req.body)
      .execute('SP_InsertSale');
    res.status(201).json({ data: result.recordset[0] });
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  const requeridos = faltantes(req.body, camposVenta);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'InvoiceID inválido' });
  }
  if (requeridos.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${requeridos.join(', ')}` });
  }

  try {
    const pool = await poolPromise;
    await parametrosVenta(pool.request(), req.body)
      .input('InvoiceID', sql.Int, id)
      .execute('SP_UpdateSale');
    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'InvoiceID inválido' });
  }

  try {
    const pool = await poolPromise;
    await pool.request().input('InvoiceID', sql.Int, id).execute('SP_DeleteSale');
    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
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