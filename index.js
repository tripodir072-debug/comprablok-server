const express = require('express');
const mercadopago = require('mercadopago');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// CONFIGURACIÓN ORIGINAL QUE ANDABA BIEN
mercadopago.configure({
    access_token: 'APP_USR-7170138245785084-040212-073be49b9f939e0d1645e3f421f579ce-1752495817'
});

app.post('/create_preference', (req, res) => {
    let preference = {
        items: [{
            title: req.body.title,
            unit_price: Number(req.body.price),
            quantity: 1,
            currency_id: 'ARS'
        }],
        back_urls: {
            "success": "https://tripodir072-debug.github.io/comprablok-server/success.html",
            "failure": "https://tripodir072-debug.github.io/comprablok-server/index.html",
        },
        auto_return: "approved",
    };

    mercadopago.preferences.create(preference)
        .then(response => {
            // Esto manda el link automático de vuelta a tu página
            res.json({ init_point: response.body.init_point });
        })
        .catch(error => {
            console.log(error);
            res.status(500).json(error);
        });
});

app.get('/', (req, res) => res.send('🛡️ COMPRABLOK ONLINE - MOTOR LISTO'));

const PORT = process.env.PORT || 10000;
app.listen(PORT, () => {
    console.log(`Servidor corriendo en puerto ${PORT}`);
});
