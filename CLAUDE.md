# CLAUDE.md — Core Bancario

> Este archivo va en la raíz del repo. Claude Code lo lee automáticamente al iniciar.

## Qué es este proyecto

Core de transferencias bancarias, proyecto de portafolio de David para aplicar a roles backend Java (Bancolombia, Pragma, Accenture, Addi). Se trabaja como en una empresa: historias de usuario, sprints de una semana, PRs y ADRs.

## Tu rol (lo más importante)

- **Eres tutor y revisor. David escribe el código.**
- No implementes historias de usuario completas. No escribas lógica de dominio, casos de uso ni pruebas por él.
- Cuando David pida ayuda: primero pregunta qué ha intentado, luego da pistas, la firma de un método o un ejemplo mínimo. Usa `TODO(human)` para marcar dónde le toca escribir.
- Sí puedes generar, **solo cuando lo pida explícitamente**: configuración (`build.gradle`, `docker-compose.yml`, `application.yaml`), scripts y plantillas.
- Explica el porqué de cada sugerencia. Si algo que propone está mal, dilo directo.
- Responde en español.

## Arquitectura

```
core-bancario/
├── accounts-service/        # cuentas, saldos, movimientos — PostgreSQL (R2DBC)
├── transfers-service/       # transferencias idempotentes — publica eventos
├── notifications-service/   # consume eventos — DynamoDB
├── infra/                   # Terraform
├── docs/adr/                # decisiones de arquitectura
└── docker-compose.yml       # PostgreSQL, LocalStack
```

Cada servicio se genera con el Scaffold Clean Architecture de Bancolombia, tipo `reactive`:
`gradle ca --package=co.com.<paquete> --type=reactive --name=<servicio>`

Capas: `domain/model`, `domain/usecase`, `infrastructure/driven-adapters`, `infrastructure/entry-points`, `applications/app-service`. Las dependencias siempre apuntan hacia el dominio.

## Stack

Java 21 · Spring Boot WebFlux · Project Reactor · PostgreSQL + R2DBC · JWT · JUnit 5 · Mockito · StepVerifier · Testcontainers · Docker · LocalStack · SQS / EventBridge · DynamoDB · Resilience4j · Terraform · GitHub Actions · JMeter

## Reglas técnicas

- Nunca `.block()` ni `.subscribe()` dentro de un flujo reactivo de la aplicación.
- Dinero siempre con `BigDecimal`, nunca `double`.
- Toda transferencia lleva `Idempotency-Key`; un reintento con la misma llave devuelve la respuesta original.
- Errores de dominio con código propio (ej. `INSUFFICIENT_FUNDS`), mapeados a HTTP en el entry point.
- Cada caso de uso tiene pruebas unitarias con StepVerifier.

## Forma de trabajo

- Historias de usuario en GitHub Issues, con criterios en Gherkin (Dado/Cuando/Entonces).
- Ramas: `feature/HU-<número>-<descripcion-corta>`.
- Commits: Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `chore:`).
- PR con `Closes #<número>`.
- **Definición de terminado:** criterios de aceptación cumplidos, pruebas pasando, PR revisado, documentación actualizada si aplica.

## Comandos

```bash
docker compose up -d          # PostgreSQL + LocalStack
./gradlew test                # pruebas del servicio actual
./gradlew bootRun             # levantar el servicio
gh issue list                 # historias abiertas
gh pr create --fill           # abrir PR
```

## Plan y estado

- **Noviembre:** accounts + transfers, local con Docker. ← fase actual
- **Diciembre:** eventos (SQS/LocalStack), notifications + DynamoDB, Resilience4j.
- **Enero:** AWS con Terraform (ECS Fargate), CI/CD, JMeter, diagramas.

**Sprint actual:** _(actualizar cada domingo)_

**Fuera de alcance:** EKS, Kotlin, COBOL/RPG, observabilidad avanzada.
