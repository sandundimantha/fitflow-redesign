# FitFlow Redesign — Weighted Technology Comparison Matrix

**Coursework:** IT3060 — Human-Computer Interaction (HCI)  
**Artifact:** Technology Selection Evaluation Matrix & Architecture Decision Record (ADR)  

---

## 1. Client Framework Evaluation

| Criteria (Weight %) | Flutter (Selected) | React Native | Native (Swift / Kotlin) |
| :--- | :---: | :---: | :---: |
| **Animation & Micro-interaction Performance (25%)** | 9.5 (Skia / Impeller 60–120 FPS) | 7.5 (JS bridge overhead) | 9.8 (Highest native capability) |
| **Cross-Platform Parity [iOS, Android, Web] (25%)** | 9.5 (Pixel-perfect identical UI) | 8.0 (Platform discrepancies) | 4.0 (Completely separate codebases) |
| **Development Velocity & Hot Reload (20%)** | 9.0 (Stateful sub-second reload) | 8.5 (Fast Refresh) | 6.0 (Longer build & compile cycles) |
| **Offline Caching & State Management (15%)** | 9.0 (Riverpod + Local Hive/Prefs) | 8.5 (Redux / Zustand + MMKV) | 8.5 (CoreData / Room) |
| **HCI Usability Score (15%)** | 9.2 (Sub-2s launch, zero layout shift) | 7.8 (Bridge latency on heavy lists) | 9.0 (Excellent responsiveness) |
| **Weighted Total Score (100%)** | **9.28** | **8.03** | **7.40** |

*Decision:* **Flutter** was chosen due to its unmatched declarative UI engine, seamless cross-platform parity, and fluid micro-animations critical for fitness tracking interactions.

---

## 2. Core Backend Framework Evaluation

| Criteria (Weight %) | NestJS (TypeScript) [Selected] | Express.js (Node.js) | Django REST Framework (Python) |
| :--- | :---: | :---: | :---: |
| **Architecture & Maintainability (30%)** | 9.5 (Modular DI, clean domain layers) | 6.5 (Unopinionated, drift prone) | 9.0 (Batteries-included monolith) |
| **Native WebSocket & Real-Time Support (25%)** | 9.5 (Integrated WebSocket Gateways) | 7.5 (Requires manual boilerplate) | 7.0 (Django Channels complexity) |
| **Type Safety & OpenAPI Automation (20%)** | 9.8 (TypeScript + Swagger decorators) | 6.0 (Manual schema sync) | 8.5 (drf-spectacular) |
| **Performance & Async Concurrency (15%)** | 8.8 (Node.js event loop) | 8.8 (Node.js event loop) | 7.0 (Synchronous default WSGI) |
| **Developer Ergonomics (10%)** | 9.0 (CLI, testing utilities) | 8.0 (Fast prototyping) | 8.5 (Admin panel) |
| **Weighted Total Score (100%)** | **9.31** | **7.22** | **8.15** |

*Decision:* **NestJS** provides enterprise-grade structure, built-in Swagger/OpenAPI, and WebSocket abstractions suited for live social feed distribution.

---

## 3. Data Layer: Relational (PostgreSQL) vs Document (MongoDB) vs In-Memory (Redis)

| Requirement | PostgreSQL (Prisma) | MongoDB (Mongoose) | Redis (In-Memory) |
| :--- | :--- | :--- | :--- |
| **Primary Workload** | Structured relational health logs, user accounts, macro nutrition breakdown. | Unstructured social posts, user reactions, comments, media attachments. | Running daily calorie counter, token blacklist, real-time pub/sub feed updates. |
| **Consistency Model** | ACID Transactions | Tunable / Document-level atomicity | In-memory atomic counters (`INCRBY`) |
| **Query Pattern** | Complex relational queries (weekly comparisons, historical trends). | High-write feed streams, nested comment trees. | Key-value lookups ($O(1)$) and Pub/Sub channel broadcasts. |
| **Why Not Single DB?** | Social feeds would bloat relational indexes with unstructured comments. | Relational integrity for user stats, workouts, and plans requires foreign keys and constraints. | Neither disk database provides sub-millisecond running totals or pub/sub fanout without polling. |

---

## 4. AI Microservice Framework: FastAPI vs Flask vs Express

| Criteria (Weight %) | FastAPI (Python) [Selected] | Flask (Python) | Express.js (Node.js) |
| :--- | :---: | :---: | :---: |
| **Inference / Python Ecosystem Interop (35%)** | 9.5 (Direct NumPy, PyTorch, Scikit access) | 9.5 (Python native) | 4.0 (Requires child process / interop) |
| **Asynchronous Request Throughput (25%)** | 9.6 (Starlette async event loop) | 6.0 (WSGI synchronous threading) | 9.2 (Node async event loop) |
| **Schema Validation & Documentation (25%)** | 9.8 (Pydantic v2 + Auto OpenAPI) | 6.5 (Marshmallow / manual validation) | 7.0 (Zod / Joi manual setup) |
| **Latency & Overhead (15%)** | 9.2 (Sub-3-second plan SLA) | 7.0 (Higher overhead) | 8.8 (Fast I/O) |
| **Weighted Total Score (100%)** | **9.56** | **7.50** | **6.55** |

*Decision:* **FastAPI** provides the highest asynchronous performance, automatic Pydantic schema validation, and instant access to modern AI/heuristic modeling libraries.
