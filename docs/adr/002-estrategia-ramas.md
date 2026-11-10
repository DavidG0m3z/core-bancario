# ADR-002: Estrategia de ramas

- **Estado:** Propuesto
- **Fecha:** 2026-11-09

## Contexto
Un solo desarrollador, main protegida, despliegue continuo planeado en `INF-06`

Restricciones:
- Soy un solo desarrollador
- No hay planeadas versiones, es un Demo

## Opciones consideradas

1. GitHub Flow
2. Trunk-base
3. GitFlow

## Decisión

GitHub Flow, porque:
- porque las ramas `develop` y `release` sirven para cordinar a varias personas y preparar versiones planificadas, problemas que en mi caso no estan.

## Consecuencias
- **Gano:** simplicidad y flujo que encaja con `CI`. 
- **pierdo:** practica `develop`, `release` y `hotfix`
- **Pendiente:** Si el proyecto llega a tener equipo o versiones planificadas, revisar esta decision.
