const express = require('express');
const sql = require('mssql');

const app = express();
app.use(express.json());

const config = {
  user: process.env.DB_USER || 'sa',
  password: process.env.DB_PASSWORD || 'DockerStrongPass2026!',
  server: process.env.DB_SERVER || 'host.docker.internal',
  port: Number(process.env.DB_PORT || 1433),
  database: process.env.DB_DATABASE || 'CELEBRITIES',
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

// GET all celebrities
app.get('/api/celebrities', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT * FROM CELEBRITIES');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET celebrity by ID
app.get('/api/celebrities/:id', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('SELECT * FROM CELEBRITIES WHERE ID = @id');
    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Celebrity not found' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST create celebrity
app.post('/api/celebrities', async (req, res) => {
  try {
    const { FULLNAME, NATIONALITY, REQPHOTOPATH } = req.body;
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('fullname', sql.NVarChar(50), FULLNAME)
      .input('nationality', sql.NVarChar(2), NATIONALITY)
      .input('reqphotopath', sql.NVarChar(200), REQPHOTOPATH || null)
      .query('INSERT INTO CELEBRITIES (FULLNAME, NATIONALITY, REQPHOTOPATH) OUTPUT INSERTED.* VALUES (@fullname, @nationality, @reqphotopath)');
    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT update celebrity
app.put('/api/celebrities/:id', async (req, res) => {
  try {
    const { FULLNAME, NATIONALITY, REQPHOTOPATH } = req.body;
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .input('fullname', sql.NVarChar(50), FULLNAME)
      .input('nationality', sql.NVarChar(2), NATIONALITY)
      .input('reqphotopath', sql.NVarChar(200), REQPHOTOPATH || null)
      .query('UPDATE CELEBRITIES SET FULLNAME=@fullname, NATIONALITY=@nationality, REQPHOTOPATH=@reqphotopath WHERE ID=@id; SELECT * FROM CELEBRITIES WHERE ID=@id');
    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Celebrity not found' });
    }
    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE celebrity
app.delete('/api/celebrities/:id', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request()
      .input('id', sql.Int, req.params.id)
      .query('DELETE FROM CELEBRITIES WHERE ID=@id');
    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ error: 'Celebrity not found' });
    }
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = Number(process.env.PORT || 2280);
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
