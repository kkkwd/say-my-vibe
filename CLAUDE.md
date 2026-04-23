# Type4Me — Development Guide

## Overview

macOS menu bar voice input tool. Slim cloud-only edition: cloud ASR + cloud LLM post-processing, no local models, no subscription system.

- **Cloud ASR providers (3)**: Volcano (Doubao), Soniox, Bailian (Alibaba Cloud) — all WebSocket streaming.
- **Cloud LLM providers (11)**: Doubao, MiniMax CN/Intl, Bailian, Kimi, OpenRouter, OpenAI, Gemini, DeepSeek, Zhipu, Claude.
- Swift Package Manager project (no Xcode project file). Single build variant.

## Build & Run

```bash
swift build -c release
```

Built binary: `.build/release/Type4Me`. Package as `.app` via `scripts/package-app.sh`, deploy via `scripts/deploy.sh`, build a DMG via `scripts/build-dmg.sh`.

## ASR Provider Architecture

`ASRProvider` enum + `ASRProviderConfig` protocol + `ASRProviderRegistry`.

- `ASRProvider` enum: `volcano`, `soniox`, `bailian`. All cloud, all streaming.
- Each provider has its own Config in `Type4Me/ASR/Providers/`, defining `credentialFields` for dynamic UI rendering.
- `ASRProviderRegistry`: maps provider → config type + client factory + capabilities.
- `SpeechRecognizer` protocol is the client-side abstraction.

### Adding a New Provider

1. Add a case to `ASRProvider`.
2. Create a Config in `Type4Me/ASR/Providers/` implementing `ASRProviderConfig`.
3. Write the client implementing `SpeechRecognizer`.
4. Register in `ASRProviderRegistry.all` with `ProviderEntry(configType:, createClient:, capabilities:)`.

## LLM Provider Architecture

`LLMProvider` enum + `LLMProviderConfig` protocol + `LLMProviderRegistry`.

- Most providers use the generic `OpenAICompatibleLLMConfig<Tag>` (zero-cost tag types map a Tag to an `LLMProvider`).
- `ClaudeLLMConfig` is the only non-OpenAI-compatible config.
- `LLMProvider.thinkingDisableField` encodes the per-provider strategy for disabling chain-of-thought (`thinking`/`enable_thinking`/`reasoning_effort`); MiniMax uses `reasoning_split` instead.

## Credential Storage

Hybrid storage:
- **Secure fields** (`isSecure: true`, e.g. API keys): macOS Keychain (`com.type4me.grouped` / `com.type4me.scalar`).
- **Non-secure fields** (model, language, etc.): `~/Library/Application Support/Type4Me/credentials.json` (file mode 0600).
- Auto-migration on first launch moves existing secure fields from JSON to Keychain.

**Do not rely on environment variables** for credentials. GUI-launched apps cannot read shell env vars from `~/.zshrc`. Configure via the Settings UI.

## Permissions Required

| Permission | Purpose |
|---|---|
| Microphone | Audio capture |
| Accessibility | Global hotkey listening + text injection into other apps |

## Key Files

| Path | Responsibility |
|---|---|
| `Type4Me/ASR/ASRProvider.swift` | Provider enum + protocol + `CredentialField` |
| `Type4Me/ASR/ASRProviderRegistry.swift` | Provider → config + client factory + capabilities |
| `Type4Me/ASR/Providers/*.swift` | Per-vendor Config implementations |
| `Type4Me/ASR/SpeechRecognizer.swift` | `SpeechRecognizer` protocol + `LLMConfig` + event types |
| `Type4Me/ASR/VolcASRClient.swift` | Volcano streaming WebSocket client |
| `Type4Me/ASR/SonioxASRClient.swift` | Soniox streaming WebSocket client |
| `Type4Me/ASR/BailianASRClient.swift` | Bailian (DashScope) streaming WebSocket client |
| `Type4Me/Session/RecognitionSession.swift` | Core state machine: record → ASR → inject |
| `Type4Me/Session/SoundFeedback.swift` | Start/stop/error sounds |
| `Type4Me/Audio/AudioCaptureEngine.swift` | Audio capture |
| `Type4Me/UI/AppState.swift` | `ProcessingMode` definition, built-in modes |
| `Type4Me/Services/KeychainService.swift` | Credential read/write + migration |
| `Type4Me/Services/HotwordStorage.swift` | ASR hotword storage |
| `Type4Me/LLM/LLMProvider.swift` | LLM provider enum + thinking-disable strategy |
| `Type4Me/LLM/LLMProviderRegistry.swift` | LLM provider → config |
| `Type4Me/LLM/Providers/OpenAICompatibleLLMConfig.swift` | Generic config + per-vendor tags |
| `Type4Me/LLM/Providers/ClaudeLLMConfig.swift` | Anthropic Messages API config |
| `scripts/build-dmg.sh` | Build + sign + notarize a DMG |
| `scripts/package-app.sh` | Build binary + assemble `.app` bundle + sign |
| `scripts/deploy.sh` | Re-sign + relaunch installed app |

## Development Lessons & Patterns

### Streaming ASR: Duplicate Text Prevention
- Streaming ASR emits partial results that get replaced by final results.
- Track `confirmedText` (finalized segments) separately from `currentPartial`.
- Display `confirmedText + currentPartial`, replace partial on each update, append on segment finalization.
- Endpoint detection signals segment boundaries.

### First-Character Accuracy
- The recording-start sound bleeds into the first ~400ms of audio.
- Skip the initial 6400 samples (at 16kHz) in the ASR client before feeding the recognizer — significantly improves first-character recognition.

### UI Patterns
- Dangerous actions (delete) require two-step confirmation (show button → confirm).
- Test/action buttons should be spatially separated from destructive actions.
