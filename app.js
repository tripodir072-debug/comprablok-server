const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');
const path = require('path');

const app = express();
app.use(express.json());
app.use(cors());

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, '/')));

const client = new MercadoPagoConfig({
  accessToken: process.env.MP_ACCESS_TOKEN
});

app.post("/create_preference", async (req, res) => {
  try {
    // Recibimos los datos del frontend, incluyendo el nombre del vendedor
    const { title, price, vendedor, trato_id } = req.body;
    
    // Aseguramos que el nombre del vendedor se use o se ponga uno por defecto
    const nombreVendedor = vendedor ? vendedor.toUpperCase() : "VENDEDOR REGISTRADO";
    const montoFinal = Number(price) * 1.10; // Comisión del 10%

    const preference = new Preference(client);
    const result = await preference.create({
      body: {
        items: [{
          // Ponemos al vendedor como el ID del ítem para tu control interno
          id: nombreVendedor,
          // Título ultra-seguro para el comprador
          title: `🛡️ VENDEDOR VALIDADO: ${nombreVendedor} | Producto: ${title}`,
          unit_price: montoFinal,
          quantity: 1,
          currency_id: "ARS",
          description: "Operación protegida por el Protocolo de Custodia TRATO de RICHARD BRO"
        }],
        // ID de control único
        external_reference: trato_id || "TR-SIN-ID",
        back_urls: {
          success: "https://comprablok-server.onrender.com/success.html",
          failure: "https://comprablok-server.onrender.com/vender.html",
        },
        auto_return: "approved",
        // Metadata extra por si Mercado Pago te pide auditoría
        metadata: {
          vendedor_nombre: nombreVendedor,
          protocolo: "TRATO_RICHARD_BRO"
        }
      },
    });
    res.json({ init_point: result.init_point });
  } catch (e) {
    console.error("Error MP:", e);
    res.status(500).json({ error: e.message });
  }
});

// RUTAS DE NAVEGACIÓN
app.get('/', (req, res) => { res.sendFile(path.join(__dirname, 'index.html')); });
app.get('/login.html', (req, res) => { res.sendFile(path.join(__dirname, 'login.html')); });
app.get('/registro.html', (req, res) => { res.sendFile(path.join(__dirname, 'registro.html')); });
app.get('/success.html', (req, res) => { res.sendFile(path.join(__dirname, 'success.html')); });
app.get('/vender.html', (req, res) => { res.sendFile(path.join(__dirname, 'vender.html')); });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => { 
    console.log('🚀 RICHARDBRO ONLINE - PROTOCOLO TRATO ACTIVADO'); 
});
