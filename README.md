# Counter App

A small Flask application that counts page visits using Redis. Docker Compose runs the app, Redis, and an nginx reverse proxy. The Compose configuration uses the published Docker Hub image `mohamed20202030/counter_app-web:latest` for the Flask service.

## Requirements

- Docker Engine
- Docker Compose v2 (`docker compose`)

## Deployment flow

The normal image deployment flow is:

1. Push a commit to the `main` branch.
2. The GitHub Actions workflow in `.github/workflows/docker-ci.yml` builds the image from the repository's `Dockerfile` and pushes the `latest` tag to Docker Hub.
3. On the machine running the app, run `repull-last-image.sh` from this repository directory. It pulls the new `web` image and starts or updates the Compose services.
4. nginx accepts browser requests on port `8050` and forwards them to Flask on port `5000`. Flask increments the `hits` value in Redis and returns the count.

The workflow requires the repository's GitHub Actions secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`. The username must refer to the Docker Hub namespace used by the image in `docker-compose.yml` (`mohamed20202030`), or the Compose image reference must be changed to match the secret's namespace.

## Start or update the app

From the project directory, run the script:

```bash
bash ./repull-last-image.sh
```

The script runs `sudo docker compose pull web` followed by `sudo docker compose up -d`. It refreshes only the Flask image explicitly; Compose also starts nginx and Redis if needed. Because the script uses `sudo`, Docker Hub credentials for a private image must be available to root. Log in with `sudo docker login -u <dockerhub-username>` if required. For a public image, login is generally not needed to pull it.

Open [http://localhost:8050](http://localhost:8050). Refreshing the page increments the visit count.

You can also start the services without the script:

```bash
docker compose up -d
```

When the `web` image is not available locally, Compose pulls the image specified in `docker-compose.yml`.

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

The Redis counter is not stored in a persistent volume, so it resets when the Redis container is removed, including when you run `docker compose down`.

## How it works

- **nginx** listens on host port `8050` and proxies requests to the `web` service.
- **web** runs the image `mohamed20202030/counter_app-web:latest` on port `5000`. It connects to Redis using the Compose service name `redis`.
- **redis** stores the visit count under the `hits` key.
- The Flask app retries Redis connections before returning an error.

## Project files

- `app.py` — Flask route and Redis-backed hit counter.
- `requirements.txt` — Flask and Redis Python dependencies.
- `Dockerfile` — Builds the Python app image.
- `docker-compose.yml` — Defines nginx, web, and Redis services, including the published web image.
- `repull-last-image.sh` — Pulls the latest web image and starts or updates the Compose services.
- `.github/workflows/docker-ci.yml` — Builds and pushes the Docker image when a commit is pushed to `main`.
- `nginx.conf` — nginx reverse-proxy configuration.
- `docker-compose-obslete.yml` — Older Compose configuration; not used by the commands above.
- `testCI.txt` and `testCI2.txt` — Additional files copied into the Docker image by the Dockerfile.

## Build and publish manually

For a manual image build and publish, use the same repository and tag that Compose expects:

```bash
sudo docker login -u mohamed20202030
sudo docker build -t mohamed20202030/counter_app-web:latest .
sudo docker push mohamed20202030/counter_app-web:latest
```

After publishing, run `bash ./repull-last-image.sh` on the deployment machine to pull and use the updated image. The Compose file currently references a prebuilt image rather than building locally.

## Compatibility note

The Dockerfile uses Python 3.6, which is end-of-life. Consider upgrading the base image and checking dependency compatibility before using this app beyond a local demonstration.