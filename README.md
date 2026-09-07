# 🏀 Fantasy Basketball App

An end-to-end fantasy basketball platform combining a native iOS app with a Django REST API backend — built as my Computer Engineering graduation project at Maltepe University.

![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-000000?style=for-the-badge&logo=swift&logoColor=white)
![Django](https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white)
![DRF](https://img.shields.io/badge/Django%20REST%20Framework-A30000?style=for-the-badge)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000?style=for-the-badge)

## Overview

Users build a roster by opening card packs, manage their team and lineup, browse a player marketplace, and get help from an in-app AI assistant — all backed by a REST API serving live player and team data.

## Features

- **Card-pack collection system** — open packs to receive players with different rarity tiers; collected cards and pulled players are tracked per user
- **Team management** — build and manage a roster, view team and player detail screens
- **Marketplace** — browse and trade player cards with other users
- **In-app AI chatbot** — a locally-run Ollama model is accessible from a chatbot button present on every screen (home, match, player views, etc.), answering user questions in context
- **Authentication** — user registration and login

## Architecture

**Backend** — Django + Django REST Framework, exposing a REST API (`/api/...`) for teams, players, and cards, with SQLite as the database and media storage for player pictures and team logos.

**Frontend** — a native iOS app built with SwiftUI, communicating with the backend through a dedicated API service layer (`APIService.swift`, `AuthService.swift`).

```
fantasy-basketball/
├── backend/              # Django + DRF REST API (SQLite, media storage)
│   └── myapp/            # models, serializers, views, urls
└── frontend/              # Native iOS app (SwiftUI, Xcode project)
    └── FantasyBasketball/
```

## Status

Graduation project — feature-complete for its original scope, not under active development.
