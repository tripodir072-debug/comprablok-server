const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cors());

// ESTO ES CLAVE: Le dice al servidor que busque archivos en tu carpeta principal
app.use(express.static(path.join(__dirname, '/')));

const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN
});

app.post("/create_preference", async (req, res) => {
  try {
    // Agregamos 'trato_id' para recibirlo desde el frontend
    const { title, price, vendedor, trato_id } = req.body;
    const montoFinal = Number(price) * 1.10; // Tu comisión del 10%

    const preference = new Preference(client);
    const result = await preference.create({
      body: {
        items: [{
          id: vendedor || "Richard_Admin",
          title: (title || "Venta") + " - Protegido por RICHARDBRO",
          unit_price: montoFinal,
          quantity: 1,
          currency_id: "ARS"
        }],
        // ESTA LÍNEA ES LA MAGIA: Guarda tu ID de control en Mercado Pago
        external_reference: trato_id || "TR-SIN-ID",
        back_urls: {
          success: "https://comprablok-server.onrender.com/success.html",
          failure: "https://comprablok-server.onrender.com/vender.html",
        },
        auto_return: "approved",
      },
    });
    res.json({ init_point: result.init_point });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// DEFINICIÓN DE RUTAS (Las llaves para entrar a cada página)
app.get('/', (req, res) => { res.sendFile(path.join(__dirname, 'index.html')); });
app.get('/login.html', (req, res) => { res.sendFile(path.join(__dirname, 'login.html')); });
app.get('/success.html', (req, res) => { res.sendFile(path.join(__dirname, 'success.html')); });
app.get('/vender.html', (req, res) => { res.sendFile(path.join(__dirname, 'vender.html')); });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => { console.log('🚀 RICHARDBRO ONLINE - PUERTAS ABIERTAS'); });
