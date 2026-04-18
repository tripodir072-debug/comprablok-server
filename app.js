const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static(__dirname));

const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN
});

app.post("/create_preference", async (req, res) => {
  try {
    const { title, price, vendedor } = req.body;
    
    // AQUÍ EL 10% DE COMISIÓN
    const montoBase = Number(price);
    const montoFinal = montoBase * 1.10; 

    const preference = new Preference(client);
    const result = await preference.create({
      body: {
        items: [{
          id: vendedor || "RichardBro_User", // Aquí guardamos quién hizo la venta
          title: (title || "Producto") + " (Protegido por RICHARDBRO)",
          unit_price: montoFinal,
          quantity: 1,
          currency_id: "ARS"
        }],
        back_urls: {
          success: "https://comprablok-server.onrender.com/success.html",
          failure: "https://comprablok-server.onrender.com/vender.html",
          pending: "https://comprablok-server.onrender.com/vender.html"
        },
        auto_return: "approved",
      },
    });
    res.json({ init_point: result.init_point });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Rutas para que Render encuentre los archivos
app.get('/', (req, res) => { res.sendFile(path.join(__dirname, 'index.html')); });
app.get('/login', (req, res) => { res.sendFile(path.join(__dirname, 'login.html')); });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => { console.log('🚀 RICHARDBRO SISTEMA DE LOGIN ONLINE'); });
