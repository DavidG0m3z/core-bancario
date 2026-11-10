# ADR-001: Estructura del repositorio

- **Estado:** Aceptado
- **Fecha:** 2026-11-09

## Contexto

El proyecto es un core bancario con tres microservicios reactivos (accounts, transfers y notifications), más infraestructura (Terraform, docker-compose) y documentación compartida.

Restricciones:
- Soy el único desarrollador.
- Es un proyecto de portafolio: lo van a revisar reclutadores en poco tiempo.

## Opciones consideradas

1. **Monorepo:** los tres servicios, la infraestructura y la documentación en un solo repositorio de GitHub.
2. **Un repositorio por servicio:** un repositorio por cada servicio, más uno para la infraestructura.

## Decisión

Monorepo, porque:
- Con un solo desarrollador no existen las razones que llevan a separar repositorios en una empresa (equipos distintos, permisos por equipo, despliegues independientes entre equipos).
- Un reclutador revisa un solo enlace en lugar de cuatro.
- La infraestructura, el docker-compose y la documentación quedan una sola vez en la raíz, sin un repositorio aparte.

## Consecuencias

- **Gano:** simplicidad y un proyecto fácil de revisar.
- **Pierdo:** la separación natural del CI. Por defecto, un cambio en un servicio compila los tres. Lo resuelvo con filtros por carpeta en GitHub Actions (`paths`).
- **Riesgo:** que un servicio importe código de otro y quede acoplado. Lo evito manteniendo cada servicio como un proyecto Gradle independiente, sin dependencias entre ellos.
- **Pendiente:** si el proyecto crece a un producto con varios equipos, revisar esta decisión y separar los repositorios.