const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');

const app = express();
app.use(express.json());
app.use(cors());

const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN
});

// MOTOR TRATO: Generador de pagos automáticos
app.post("/create_preference", async (req, res) => {
  try {
    const { title, price } = req.body;
    const preference = new Preference(client);
    const result = await preference.create({
      body: {
        items: [{
          title: title || "Pago Seguro TRATO",
          unit_price: Number(price),
          quantity: 1,
          currency_id: "ARS",
        }],
        back_urls: {
          success: "https://comprablok-server.onrender.com/success",
          failure: "https://comprablok-server.onrender.com/failure",
        },
        auto_return: "approved",
      },
    });
    res.json({ init_point: result.init_point });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/', (req, res) => { res.send('MOTOR TRATO: ONLINE 🚀'); });

app.listen(3000, () => {
  console.log('\n🚀 TRATO: Motor de pagos listo!');
});
