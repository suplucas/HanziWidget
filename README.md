# HanziWidget

App iOS de prática de hanzi com widget de tela e tela de bloqueio.

## Features

- **Carrossel** — cards com reveal horizontal em 3 etapas (hanzi → pinyin → significado + exemplo) e navegação vertical
- **Prática (SRS)** — fila de revisão com grades *De novo / Difícil / Sei / Fácil* (SM-2 simplificado)
- **Quiz** — escolha o significado; acertos agendam revisão, erros voltam para hoje
- **Dicionário** — busca por hanzi, pinyin (com ou sem tons), `pinyin_num` ou tradução
- **Favoritos** — estrela nos cards e filtro no dicionário
- **TTS** — pronúncia em mandarim (`zh-CN`)
- **Widget** — hanzi do dia (small/medium) + acessórios do lock screen
- **Dataset** — 300 hanzi em `HanziWidget/Shared/hanzi.json`

## Estrutura

```
HanziWidget/                 # app
  App/                       # views (carrossel, prática, dicionário)
  Model/                     # HanziItem, SRS, ReviewState (SwiftData)
  Shared/                    # HanziStore + hanzi.json (compartilhado com o widget)
HanziWidgetExtension/        # widget
HanziWidgetTests/            # testes unitários
HanziWidgetUITests/          # testes de UI
```

O JSON e o `HanziStore` entram nos dois targets via `membershipExceptions` no Xcode 16+ (pastas sincronizadas).

## Requisitos

- Xcode 26+
- iOS 26+
- SwiftLint + pre-commit (opcional, no Mac):

```bash
brew install swiftlint pre-commit
pre-commit install
```

## Rodar

1. Abra `HanziWidget.xcodeproj`
2. Scheme **HanziWidget** → ⌘R (app) / ⌘U (testes)

CLI:

```bash
xcodebuild -project HanziWidget.xcodeproj -scheme HanziWidget \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

xcodebuild -project HanziWidget.xcodeproj -scheme HanziWidget \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Testes

- `HanziStoreTests` — carga do dataset, fallback, busca
- `SRSTests` — agendamento SRS (good/again/hard/easy)
- `ReviewRepositoryTests` — SwiftData em memória
- `HanziItemDecodingTests` — JSON snake_case
- `HanziWidgetUITests` — abas, busca, contador

## Ícones

```bash
python3 scripts/generate_icons.py
```

Gera `AppIcon.png`, `AppIcon-Dark.png` e `AppIcon-Tinted.png` nos dois asset catalogs.

## Roadmap

- [x] Fase 0 — infra (gitignore, README, ícones, scheme, polish widget)
- [x] Fase 1 — testes, injeção do store, CI
- [x] Fase 2 — SwiftData + SRS + quiz + favoritos + TTS + contador
- [ ] Fase 3 — App Group p/ progresso no widget, widgets maiores, streaks
- [ ] Fase 4 — import/export, anotações, reconhecimento de escrita
- [ ] Fase 5 — analytics locais, atalhos, Spotlight

## Bundle ID

- App: `com.demo.HanziWidget`
- Widget: `com.demo.HanziWidget.HanziWidgetExtension`
- Tests: `com.demo.HanziWidgetTests` / `com.demo.HanziWidgetUITests`

Ajuste no Xcode (Signing & Capabilities) se for publicar na App Store.
