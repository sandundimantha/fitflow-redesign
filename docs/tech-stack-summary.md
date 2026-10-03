# FitFlow Redesign — Technology Stack Summary

**Coursework:** IT3060 — Human-Computer Interaction (HCI)  
**Project:** FitFlow Mobile Fitness Application Redesign  
**Date:** March 2026  

---

## 1. Executive Overview

FitFlow is an end-to-end fitness application redesigned to solve critical usability and engagement bottlenecks discovered during empirical HCI user evaluations. The system couples a cross-platform Flutter client with an event-driven NestJS core backend, an asynchronous Python/FastAPI microservice for personalized workout generation, and a multi-model data layer (PostgreSQL, MongoDB, and Redis).

---

## 2. Layer-by-Layer Architectural Specification

| Architectural Layer | Selected Technology | Version / Specification | Architectural Rationale |
| :--- | :--- | :--- | :--- |
| **Client Application** | **Flutter** (Dart) | Flutter 3.x (iOS, Android, Web) | Single declarative codebase providing native 60–120 FPS animations, sub-2-second cold start, and full cross-platform parity. |
| **State Management** | **Flutter Riverpod** | v2.5+ | Compile-safe, testable state management without Flutter context dependencies, enabling offline caching and instant reactive UI updates. |
| **Core API Gateway** | **NestJS** (TypeScript / Node.js) | v10.x / Node 22 | Modular enterprise framework featuring strict dependency injection, built-in OpenAPI/Swagger, WebSocket gateways, and guard-based auth pipelines. |
| **AI Microservice** | **FastAPI** (Python) | Python 3.11+, FastAPI 0.110+ | High-throughput asynchronous REST API for rapid heuristic and ML-driven workout plan generation with strict Pydantic schemas (< 3s SLA). |
| **Primary Relational DB**| **PostgreSQL** via **Prisma ORM** | PostgreSQL 16 | ACID-compliant relational model for strict transactional consistency across users, workouts, logs, and macro nutrition entries. |
| **Secondary Document DB**| **MongoDB** via **Mongoose** | MongoDB 7.0 | Schemaless, scalable document storage optimized for high-volume social activity feeds, challenge updates, and nested user comments. |
| **In-Memory Cache & Pub/Sub**| **Redis** | Redis 7 | Sub-millisecond read cache for daily running caloric/macro totals, user session states, and real-time pub/sub event distribution. |
| **Real-Time Communication**| **WebSockets** (Socket.io / ws) | NestJS WebSocket Gateway | Bidirectional real-time delivery of social feed posts and live workout updates directly into user feeds without battery-draining polling. |
| **Object / Media Storage** | **S3-Compatible Storage** / **MinIO** | MinIO (Dev) / AWS S3 (Prod) | Secure binary storage for user avatars, exercise video demonstrations, and social challenge media proof. |
| **Authentication & AuthZ**| **Firebase Authentication** | Firebase Admin SDK + JWT Guard | Secure token issuance supporting phone/email login, validated at the NestJS API gateway, with development bypass mode for local testing. |
| **Push Notifications** | **Firebase Cloud Messaging (FCM)** | FCM v1 HTTP API | Background notification dispatch for challenge updates, social mentions, and workout streak reminders when the client is closed. |

---

## 3. HCI Design & Usability Principles Addressed

1. **Strict 2-Tap Navigation Rule**:
   - *Previous Bottleneck:* In legacy usability tests, users struggled with buried workout history, nutrition logs, and settings.
   - *Redesign Solution:* The dashboard directly surfaces Today's Workout above the fold, with persistent bottom navigation and direct deep links to Workout History, Nutrition Tracking, AI Workout Assistant, and Social Feed within at most 2 taps.
2. **Perceptual Speed & Latency Targets**:
   - Application cold launch targeted at **< 2.0 seconds**.
   - AI Plan generation targeted at **< 3.0 seconds**, displaying animated progress feedback to reduce perceived wait time.
3. **Cognitive Load Minimization in Nutrition Logging**:
   - Implemented real-time food name autocomplete so users do not experience typing fatigue or search friction when tracking meals.
4. **Offline Resilience**:
   - Dashboard statistics and past workout logs are locally persisted in the Flutter client to prevent blank or jarring error states during intermittent network loss.
