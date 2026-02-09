# CI/CD Notes – GitHub Actions (Without Docker)

## 1. Big Picture

This setup demonstrates a **basic CI/CD pipeline** using:

- GitHub Actions (CI tool)
- Vercel (Hosting + CD)
- React (Sample application)

### Goal

Whenever you **push code to GitHub**:

1. GitHub Actions triggers automatically.
2. It installs dependencies.
3. It builds the React app.
4. It deploys the build to **Vercel**.

This is the simplest real-world CI/CD flow used in many frontend teams.

---

## 2. Why This Matters (Industry Context)

In modern systems:

- CI/CD ensures:
  - No manual deployments
  - Faster feedback
  - Reproducible builds
  - Zero human error

Vercel is commonly used because:

- Free tier
- No server management
- Deep GitHub integration
- Popular for React/Next.js

---

## 3. Pipeline Strategy

### Trigger

- Event: `git push` to GitHub

### Pipeline Stages

1. Checkout code
2. Install dependencies
3. Build project
4. Deploy to Vercel

This follows the classic:

> **Source → Build → Deploy**

---

## 5. Vercel Setup

To allow GitHub Actions to deploy, we need credentials.

### 5.1 Vercel Token

Path:
Vercel Dashboard → Settings → Tokens → Create Token

This token allows GitHub to authenticate with Vercel.

---

### 5.2 Project ID & Org ID

Install Vercel CLI:

```bash
npm install -g vercel
```

Link project:

```bash
vercel link
```

This creates a folder:

```
.vercel/project.json
```

Inside it:

```json
{
  "projectId": "xxx",
  "orgId": "yyy"
}
```

---

## 6. GitHub Secrets

Add secrets in:
GitHub Repo → Settings → Secrets and variables → Actions

Add these:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

These are used securely inside the pipeline.

---

## 7. GitHub Actions Workflow

Create folder:

```
.github/workflows
```

Create file:

```
deploy.yml
```

This file defines the pipeline steps (YAML).

Conceptually it contains:

1. Trigger on push
2. Setup Node
3. Install dependencies
4. Build project
5. Deploy using Vercel CLI

---

## 8. Manual Deployment (First Time)

Run locally:

```bash
vercel
```

What happens:

- Vercel bundles files
- Uploads to cloud
- Returns preview URL

Example:

```
https://remote-app-abc123.vercel.app
```

---

## 9. Verify Deployment

Via Vercel Dashboard:

1. Go to vercel.com
2. Open your project
3. Check Deployments section

If status is:

- `Ready` (green) → App is live

---

## 10. Mental Model (Very Important)

Think of CI/CD as:

```
Developer
   ↓ git push
GitHub
   ↓ triggers
GitHub Actions (CI)
   ↓ builds
Vercel (CD)
   ↓
Live Application
```

## 12. This Setup is Best For

Use this when:

- No backend
- No Docker
- Frontend-only apps
- MVP / prototypes
- Micro frontends

---

## 13. Limitations of This Approach

This pipeline does NOT cover:

- Docker
- Kubernetes
- Custom servers
- Environment promotion (dev → stage → prod)

This is **Level 1 CI/CD** (foundation).

Docker + Kubernetes = Level 2 (real enterprise CI/CD)

# CI/CD Notes – Docker + Kubernetes (Level 2 & 3)

## 14. Big Picture (Docker + K8s)

This setup extends Level 1 and represents **real-world enterprise CI/CD**.

Pipeline becomes:

```
Developer → GitHub → GitHub Actions → Docker Image → Container Registry → Kubernetes Cluster → Live App
```

Now we are:

- Packaging app as a **Docker Image**
- Pushing image to **GitHub Container Registry (GHCR)**
- Deploying that image to **Kubernetes**

---

## 15. Dockerization (Level 2 CI/CD)

### What is Dockerizing?

"Dockerizing" means:

> Packaging your app + runtime + dependencies into a portable image.

This ensures:

- Runs same on all machines
- No "works on my machine" issue
- Standard deployment artifact

---

## 16. Dockerfile

Create a file named `Dockerfile` (no extension) in project root.

This file is a **recipe** to build your app image.

Example flow inside Dockerfile (conceptual):

1. Take Node base image
2. Copy project files
3. Install dependencies
4. Build app
5. Serve via Nginx

---

## 17. Build Docker Image

Run inside project:

```bash
docker build -t my-react-docker-app .
```

This creates a local Docker image.

Verify:

```bash
docker images
```

---

## 18. Run Docker Container Locally

Start container:

```bash
docker run -d -p 8080:80 --name react-test-container my-react-docker-app
```

Meaning:

- `-d` → detached mode
- `-p 8080:80` → map host port to container
- `--name` → container name

Open:

```
http://localhost:8080
```

---

## 19. Push Image via GitHub Actions

Now pipeline also:

- Builds Docker image
- Pushes it to **GitHub Container Registry (GHCR)**

Image format:

```
ghcr.io/username/repo/my-react-app:latest
```

---

## 20. Pull Image from Registry

Simulating production server:

```bash
docker pull ghcr.io/your-username/your-repo/my-react-app:latest
eg
docker pull ghcr.io/nikhildeveloper2025/react-ci-cd-repo/my-react-app:latest
```

Verify:

```bash
docker images
```

This proves image exists in cloud.

---

## 21. Kubernetes Setup (Free Local Cluster)

Docker Desktop already provides Kubernetes.

Steps:

1. Open Docker Desktop
2. Settings → Kubernetes
3. Enable Kubernetes
4. Apply & Restart

Green Kubernetes icon = cluster ready.

---

## 22. Verify Cluster

```bash
kubectl get nodes
```

Expected:

```
docker-desktop   Ready
```

---

## 23. Deployment YAML

Create `deployment.yaml`

This is Kubernetes equivalent of:

> docker-compose.yml

It defines:

- Which image to run
- How many replicas
- Container ports

This file is **Source of Truth**.

---

## 24. Deploy to Kubernetes

```bash
kubectl apply -f deployment.yaml
```

What happens:

- Kubernetes pulls image from GHCR
- Creates multiple Pods
- Manages lifecycle

Check:

```bash
kubectl get pods
```

---

## 25. Expose via Service

Pods are internal only.

Create `service.yaml`

Apply:

```bash
kubectl apply -f service.yaml
```

Now accessible:

```
http://localhost
```

---

## 26. Three Running Environments

After full setup:

| Environment   | URL            | Meaning          |
| ------------- | -------------- | ---------------- |
| Manual Docker | localhost:8080 | Local container  |
| Cloud Image   | localhost:9090 | Pulled from GHCR |
| Kubernetes    | localhost:80   | Cluster service  |

Same app running in 3 infrastructures.

---

## 27. Mental Model (Docker + K8s)

```
Code
 ↓
Dockerfile
 ↓
Docker Image
 ↓
Container Registry
 ↓
Kubernetes Deployment
 ↓
Pods
 ↓
Service
 ↓
Users
```

---

## 28. Interview One-Liners

### Docker

> "Docker packages my application and dependencies into a portable image."

### Kubernetes

> "Kubernetes orchestrates containers, handles scaling, healing, and service discovery."

### CI/CD

> "GitHub Actions builds the Docker image and Kubernetes pulls it to deploy automatically."

---

## 29. Why This Is Real Enterprise CI/CD

Because it gives:

- Zero downtime deployments
- Horizontal scaling
- Rollbacks
- Infra abstraction

---

## 30. Final CI/CD Levels Summary

| Level   | Stack                                | Use Case           |
| ------- | ------------------------------------ | ------------------ |
| Level 1 | GitHub Actions + Vercel              | Frontend MVP       |
| Level 2 | GitHub Actions + Docker              | Backend services   |
| Level 3 | GitHub Actions + Docker + Kubernetes | Enterprise systems |

This is the **complete modern CI/CD learning path**.

---

Code → CI → Image → Registry → Cluster → Pods → Service → Users

Next Learning-
Environments
dev → staging → prod

Rollbacks
previous image versions
