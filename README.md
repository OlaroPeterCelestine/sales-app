# SAFARI Field

Mobile-first sales-force app for Route Sales Representatives (Flutter, dark + orange UI, mobile-only). Localised for Kampala, Uganda.

## Features implemented (prototype)

| PRD area | Feature | Status |
|---|---|---|
| Attendance & Security | Face-Match clock-in gate | ✅ simulated |
| Attendance & Security | Distress triple-tap Action Button (GPS + last data → dispatch) | ✅ simulated |
| Route & Visit | Smart Beat Map with tiering (HoReCa / GT / MT) and ETAs | ✅ |
| Route & Visit | Geofenced check-in (50 m radius) | ✅ simulated GPS |
| Route & Visit | Visit timer vs tier time-budget | ✅ |
| Retail Execution | AI Planogram audit + gap analysis + competitor shelf share | ✅ simulated vision |
| Retail Execution | Stock-on-Hand with Critical Stock flagging | ✅ |
| Retail Execution | Competitor intel (OCR price/promo) | ✅ simulated OCR |
| Order Management | Voice ordering (English / Luganda / Swahili NLP) | ✅ simulated STT |
| Order Management | TPM promo logic (BOGO auto-apply) | ✅ |
| Reporting | DSR — strike rate, booked value, cash collected | ✅ |
| Reporting | Leaderboard + Day Score + streaks | ✅ |
| Design | High-contrast dark mode, haptics, bottom navigation | ✅ |

## Still needs real integration

The hardware/AI-dependent features are wired end-to-end with realistic simulations, but production requires:

- On-device **face recognition** model + camera capture (clock-in).
- **Speech-to-text** engine + NLP intent parser for voice ordering.
- **Image-recognition** model for planogram facing detection.
- **OCR** pipeline for competitor price capture.
- Live **GPS / geofencing** and a **DMS sync queue** with offline-first persistence (currently in-memory).
- Backend dispatch channel for distress alerts.

## Run

```bash
flutter run            # device / emulator
flutter build web      # PWA build → build/web
```
