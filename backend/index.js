const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', servico: 'ensalamento-api', hora: new Date().toISOString() });
});

app.get('/db-test', async (req, res) => {
  try {
    const resultado = await pool.query('SELECT NOW() AS agora');
    res.json({ status: 'ok', banco: 'conectado', hora_do_banco: resultado.rows[0].agora });
  } catch (erro) {
    res.status(500).json({ status: 'erro', mensagem: erro.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API rodando na porta ${PORT}`));
