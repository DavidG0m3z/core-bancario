# Backlog — Core Bancario

> Propuesta de títulos y objetivos. **Tú escribes** el "Como / Quiero / Para" y los criterios en Gherkin de cada historia; yo te las reviso.
> Códigos por épica: FUN (fundaciones), CTA (cuentas), SEG (seguridad), TRF (transferencias), NOT (notificaciones), RES (resiliencia), INF (infraestructura), DOC (documentación).
> Tipos: **HU** = historia de usuario · **TEC** = historia técnica · **SPIKE** = investigación con tiempo límite y un entregable.

---

## Decisiones que hay que tomar (ADR)

Cada una sale de un spike o de una historia. No avances la historia sin escribir el ADR.

| ADR | Pregunta | Cuándo |
|---|---|---|
| 001 | ¿Monorepo o un repo por servicio? | Sprint 1 (FUN-01) |
| 002 | ¿Estrategia de ramas: GitFlow o trunk-based? | Sprint 1 (FUN-01) |
| 003 | ¿R2DBC + PostgreSQL? ¿Cómo manejo migraciones (Flyway)? | Sprint 1 (FUN-03) |
| 004 | ¿Quién emite el JWT (endpoint propio, Keycloak, Cognito)? | Sprint 3 (SEG-01) |
| 005 | ¿Cómo hace transfers el débito y el crédito: llamada HTTP, saga, eventos? ¿Qué pasa si falla a la mitad? | Sprint 3 (TRF-02) |
| 006 | ¿Cómo evito saldos negativos con transferencias concurrentes (bloqueo optimista o pesimista)? | Sprint 4 (TRF-06) |

---

## Épica 0 — Fundaciones (noviembre)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| FUN-01 | TEC | Crear repo, GitHub Project y plantillas | Repo, tablero (Backlog / Sprint / En progreso / En revisión / Hecho), plantillas de issue y PR, labels, milestones. ADR-001 y 002. **Límite: 1 sesión.** |
| FUN-02 | SPIKE | Fundamentos de WebFlux y Reactor | Mono, Flux, map vs flatMap, manejo de errores, StepVerifier. Entregable: un mini proyecto de prueba + notas + borrador del primer artículo. **Límite: 2 sesiones.** |
| FUN-03 | TEC | Generar accounts-service con el scaffold reactivo | `gradle ca --type=reactive`, entry point WebFlux, health check, PostgreSQL en docker-compose, Flyway. ADR-003. |
| FUN-04 | TEC | CI básico en GitHub Actions | Cada PR compila y corre las pruebas. Si falla, no se hace merge. |

## Épica 1 — Gestión de cuentas (noviembre)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| CTA-01 | HU | Abrir una cuenta de ahorros | Número de cuenta único, saldo inicial 0, estado ACTIVA, asociada a un cliente. |
| CTA-02 | HU | Consultar una cuenta y su saldo | Error claro si la cuenta no existe. |
| CTA-03 | HU | Consignar dinero en una cuenta | Necesaria para tener saldo. Monto > 0, cuenta activa, genera un movimiento. `BigDecimal`. |
| CTA-04 | HU | Consultar movimientos de una cuenta | Paginados, ordenados del más reciente al más antiguo. |
| CTA-05 | HU | Bloquear una cuenta | Una cuenta bloqueada no acepta consignaciones ni transferencias. |
| CTA-06 | TEC | Formato estándar de errores | Códigos de dominio (`ACCOUNT_NOT_FOUND`, `ACCOUNT_BLOCKED`...) mapeados a HTTP en un solo lugar. |

## Épica 2 — Seguridad (noviembre)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| SEG-01 | SPIKE | Cómo emitir y validar JWT en WebFlux | Entregable: ADR-004. |
| SEG-02 | HU | Proteger los endpoints con JWT | Sin token → 401. |
| SEG-03 | HU | Un cliente solo ve y opera sus propias cuentas | Cuenta de otro cliente → 403. Pregunta típica de entrevista (control de acceso). |

## Épica 3 — Transferencias (noviembre → primera semana de diciembre)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| TRF-01 | TEC | Generar transfers-service con el scaffold | Mismo patrón que FUN-03. |
| TRF-02 | HU | Transferir dinero entre dos cuentas del banco | Camino feliz: débito en origen, crédito en destino, ambos movimientos registrados. ADR-005. |
| TRF-03 | HU | Rechazar transferencias inválidas | Saldo insuficiente, cuenta bloqueada, misma cuenta origen y destino, monto ≤ 0. |
| TRF-04 | HU | Transferencias idempotentes | Header `Idempotency-Key`: un reintento no debita dos veces y devuelve la respuesta original. |
| TRF-05 | HU | Revertir el débito si falla el crédito | Compensación. Estado final de la transferencia: FALLIDA_REVERTIDA. |
| TRF-06 | HU | Transferencias concurrentes sin saldo negativo | Dos transferencias al mismo tiempo desde una cuenta con saldo justo. ADR-006. |
| TRF-07 | HU | Consultar el estado de una transferencia | PENDIENTE / COMPLETADA / RECHAZADA / FALLIDA_REVERTIDA. |
| TRF-08 | HU | Límite diario de transferencias | Regla de negocio configurable. **Opcional**: solo si sobra tiempo. |

## Épica 4 — Notificaciones por eventos (diciembre)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| NOT-01 | TEC | SQS y DynamoDB en local con LocalStack | En docker-compose. |
| NOT-02 | HU | Publicar un evento cuando una transferencia se completa | transfers-service → SQS (o EventBridge → SQS). |
| NOT-03 | TEC | Generar notifications-service | Consume la cola. |
| NOT-04 | HU | Registrar una notificación por cada transferencia | Para origen ("enviaste") y destino ("recibiste"), guardada en DynamoDB. |
| NOT-05 | HU | Consultar mis notificaciones | Protegido con JWT. |
| NOT-06 | HU | Mensajes que fallan van a una cola de errores (DLQ) | Después de N reintentos. |
| NOT-07 | TEC | No procesar dos veces el mismo evento | Idempotencia en el consumidor. |

## Épica 5 — Resiliencia y pruebas (diciembre)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| RES-01 | TEC | Circuit breaker y retry entre transfers y accounts | Resilience4j. ¿Qué ve el cliente si accounts está caído? |
| RES-02 | TEC | Pruebas de integración con Testcontainers | PostgreSQL real y LocalStack en las pruebas. |
| RES-03 | TEC | Pruebas de aceptación de los escenarios Gherkin | Opcional: Cucumber sobre los criterios de TRF-02 y TRF-03. |

## Épica 6 — Infraestructura y despliegue (enero)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| INF-01 | TEC | Imágenes Docker multi-stage de los tres servicios | Imagen liviana; publicar en ECR. |
| INF-02 | TEC | Red y base de datos con Terraform | VPC, subnets, security groups, RDS PostgreSQL. Estado remoto en S3. |
| INF-03 | TEC | Servicios en ECS Fargate con Terraform | + balanceador. **No EKS** (costo). |
| INF-04 | TEC | SQS, DLQ y DynamoDB con Terraform | |
| INF-05 | TEC | Secretos en Secrets Manager | Nada de credenciales en el código ni en variables sueltas. |
| INF-06 | TEC | Pipeline de despliegue en GitHub Actions | Merge a main → build → push a ECR → deploy. |
| INF-07 | TEC | Prueba de carga con JMeter | Transferencias por segundo y latencia; resultado documentado. |

## Épica 7 — Documentación (continua, se cierra en enero)

| Código | Tipo | Título | Objetivo / nota |
|---|---|---|---|
| DOC-01 | TEC | Diagrama de arquitectura (C4: contexto y contenedores) | |
| DOC-02 | TEC | Diagrama de secuencia de una transferencia | Incluye el caso de fallo y la compensación. |
| DOC-03 | TEC | README del proyecto | Qué es, cómo correrlo, decisiones, enlaces a ADRs. |
| DOC-04 | TEC | Colección de API (Postman o Bruno) | Para que un reclutador pruebe en 2 minutos. |

---

## Plan de sprints (noviembre)

Supuesto: unas 12–15 horas a la semana para el proyecto. Si tienes menos, se corre todo una semana; mejor eso que historias a medias.

| Sprint | Fechas | Historias | Meta del sprint |
|---|---|---|---|
| 1 | 9 – 15 nov | FUN-01, FUN-02, FUN-03, CTA-01 | El servicio de cuentas existe, corre en Docker y abre una cuenta. |
| 2 | 16 – 22 nov | FUN-04, CTA-02, CTA-03, CTA-04, CTA-06 | Puedo consignar y ver saldo y movimientos; CI corriendo. |
| 3 | 23 – 29 nov | CTA-05, SEG-01, SEG-02, SEG-03, TRF-01 | Cuentas protegidas con JWT; transfers-service creado. |
| 4 | 30 nov – 6 dic | TRF-02, TRF-03, TRF-04, TRF-07 | Primera transferencia de punta a punta, idempotente. |

TRF-05 y TRF-06 (compensación y concurrencia) pasan al sprint 5. Son las más difíciles y las mejores para entrevistas: mejor dedicarles el tiempo que piden.

**Siguiente paso:** escribe las historias del sprint 1 (FUN-03 y CTA-01 son las que más necesitan criterios claros) y pégamelas para revisarlas.
