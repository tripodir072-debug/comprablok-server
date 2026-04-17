const express = require('express');
const cors = require('cors');
const { MercadoPagoConfig, Preference } = require('mercadopago');

const app = express();
app.use(express.json());
app.use(cors());

const client = new MercadoPagoConfig({ 
    accessToken: 'APP_USR-3822730786979070-041707-2a6a7a0555139c12f88e5ba93b0ed401-220923936' 
});

app.post('/crear-venta', async (req, res) => {
    const { monto } = req.body;
    console.log(`💰 Pedido recibido: $${monto}`);
    const precioFinal = parseFloat(monto) * 1.10;

    try {
        const preference = new Preference(client);
        const result = await preference.create({
            body: {
                items: [{
                    title: 'Venta Comprablok Oficial',
                    quantity: 1,
                    unit_price: precioFinal,
                    currency_id: 'ARS'
                }],
                back_urls: { success: 'https://comprablok.web.app' },
                auto_return: 'approved'
            }
        });
        res.json({ link: result.init_point });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Esto sirve la web automáticamente
app.get('/', (req, res) => { res.sendFile(__dirname + '/index.html'); });

app.listen(3000, () => {
    console.log('\n✨ ¡TODO INTEGRADO CON ÉXITO, RICHARD! ✨');
    console.log('🚀 MOTOR COMPRABLOK: Esperando tus ventas...');
});
