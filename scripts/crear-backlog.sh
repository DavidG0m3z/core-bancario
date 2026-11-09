#!/usr/bin/env bash
# Crea labels, milestones e issues del backlog en GitHub.
# Uso: ./crear-backlog.sh DavidG0m3z/core-bancario
# Requiere: gh instalado y autenticado (gh auth login).
# Los issues se crean con el título y el objetivo; la historia y los criterios los escribes tú.
set -euo pipefail

REPO="${1:?Uso: ./crear-backlog.sh usuario/repo}"

echo "== Labels =="
label() { gh label create "$1" --repo "$REPO" --color "$2" --force >/dev/null; echo "  $1"; }
label "historia" "1D76DB"
label "tecnica"  "5319E7"
label "spike"    "FBCA04"
label "opcional" "C5DEF5"
for e in fundaciones cuentas seguridad transferencias notificaciones resiliencia infraestructura documentacion; do
  label "epica:$e" "BFD4F2"
done

echo "== Milestones =="
milestone() {
  gh api "repos/$REPO/milestones" -f title="$1" -f due_on="$2" >/dev/null 2>&1 || true
  echo "  $1"
}
milestone "Noviembre - Cuentas y transferencias" "2026-12-06T23:59:59Z"
milestone "Diciembre - Eventos y resiliencia"   "2027-01-03T23:59:59Z"
milestone "Enero - Despliegue y documentacion"  "2027-01-31T23:59:59Z"

M1="Noviembre - Cuentas y transferencias"
M2="Diciembre - Eventos y resiliencia"
M3="Enero - Despliegue y documentacion"

echo "== Issues =="
issue() {
  # $1 título  $2 objetivo  $3 labels  $4 milestone  $5 tipo (historia|tecnica)
  local body
  if [ "$5" = "historia" ]; then
    body=$(printf '**Objetivo:** %s\n\n## Historia\n\n**Como** ...\n**Quiero** ...\n**Para** ...\n\n## Criterios de aceptación\n\n```gherkin\nEscenario: ...\n  Dado ...\n  Cuando ...\n  Entonces ...\n```\n\n## Definición de terminado\n\n- [ ] Criterios cumplidos\n- [ ] Pruebas pasando\n- [ ] PR revisado\n' "$2")
  else
    body=$(printf '**Objetivo:** %s\n\n## Entregable\n\n- [ ] ...\n\n## Definición de terminado\n\n- [ ] Entregable completo\n- [ ] ADR escrito (si aplica)\n- [ ] PR revisado\n' "$2")
  fi
  gh issue create --repo "$REPO" --title "$1" --body "$body" --label "$3" --milestone "$4" >/dev/null
  echo "  $1"
}

# Épica 0 — Fundaciones
issue "[FUN-01] Crear repo, GitHub Project y plantillas" "Tablero, plantillas, labels, milestones. ADR-001 (monorepo) y ADR-002 (ramas). Límite: 1 sesión." "tecnica,epica:fundaciones" "$M1" tecnica
issue "[FUN-02] Spike: fundamentos de WebFlux y Reactor" "Mono, Flux, map vs flatMap, errores, StepVerifier. Mini proyecto + notas + borrador de artículo. Límite: 2 sesiones." "spike,epica:fundaciones" "$M1" tecnica
issue "[FUN-03] Generar accounts-service con el scaffold reactivo" "Scaffold tipo reactive, health check, PostgreSQL en docker-compose, Flyway. ADR-003." "tecnica,epica:fundaciones" "$M1" tecnica
issue "[FUN-04] CI básico en GitHub Actions" "Cada PR compila y corre las pruebas." "tecnica,epica:fundaciones" "$M1" tecnica

# Épica 1 — Cuentas
issue "[CTA-01] Abrir una cuenta de ahorros" "Número único, saldo inicial 0, estado ACTIVA, asociada a un cliente." "historia,epica:cuentas" "$M1" historia
issue "[CTA-02] Consultar una cuenta y su saldo" "Error claro si la cuenta no existe." "historia,epica:cuentas" "$M1" historia
issue "[CTA-03] Consignar dinero en una cuenta" "Monto > 0, cuenta activa, genera movimiento. BigDecimal." "historia,epica:cuentas" "$M1" historia
issue "[CTA-04] Consultar movimientos de una cuenta" "Paginados, del más reciente al más antiguo." "historia,epica:cuentas" "$M1" historia
issue "[CTA-05] Bloquear una cuenta" "Una cuenta bloqueada no acepta consignaciones ni transferencias." "historia,epica:cuentas" "$M1" historia
issue "[CTA-06] Formato estándar de errores" "Códigos de dominio mapeados a HTTP en un solo lugar." "tecnica,epica:cuentas" "$M1" tecnica

# Épica 2 — Seguridad
issue "[SEG-01] Spike: emitir y validar JWT en WebFlux" "Entregable: ADR-004 (quién emite el token)." "spike,epica:seguridad" "$M1" tecnica
issue "[SEG-02] Proteger los endpoints con JWT" "Sin token → 401." "historia,epica:seguridad" "$M1" historia
issue "[SEG-03] Un cliente solo ve y opera sus propias cuentas" "Cuenta de otro cliente → 403." "historia,epica:seguridad" "$M1" historia

# Épica 3 — Transferencias
issue "[TRF-01] Generar transfers-service con el scaffold" "Mismo patrón que FUN-03." "tecnica,epica:transferencias" "$M1" tecnica
issue "[TRF-02] Transferir dinero entre dos cuentas del banco" "Camino feliz: débito, crédito y movimientos. ADR-005." "historia,epica:transferencias" "$M1" historia
issue "[TRF-03] Rechazar transferencias inválidas" "Saldo insuficiente, cuenta bloqueada, misma cuenta, monto ≤ 0." "historia,epica:transferencias" "$M1" historia
issue "[TRF-04] Transferencias idempotentes" "Idempotency-Key: un reintento no debita dos veces." "historia,epica:transferencias" "$M1" historia
issue "[TRF-05] Revertir el débito si falla el crédito" "Compensación. Estado FALLIDA_REVERTIDA." "historia,epica:transferencias" "$M2" historia
issue "[TRF-06] Transferencias concurrentes sin saldo negativo" "Dos transferencias simultáneas con saldo justo. ADR-006." "historia,epica:transferencias" "$M2" historia
issue "[TRF-07] Consultar el estado de una transferencia" "PENDIENTE / COMPLETADA / RECHAZADA / FALLIDA_REVERTIDA." "historia,epica:transferencias" "$M1" historia
issue "[TRF-08] Límite diario de transferencias" "Regla de negocio configurable. Solo si sobra tiempo." "historia,epica:transferencias,opcional" "$M2" historia

# Épica 4 — Notificaciones
issue "[NOT-01] SQS y DynamoDB en local con LocalStack" "En docker-compose." "tecnica,epica:notificaciones" "$M2" tecnica
issue "[NOT-02] Publicar un evento cuando una transferencia se completa" "transfers-service → SQS/EventBridge." "historia,epica:notificaciones" "$M2" historia
issue "[NOT-03] Generar notifications-service" "Consume la cola." "tecnica,epica:notificaciones" "$M2" tecnica
issue "[NOT-04] Registrar una notificación por cada transferencia" "Origen y destino, guardado en DynamoDB." "historia,epica:notificaciones" "$M2" historia
issue "[NOT-05] Consultar mis notificaciones" "Protegido con JWT." "historia,epica:notificaciones" "$M2" historia
issue "[NOT-06] Mensajes fallidos van a una DLQ" "Después de N reintentos." "historia,epica:notificaciones" "$M2" historia
issue "[NOT-07] No procesar dos veces el mismo evento" "Idempotencia en el consumidor." "tecnica,epica:notificaciones" "$M2" tecnica

# Épica 5 — Resiliencia
issue "[RES-01] Circuit breaker y retry entre transfers y accounts" "Resilience4j." "tecnica,epica:resiliencia" "$M2" tecnica
issue "[RES-02] Pruebas de integración con Testcontainers" "PostgreSQL y LocalStack reales." "tecnica,epica:resiliencia" "$M2" tecnica
issue "[RES-03] Pruebas de aceptación con Cucumber" "Sobre los criterios de TRF-02 y TRF-03." "tecnica,epica:resiliencia,opcional" "$M2" tecnica

# Épica 6 — Infraestructura
issue "[INF-01] Imágenes Docker multi-stage" "Los tres servicios, publicadas en ECR." "tecnica,epica:infraestructura" "$M3" tecnica
issue "[INF-02] Red y base de datos con Terraform" "VPC, subnets, security groups, RDS. Estado remoto en S3." "tecnica,epica:infraestructura" "$M3" tecnica
issue "[INF-03] Servicios en ECS Fargate con Terraform" "Con balanceador. No EKS." "tecnica,epica:infraestructura" "$M3" tecnica
issue "[INF-04] SQS, DLQ y DynamoDB con Terraform" "" "tecnica,epica:infraestructura" "$M3" tecnica
issue "[INF-05] Secretos en Secrets Manager" "Sin credenciales en código." "tecnica,epica:infraestructura" "$M3" tecnica
issue "[INF-06] Pipeline de despliegue en GitHub Actions" "Merge a main → build → ECR → deploy." "tecnica,epica:infraestructura" "$M3" tecnica
issue "[INF-07] Prueba de carga con JMeter" "Transferencias por segundo y latencia, documentado." "tecnica,epica:infraestructura" "$M3" tecnica

# Épica 7 — Documentación
issue "[DOC-01] Diagrama de arquitectura C4" "Contexto y contenedores." "tecnica,epica:documentacion" "$M3" tecnica
issue "[DOC-02] Diagrama de secuencia de una transferencia" "Incluye fallo y compensación." "tecnica,epica:documentacion" "$M3" tecnica
issue "[DOC-03] README del proyecto" "Qué es, cómo correrlo, decisiones, ADRs." "tecnica,epica:documentacion" "$M3" tecnica
issue "[DOC-04] Colección de API (Postman o Bruno)" "Para probar en 2 minutos." "tecnica,epica:documentacion" "$M3" tecnica

echo "Listo. En GitHub Projects activa el workflow 'Auto-add to project' para traer estos issues al tablero."
