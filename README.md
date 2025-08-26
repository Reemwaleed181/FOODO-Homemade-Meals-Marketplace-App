# Foodo – Homemade Meals Marketplace (Flutter + Django)

Foodo is a two‑sided marketplace that connects home cooks with customers. Users discover homemade dishes with nutrition and dietary info, add items to cart, and complete a guided checkout. Home cooks can list meals from a simple dashboard. The Flutter app talks to a Django backend for authentication and OTP flows, and also ships with local JSON data for fast prototyping and offline‑friendly demos.

## ✨ Features

- **Authentication**: signup/login, email verification, and OTP‑based forgot/reset password via Django APIs
- **Meal discovery**: featured/community lists, search, category and diet filters, detailed nutrition info
- **Commerce**: add to cart, quantity management, tax and delivery fee calculation, order confirmation
- **Chef module**: create/sell meal flow and a lightweight chef dashboard
- **Profile**: delivery details and payment method selection
- **Design**: Material 3 theme, responsive layouts, image caching, and smooth animations

## 🧱 Architecture

- **Presentation**: screens and reusable widgets under `lib/screens` and `lib/widgets`
- **State management**: Provider notifiers
  - `AuthProvider` – auth/OTP/session
  - `MealProvider` – catalog, search, filters
  - `CartProvider` – cart items and totals
  - `NavigationProvider` – simple app‑shell routing
- **Data layer**: services in `lib/services`
  - `ApiService` – REST calls to Django (`signup`, `login`, OTP, password reset)
  - `DataService` – cached reads from `assets/data/*.json` with search and filters
  - `StorageService` – token and user persistence using `shared_preferences`
  - `EmailService` – pluggable email sender (debug‑friendly)
- **Configuration**: `lib/config/app_config.dart` with platform‑aware base URL and `--dart-define` override

## 🗂️ Project Structure

```
lib/
├── config/           # App configuration (base URLs, flags)
├── models/           # Data models (meal, user, cart item)
├── providers/        # Provider notifiers (auth, meals, cart, navigation)
├── screens/          # UI screens (auth, home, meal detail, cart, profile, chef)
├── services/         # ApiService, DataService, StorageService, EmailService
├── theme/            # Colors and theme
└── widgets/          # Reusable UI components
assets/
└── data/             # meals.json, users.json, app_config.json
```

## 🧰 Tech Stack

- **Flutter/Dart**, Material 3
- **Provider** for state management
- Networking with **http**, JSON serialization
- Persistence with **shared_preferences**
- Image caching via **cached_network_image**
- Backend: **Django REST** (Auth + OTP/password flows)



## 🔌 Backend (Django)

The repository includes a Django backend under `Backend_foodo/` with endpoints consumed by the Flutter app:

- `POST /api/auth/signup/`
- `POST /api/auth/login/`
- `POST /api/send-otp/`
- `POST /api/resend-otp/`
- `POST /api/verify-email/`
- `POST /api/forgot-password/`
- `POST /api/verify-password-reset-otp/`
- `POST /api/reset-password/`

See `Backend_foodo/README` or `DJANGO_SETUP.md` for environment setup and running the server..



