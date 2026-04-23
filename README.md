<p align="center">
  <a href="#中文">中文</a> | <a href="#english">English</a>
</p>

---

# 中文

> 本项目是 [joewongjc/type4me](https://github.com/joewongjc/type4me) 的精简 Fork — **仅保留云端 ASR + 云端 LLM**，去除本地模型、订阅系统及多版本打包。

macOS 菜单栏语音输入工具。

## 功能

- **云端语音识别**：3 个 Provider — 火山 (Doubao)、Soniox、阿里云百炼 (Bailian)。WebSocket 流式识别，边说边出字。
- **云端文本处理**：11 个 LLM Provider — Doubao / MiniMax CN / MiniMax Intl / Bailian / Kimi / OpenRouter / OpenAI / Gemini / DeepSeek / Zhipu / Claude。
- **多模式**：快速模式、语音润色、英文翻译、Prompt 优化、自定义。每个模式可绑定独立全局快捷键。
- **Prompt 变量**：`{text}`（识别文字）、`{selected}`（选中文本）、`{clipboard}`（剪贴板内容）。
- **词汇管理**：ASR 热词 + 片段替换。
- **历史记录**：本地存储所有识别记录，支持 CSV 导出。

系统要求：**macOS 14+ (Sonoma)**

## 构建

```bash
# 1. 编译 + 打包 .app（输出到 dist/Type4Me.app）
APP_PATH="$PWD/dist/Type4Me.app" ARCH=arm64 bash scripts/package-app.sh

# 2. 安装到 Applications 并启动
cp -R dist/Type4Me.app /Applications/
open /Applications/Type4Me.app

# 3.（可选）打包带签名的 DMG
bash scripts/build-dmg.sh
```

首次启动需在「系统设置 → 隐私与安全」中授予 **麦克风** 与 **辅助功能** 权限。ASR / LLM 凭据在 Settings UI 中配置，API Key 存入 macOS Keychain。

## 架构

| 模块 | 说明 |
|------|------|
| `Type4Me/ASR/` | ASR 抽象层 + 3 个云端 Provider 客户端 |
| `Type4Me/LLM/` | LLM 抽象层 + 11 个云端 Provider 配置 |
| `Type4Me/Audio/` | 音频采集 (16kHz mono PCM) |
| `Type4Me/Session/` | 核心状态机：录音 → ASR → 注入 |
| `Type4Me/Services/` | 凭证存储、热词、更新检查 |
| `Type4Me/Input/` | 全局快捷键 |
| `Type4Me/Injection/` | 文本注入（剪贴板 Cmd+V） |
| `Type4Me/UI/` | SwiftUI 界面：浮窗 + 设置 |

详见 `CLAUDE.md`。

## 许可证

[MIT License](LICENSE) — 原作者 © joewongjc，本 Fork 修改部分 © kkkwd。

---

# English

> This is a slim fork of [joewongjc/type4me](https://github.com/joewongjc/type4me) — **cloud ASR + cloud LLM only**. Local models, subscription system, and multi-variant packaging have been removed.

macOS menu bar voice input tool.

## Features

- **Cloud ASR (3 providers)**: Volcano (Doubao), Soniox, Alibaba Cloud Bailian. WebSocket streaming recognition.
- **Cloud LLM (11 providers)**: Doubao / MiniMax CN / MiniMax Intl / Bailian / Kimi / OpenRouter / OpenAI / Gemini / DeepSeek / Zhipu / Claude.
- **Modes**: Quick, Voice Polish, English Translation, Prompt Optimize, Custom. Each can bind its own global hotkey.
- **Prompt variables**: `{text}` (recognized text), `{selected}` (selected text at record start), `{clipboard}` (clipboard at record start).
- **Vocabulary management**: ASR hotwords + snippet replacement.
- **History**: All transcripts stored locally with CSV export.

Requires **macOS 14+ (Sonoma)**.

## Build

```bash
# 1. Compile + package .app (output: dist/Type4Me.app)
APP_PATH="$PWD/dist/Type4Me.app" ARCH=arm64 bash scripts/package-app.sh

# 2. Install and launch
cp -R dist/Type4Me.app /Applications/
open /Applications/Type4Me.app

# 3. (Optional) Build a signed DMG
bash scripts/build-dmg.sh
```

On first launch grant **Microphone** and **Accessibility** permissions in System Settings → Privacy & Security. Configure ASR / LLM credentials via the Settings UI; API keys are stored in macOS Keychain.

## Architecture

| Module | Description |
|--------|-------------|
| `Type4Me/ASR/` | ASR abstraction + 3 cloud provider clients |
| `Type4Me/LLM/` | LLM abstraction + 11 cloud provider configs |
| `Type4Me/Audio/` | Audio capture (16kHz mono PCM) |
| `Type4Me/Session/` | Core state machine: record → ASR → inject |
| `Type4Me/Services/` | Credential storage, hotwords, update checking |
| `Type4Me/Input/` | Global hotkeys |
| `Type4Me/Injection/` | Text injection (clipboard Cmd+V) |
| `Type4Me/UI/` | SwiftUI interface: floating bar + settings |

See `CLAUDE.md` for details.

## License

[MIT License](LICENSE) — original © joewongjc, slim fork modifications © kkkwd.
