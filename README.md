# Counter App

A small Flask application that counts page visits using Redis. Docker Compose runs the app, Redis, and an nginx reverse proxy.

## Requirements

- Docker Engine
- Docker Compose v2 (`docker compose`)

## Start the app

From the project directory, run:

```bash
docker compose up -d
```

Compose builds the Flask image and starts the services in the background. Open [http://localhost:8090](http://localhost:8090) in your browser. Refreshing the page increments the visit count.

To follow the service logs:

```bash
docker compose logs -f
```

To check service status:

```bash
docker compose ps
```

## Stop the app

Stop and remove the containers and Compose network with:

```bash
docker compose down
```

The Redis counter is not stored in a persistent volume, so it resets when the Redis container is removed.

## How it works

- **nginx** listens on host port `8090` and proxies requests to the `web` service.
- **web** builds from the local `Dockerfile` and runs the Flask app on port `5000`. It connects to Redis using the Compose service name `redis`.
- **redis** stores the visit count under the `hits` key.
- The Flask app retries Redis connections before returning an error.

## Project files

- `app.py` — Flask route and Redis-backed hit counter.
- `requirements.txt` — Flask and Redis Python dependencies.
- `Dockerfile` — Builds the Python app image.
- `docker-compose.yml` — Defines nginx, web, and Redis services.
- `nginx.conf` — nginx reverse-proxy configuration.
- `docker-compose-obslete.yml` — Older Compose configuration; not used by the commands above.

## Rebuild after changes

If you change the app or its dependencies, rebuild the image when starting the services:

```bash
docker compose up -d --build
```

## Compatibility note

The Dockerfile uses Python 3.6, which is end-of-life. Consider upgrading the base image and checking dependency compatibility before using this app beyond a local demonstration.