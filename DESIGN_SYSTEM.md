# Sistema de diseño — Guía de estilo (base: MecaLab360 landing)

Este documento describe el sistema de diseño visual usado en el proyecto de landing de MecaLab360, para reutilizarlo como base de estilo en nuevos proyectos. Súbelo al apartado "Project knowledge" de un Claude Project y Claude lo usará como guía de diseño consistente en ese proyecto nuevo.

## Filosofía visual

Estética inspirada en **GitHub Primer (modo oscuro)**: interfaz técnica, minimalista, orientada a desarrolladores/ingeniería. Fondo oscuro, tipografía monoespaciada para metadata técnica, colores de acento saturados usados con moderación (no de fondo, solo como acentos puntuales: bordes, íconos, texto de estado).

Principios:
- Todo color vive en **custom properties de CSS** (`:root`), nunca hex hardcodeado en componentes.
- Cada componente tiene su propio archivo `.css` colocado junto al `.jsx`, importado directamente.
- Sin librería de UI (sin MUI/Chakra/shadcn) — todo construido desde cero sobre el sistema de tokens.
- Contenido (copy, listas de datos) separado de la capa visual, en `src/data/*.js`.

## Paleta de colores (tokens)

```css
:root {
  /* Canvas */
  --color-canvas-default: #0D1117;   /* fondo de página */
  --color-canvas-subtle: #161B22;    /* superficies: tarjetas, inputs, nav mobile */
  --color-canvas-inset: #010409;     /* fondos hundidos: tags, terminal */

  /* Bordes */
  --color-border-default: #30363D;
  --color-border-muted: #21262D;

  /* Texto */
  --color-fg-default: #E6EDF3;       /* texto principal */
  --color-fg-muted: #8B949E;         /* texto secundario */
  --color-fg-subtle: #6E7681;        /* texto terciario, metadata */

  /* Accent (links, focus, highlights informativos) */
  --color-accent-fg: #58A6FF;
  --color-accent-muted: rgba(56, 139, 253, 0.12);

  /* Success / color de marca — úsalo para CTAs primarios y estados "activo/completado" */
  --color-success-fg: #F47820;
  --color-success-emphasis: #C45A0A;
  --color-success-hover: #D96A10;
  --color-success-muted: rgba(244, 120, 32, 0.12);

  /* Attention (badges "próximo", advertencias suaves) */
  --color-attention-fg: #D29922;
  --color-attention-muted: rgba(187, 128, 9, 0.12);

  /* Danger (errores de formulario) */
  --color-danger-fg: #F85149;

  /* Tipografía */
  --font-sans: 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', 'SFMono-Regular', Consolas, monospace;

  /* Radios */
  --radius-sm: 4px;
  --radius-md: 6px;
  --radius-lg: 8px;
  --radius-full: 9999px;

  /* Transiciones */
  --transition-fast: 150ms ease;
  --transition-base: 200ms ease;
}
```

**Regla importante:** si el proyecto necesita un color de marca distinto al naranja `#F47820`, reemplaza solo los valores de `--color-success-*` — el resto del sistema no depende de ese hex específico. No mezcles el naranja de marca con verde `#3FB950`/`rgba(46,160,67,...)` en el mismo elemento: elige uno solo como color de "éxito/activo" y aplícalo de forma consistente (texto, fondo y borde deben usar la misma familia de color).

**Colores de marca externa** (no van en el sistema de tokens, se hardcodean donde se usan): p. ej. `#25D366` para botones de WhatsApp — un color reconocible de un servicio externo no debe vivir en la paleta propia.

**Colores por categoría/etiqueta:** para tarjetas de servicios/features donde cada ítem necesita su propio acento (ej. íconos), está bien usar una paleta rotativa de colores saturados con fondo `rgba(<color>, 0.12)`, siguiendo el patrón de "labels" de GitHub: azul `#58A6FF`, naranja `#F0883E`, morado `#BC8CFF`, verde `#3FB950`. Esto es distinto del color de marca/success — son acentos decorativos, no semánticos.

## Tipografía

- **Inter**: todo el copy de UI (headlines, párrafos, botones, nav).
- **JetBrains Mono**: metadata técnica — labels de sección (`.section__label`), badges de estado, timestamps, tags, contador de proyectos, prompt/output de terminal. Le da el toque "técnico/dev" a la interfaz.
- Ambas se cargan como Google Fonts en `index.html`.

Escala tipográfica usada:
- Headline hero: `clamp(2rem, 4.5vw, 3.2rem)`, weight 700, `letter-spacing: -0.02em`
- Título de sección: `clamp(1.5rem, 3vw, 2rem)`, weight 600
- Subtítulo de sección: `15px`, `color: var(--color-fg-muted)`
- Body/párrafo: `14–16px`, `line-height: 1.65–1.75`
- Labels/metadata mono: `11–13px`, uppercase, `letter-spacing: 0.06–0.08em`

## Layout y espaciado

```css
.container { max-width: 1100px; margin: 0 auto; padding: 0 24px; }
.section { padding: 80px 0; }
```

- Una sola columna de contenido máx. `1100px`, centrada.
- Todas las secciones usan el mismo padding vertical de `80px` (se reduce en mobile, ej. hero baja a `48px/56px` bajo `480px`).
- Breakpoints usados según necesidad de cada componente (no hay tokens de breakpoint compartidos): `480px`, `520px`, `640px`, `768px`, `860px`, `900px`.

## Componentes base reutilizables

### Botones
```css
.btn { padding: 7px 16px; border-radius: var(--radius-md); font-size: 14px; font-weight: 500; }
.btn--primary   { background: var(--color-success-emphasis); color: #fff; } /* hover: --color-success-hover */
.btn--secondary { background: var(--color-canvas-subtle); border: 1px solid var(--color-border-default); }
.btn--lg { padding: 10px 20px; font-size: 15px; }
```
- `:active` → `transform: scale(0.97)`
- `:focus-visible` → `outline: 2px solid var(--color-accent-fg); outline-offset: 2px;`

### Tarjetas (cards)
Fondo `--color-canvas-subtle`, borde `1px solid --color-border-default`, `border-radius: var(--radius-lg)`, hover sube el borde a un gris más claro (`#444C56`) y agrega `box-shadow: 0 4px 16px rgba(1,4,9,0.3)`.

### Badges / pills de estado
`border-radius: var(--radius-full)`, `font-family: var(--font-mono)`, `font-size: 11px`, con texto+fondo+borde de la **misma** familia de color semántico (success/attention/danger) — nunca mezclar familias en un mismo pill.

### Inputs de formulario
Fondo `--color-canvas-default` (más oscuro que la card que los contiene), borde `--color-border-default`, focus con `border-color: var(--color-accent-fg)` + `box-shadow: 0 0 0 3px var(--color-accent-muted)`. Estado de error: borde y sombra en `--color-danger-fg`.

### Texto degradado (uso puntual, para 1-2 palabras clave)
```css
.gradient-text {
  background: linear-gradient(135deg, #F47820 0%, #FFFFFF 100%);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
}
```

## Animación y accesibilidad

- Toda animación debe respetar `prefers-reduced-motion`. Patrón global en `index.css`:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```
- Componentes con animación por JS (ej. efecto de escritura tipo terminal) deben además chequear `window.matchMedia('(prefers-reduced-motion: reduce)')` en el `useEffect` de montaje y saltar directo al estado final si es `true` — el CSS global no cubre animaciones manejadas con `setState`/`setTimeout`.
- Transiciones cortas y sutiles: `150ms` para hover/focus de color y borde, `200ms` para transformaciones de layout (menú hamburguesa, etc).

## Convenciones de código (React)

- Componentes funcionales + hooks únicamente, sin clases.
- `prop-types` en todo componente que reciba props.
- Un archivo `.css` por componente, mismo nombre, import directo en el `.jsx`.
- Contenido variable (listas de items, copy largo) vive en `src/data/*.js` como arrays de objetos tipados por comentario JSDoc — nunca hardcodeado en el JSX.
- Nunca hex directo en JSX/CSS de componentes salvo: (a) colores de marca externa reconocible (WhatsApp, etc.), (b) paleta rotativa decorativa de íconos por categoría — ambos casos documentados arriba.

## Cómo aplicar esto a un proyecto nuevo

1. Copia el bloque de tokens `:root` completo a tu `index.css` (o equivalente) del proyecto nuevo.
2. Si cambia el color de marca, redefine solo `--color-success-*` con la nueva paleta (mantén la misma estructura: fg / emphasis / hover / muted).
3. Reutiliza las clases utilitarias (`.container`, `.section`, `.btn`, `.gradient-text`) tal cual — son agnósticas del contenido.
4. Sigue el patrón de badges/pills y cards de arriba para cualquier UI de "estado" (activo, completado, próximo, error).
