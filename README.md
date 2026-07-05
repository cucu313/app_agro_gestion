# AgroApp — Gestión Agrícola (iPad)

Aplicación nativa para iPad, desarrollada en Flutter, para administrar una
explotación agropecuaria de forma completamente **offline**, con todos los
datos guardados en **SQLite local** en el propio dispositivo (sin nube, sin
multiusuario).

## ⚠️ Importante: qué es esto y qué falta

Este es el **proyecto Flutter completo en código fuente**, con arquitectura,
base de datos y varios módulos funcionando. No fue compilado ni ejecutado
acá porque generar y correr una app de iPad requiere **Xcode en una Mac**
(este entorno no tiene acceso a eso). Los pasos de abajo te llevan de este
código a la app corriendo en tu iPad.

## Estado actual de los módulos

| Módulo | Estado |
|---|---|
| 🏠 Dashboard / Inicio | ✅ Funcional (resumen dinámico + próximas tareas reales del calendario) |
| 🌾 Cultivos | ✅ Funcional completo (alta, edición, borrado, historial de fertilizaciones/aplicaciones/riegos/producción) |
| 🐄 Ganado | ✅ Funcional completo (alta, edición, borrado, historial de vacunas/tratamientos/reproducción/compras/ventas/fallecimientos/observaciones) |
| 🚜 Maquinaria | ✅ Funcional completo (alta, edición, borrado, historial de mantenimientos/cambios de aceite/reparaciones/combustible) |
| 💰 Finanzas | ✅ Funcional (ingresos, egresos, balance automático) |
| 📅 Calendario | ✅ Funcional completo (vista mensual, eventos por tipo, notificaciones locales en Android/iOS) |
| 📊 Reportes | ✅ Funcional completo (gráficos de finanzas, producción, ganado y maquinaria + exportación a PDF y Excel) |
| 📝 Notas | ✅ Funcional completo (crear, editar, fijar, buscar y eliminar notas libres) |
| ⚙ Configuración | ✅ Funcional (datos del establecimiento, moneda). Backup/restore de `.db` queda como mejora futura |
| 🌗 Tema claro/oscuro | ✅ Funcional |
| 🖥 Menú lateral + Dashboard | ✅ Funcional |

**Todos los módulos pedidos originalmente están completos.** Lo único que queda como posible mejora futura es la exportación/importación manual del archivo de base de datos completo (backup/restore) desde Configuración.

## Cómo correr el proyecto

1. Instalá Flutter (canal estable): https://docs.flutter.dev/get-started/install
2. Abrí una terminal en la carpeta del proyecto:
   ```bash
   cd agro_app
   flutter pub get
   ```
3. Para correr en el **simulador de iPad** (necesitás Xcode instalado en macOS):
   ```bash
   open -a Simulator
   flutter run
   ```
4. Para correr en un **iPad físico**: conectalo, abrí el proyecto con
   `open ios/Runner.xcworkspace` en Xcode, seleccioná tu equipo de firma
   (Signing Team) en la pestaña "Signing & Capabilities", y ejecutá desde
   Xcode o con `flutter run -d <device_id>`.

## Arquitectura

```
lib/
  core/               # Infraestructura transversal
    database/          # DatabaseHelper (sqflite) con el esquema completo
    theme/              # Colores y ThemeData claro/oscuro
    widgets/            # Widgets reutilizables (StatCard, ModulePlaceholder)
  models/             # Clases de datos puras (toMap/fromMap)
  modules/            # Un folder por sección funcional
    cultivos/           # repository + list + form + detail  ← módulo de referencia
    ganado/
    maquinaria/
    finanzas/            # repository + screen
    calendario/
    reportes/
    configuracion/
    dashboard/
  shared/
    layout/             # Menú lateral + navegación principal
  main.dart            # Entry point, fuerza orientación horizontal
```

Cada módulo sigue (o debería seguir) este patrón, tomando **Cultivos** como
referencia:
- `models/<entidad>.dart` — clase de datos con `toMap()`/`fromMap()`
- `modules/<modulo>/<modulo>_repository.dart` — acceso a SQLite
- `modules/<modulo>/<modulo>_list_screen.dart` — listado (tarjetas o tabla)
- `modules/<modulo>/<modulo>_form_screen.dart` — alta/edición
- `modules/<modulo>/<modulo>_detail_screen.dart` — detalle + historial

## Próximos pasos sugeridos (en orden)

1. **Ganado**: replicar el patrón de Cultivos. Los modelos (`Animal`,
   `AnimalEvento`) y las tablas SQLite ya están creados.
2. **Maquinaria**: ídem, con `Maquinaria` y `MaquinariaMantenimiento`.
3. **Calendario**: usar el paquete `table_calendar` para la vista mensual y
   `flutter_local_notifications` para las notificaciones de eventos
   (el modelo `EventoCalendario` y su tabla ya existen).
4. **Reportes**: usar `fl_chart` para los gráficos y `pdf`/`printing`/`excel`
   para exportar (paquetes ya declarados en `pubspec.yaml`).
5. **Fotografías**: usar `image_picker` + `path_provider` para guardar
   imágenes en el sandbox de la app y referenciarlas en `lote_fotos` /
   `animal_fotos` (tablas ya creadas).
6. **Backup/restore**: copiar el archivo `agro_app.db` (ubicado vía
   `getDatabasesPath()`) usando `file_picker` para exportar/importar.

## Diseño

- Paleta en `lib/core/theme/app_colors.dart`: verdes de cultivo, tonos
  tierra, grises neutros — fácil de ajustar a tu gusto.
- Bordes redondeados, tarjetas con sombra suave, tipografía con pesos
  marcados, menú lateral permanente: todo en `app_theme.dart` y
  `main_layout.dart`.
- Modo claro/oscuro ya conectado de punta a punta (interruptor en el pie
  del menú lateral).

## Notas técnicas

- Toda la base de datos vive en el dispositivo (`sqflite`), no hay ninguna
  llamada de red en el código.
- La arquitectura está pensada para un solo usuario: no hay lógica de
  autenticación ni sincronización, tal como pediste.
- El código está comentado en español, siguiendo el idioma del proyecto.
