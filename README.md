# Inclusion+

**Inclusive and Accessible Mobile App Prototyping for Social Participation**

Inclusion+ is a mobile application designed to support accessibility, autonomy, and social participation for higher education students with disabilities.

The platform combines accessibility-aware navigation, accessibility information, community contributions, help request flows, issue reporting, and AI-powered accessibility summaries.

---

## Current Status

This project is currently an **Alpha Version** developed for academic purposes.

Some features are fully connected to backend services, while others are implemented as frontend-level flows or simulated interactions.

---

## Features

### Implemented / Partially Implemented

- User authentication (fully)
- Interactive map (fully)
- Location search (fully)
- Route planning 
- Google Maps redirection (temporary solution for route verification)
- Accessibility place information (fully)
- AI-generated accessibility summaries (fully)
- Community posts and comments
- Report accessibility issue flow
- Request help flow
- Accessibility onboarding
- Home dashboard with quick actions

### Planned Features

- Real-time elevator status
- Indoor navigation
- Alternative accessible routes
- Voice assistant
- Academic accessibility support
- Buddy system
- Accessibility notifications
- Erasmus mobility toolkit

---

## Tech Stack

### Frontend

- Flutter
- Dart
- Provider
- Google Maps Flutter

### Backend

- Node.js
- Express.js
- JWT Authentication
- bcrypt
- Multer
- Axios

### Database

- PostgreSQL
- PostGIS

### External APIs

- Google Places API
- Google Routes API
- Accessibility Cloud API
- Gemini API

### DevOps

- Docker
- Docker Compose

---

## Architecture Overview

```text
Flutter Frontend
      |
      | HTTP / REST
      v
Node.js + Express Backend
      |
      | SQL / PostGIS Queries
      v
PostgreSQL + PostGIS Database
      |
      | External API Calls
      v
Google Places API
Google Routes API
Accessibility Cloud API
Gemini API
```

The backend works as an aggregation layer between the Flutter application, the database, and external accessibility/location services.

---

## Project Structure

```text
Inclusion-Plus/
├── backend/
│   ├── src/
│   │   ├── config/
│   │   ├── controllers/
│   │   ├── db/
│   │   ├── middleware/
│   │   ├── models/
│   │   ├── routes/
│   │   └── services/
│   ├── uploads/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── package.json
│   └── .env.example
│
├── frontend/
│   ├── android/
│   ├── ios/
│   ├── lib/
│   │   ├── models/
│   │   ├── navigation/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── state/
│   │   ├── theme/
│   │   └── widgets/
│   ├── assets/
│   ├── pubspec.yaml
│   └── .env
│
└── README.md
```

---

## Prerequisites

Before running the project, install:

- Git
- Docker Desktop or Docker Engine + Docker Compose
- Flutter SDK
- Android Studio, Android Emulator, physical device, or Chrome
- External API keys:
  - Google Maps API key
  - Gemini API key
  - Accessibility Cloud API token

---

## Environment Variables

Create a `.env` file inside the `backend/` folder based on `.env.example`.

Example:

```env
PORT=3000
DATABASE_URL=postgres://postgres:postgres@db:5432/inclusion_plus
JWT_SECRET=your_secure_secret_here

GOOGLE_MAPS_API_KEY=your_google_maps_api_key
GEMINI_API_KEY=your_gemini_api_key
ACCESSIBILITY_CLOUD_API_TOKEN=your_accessibility_cloud_token
```

The `JWT_SECRET` must be replaced with a strong random secret before production deployment.

Do not commit real API keys or secrets to GitHub.

---

## Running the Backend

Navigate to the backend folder:

```bash
cd backend
```

Start the backend and database containers:

```bash
docker compose up --build
```

This starts:

```text
inclusion_db       PostgreSQL + PostGIS database
inclusion_backend  Node.js / Express API
```

The backend runs on:

```text
http://localhost:3000
```

The database runs on:

```text
localhost:5432
```

---

## Database Setup

After the containers are running, open another terminal and execute:

```bash
cd backend
npm run db:migrate
npm run db:seed
```

The migration creates the database schema and the seed command inserts initial data.

---

## Running the Frontend

Navigate to the frontend folder:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To specify the backend URL:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

For Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

For a physical device, replace the URL with the local IP address of the machine running the backend:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
```

---

## API Validation

To confirm that the backend is running, open:

```text
http://localhost:3000
```

or test endpoints using Postman.

---

## Main Functional Areas

### Home

Central dashboard with quick access to route planning, issue reporting, help requests, alerts, and university-related information.

### Map

Allows users to search locations, view place details, access accessibility information, request directions, and open routes in Google Maps.

### AI Assistant

Generates accessibility-oriented summaries for selected places using Gemini API.

### Report Issue

Allows users to report accessibility-related issues through a guided form.

### Request Help

Provides assistance request flows, emergency contact access, and support-related actions.

### Community

Allows users to create posts, view accessibility-related discussions, and comment on posts.

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|---|---:|---:|
| CPU | 2 vCPUs | 4 vCPUs |
| RAM | 4 GB | 8 GB or more |
| GPU | Not required | Not required |
| Storage | 10 GB free space | 20 GB free space |
| Network | Internet connection | Stable broadband connection |

A dedicated GPU is not required because AI processing is handled through external APIs.

---

## Development Notes

- The backend and database are containerized using Docker Compose.
- The frontend is not currently containerized and must be run using Flutter.
- Some frontend flows use static or simulated data.
- External API credentials must be configured before testing map, route, accessibility, and AI features.
- The project is intended as an academic alpha prototype and should be further validated before production use.

---

## Authors

- Leonor Gabriel
- Miguel Puga

BSc in Software Applications and Development  
ISCTE-Sintra  
2025/2026

---

## License

Academic project developed for ISCTE-Sintra.
