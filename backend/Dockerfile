FROM node:24-alpine AS builder
WORKDIR /app
RUN apk add --no-cache python3 make g++

COPY package*.json ./
RUN npm ci

COPY . .
RUN npx prisma generate
RUN npm run build

FROM node:24-alpine
WORKDIR /app
RUN apk add --no-cache python3 make g++

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
