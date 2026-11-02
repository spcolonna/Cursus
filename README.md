# Via Imperia

Juego móvil (Flutter, iOS y Android) de decisiones en **tiempo real de reloj**. Sos un mensajero en la Roma del 50 a.C.: elegís una ruta (de 30 min a 72 h reales), en el camino aparecen eventos con 2-3 opciones y al llegar entregás y recibís una nota de S a F.

**Diseño:** la guía viva es [docs/GDD_MASTER_v2.md](docs/GDD_MASTER_v2.md), con el plan por fases en [docs/ROADMAP_MEJORAS_v1.md](docs/ROADMAP_MEJORAS_v1.md). El `The_Messenger_GDD_v1.docx` de la carpeta padre es archivo histórico. Para trabajar en el código, ver [CLAUDE.md](CLAUDE.md) (mapa del código e invariantes).

## Correr

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

## Arquitectura

```
lib/
├── domain/            reglas puras: no importa Flutter ni data/ (lo verifica un test)
│   ├── entities/      Messenger, Mission, eventos, mundo, árbol de skills, gremio, avisos
│   ├── repositories/  contratos abstractos + GameContentCatalog (contenido inyectado)
│   └── usecases/      aceptar, resolver evento, entregar, auto-resolver, tienda...
├── data/              contenido: tutorial, rutas, eventos y arcos narrativos
├── infrastructure/
│   ├── local/         persistencia en SharedPreferences (JSON, con backups ante corrupción)
│   ├── notifications/ avisos locales (flutter_local_notifications)
│   ├── monetization/  compras in-app y rewarded ads
│   ├── audio/ progress/
└── presentation/      tema, widgets, providers (Riverpod) y pantallas
```

`router.dart` (go_router) y `main.dart` (entry point).

## Flujo de pantallas

```
Splash → Login → Onboarding → Elección de personaje → Home
Home → Misión (?m=<mensajero>) → Evento → Resultado de misión
Home → Perfil · Árbol de skills · Tienda · Ajustes
```

Cada mensajero (hasta 4) tiene su propia misión; las rutas de misión y evento reciben el id por el parámetro `m`.

## Mecánicas clave

- **Reloj real:** el progreso se congela en cada evento hasta que el jugador decide. Si no decide en 60 min, se resuelve solo con la opción más segura.
- **Avisos locales:**
  - Eventos y entregas.
  - Mensajero ocioso (a las 4 h) y contratos sin cobrar (19:00).
  - Silencio nocturno (22-8) y tope de 4 por día.
  - Tocar un aviso abre la misión o el evento de ese mensajero.
- **Sin backend:** todo se guarda en el dispositivo. Para pasar a Firebase, alcanza con implementar los contratos de `domain/repositories/` y cambiar los providers.
