const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

const camposProveedor = [
  'SupplierReference', 'SupplierName', 'SupplierCategoryID',
  'PrimaryContactPersonID', 'AlternateContactPersonID', 'DeliveryCityID',
  'PostalCityID', 'DeliveryPostalCode', 'PostalPostalCode', 'PhoneNumber',
  'FaxNumber', 'WebsiteURL', 'DeliveryAddressLine1', 'PostalAddressLine1',
  'BankAccountBranch', 'BankAccountName', 'BankAccountNumber', 'PaymentDays',
  'LastEditedBy'
];

function faltantes(body, campos) {
  return campos.filter(campo => body[campo] === undefined || body[campo] === null || body[campo] === '');
}

function parametrosProveedor(request, body) {
  return request
    .input('SupplierReference', sql.NVarChar(20), body.SupplierReference ?? null)
    .input('SupplierName', sql.NVarChar(100), body.SupplierName)
    .input('SupplierCategoryID', sql.Int, body.SupplierCategoryID)
    .input('PrimaryContactPersonID', sql.Int, body.PrimaryContactPersonID)
    .input('AlternateContactPersonID', sql.Int, body.AlternateContactPersonID)
    .input('DeliveryMethodID', sql.Int, body.DeliveryMethodID ?? null)
    .input('DeliveryCityID', sql.Int, body.DeliveryCityID)
    .input('PostalCityID', sql.Int, body.PostalCityID)
    .input('DeliveryPostalCode', sql.NVarChar(10), body.DeliveryPostalCode)
    .input('PostalPostalCode', sql.NVarChar(20), body.PostalPostalCode)
    .input('PhoneNumber', sql.NVarChar(20), body.PhoneNumber)
    .input('FaxNumber', sql.NVarChar(20), body.FaxNumber)
    .input('WebsiteURL', sql.NVarChar(255), body.WebsiteURL)
    .input('DeliveryAddressLine1', sql.NVarChar(60), body.DeliveryAddressLine1)
    .input('DeliveryAddressLine2', sql.NVarChar(60), body.DeliveryAddressLine2 ?? null)
    .input('PostalAddressLine1', sql.NVarChar(60), body.PostalAddressLine1)
    .input('PostalAddressLine2', sql.NVarChar(60), body.PostalAddressLine2 ?? null)
    .input('DeliveryLatitude', sql.Decimal(9, 6), body.DeliveryLatitude ?? null)
    .input('DeliveryLongitude', sql.Decimal(9, 6), body.DeliveryLongitude ?? null)
    .input('BankAccountBranch', sql.NVarChar(20), body.BankAccountBranch)
    .input('BankAccountName', sql.NVarChar(100), body.BankAccountName)
    .input('BankAccountNumber', sql.NVarChar(20), body.BankAccountNumber)
    .input('PaymentDays', sql.Int, body.PaymentDays)
    .input('LastEditedBy', sql.Int, body.LastEditedBy);
}

function estadoError(err) {
  return err.number >= 50000 || err.code === 'EREQUEST' ? 400 : 500;
}

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

router.post('/', async (req, res) => {
  const requeridos = faltantes(req.body, camposProveedor);
  if (requeridos.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${requeridos.join(', ')}` });
  }

  // insert proveedor
  try {
    const pool = await poolPromise;
    const result = await parametrosProveedor(pool.request(), req.body)
      .execute('SP_InsertSupplier');
    res.status(201).json({ data: result.recordset[0] });
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  const requeridos = faltantes(req.body, camposProveedor);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'SupplierID inválido' });
  }
  if (requeridos.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${requeridos.join(', ')}` });
  }

  // update proveedor
  try {
    const pool = await poolPromise;
    await parametrosProveedor(pool.request(), req.body)
      .input('SupplierID', sql.Int, id)
      .execute('SP_UpdateSupplier');
    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'SupplierID inválido' });
  }

  // delete proveedor
  try {
    const pool = await poolPromise;
    await pool.request().input('SupplierID', sql.Int, id).execute('SP_DeleteSupplier');
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
      .input('SupplierID', sql.Int, parseInt(req.params.id))
      .execute('SP_GetSupplierDetails');

    res.json({ data: result.recordset });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;