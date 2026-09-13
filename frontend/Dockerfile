FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .

ARG API_BASE_URL=/api
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
