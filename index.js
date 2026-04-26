const express = require('express');
const mercadopago = require('mercadopago');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

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
        res.status(500).json({ error: "Error" });
    }
});

// PANTALLA DE BIENVENIDA PROFESIONAL CON REDIRECCIÓN
app.get('/', (req, res) => {
    res.send(`
        <!DOCTYPE html>
        <html lang="es">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>TRATO™ | Richard Bro</title>
            <style>
                :root { --blue: #1877F2; --neon: #00d2ff; --dark: #020617; }
                body { background: var(--dark); color: white; font-family: sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; text-align: center; overflow: hidden; }
                .card { background: rgba(30, 41, 59, 0.4); backdrop-filter: blur(20px); padding: 60px 40px; border-radius: 50px; border: 1px solid rgba(0, 210, 255, 0.2); box-shadow: 0 0 100px rgba(0,0,0,0.8); width: 85%; max-width: 450px; }
                .shield { font-size: 80px; margin-bottom: 20px; filter: drop-shadow(0 0 20px var(--blue)); }
                h1 { letter-spacing: -2px; margin: 0; font-size: 35px; font-weight: 900; }
                .subtitle { color: var(--neon); font-size: 12px; font-weight: bold; letter-spacing: 5px; margin-bottom: 40px; text-transform: uppercase; }
                .btn-enter { display: inline-block; background: var(--blue); color: white; text-decoration: none; padding: 22px 45px; border-radius: 25px; font-weight: 900; font-size: 14px; letter-spacing: 2px; text-transform: uppercase; transition: 0.3s; box-shadow: 0 10px 30px rgba(24, 119, 242, 0.4); }
                .btn-enter:hover { transform: translateY(-5px); box-shadow: 0 15px 40px rgba(24, 119, 242, 0.6); background: #2384ff; }
                .footer { margin-top: 40px; font-size: 10px; opacity: 0.3; letter-spacing: 2px; }
            </style>
        </head>
        <body>
            <div class="card">
                <div class="shield">🛡️</div>
                <h1>TRATO™</h1>
                <p class="subtitle">Búnker de Seguridad</p>
                <p style="opacity: 0.7; font-size: 14px; margin-bottom: 40px;">Bienvenido al sistema de arbitraje y custodia más seguro de Argentina.</p>
                <a href="https://tripodir072-debug.github.io/comprablok-server/" class="btn-enter">INGRESAR AL SISTEMA</a>
                <div class="footer">RICHARDBRO® ARBITRAGE SECURITY</div>
            </div>
        </body>
        </html>
    `);
});

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => console.log("Live"));
