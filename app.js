const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cors());
app.use(express.static(__dirname));

// CONEXIÓN CON TU TOKEN (Asegurate que esté en Render)
const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN
});

app.post("/create_preference", async (req, res) => {
  try {
    const { title, price } = req.body;
    const preference = new Preference(client);
    
    const result = await preference.create({
      body: {
        items: [{
          id: "RB-001",
          title: title || "Venta Oficial RICHARDBRO",
          unit_price: Number(price),
          quantity: 1,
          currency_id: "ARS"
        }],
        // AQUÍ ESTABA EL ERROR: Ahora te manda a tu propia página de éxito
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

app.get('/', (req, res) => { res.sendFile(path.join(__dirname, 'index.html')); });

app.listen(3000, () => { console.log('🚀 RICHARDBRO ONLINE'); });
