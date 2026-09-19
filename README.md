# MIR Simulador

App nativa para iPhone (SwiftUI, iOS 16+, compatible con iPhone 12 mini o superior) para practicar el examen MIR de acceso a especialidades de Medicina en España.

## Funcionalidades

- **Practicar por especialidad**: las preguntas se agrupan automáticamente por especialidad médica (Cardiología, Digestivo, Pediatría, etc.), con corrección inmediata al responder.
- **Practicar por examen**: simula un examen completo en el orden y formato originales, corrección al final y hoja de resultados con nota estimada (regla de 3 fallos = -1 acierto).
- **Imágenes clínicas**: las preguntas que dependen de una imagen (radiografías, ECG, biopsias, árboles genealógicos, etc.) la muestran inline, con zoom a pantalla completa.
- **Estadísticas**: aciertos/fallos globales y por especialidad, guardados localmente en el dispositivo.
- **Explicaciones**: cada pregunta tiene un campo de explicación ya preparado en el modelo de datos (`explanation`). Hoy aparece como "explicación pendiente"; se puede ir rellenando pregunta a pregunta sin tocar el resto de la app (ver más abajo).

## Datos incluidos

El banco de preguntas se basa en el **examen oficial MIR 2025** (convocatoria de Medicina), publicado por el Ministerio de Sanidad:

- Las 210 preguntas del cuadernillo de examen (200 + 10 de reserva), extraídas del PDF oficial.
- Las respuestas correctas aprobadas **definitivamente** por la Comisión Calificadora (incluye las 7 preguntas anuladas: 13, 50, 64, 139, 142, 161 y 208, marcadas como tales en la app en vez de mostrar una respuesta correcta inventada).
- Las 25 imágenes clínicas del cuadernillo de imágenes, recortadas y asociadas a su pregunta.
- La clasificación por especialidad **no es oficial**: el Ministerio no publica las preguntas etiquetadas por especialidad, así que se ha hecho una clasificación temática orientativa (la que usan habitualmente las academias) pregunta a pregunta. El enunciado, las opciones y la respuesta correcta sí son el texto oficial tal cual se publicó (incluida, por ejemplo, la errata real del Ministerio en la pregunta 161, que es precisamente la razón por la que esa pregunta fue anulada).

Todo el contenido vive en `Resources/Exams/mir2025/`:
- `questions.json`: array de preguntas (ver esquema abajo).
- `images/*.png`: imágenes referenciadas por las preguntas.

### Esquema de `questions.json`

```json
{
  "id": "mir2025-001",
  "number": 1,
  "examId": "mir2025",
  "specialty": "Traumatología y Cirugía Ortopédica",
  "statement": "Enunciado de la pregunta...",
  "options": ["Opción 1", "Opción 2", "Opción 3", "Opción 4"],
  "correctIndex": 0,
  "annulled": false,
  "images": ["imagen_1"],
  "explanation": null
}
```

## Cómo añadir explicaciones

Edita `Resources/Exams/mir2025/questions.json` y rellena el campo `"explanation"` de la pregunta que quieras (texto libre en español). La app la mostrará automáticamente la próxima vez que se abra esa pregunta; si el campo es `null` o está vacío, se sigue mostrando el aviso de "explicación pendiente". No hace falta tocar nada de código Swift.

## Cómo añadir más exámenes (2024, 2023, ...)

1. Repite el proceso de extracción con los PDFs oficiales del Ministerio de Sanidad (enunciado + respuestas correctas, y cuadernillo de imágenes si lo hay). En `Tools/` se incluyen los scripts Python usados para el examen 2025 como punto de partida (extracción de texto por columnas con `pdfplumber`, extracción de la clave de respuestas por posición de palabra, y recorte de imágenes).
2. Genera un `questions.json` con el mismo esquema, usando un `examId` nuevo (por ejemplo `"mir2024"`) y las especialidades del catálogo en `Sources/Models/Specialty.swift` (o añade especialidades nuevas si hace falta).
3. Copia el resultado a `Resources/Exams/<examId>/questions.json` (+ `images/` si aplica).
4. Registra el examen en `QuestionRepository.load()` (`Sources/Data/QuestionRepository.swift`), añadiendo una entrada más al array `exams`.

## Cómo compilar y ejecutar (necesitas un Mac con Xcode)

Este proyecto usa [XcodeGen](https://github.com/yonaskolb/XcodeGen) para generar el `.xcodeproj` a partir de `project.yml`, así el proyecto se mantiene como texto plano y es fácil de versionar.

```bash
brew install xcodegen
cd MIR
xcodegen generate
open MIRSimulador.xcodeproj
```

En Xcode, selecciona un simulador de iPhone 12 mini (o cualquier iPhone más reciente) o tu dispositivo físico, y pulsa Run (⌘R). El target mínimo es iOS 16.0.

Si prefieres no instalar XcodeGen, puedes crear un proyecto "App" nuevo en Xcode (SwiftUI, iOS 16) y arrastrar dentro las carpetas `Sources/` y `Resources/Exams/` (marcando esta última como "Create folder references", no como grupo, para que se mantenga la estructura de subcarpetas).

## Estructura del proyecto

```
project.yml                  # definición del proyecto Xcode (XcodeGen)
Sources/
  App/                        # punto de entrada de la app
  Models/                     # Question, Specialty, Stats
  Data/                       # QuestionRepository, StatsStore, QuizSession
  Views/                      # pantallas SwiftUI
  Assets.xcassets/            # icono y color de acento (a personalizar)
Resources/
  Exams/mir2025/
    questions.json
    images/
Tools/                        # scripts usados para extraer el examen 2025 de los PDFs oficiales
```

## Próxima ronda (pendiente de ejecutar)

Planificado el 2026-09-19 para retomar en la siguiente sesión. Como el entorno de esta sesión es efímero (se recicla por inactividad) y los cron jobs de esta herramienta no sobreviven al cierre de la sesión, no se programó nada automático: hay que pedir explícitamente que se continúe por aquí.

1. **Estado vacío sin acción** (Low, de la auditoría de diseño anterior)
   - Dónde: `Sources/Views/QuizView.swift`, `ContentUnavailableFallback` (se muestra cuando `session.current` es `nil`, hoy una ruta inalcanzable con los datos actuales, pero conviene dejarla correcta).
   - Qué falta: `writing.md › Best practices`: "Provide clear next steps on any blank screens... give them a button or link to do so if possible." Hoy el texto ("No hay preguntas disponibles") no ofrece ninguna acción.
   - Arreglo propuesto: añadir un botón "Volver" que use el `AppRouter` (`router.returnToHome()`) ya existente, igual que en `ResultsView`.

2. **Icono de la app** (`Sources/Assets.xcassets/AppIcon.appiconset`, hoy vacío)
   - Guía aplicable (`app-icons.md`): icono simple, un único concepto reconocible, formas sólidas/superpuestas, sin texto salvo que sea esencial, fondo liso o degradado a pantalla completa, PNG 1024×1024 sin máscara de esquinas (el sistema la aplica).
   - Concepto propuesto: algo que diga "examen médico tipo test", no un cruz médica genérica — por ejemplo un estetoscopio simple en blanco sobre fondo con el azul de `AccentColor` (o su degradado), o una insignia circular tipo "opción marcada" (un círculo relleno, a modo de burbuja de respuesta correcta) superpuesto a una silueta médica sencilla. A decidir/afinar mañana con el usuario antes de generarlo.
   - Cómo ejecutarlo sin Mac: generar el PNG 1024×1024 con Python/Pillow (ya hay un entorno con Pillow en `/tmp/mirvenv` de la sesión anterior, o crear uno nuevo) y colocarlo en `Sources/Assets.xcassets/AppIcon.appiconset/`, actualizando su `Contents.json` para referenciarlo como icono "universal" (ya está declarado el tamaño 1024×1024, solo falta añadir el fichero y el campo `"filename"`).

## Otras ideas de mejora (sin fecha)

- Añadir más exámenes de años anteriores.
- Ir incorporando explicaciones pregunta a pregunta.
- Modo "repasar solo falladas".

## Revisión de diseño (Apple HIG)

Se pasó una auditoría de diseño completa contra las Human Interface Guidelines de Apple (accesibilidad, convenciones de plataforma, tipografía/color, interacción). Ya están corregidos:

- Contraste del color de acento en modo oscuro (antes 1.4:1, ahora >5:1), con variante clara/oscura en `AccentColor.colorset`.
- Bug de estadísticas duplicadas si se vuelve a "Finalizar" un examen tras revisarlo (`QuizSession.markResultsRecordedIfNeeded()`).
- El círculo con la letra de cada opción ya escala con Dynamic Type en vez de recortarse en tamaños de texto grandes.
- Etiquetas de accesibilidad (VoiceOver) en las imágenes clínicas, el estado de cada opción (correcta/incorrecta/seleccionada) y el botón de cerrar del visor de imágenes.
- Botones "Anterior/Siguiente/Finalizar" fijos en una barra inferior en vez de al final del scroll.
- Aviso de confirmación si se intenta finalizar un examen con preguntas sin responder.
- Botón "Inicio" para volver directamente a la pantalla principal desde los resultados.
- Zoom por pellizco acumulativo con desplazamiento (pan) en las imágenes clínicas ampliadas, en vez de reiniciarse en cada gesto.
- Texto de especialidad apilado bajo el número de pregunta en el repaso de resultados, para que no se apriete con texto grande.
