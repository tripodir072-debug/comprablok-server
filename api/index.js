const express = require('express');
const mercadopago = require('mercadopago');
const cors = require('cors');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cors());

const client = new mercadopago.MercadoPagoConfig({ 
    accessToken: 'APP_USR-7170138245785084-040212-073be49b9f939e0d1645e3f421f579ce-1752495817' 
});

const preference = new mercadopago.Preference(client);

// API para crear pagos
app.post('/api/create_preference', async (req, res) => {
    try {
        const body = {
            items: [{
                title: req.body.title,
                unit_price: Number(req.body.price),
                quantity: 1,
                currency_id: 'ARS'
            }],
            back_urls: {
                "success": "https://www.google.com", 
                "failure": "https://www.google.com",
            },
            auto_return: "approved",
        };
        const response = await preference.create({ body });
        res.json({ init_point: response.init_point });
    } catch (error) {
        res.status(500).json({ error: "Error" });
    }
});

// Ruta para el Login (Fachada)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../index.html'));
});

// Ruta para la Terminal (Vender)
app.get('/vender', (req, res) => {
    res.sendFile(path.join(__dirname, '../vender.html'));
});

module.exports = app;
