FROM node:24-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++
ENV PUPPETEER_SKIP_DOWNLOAD=true

COPY package*.json ./
RUN npm ci

COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:24-alpine
WORKDIR /app
# Chromium del sistema para generar los PDF de checklist con Puppeteer:
# la versión de Chromium que Puppeteer descarga por defecto es glibc y no
# corre sobre musl (Alpine), así que se usa el paquete de Alpine en su lugar.
RUN apk add --no-cache python3 make g++ chromium
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN npm install -g pm2

COPY package*.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY ecosystem.config.js ./

RUN npx prisma generate

ENV NODE_ENV=production
EXPOSE 3000

CMD ["sh", "-c", "npx prisma migrate deploy && pm2-runtime ecosystem.config.js"]
