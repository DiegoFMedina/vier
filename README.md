# Vier

Plataforma de levantamiento y captura de datos en terreno. MVP: login, listado de
levantamientos ("inicio levantamiento") y captura de fotos/documentos en terreno.

## Stack

- **Frontend:** Flutter Web + Riverpod + GoRouter
- **Backend:** NestJS + TypeScript
- **Base de datos:** PostgreSQL + Prisma
- **Archivos:** MinIO (S3-compatible)
- **Autenticación:** JWT
- **Despliegue:** Docker Compose + Nginx + PM2

## Estructura

```
backend/    API NestJS (auth, levantamientos, capturas)
frontend/   App Flutter Web
nginx.conf  Config de Nginx dentro del contenedor del frontend (proxy /api -> backend)
docker-compose.yml
```

## Levantar todo con Docker Compose

```bash
cp .env.example .env   # ajustar si es necesario
docker compose up --build
```

- Frontend: http://localhost:8080
- Backend API: http://localhost:8080/api (proxeado por Nginx) o http://localhost:3000/api directo
- Consola MinIO: http://localhost:9001

Usuario de prueba (se crea al aplicar el seed, ver abajo):

```
admin@vier.cl / vier1234
```

La primera vez, corre el seed dentro del contenedor del backend:

```bash
docker compose exec backend npx ts-node prisma/seed.ts
```

## Desarrollo local (sin Docker para el código de la app)

Requiere Postgres y MinIO corriendo (puedes usar solo esos dos servicios de
`docker-compose.yml`: `docker compose up postgres minio`).

### Backend

```bash
cd backend
cp .env.example .env      # ajustar DATABASE_URL / MINIO_* si es necesario
npm install
npx prisma migrate dev
npx ts-node prisma/seed.ts
npm run start:dev
```

API disponible en `http://localhost:3000/api`.

### Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

## Módulos del backend

- **auth**: login con JWT (`POST /api/auth/login`, `GET /api/auth/me`).
- **levantamientos**: CRUD del levantamiento inicial en terreno.
- **capturas**: subida de fotos/documentos por levantamiento, almacenados en
  MinIO; el listado devuelve URLs firmadas de descarga.
- **checklist-plantillas**: plantillas reutilizables de checklist (secciones →
  grupos → ítems), editables y con secciones/ítems dinámicos. `PUT
  /checklist-plantillas/:id/estructura` reemplaza el árbol completo (más simple
  para un builder que ir campo a campo). Logo de empresa y de cliente
  configurables por plantilla (`POST /checklist-plantillas/:id/logo`).
- **checklist-instancias**: al crear un checklist para un levantamiento
  (`POST /levantamientos/:id/checklists`) se copia la estructura de la
  plantilla en ese momento (si luego editas la plantilla, los checklists ya
  creados no cambian). Incluye metadata del documento (contrato, revisión,
  preparó/revisó/aprobó), historial de revisiones, y respuestas SI/NO +
  observaciones por ítem (`PATCH /checklists/:id/items/:itemId`). `GET
  /checklists/:id/pdf` genera el documento en PDF (Puppeteer) replicando el
  formato de portada/aprobaciones/checklist del documento base.

## Notas de diseño de la app

Paleta morado/violeta profundo con acentos fucsia/naranja para CTAs, tarjetas
con esquinas muy redondeadas y sombras suaves, tipografía geométrica (Manrope),
ilustraciones planas para estados vacíos, navegación inferior minimalista.
