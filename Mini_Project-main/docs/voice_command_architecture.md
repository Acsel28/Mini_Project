# Voice-First Navigation Plan

## Goals
- Allow the user to operate the entire wellness app hands-free using natural speech.
- Automatically detect the end of speech and trigger the appropriate in-app action without extra taps.
- Use Google Gemini to interpret free-form language into structured intents (navigation, tracking, analytics, etc.).
- Keep secrets out of the repo while making configuration as simple as dropping a `.env` file that only contains the API key.

## System Overview
```
Mic (speech_to_text) ➜ Transcript stream ➜ Gemini intent parser ➜ Command router ➜ UI / Services
```

### 1. Capture Layer (`VoiceAssistantService`)
- Keeps a single instance of `SpeechToText`.
- Starts/stops listening, using `pauseFor` + `listenFor` so speech ends automatically once the user finishes a sentence.
- Emits interim text to the UI so we can show “Heard: …” to build trust.
- Sends the final transcript to the intent engine.

### 2. Intent Engine (`GeminiCommandService`)
- Calls `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent` with:
  - System prompt describing available intents (`open_screen`, `log_water`, `regenerate_plan`, etc.).
  - Request for JSON only, so decoding is reliable.
- Requires `GEMINI_API_KEY` loaded via `flutter_dotenv`.
- Returns a `VoiceCommandResult` object with:
  - `intent` – enum-like string.
  - `entities` – slots such as `{"screen": "insights"}` or `{"water_ml": 250}`.
  - `confidence` – optional float for analytics/fallback messaging.

### 3. Command Router (`VoiceCommandRouter`)
- Stateless mapper that decides what to do with a `VoiceCommandResult`:
  - Navigation: use a global `navigatorKey` so we can push screens without needing widget context.
  - Data actions: call existing services (e.g., `HealthLoggingService.logWater`).
  - Content queries: reuse `MealService`, `DiseaseService`, etc., to read information aloud via `TTSService`.
- Provides default error handling + TTS confirmation when intents are unknown or required parameters are missing.

### 4. UI Hooks
- Replace ad-hoc voice buttons with a single `VoiceFab` widget that shows the current state (idle, listening, processing).
- Expose a stream (`VoiceAssistantService.stateStream`) if we need to show “listening” across multiple screens.
- Add onboarding tips in the hero section describing available commands so users try the feature.

## Configuration & Secrets
- Add `flutter_dotenv` dependency.
- Create `.env.example` (committed) and `.env` (ignored) with:
  ```
  GEMINI_API_KEY=your-key-here
  ```
- Load env early in `main.dart` (`await dotenv.load();`).
- Fail gracefully with a SnackBar + log if the key is missing.

## Supported Voice Intents (v1)
| Intent | Example Utterances | Action |
| --- | --- | --- |
| `open_screen` | "Go to insights", "Show my progress" | Pushes the requested page via global nav key |
| `summarize_meal_plan` | "What's for lunch today?" | Fetches today’s plan and reads macros |
| `regenerate_plan` | "Refresh my meal plan" | Calls existing regenerate endpoint |
| `log_water` | "Log 300 milliliters water" | Invokes `HealthLoggingService.logWater` |
| `log_sleep` | "I slept 7 hours" | Invokes `HealthLoggingService.logSleep` |
| `search_condition` | "Find plans for PCOS" | Navigates to search + pre-fills query |
| `coach_tip` | "Ask coach about stress" | Opens coach tab and optionally seeds question |

Additional intents can be layered on by updating the Gemini prompt + router map.

## Safety & Offline Modes
- If Speech-to-Text or Gemini is unavailable we fall back to deterministic phrase matching (current behavior) so the feature still works in a basic form.
- All long-running calls (Gemini, network) should surface a progress UI and time out after ~8 seconds to keep the assistant responsive.

## Next Steps
1. Add dependencies + env plumbing (`flutter_dotenv`, `.env.example`).
2. Implement `GeminiCommandService`, `VoiceCommandResult`, and `VoiceCommandRouter`.
3. Update `VoiceAssistantService` to use the router + expose state changes for UI.
4. Replace legacy buttons in home + coach screens with the new voice FAB.
5. QA flows (navigation, logging, meal summary) using only voice.
