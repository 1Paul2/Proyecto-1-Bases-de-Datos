const express = require('express');
const router = express.Router();
const { sql, poolPromise } = require('../db');

const camposObligatorios = [
  'CustomerName',
  'CustomerCategoryID',
  'PrimaryContactPersonID',
  'BillToCustomerID',
  'DeliveryMethodID',
  'DeliveryCityID',
  'PostalCityID',
  'DeliveryPostalCode',
  'PostalPostalCode',
  'PhoneNumber',
  'FaxNumber',
  'PaymentDays',
  'StandardDiscountPercentage',
  'IsStatementSent',
  'IsOnCreditHold',
  'WebsiteURL',
  'DeliveryAddressLine1',
  'PostalAddressLine1',
  'AccountOpenedDate'
];

function validarCampos(body, campos) {
  return campos.filter(campo => body[campo] === undefined || body[campo] === null || body[campo] === '');
}

function enteroOpcional(valor) {
  if (valor === undefined || valor === null || valor === '') return null;
  const numero = Number(valor);
  return Number.isInteger(numero) && numero > 0 ? numero : null;
}

function decimalOpcional(valor) {
  if (valor === undefined || valor === null) return null;
  if (typeof valor === 'string' && valor.trim() === '') return null;
  const numero = Number(typeof valor === 'string' ? valor.trim() : valor);
  return Number.isFinite(numero) ? numero : null;
}

function agregarParametrosCliente(request, body) {
  return request
    .input('CustomerName', sql.NVarChar(100), body.CustomerName)
    .input('CustomerCategoryID', sql.Int, body.CustomerCategoryID)
    .input('BuyingGroupID', sql.Int, enteroOpcional(body.BuyingGroupID))
    .input('PrimaryContactPersonID', sql.Int, body.PrimaryContactPersonID)
    .input('AlternateContactPersonID', sql.Int, enteroOpcional(body.AlternateContactPersonID))
    .input('BillToCustomerID', sql.Int, enteroOpcional(body.BillToCustomerID))
    .input('DeliveryMethodID', sql.Int, body.DeliveryMethodID)
    .input('DeliveryCityID', sql.Int, enteroOpcional(body.DeliveryCityID))
    .input('PostalCityID', sql.Int, body.PostalCityID)
    .input('DeliveryPostalCode', sql.NVarChar(10), body.DeliveryPostalCode)
    .input('PostalPostalCode', sql.NVarChar(20), body.PostalPostalCode ?? null)
    .input('PhoneNumber', sql.NVarChar(20), body.PhoneNumber ?? null)
    .input('FaxNumber', sql.NVarChar(20), body.FaxNumber ?? null)
    .input('PaymentDays', sql.Int, body.PaymentDays)
    .input('StandardDiscountPercentage', sql.Decimal(18, 3), body.StandardDiscountPercentage)
    .input('IsStatementSent', sql.Bit, body.IsStatementSent ? 1 : 0)
    .input('IsOnCreditHold', sql.Bit, body.IsOnCreditHold ? 1 : 0)
    .input('WebsiteURL', sql.NVarChar(100), body.WebsiteURL ?? null)
    .input('DeliveryAddressLine1', sql.NVarChar(60), body.DeliveryAddressLine1 ?? null)
    .input('DeliveryAddressLine2', sql.NVarChar(60), body.DeliveryAddressLine2 ?? null)
    .input('PostalAddressLine1', sql.NVarChar(60), body.PostalAddressLine1 ?? null)
    .input('PostalAddressLine2', sql.NVarChar(60), body.PostalAddressLine2 ?? null)
    .input('AccountOpenedDate', sql.Date, body.AccountOpenedDate)
    .input('DeliveryLatitude', sql.Decimal(9, 6), decimalOpcional(body.DeliveryLatitude))
    .input('DeliveryLongitude', sql.Decimal(9, 6), decimalOpcional(body.DeliveryLongitude));
}

function estadoError(err) {
  return err.number >= 50000 || err.code === 'EREQUEST' ? 400 : 500;
}

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

router.post('/', async (req, res) => {
  const faltantes = validarCampos(req.body, camposObligatorios);
  if (faltantes.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${faltantes.join(', ')}` });
  }

  // insert cliente
  try {
    const pool = await poolPromise;
    const result = await agregarParametrosCliente(pool.request(), req.body)
      .execute('SP_InsertCustomer');

    res.status(201).json({ data: result.recordset[0] });
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.put('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  const faltantes = validarCampos(req.body, camposObligatorios);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'CustomerID inválido' });
  }
  if (faltantes.length > 0) {
    return res.status(400).json({ error: `Campos obligatorios: ${faltantes.join(', ')}` });
  }


  // update cliente
  try {
    const pool = await poolPromise;
    await agregarParametrosCliente(pool.request(), req.body)
      .input('CustomerID', sql.Int, id)
      .execute('SP_UpdateCustomer');

    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

router.delete('/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  if (!Number.isInteger(id) || id <= 0) {
    return res.status(400).json({ error: 'CustomerID inválido' });
  }

  // delete cliente
  try {
    const pool = await poolPromise;
    await pool.request()
      .input('CustomerID', sql.Int, id)
      .execute('SP_DeleteCustomer');

    res.status(204).send();
  } catch (err) {
    res.status(estadoError(err)).json({ error: err.message });
  }
});

// Detalle
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