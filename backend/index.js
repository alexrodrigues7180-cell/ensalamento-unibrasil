const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Rota de saúde: prova que a API está viva
app.get('/health', (req, res) => {
  res.json({ status: 'ok', servico: 'ensalamento-api', hora: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API rodando na porta ${PORT}`));
