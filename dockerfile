# Dockerfile – PocketBase en Alpine, listo para Sliplane
FROM alpine:3.20

ARG PB_VERSION=0.22.15
ARG PB_ARCH=linux_amd64

RUN apk add --no-cache curl unzip ca-certificates tzdata wget \
 && adduser -D -H -s /sbin/nologin pocketbase \
 && mkdir -p /pb_data /pb_public /pb_migrations /app \
 && chown -R pocketbase:pocketbase /pb_data /pb_public /pb_migrations /app

WORKDIR /app

RUN curl -L -o pb.zip \
  "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_${PB_ARCH}.zip" \
 && unzip pb.zip && rm pb.zip && chmod +x pocketbase

<<<<<<< HEAD
=======
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh && chown pocketbase:pocketbase /app/start.sh
>>>>>>> 0abcb026131fcf141f3667dedc6463b539a8ae3a

USER pocketbase
EXPOSE 8090

# Healthcheck local del contenedor (GET /api/health retorna 200 si está OK)
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=5 \
  CMD wget -qO- http://127.0.0.1:${PORT:-8090}/api/health || exit 1

# ¡Clave!: usar $PORT que Sliplane/Railway define; fallback a 8090 si no está
CMD ["./start.sh"]
