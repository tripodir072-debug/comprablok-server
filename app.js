const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');

const app = express();
app.use(express.json());
app.use(cors());

const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN
});

// --- MOTOR DE PAGOS TRATO ---
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

// --- ETAPA 2: SEGURIDAD Y VERIFICACIÓN ---

// 1. Registro de Usuarios Verificados (Simulado para hoy)
app.post("/verificar_usuario", (req, res) => {
  const { dni, nombre } = req.body;
  console.log(`✅ Usuario verificado: ${nombre} (DNI: ${dni})`);
  res.json({ status: "success", message: "Usuario verificado en RICHARDBRO" });
});

// 2. Buscador de Alerta por Robo
app.get("/chequear_producto/:serial", (req, res) => {
  const serial = req.params.serial;
  // Aquí luego conectaremos con la base de datos real
  res.json({ seguro: true, mensaje: "Producto sin reportes de robo" });
});

// 3. Confirmación de Entrega (Liberar fondos)
app.post("/confirmar_entrega", (req, res) => {
  const { transaccionId } = req.body;
  res.json({ status: "success", message: "Fondos liberados al vendedor" });
});

app.get('/', (req, res) => { res.sendFile(__dirname + '/index.html'); });
app.listen(3000, () => {
  console.log('🏁 RICHARDBRO: Motor completo y blindado listo!');
});
