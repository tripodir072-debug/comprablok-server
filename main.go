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
