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

Now **real** (no longer simulated):

- **Offline-first persistence + DMS sync queue** — `shared_preferences`; state survives reload, offline events queue and replay, with a Work-Offline toggle and sync badge.
- **Live GPS geofencing** — `geolocator` computes real distance to outlet coordinates ("Simulate arrival" kept as a fallback for demos away from Kampala).
- **Camera capture** — `image_picker` takes a real selfie at clock-in and a real shelf photo for the planogram audit.
- **Charts** — `fl_chart` pie/donut + bar across Home and Reports.
- **Currency** — UGX everywhere.

Still needs a trained model or a server (cannot live inside a Flutter/web app):

- On-device **face recognition** matching (capture is real; identity match is simulated).
- **Image-recognition** model for planogram facing detection (photo is real; analysis is simulated).
- **Speech-to-text + NLP** for voice ordering (parsing is local/simulated).
- **OCR** pipeline for competitor price capture.
- **DMS backend** endpoint for sync replay + distress dispatch (queue is real; the server is not).

## Run

```bash
flutter run            # device / emulator
flutter build web      # PWA build → build/web
```
