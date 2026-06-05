# TDWA07-01

CRUD REST API for CELEBRITIES database based on TDWA06-01.

## Build image

```powershell
docker build -t ghigher/tdwa07-01 .
```

## Run container

If SQL Server is available on the host at `127.0.0.1:1433`, run:

```powershell
docker run --rm --name tdwa07-01 -p 2280:2280 --add-host=host.docker.internal:host-gateway ghigher/tdwa07-01
```

## Push to Docker Hub

```powershell
docker login
docker push ghigher/tdwa07-01
```

## API

```text
GET    /api/celebrities
GET    /api/celebrities/:id
POST   /api/celebrities
PUT    /api/celebrities/:id
DELETE /api/celebrities/:id
```
