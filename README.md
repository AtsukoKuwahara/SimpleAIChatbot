# OrangeBot (SimpleAIChatbot)

OrangeBot is a SwiftUI iOS chatbot app connected to local Ollama.
It is designed for beginner-friendly local AI chat with simple model management and archive review.

## Core Value

- **Model flexibility for local AI**
  Switch models, add models in-app, and compare behavior quickly.
- **Archive-first learning workflow**
  Save Q&A history and review past conversations anytime.

## Architecture

Runtime path:

`iOS App (SwiftUI) -> Ollama API (http://localhost:11434)`

## Code Structure

Main modules:

- `SimpleAIChatbot/App`: app entry, tabs, settings state, model list refresh
- `SimpleAIChatbot/Views`: chat, archive, detail, loading, model manager sheet
- `SimpleAIChatbot/Services`: networking and chat persistence logic
- `SimpleAIChatbot/Models`: `ChatEntry`

## Features

- Chat with local Ollama (`/api/chat`)
- Model selection from a compact chooser + guide table
- In-app model download and refresh (`Manage Models`)
- Chat-oriented model list filtering (non-chat models can be hidden)
- Archive tab for reviewing saved conversations
- Persisted generation settings:
  - `temperature`
  - `seed`
  - `top_k`
- Better error messages (timeout/connection/server errors)

## Model UX (Beginner-Friendly)

- **Choose** button opens recommended models
- **Manage Models...** opens a dedicated sheet where users can:
  - add a model (via Ollama pull)
  - refresh local model list
  - switch current model
- If a model tag is omitted (example: `mistral`), the app resolves it to `mistral:latest`

## How Available Models Are Fetched

- The app calls `GET /api/tags` to fetch local installed models.
- It calls `POST /api/pull` to download a new model.
- After download, it refreshes `/api/tags` and updates the UI list.

## Requirements

- iOS 17.0+
- Xcode 15.4+ (newer versions supported)
- Swift 5.9+
- Ollama 0.15+ installed and running locally
- macOS environment where iOS Simulator and Ollama run on the same machine

## Tested Environment

- Xcode: 26.x
- iOS Simulator: iPhone 17 (iOS 26.2)
- Ollama: 0.15.5

## Getting Started

1. Clone:

```bash
git clone https://github.com/AtsukoKuwahara/SimpleAIChatbot.git
cd SimpleAIChatbot
```

2. Pull at least one model:

```bash
ollama pull llama3.1
```

3. Start Ollama:

```bash
ollama serve
```

4. Open in Xcode:

```bash
open SimpleAIChatbot.xcodeproj
```

5. Run on simulator (for localhost access, use iOS Simulator on the same Mac).

## API Example

Request for chat (`POST /api/chat`):

```json
{
  "model": "llama3.1:latest",
  "messages": [{ "role": "user", "content": "Why is the sky blue?" }],
  "options": {
    "seed": 42,
    "temperature": 0.8,
    "top_k": 40
  },
  "stream": false
}
```

## Known Limitations

- Non-streaming response rendering only
- No long-conversation summarization/windowing yet
- No token/cost telemetry in UI
- Local-only archive (no cloud sync/export)

## Screenshots

<div align="center">
<img src="SimpleAIChatbot/assets/chat_screen_image.jpg" alt="Chat Screen" width="300"/>
<img src="SimpleAIChatbot/assets/archive_screen_image.jpg" alt="Archive Screen" width="300"/>
<img src="SimpleAIChatbot/assets/manage_models_image.jpg" alt="Manage Models Screen" width="300"/>
<img src="SimpleAIChatbot/assets/settings_screen_image.jpg" alt="Settings Screen" width="300"/>
</div>
