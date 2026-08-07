## Enrutamiento

**`go_router`**, introducido en cuanto hubo más de una pantalla real que navegar (dashboard →
detalle de dispositivo). Antes de eso, el arranque de la app resolvía la pantalla a mano según el
estado de `authController` — eso se reemplaza por rutas + `redirect` de `go_router` basado en ese
mismo estado (no se duplica la lógica de sesión, solo se conecta a rutas). Rutas nuevas se agregan
a medida que la feature correspondiente exista de verdad — no declares rutas para pantallas que
todavía no se construyeron.

Rutas actuales: `/login`, `/dashboard`, `/devices/:id` (primera ruta con path param del proyecto —
`AppRoutes.deviceDetailPath(id)` arma el string, `state.pathParameters['id']!` lo lee en el
`builder`). Desde el dashboard se navega con `context.push(...)`, no `Navigator.push` — en widget
tests que ejercen ese flujo hace falta un `GoRouter` real de verdad en el árbol (ver gotcha de
testing más abajo), un `MaterialApp(home: ...)` sin router no alcanza.
