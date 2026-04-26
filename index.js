const express = require('express');
const mercadopago = require('mercadopago');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// CONFIGURACIÓN ACTUALIZADA (SDK v2)
const client = new mercadopago.MercadoPagoConfig({ 
    accessToken: 'APP_USR-7170138245785084-040212-073be49b9f939e0d1645e3f421f579ce-1752495817' 
});

const preference = new mercadopago.Preference(client);

app.post('/create_preference', async (req, res) => {
    try {
        const body = {
            items: [{
                title: req.body.title,
                unit_price: Number(req.body.price),
                quantity: 1,
                currency_id: 'ARS'
            }],
            back_urls: {
                "success": "https://tripodir072-debug.github.io/comprablok-server/success.html",
                "failure": "https://tripodir072-debug.github.io/comprablok-server/failure.html",
            },
            auto_return: "approved",
        };

        const response = await preference.create({ body });
        res.json({ init_point: response.init_point });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Error al crear la preferencia" });
    }
});

app.get('/', (req, res) => res.send('🛡️ BÚNKER TRATO - 100% OPERATIVO'));

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`Servidor en puerto ${PORT}`));
