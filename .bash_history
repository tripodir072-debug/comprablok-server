					<button type="submit" class="btn btn-secondary">INGRESAR</button>
				</form>
			</div>
		</div></body></html>`)
	})

	http.HandleFunc("/dashboard", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("vendedor")
		resp, _ := http.Get("https://trato-89ed9-default-rtdb.firebaseio.com/tratos_app.json")
		defer resp.Body.Close()
		body, _ := ioutil.ReadAll(resp.Body)
		var tratos map[string]map[string]interface{}
		json.Unmarshal(body, &tratos)

		fmt.Fprintf(w, headerHTML + `<div class="navbar">Panel de %s</div>
		<div class="container">
			<a href="/nueva-venta?vendedor=%s" class="btn btn-secondary" style="margin-bottom:20px;">+ NUEVA VENTA</a>
			<div class="card">
				<h4 style="margin-top:0; text-align:left;">Ventas Registradas</h4>`, user, user)
		
		encontrado := false
		for _, t := range tratos {
			vData, _ := t["vendedor"].(string)
			if vData == user || user == "admin" {
				encontrado = true
				fmt.Fprintf(w, `<div class="item-venta">
					<div><b>%v</b><br><small>DNI: %v | %v</small></div>
					<div style="text-align:right;"><b>$%.2f</b><br><span class="status">%v</span></div>
				</div>`, t["producto"], t["dni"], t["entrega"], t["monto"], t["estado"])
			}
		}
		if !encontrado { fmt.Fprint(w, "<p style='color:#888;'>No hay ventas todavía.</p>") }
		fmt.Fprintf(w, `</div><a href="/" style="display:block; text-align:center; color:#888; text-decoration:none;">Cerrar Sesión</a></div></body></html>`)
	})

	http.HandleFunc("/nueva-venta", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("vendedor")
		fmt.Fprintf(w, headerHTML + `<div class="navbar">Nueva Operación</div>
		<div class="container"><div class="card">
			<form action="/crear" method="GET">
				<input type="hidden" name="vendedor" value="%s">
				<input type="text" name="prod" placeholder="Producto" required>
				<input type="number" name="dni" placeholder="DNI Comprador" required>
				<input type="number" name="monto" placeholder="Monto ARS" required>
				<select name="tipo">
					<option value="Cara a Cara">Cara a Cara (QR)</option>
					<option value="Envío">Envío a Domicilio</option>
				</select>
				<button type="submit" class="btn btn-secondary">GENERAR</button>
			</form>
		</div></div></body></html>`, user)
	})

	http.HandleFunc("/crear", func(w http.ResponseWriter, r *http.Request) {
		vendedor := r.URL.Query().Get("vendedor")
		prod := r.URL.Query().Get("prod")
		dni := r.URL.Query().Get("dni")
		tipo := r.URL.Query().Get("tipo")
		monto, _ := strconv.ParseFloat(r.URL.Query().Get("monto"), 64)
		id := fmt.Sprintf("%d", time.Now().Unix())
		
		trato := map[string]interface{}{
			"monto": monto * 1.03, "estado": "pendiente", "producto": prod, 
			"vendedor": vendedor, "dni": dni, "entrega": tipo,
		}
		js, _ := json.Marshal(trato)
		req, _ := http.NewRequest("PUT", "https://trato-89ed9-default-rtdb.firebaseio.com/tratos_app/"+id+".json", bytes.NewBuffer(js))
		http.DefaultClient.Do(req)
		
		link := "https://comprablok-server.onrender.com/pago?id=" + id
		qrURL := "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=" + url.QueryEscape(link)

		fmt.Fprintf(w, headerHTML + `<div class="container">
			<div class="card">
				<h3 style="color:#4caf50; margin-bottom:5px;">¡Trato Creado!</h3>
				<p style="margin-top:0; color:#666;">Entrega: <b>%s</b></p>
				<div style="margin:15px 0;">
					<img src="%s" style="width:180px; height:180px; border:1px solid #eee; border-radius:10px;">
				</div>
				<div class="btn-group">
					<a href="https://wa.me/?text=%s" class="btn btn-wa"><i class="fab fa-whatsapp"></i> ENVIAR LINK</a>
					<a href="/dashboard?vendedor=%s" class="btn btn-back">VOLVER AL PANEL</a>
				</div>
			</div>
		</div></body></html>`, tipo, qrURL, url.QueryEscape("Confirmá tu compra: "+link), vendedor)
	})

	http.HandleFunc("/pago", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Página de pago del cliente")
	})

	http.ListenAndServe(":"+port, nil)
}
EOF

git add .
git commit -m "💎 FIX: Espaciado de botones con Flexbox"
git push origin main --force
cat <<'EOF' > main.go
package main
import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"net/url"
	"strconv"
	"strings"
	"io/ioutil"
	"time"
)

const headerHTML = `<html><head><meta name="viewport" content="width=device-width, initial-scale=1"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"><style>
	body{font-family:'Segoe UI',sans-serif; background:#f0f2f5; margin:0; padding-bottom:30px;}
	.navbar{background:#004a8d; color:white; padding:15px; text-align:center; font-weight:bold;}
	.container{padding:20px; max-width:450px; margin:auto;}
	.card{background:white; padding:25px; border-radius:20px; box-shadow:0 4px 15px rgba(0,0,0,0.1); margin-bottom:20px; text-align:center;}
	input, select{width:100%; padding:15px; margin:10px 0; border-radius:12px; border:1px solid #ddd; font-size:16px; box-sizing:border-box;}
	
	/* Botones con separación forzada */
	.btn{color:white; padding:18px; border-radius:12px; text-decoration:none; display:block; font-weight:bold; border:none; width:100%; cursor:pointer; font-size:16px; box-sizing:border-box;}
	.btn-wa{background:#25d366; margin-bottom:20px !important;} /* Margen extra inferior */
	.btn-secondary{background:#004a8d;}
	.btn-back{background:#6c757d;}
	
	.item-venta{border-bottom:1px solid #eee; padding:15px 0; display:flex; justify-content:space-between; align-items:center; text-align:left;}
	.status{font-size:12px; background:#fff3e0; color:#ef6c00; padding:4px 10px; border-radius:10px; font-weight:bold;}
</style></head><body>`

func main() {
	port := os.Getenv("PORT")
	if port == "" { port = "8080" }

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(w, headerHTML + `<div class="container" style="margin-top:60px;">
			<div class="card">
				<i class="fas fa-shield-alt" style="font-size:50px; color:#004a8d; margin-bottom:15px;"></i>
				<h2>Ingreso TRATO</h2>
				<form action="/dashboard" method="GET">
					<input type="text" name="vendedor" placeholder="Usuario" required>
					<button type="submit" class="btn btn-secondary">INGRESAR</button>
				</form>
			</div>
		</div></body></html>`)
	})

	http.HandleFunc("/dashboard", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("vendedor")
		resp, _ := http.Get("https://trato-89ed9-default-rtdb.firebaseio.com/tratos_app.json")
		defer resp.Body.Close()
		body, _ := ioutil.ReadAll(resp.Body)
		var tratos map[string]map[string]interface{}
		json.Unmarshal(body, &tratos)

		fmt.Fprintf(w, headerHTML + `<div class="navbar">Panel de %s</div>
		<div class="container">
			<a href="/nueva-venta?vendedor=%s" class="btn btn-secondary" style="margin-bottom:20px;">+ NUEVA VENTA</a>
			<div class="card">
				<h4 style="margin-top:0; text-align:left;">Ventas Registradas</h4>`, user, user)
		
		encontrado := false
		for _, t := range tratos {
			vData, _ := t["vendedor"].(string)
			if vData == user || user == "admin" {
				encontrado = true
				fmt.Fprintf(w, `<div class="item-venta">
					<div><b>%v</b><br><small>DNI: %v | %v</small></div>
					<div style="text-align:right;"><b>$%.2f</b><br><span class="status">%v</span></div>
				</div>`, t["producto"], t["dni"], t["entrega"], t["monto"], t["estado"])
			}
		}
		if !encontrado { fmt.Fprint(w, "<p style='color:#888;'>No hay ventas todavía.</p>") }
		fmt.Fprintf(w, `</div><a href="/" style="display:block; text-align:center; color:#888; text-decoration:none;">Cerrar Sesión

git add .
git commit -m "💎 FIX: Margen forzado entre botones y QR"
git push origin main --force

cat <<'EOF' > main.go
package main
import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"net/url"
	"strconv"
	"strings"
	"io/ioutil"
	"time"
)

const headerHTML = `<html><head><meta name="viewport" content="width=device-width, initial-scale=1"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"><style>
	body{font-family:'Segoe UI',sans-serif; background:#f0f2f5; margin:0; padding-bottom:30px;}
	.navbar{background:#004a8d; color:white; padding:15px; text-align:center; font-weight:bold;}
	.container{padding:20px; max-width:450px; margin:auto;}
	.card{background:white; padding:25px; border-radius:20px; box-shadow:0 4px 15px rgba(0,0,0,0.1); margin-bottom:20px; text-align:center;}
	
	/* Botones con Rejilla (Grid) para separación exacta */
	.btn-container {
		display: grid;
		grid-template-columns: 1fr;
		gap: 20px; /* Separación de 20px garantizada */
		margin-top: 20px;
	}
	
	.btn{color:white; padding:18px; border-radius:12px; text-decoration:none; display:block; font-weight:bold; border:none; width:100%; cursor:pointer; font-size:16px; box-sizing:border-box; margin:0;}
	.btn-wa{background:#25d366;}
	.btn-secondary{background:#004a8d;}
	.btn-back{background:#6c757d;}
	
	.item-venta{border-bottom:1px solid #eee; padding:15px 0; display:flex; justify-content:space-between; align-items:center; text-align:left;}
	.status{font-size:12px; background:#fff3e0; color:#ef6c00; padding:4px 10px; border-radius:10px; font-weight:bold;}
</style></head><body>`

func main() {
	port := os.Getenv("PORT")
	if port == "" { port = "8080" }

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(w, headerHTML + `<div class="container" style="margin-top:60px;">
			<div class="card">
				<i class="fas fa-shield-alt" style="font-size:50px; color:#004a8d; margin-bottom:15px;"></i>
				<h2>Ingreso TRATO</h2>
				<form action="/dashboard" method="GET">
					<input type="text" name="vendedor" placeholder="Usuario" required style="width:100%; padding:15px; margin:10px 0; border-radius:12px; border:1px solid #ddd;">
					<button type="submit" class="btn btn-secondary">INGRESAR</button>
				</form>
			</div>
		</div></body></html>`)
	})

	http.HandleFunc("/dashboard", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("vendedor")
		resp, _ := http.Get("https://trato-89ed9-default-rtdb.firebaseio.com/tratos_app.json")
		defer resp.Body.Close()
		body, _ := ioutil.ReadAll(resp.Body)
		var tratos map[string]map[string]interface{}
		json.Unmarshal(body, &tratos)

		fmt.Fprintf(w, headerHTML + `<div class="navbar">Panel de %s</div>
		<div class="container">
			<a href="/nueva-venta?vendedor=%s" class="btn btn-secondary" style="margin-bottom:20px;">+ NUEVA VENTA</a>
			<div class="card">
				<h4 style="margin-top:0; text-align:left;">Ventas Registradas</h4>`, user, user)
		
		encontrado := false
		for _, t := range tratos {
			vData, _ := t["vendedor"].(string)
			if vData == user || user == "admin" {
				encontrado = true
				fmt.Fprintf(w, `<div class="item-venta">
					<div><b>%v</b><br><small>DNI: %v | %v</small></div>
					<div style="text-align:right;"><b>$%.2f</b><br><span class="status">%v</span></div>
				</div>`, t["producto"], t["dni"], t["entrega"], t["monto"], t["estado"])
			}
		}
		if !encontrado { fmt.Fprint(w, "<p style='color:#888;'>No hay ventas todavía.</p>") }
		fmt.Fprintf(w, `</div><a href="/" style="display:block; text-align:center; color:#888; text-decoration:none;">Cerrar Sesión</a></div></body></html>`)
	})

	http.HandleFunc("/nueva-venta", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("vendedor")
		fmt.Fprintf(w, headerHTML + `<div class="navbar">Nueva Operación</div>
		<div class="container"><div class="card">
			<form action="/crear" method="GET">
				<input type="hidden" name="vendedor" value="%s">
				<input type="text" name="prod" placeholder="Producto" required style="width:100%; padding:15px; margin:10px 0; border-radius:12px; border:1px solid #ddd;">
				<input type="number" name="dni" placeholder="DNI Comprador" required style="width:100%; padding:15px; margin:10px 0; border-radius:12px; border:1px solid #ddd;">
				<input type="number" name="monto" placeholder="Monto ARS" required style="width:100%; padding:15px; margin:10px 0; border-radius:12px; border:1px solid #ddd;">
				<select name="tipo" style="width:100%; padding:15px; margin:10px 0; border-radius:12px; border:1px solid #ddd;">
					<option value="Cara a Cara">Cara a Cara (QR)</option>
					<option value="Envío">Envío a Domicilio</option>
				</select>
				<button type="submit" class="btn btn-secondary">GENERAR</button>
			</form>
		</div></div></body></html>`, user)
	})

	http.HandleFunc("/crear", func(w http.ResponseWriter, r *http.Request) {
		vendedor := r.URL.Query().Get("vendedor")
		prod := r.URL.Query().Get("prod")
		dni := r.URL.Query().Get("dni")
		tipo := r.URL.Query().Get("tipo")
		monto, _ := strconv.ParseFloat(r.URL.Query().Get("monto"), 64)
		id := fmt.Sprintf("%d", time.Now().Unix())
		
		trato := map[string]interface{}{
			"monto": monto * 1.03, "estado": "pendiente", "producto": prod, 
			"vendedor": vendedor, "dni": dni, "entrega": tipo,
		}
		js, _ := json.Marshal(trato)
		req, _ := http.NewRequest("PUT", "https://trato-89ed9-default-rtdb.firebaseio.com/tratos_app/"+id+".json", bytes.NewBuffer(js))
		http.DefaultClient.Do(req)
		
		link := "https://comprablok-server.onrender.com/pago?id=" + id
		qrURL := "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=" + url.QueryEscape(link)

		fmt.Fprintf(w, headerHTML + `<div class="container">
			<div class="card">
				<h3 style="color:#4caf50; margin-bottom:5px;">¡Trato Creado!</h3>
				<p style="margin-top:0; color:#666;">Entrega: <b>%s</b></p>
				<div style="margin:15px 0;">
					<img src="%s" style="width:180px; height:180px; border:1px solid #eee; border-radius:10px;">
				</div>
				<div class="btn-container">
					<a href="https://wa.me/?text=%s" class="btn btn-wa"><i class="fab fa-whatsapp"></i> ENVIAR LINK</a>
					<a href="/dashboard?vendedor=%s" class="btn btn-back">VOLVER AL PANEL</a>
				</div>
			</div>
		</div></body></html>`, tipo, qrURL, url.QueryEscape("Confirmá tu compra de "+prod+": "+link), vendedor)
	})

	http.HandleFunc("/pago", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Página de pago del cliente")
	})

	http.ListenAndServe(":"+port, nil)
}
EOF

git add .
git commit -m "🚀 Estilo Grid: Separación de botones 100% garantizada"
git push origin main --force
cat <<'EOF' > main.go
package main
import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"net/url"
	"strconv"
	"strings"
	"io/ioutil"
	"time"
)

// Estilos base de TRATO (Limpio y Profesional)
const headerHTML = `<html><head><meta name="viewport" content="width=device-width, initial-scale=1"><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"><style>
	body{font-family:'Segoe UI',sans-serif; background:#f4f7f6; margin:0; color:#333;}
	.navbar{background:#004a8d; color:white; padding:15px; text-align:center; font-weight:bold; font-size:20px;}
	.container{padding:20px; max-width:450px; margin:auto;}
	.card{background:white; padding:25px; border-radius:15px; box-shadow:0 10px 25px rgba(0,0,0,0.1); margin-bottom:20px; text-align:center;}
	.role-box{display:grid; grid-template-columns: 1fr; gap:15px; margin-top:20px;}
	input, select{width:100%; padding:15px; margin:10px 0; border-radius:10px; border:1px solid #ddd; font-size:16px; box-sizing:border-box;}
	.btn{color:white; padding:18px; border-radius:10px; text-decoration:none; display:block; font-weight:bold; border:none; width:100%; cursor:pointer; font-size:16px;}
	.btn-primary{background:#004a8d;}
	.btn-vendedor{background:#28a745;}
	.btn-comprador{background:#17a2b8;}
	.footer-link{display:block; margin-top:20px; color:#666; text-decoration:none; font-size:14px;}
</style></head><body>`

func main() {
	port := os.Getenv("PORT")
	if port == "" { port = "8080" }

	// 1. LOGIN: La puerta de entrada única
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(w, headerHTML + `
		<div class="navbar">🛡️ TRATO</div>
		<div class="container">
			<div class="card">
				<h3>Identificación de Usuario</h3>
				<p>Ingresá tu nombre para continuar</p>
				<form action="/identificar" method="GET">
					<input type="text" name="usuario" placeholder="Tu Nombre o Apodo" required>
					<button type="submit" class="btn btn-primary">ENTRAR</button>
				</form>
			</div>
		</div></body></html>`)
	})

	// 2. IDENTIFICAR: Selección de Rol (Soy Comprador / Soy Vendedor)
	http.HandleFunc("/identificar", func(w http.ResponseWriter, r *http.Request) {
		usuario := r.URL.Query().Get("usuario")
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		fmt.Fprintf(w, headerHTML + `
		<div class="navbar">Bienvenido, %s</div>
		<div class="container">
			<div class="card">
				<h3>¿Qué vas a hacer hoy?</h3>
				<div class="role-box">
					<a href="/vendedor?user=%s" class="btn btn-vendedor"><i class="fas fa-store"></i> SOY VENDEDOR</a>
					<a href="/comprador?user=%s" class="btn btn-comprador"><i class="fas fa-shopping-cart"></i> SOY COMPRADOR</a>
				</div>
				<a href="/" class="footer-link">Volver al inicio</a>
			</div>
		</div></body></html>`, usuario, usuario, usuario)
	})

	// 3. VENDEDOR: Panel para crear tratos
	http.HandleFunc("/vendedor", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("user")
		fmt.Fprintf(w, headerHTML + `
		<div class="navbar">Panel Vendedor</div>
		<div class="container">
			<div class="card">
				<h4>Generar Nueva Venta</h4>
				<form action="/crear-trato" method="GET">
					<input type="hidden" name="vendedor" value="%s">
					<input type="text" name="prod" placeholder="Producto" required>
					<input type="number" name="monto" placeholder="Monto (ARS)" required>
					<input type="number" name="dni_cliente" placeholder="DNI del Comprador" required>
					<select name="modalidad">
						<option value="cara-a-cara">Cara a Cara (QR)</option>
						<option value="distancia">A Distancia (Envío)</option>
					</select>
					<button type="submit" class="btn btn-vendedor">CREAR TRATO SEGURO</button>
				</form>
			</div>
			<a href="/identificar?usuario=%s" class="footer-link" style="text-align:center;">Cambiar de Rol</a>
		</div></body></html>`, user, user)
	})

	// 4. COMPRADOR: Panel para ver sus compras (Filtrado por DNI o Usuario)
	http.HandleFunc("/comprador", func(w http.ResponseWriter, r *http.Request) {
		user := r.URL.Query().Get("user")
		fmt.Fprintf(w, headerHTML + `
		<div class="navbar">Mis Compras</div>
		<div class="container">
			<div class="card">
				<h3>Tus Tratos Pendientes</h3>
				<p>Próximamente verás aquí los productos vinculados a tu usuario.</p>
				<p style="color:#888;">Cargando base de datos...</p>
			</div>
			<a href="/identificar?usuario=%s" class="footer-link" style="text-align:center;">Volver</a>
		</div></body></html>`, user)
	})

	http.ListenAndServe(":"+port, nil)
}
EOF

git init
git remote add origin https://github.com/tripodir072-debug/comprablok-server.git
git add .
git commit -m "🥚 Proyecto TRATO: Fase 1 - Login y Roles"
git branch -M main
git push origin main --force
rm -rf * .git
cat <<'EOF' > main.go
package main
import (
	"fmt"
	"net/http"
	"os"
)

const style = `<html><head><meta name="viewport" content="width=device-width, initial-scale=1"><style>
	body{font-family:sans-serif; background:#f0f2f5; display:flex; justify-content:center; align-items:center; height:100vh; margin:0;}
	.card{background:white; padding:30px; border-radius:15px; box-shadow:0 4px 10px rgba(0,0,0,0.1); width:90%; max-width:350px; text-align:center;}
	input{width:100%; padding:15px; margin:10px 0; border-radius:8px; border:1px solid #ccc; box-sizing:border-box; font-size:16px;}
	.btn{background:#004a8d; color:white; padding:15px; border:none; border-radius:8px; width:100%; font-weight:bold; cursor:pointer; font-size:16px;}
</style></head><body>`

func main() {
	port := os.Getenv("PORT")
	if port == "" { port = "8080" }

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, style + `
			<div class="card">
				<h2>🛡️ TRATO</h2>
				<p>Paso 1: Identificación</p>
				<form action="/test-login" method="GET">
					<input type="text" name="nombre" placeholder="Tu Nombre" required>
					<input type="number" name="dni" placeholder="Tu DNI" required>
					<button type="submit" class="btn">PROBAR ACCESO</button>
				</form>
			</div>
		</body></html>`)
	})

	http.HandleFunc("/test-login", func(w http.ResponseWriter, r *http.Request) {
		nombre := r.URL.Query().Get("nombre")
		dni := r.URL.Query().Get("dni")
		fmt.Fprintf(w, style + `
			<div class="card">
				<h3 style="color:green;">¡Punto 1 Superado!</h3>
				<p>El sistema te reconoce como:</p>
				<p><b>Usuario:</b> %s</p>
				<p><b>DNI:</b> %s</p>
				<hr>
				<p>¿Ves tus datos correctamente arriba? <br> Si es así, avisame y pasamos al Punto 2 (Selector de Rol).</p>
				<a href="/" style="color:#666; font-size:14px; text-decoration:none;">Reiniciar Prueba</a>
			</div>
		</body></html>`, nombre, dni)
	})

	http.ListenAndServe(":"+port, nil)
}
EOF

