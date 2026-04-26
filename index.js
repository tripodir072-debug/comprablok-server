const express = require('express');
const mercadopago = require('mercadopago');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// CONFIGURACIÓN SDK v2
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

// ESTO ES LO QUE REEMPLAZA EL "MENSAJE FEO"
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>TRATO Búnker</title>
            <style>
                body { background: #020617; color: white; font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; text-align: center; }
                .card { background: rgba(30, 41, 59, 0.5); backdrop-filter: blur(10px); padding: 50px; border-radius: 40px; border: 1px solid rgba(0, 210, 255, 0.3); box-shadow: 0 0 50px rgba(0,0,0,0.5); }
                .logo { font-size: 70px; margin-bottom: 20px; }
                h1 { letter-spacing: -2px; margin: 0; font-size: 32px; }
                .status { color: #00d2ff; font-weight: bold; letter-spacing: 3px; font-size: 12px; margin-top: 10px; }
            </style>
        </head>
        <body>
            <div class="card">
                <div class="logo">🛡️</div>
                <h1>TRATO™ BÚNKER</h1>
                <div class="status">SISTEMA ONLINE - ENCRIPTADO</div>
                <p style="opacity: 0.5; font-size: 10px; margin-top: 30px;">RICHARDBRO® ARBITRAGE SECURITY</p>
            </div>
        </body>
        </html>
    `);
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log(`Servidor en puerto ${PORT}`));
