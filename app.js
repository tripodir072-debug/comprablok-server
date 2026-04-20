const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// 1. Servir archivos estáticos (esto evita que los estilos se pisen)
app.use(express.static(__dirname));

// 2. Ruta principal única
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// 3. Ruta para el proceso de Mercado Pago (lo que usa vender.html)
app.post('/create_preference', async (req, res) => {
    // Aquí va tu lógica de Mercado Pago...
    // Si no la tenés a mano, avisame y te paso el bloque del Token.
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
    console.log("Servidor TRATO funcionando correctamente");
});
