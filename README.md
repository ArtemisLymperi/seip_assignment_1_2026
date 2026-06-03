# Software Engineering in Practice — Assignment 1 (2026)
## Advanced DevOps: Production-Grade CI/CD, External Configuration, and Orchestration
**Vasiliki Artemis Lymperi (t8230079)**  
<br>

## Prerequisites

Make sure you have the following tools installed on your machine:

| Tool | Version | Link |
|------|---------|------|
| Git | Latest | https://git-scm.com |
| Docker Desktop | Latest | https://docs.docker.com/desktop |
| Minikube | v1.38.1+ | https://minikube.sigs.k8s.io/docs/start |
| kubectl | v1.33.0+ | https://kubernetes.io/docs/tasks/tools/install-kubectl-windows |



## Clone the Repository

```bash
git clone https://github.com/ArtemisLymperi/seip_assignment_1_2026
cd seip_assignment_1_2026
```

## Task 1 - Containerization

The repository contains a production-optimized `Dockerfile` at the root.

It uses `node:18-alpine` as the base image and leverages Docker layer caching by copying `package.json` before the source code.


## Task 2 - CI/CD Pipeline

The repository contains a GitHub Actions workflow at `.github/workflows/ci-cd.yaml`.

Every push to the `main` branch automatically:
1. Checks out the repository code
2. Authenticates against the GitHub Container Registry (GHCR)
3. Builds and tags the image as `ghcr.io/artemislymperi/echo-api:latest`
4. Pushes the image to GHCR


## Task 3 - Cloud Native Architecture & Orchestration

### Start Minikube

```bash
minikube start --driver=docker
```

### 3.1 ConfigMap

The `k8s/configmap.yaml` defines the non-sensitive configuration parameters:

- `WELCOME_MESSAGE`: "Welcome to the Software Engineering in Practice Assignment Cluster!"
- `NODE_ENV`: "production"

Apply individually:

```bash
kubectl apply -f k8s/configmap.yaml
```

### 3.2 Secret

The `k8s/secret.yaml` stores the sensitive API key (Base64 encoded):

- `API_SECRET_KEY`: stored securely as a Base64 encoded value

Apply individually:

```bash
kubectl apply -f k8s/secret.yaml
```

### 3.3 Deployment

The `k8s/deployment.yaml` deploys the echo-api with:
- 3 replicas
- Resource limits (100m-250m CPU, 128Mi-256Mi RAM)
- Environment variables injected from ConfigMap and Secret
- LivenessProbe and readinessProbe on `/health`

```bash
kubectl apply -f k8s/deployment.yaml
```


### 3.4 Service

The `k8s/service.yaml` exposes the deployment internally via ClusterIP:
- Maps incoming cluster traffic on port 80 to container's internal port 3000

```bash
kubectl apply -f k8s/service.yaml
```


### Apply manifests in order:

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### Or apply all of them with a single command:

```bash
kubectl apply -f k8s/
```


## Interact with the Endpoints

Use `kubectl port-forward` to access the application locally:

```bash
kubectl port-forward service/echo-api-service 8080:80
```

Then visit:

| Endpoint | Description |
|----------|-------------|
| `http://localhost:8080/` | Returns the custom ConfigMap greeting |
| `http://localhost:8080/secure-config` | Returns status "Authorized" and masked secret |
