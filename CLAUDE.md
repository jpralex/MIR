# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

MIR Simulador: a native iPhone app (SwiftUI, iOS 16+, iPhone only) for practicing Spain's MIR medical residency entrance exam. Fully offline — all question data and images ship bundled in the app; the only persistence is the user's local answer stats.

## Commands

This is an Xcode project managed as plain text via [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`) — there is no committed `.xcodeproj`. Building requires macOS + Xcode; this repo cannot be built or run from a Linux/CI shell.

```bash
brew install xcodegen        # once per machine
xcodegen generate            # regenerate MIRSimulador.xcodeproj from project.yml
open MIRSimulador.xcodeproj  # then Run (⌘R) in Xcode, target iOS 16+
```

Re-run `xcodegen generate` any time you add/remove Swift files or change `project.yml` — file membership is derived from the `Sources`/`Resources/Exams` directories, not tracked manually in a project file.

There are no automated tests and no lint/format tooling configured in this repo.

The `Tools/*.py` scripts (used to build the `mir2025` dataset from the Ministerio de Sanidad's official exam PDFs) require `pdfplumber` and `poppler-utils`; they're standalone, run with plain `python3 Tools/<script>.py <args>`, and aren't part of the app build.

## Architecture

**Data flow**: `Resources/Exams/<examId>/questions.json` + `Resources/Exams/<examId>/images/*.png` are bundled resources, loaded once at launch by `QuestionRepository.shared` (`Sources/Data/QuestionRepository.swift`) via `Bundle.main.url(forResource:withExtension:subdirectory:)`. This lookup depends on `project.yml` declaring `Resources/Exams` with `type: folder` (an Xcode folder reference) rather than a plain group — a plain group would flatten the `<examId>/images/` nesting when copied into the app bundle and break the `subdirectory:` lookups. Keep that in mind if the resource wiring is ever touched.

**Adding a new exam**: generate a `questions.json` following the schema in `README.md` (one object per question: `id`, `number`, `examId`, `specialty`, `statement`, `options`, `correctIndex` — `nil` for annulled questions, `annulled`, `images`, `explanation`), drop it plus any `images/` under `Resources/Exams/<examId>/`, and register the exam in `QuestionRepository.load()`. Specialty names should match (or extend) the catalog in `Sources/Models/Specialty.swift`. Note: the per-question specialty tagging is an unofficial, editorial classification (the Ministry doesn't publish one) — accurate for study/browsing purposes but not to be treated as authoritative.

**Session/navigation model**:
- `QuizSession` (`Sources/Data/QuizSession.swift`) is the single source of truth for one practice/exam run — current index, selected answers, and mode (`.practice` vs `.exam`). It's shared between `QuizView` and `ResultsView` (the latter is pushed via `.navigationDestination(isPresented: $session.isFinished)`, not a separate route).
- `.practice` mode reveals correctness immediately per question and records each answer to `StatsStore` as it's chosen (`QuizView.select`).
- `.exam` mode allows free back/forward navigation and changing answers, and only records to `StatsStore` when finishing, via `QuizSession.markResultsRecordedIfNeeded()` — this guard exists specifically so that navigating back from `ResultsView` into the quiz (e.g. to answer skipped questions) and finishing again doesn't double-count already-recorded answers in the global stats.
- `AppRouter` (`Sources/Data/AppRouter.swift`) is a workaround for "return to Home from anywhere deep in the stack" without rearchitecting navigation to a shared `NavigationPath`: `HomeView` owns the `AppRouter` and applies `.id(router.resetToken)` to its `NavigationStack`; incrementing `resetToken` (e.g. from `ResultsView`'s "Inicio" button) tears down and recreates the whole stack, popping to root. Any new screen that needs a "back to Home" affordance should follow this same pattern rather than inventing a second navigation mechanism.

**Persistence**: `StatsStore` (`Sources/Data/StatsStore.swift`) is the only thing written to disk — a `UserStats` (`Sources/Models/Stats.swift`) JSON blob of per-question attempts in the app's Documents directory. Everything else (questions, images) is read-only bundle content.

**Design system**: `Sources/Assets.xcassets/AccentColor.colorset` defines separate light/dark variants (verified contrast, not just a single universal color) — when adding new colors, follow that pattern rather than a single-appearance color, since a custom color with no dark variant will silently look fine in Xcode previews but fail contrast in Dark Mode. A design review against Apple's HIG (accessibility, platform conventions, interaction) was done via the `apple-design` skill; see the "Revisión de diseño" section in `README.md` for what was checked and fixed.
