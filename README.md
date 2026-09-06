# ⚡ AXION INTELLIGENCE PLATFORM (Axion-UI)

> **Enterprise-Grade Real-Time IoT Telemetry, Analytics & Asset Observability Platform**  
> *Architected for High-Throughput Edge Ingestion, Sub-Second Event Correlation, and Zero-Trust Hybrid Cloud Operations.*

---

## 📌 Executive Summary

**Axion** is an industrial-scale telemetry and visual observability ecosystem built to process, correlate, and visualize millions of concurrent IoT edge metrics. Designed from a cloud-native perspective, Axion bridges the gap between raw hardware telemetry and actionable intelligence.

This repository houses the **Axion Front-End & Observability UI Engine**—a high-performance, single-page web application built with **React**, **Vite**, **TypeScript**, and **Tailwind CSS**, optimized for deployment on **Azure Kubernetes Service (AKS)** served via **Azure Application Gateway (AGIC)** and Nginx edge runtime.

---

## 🏗 System Architecture & Observability Topology

Axion follows a clean, decoupled microservices topology. Front-end visual assets are decoupled from ingress telemetry pipelines to guarantee high availability, strict security boundary isolation, and independent elasticity.

```text
                     ┌─────────────────────────────────────────────────────────┐
                     │                   CLIENT BROWSER LAYER                  │
                     │  (Axion UI React SPA - Single Page Execution Context)   │
                     └──────────────────────────┬──────────────────────────────┘
                                                │
                                    HTTPS / TLS Terminated
                                                │
                                                ▼
                     ┌─────────────────────────────────────────────────────────┐
                     │        AZURE APPLICATION GATEWAY INGRESS (AGIC)         │
                     │          (SSL Termination / Edge Routing Layer)          │
                     └──────────────────────────┬──────────────────────────────┘
                                                │
                                       Cluster-Internal Routing
                                                │
                                                ▼
                     ┌─────────────────────────────────────────────────────────┐
                     │          AKS CLUSTER (Kubernetes Data Plane)            │
                     │                                                         │
                     │   ┌─────────────────────┐     ┌─────────────────────┐   │
                     │   │   axionui-service   │     │  telemetry-service  │   │
                     │   │   (Nginx / Static)  │     │   (FastAPI Engine)  │   │
                     │   └──────────┬──────────┘     └──────────┬──────────┘   │
                     └──────────────┼───────────────────────────┼──────────────┘
                                    │                           │
                   CSI Driver &     │                           │ Private Endpoint
                   SecretProvider   ▼                           ▼
                     ┌──────────────────────────┐   ┌──────────────────────────┐
                     │     Azure Key Vault      │   │ Azure Public LoadBalancer│
                     │   (Secrets & SSL Certs)  │   │  telemetry.twivaraai...  │
                     └──────────────────────────┘   └────────────┬─────────────┘
                                                                 │
                                                                 ▼
                                                    ┌──────────────────────────┐
                                                    │ PostgreSQL / TimeSeries  │
                                                    │    (Data Persistence)    │
                                                    └──────────────────────────┘

```

---

## 🛡 Zero-Trust Security, Secrets Management & Network Isolation

Axion UI and its supporting telemetry services are architected around a strict **Zero-Trust Network Architecture (ZTNA)** within Azure:

```text
┌─────────────────────────────────────────────────────────────────────────────────┐
│                               AZURE VIRTUAL NETWORK (VNet)                      │
│                                                                                 │
│   ┌──────────────────────────┐               ┌──────────────────────────────┐   │
│   │   AKS Cluster Subnet     │               │    Private Link Subnet       │   │
│   │                          │               │                              │   │
│   │   ┌──────────────────┐   │  Private IP   │    ┌────────────────────┐    │   │
│   │   │  Axion UI Pods   ├───┼───────────────┼───>│ Key Vault Private  │    │   │
│   │   └────────┬─────────┘   │ (Internal VNet)│    │     Endpoint       │    │   │
│   │            │             │               │    └─────────┬──────────┘    │   │
│   │            │ CSI Secrets │               │              │               │   │
│   │            ▼ Driver      │               │              ▼               │   │
│   │   ┌──────────────────┐   │               │    ┌────────────────────┐    │   │
│   │   │SecretProvider    │   │               │    │  Azure Key Vault   │    │   │
│   │   │Class / ConfigMap │   │               │    │  (azrkeyvault-...) │    │   │
│   │   └──────────────────┘   │               │    └────────────────────┘    │   │
│   └──────────────────────────┘               │                              │   │
│                                              └──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘

```

### Security & Governance Primitives:

* **Azure Key Vault Integration via SecretProviderClass:** Critical secrets, TLS certs, and backend connection keys are dynamically mounted into AKS pods using the **Azure Key Vault Provider for Secrets Store CSI Driver** via custom `SecretProviderClass` manifests. No secrets or keys are ever hardcoded in Docker images or Git repositories.
* **Declarative Environment Configuration (ConfigMaps):** Cluster-level runtime behavior, dynamic UI endpoints, and feature toggles are cleanly separated from application code using Kubernetes `ConfigMap` resources.
* **Private Endpoints & VNet Isolation:** Public internet access to sensitive infrastructure components like Azure Key Vault and databases is completely disabled (`public_network_access_enabled = false`). All communication flows over isolated **Azure Private Endpoints** using private IPs within the VNet.
* **Workload Identity (Passwordless Authentication):** Pods utilize **Azure AD Workload Identity** (Managed Identities) to authenticate against Azure Key Vault via OpenID Connect (OIDC) federation, eliminating static service principal credentials.
* **Content Security Policy (CSP) & CORS Enforcement:** Integrated CSP handling (`upgrade-insecure-requests`) and origin validation eliminate Mixed-Content vulnerabilities across edge termination gateways.

---

## 🚀 Key Architectural Innovations & Features

* **Sub-Second Event Ingestion & Correlation:** Dynamic dashboard metrics reflecting real-time asset throughput, top-anomalous device alerts, and regional telemetry.
* **Build-Time & Runtime Environment Injection:** Engineered using Vite build-time static injection (`ARG` / `ENV`) combined with Kubernetes `ConfigMap` and `SecretProviderClass` objects to maintain runtime flexibility without compromising security.
* **Zero-Downtime Rolling Upgrades:** Declarative Kubernetes deployment strategies paired with `imagePullPolicy: Always` and Docker layer optimization for rapid CI/CD rollouts via Azure Container Registry (ACR).

---

## 📂 Repository Structure

```text
AxionUI/
├── manifests/                        # Production Kubernetes Infrastructure-as-Code
│   ├── axionui-deployment.yaml       # Declarative Deployment Config (Image, Replica, Policy)
│   ├── axionui-service.yaml          # ClusterIP Service Mapping
│   ├── axionui-ingress.yaml          # AGIC Ingress Configuration & SSL Redirect Rules
│   ├── axionui-configmap.yaml        # Non-sensitive Runtime Config & API Endpoint Mappings
│   └── axionui-secretprovider.yaml   # Key Vault SecretProviderClass CSI Driver Manifest
├── src/                              # Application Layer (TypeScript / React)
│   ├── components/                   # Resilient UI Design System & Atomic Views
│   │   └── pages/                    # High-Throughput Page Views (Dashboard, Historical)
│   ├── App.tsx                       # Main Routing & Global Auth Controller
│   └── main.tsx                      # Application Entry Point & React Strict Execution
├── nginx.conf                        # Production Nginx Reverse Proxy Config
├── Dockerfile                        # Multi-Stage Production Build File
├── package.json                      # Dependencies and Build Tooling
└── vite.config.ts                    # Vite Engine Configuration

```

---

## 🛠 Tech Stack & Engineering Primitives

* **Frontend Framework:** React 18 / TypeScript / Vite
* **UI & Styling:** Tailwind CSS / Lucide Icons / Recharts Data Visualization
* **Container Engine:** Docker (Multi-Stage Node Build + Alpine Nginx Serve Stage)
* **Orchestration:** Kubernetes (AKS - Azure Kubernetes Service)
* **Configuration & Storage:** Kubernetes ConfigMaps / SecretProviderClass (CSI Driver)
* **Ingress & Networking:** Azure Application Gateway (AGIC) / Private Endpoints / VNet Integration
* **Security & Governance:** Azure Key Vault / Workload Identity (OIDC)
* **Registry & Hosting:** Azure Container Registry (ACR)

---

## ⚡ Quickstart: Local Development & Build Engine

### Prerequisites

* **Node.js:** `v20.x` or higher
* **npm:** `v10.x` or higher
* **Docker:** Engine `v24.x` or higher

### 1. Local Setup

```bash
# Clone the repository
git clone [https://github.com/varuntanwar19/AxionUI.git](https://github.com/varuntanwar19/AxionUI.git)
cd AxionUI

# Install dependencies
npm install

# Start development server
npm run dev

```

### 2. Multi-Stage Docker Build

To compile static assets and wrap them in an edge Nginx runtime:

```bash
# Build the production image with explicit build argument injection
docker build --no-cache \
  --build-arg VITE_API_BASE_URL=[http://telemetry.twivaraai.online](http://telemetry.twivaraai.online) \
  -t axionacr2029.azurecr.io/axionui:v2 .

```

---

## ☸ Kubernetes Deployment (Production)

Deploy the UI and security abstractions to your AKS cluster with the following zero-downtime workflow:

```bash
# 1. Push image to Azure Container Registry
docker push axionacr2029.azurecr.io/axionui:v2

# 2. Apply Security, Configuration, and Infrastructure Manifests
kubectl apply -f manifests/axionui-secretprovider.yaml
kubectl apply -f manifests/axionui-configmap.yaml
kubectl apply -f manifests/axionui-deployment.yaml
kubectl apply -f manifests/axionui-service.yaml
kubectl apply -f manifests/axionui-ingress.yaml

# 3. Perform a zero-downtime rollout restart
kubectl rollout restart deployment axionui-deployment -n default

# 4. Verify deployment & secret mount status
kubectl get pods -l app=axion-ui

```

---

## 🤝 Author & Community

Crafted with high engineering standards by **Varun Tanwar**.

Focusing on **DevOps, Cloud Architecture (Azure/AWS), Infrastructure-as-Code (Terraform), and Observability Ecosystems**.

* **GitHub:** [@varuntanwar19](https://www.google.com/search?q=https://github.com/varuntanwar19)
* **LinkedIn:** [Connect on LinkedIn](https://www.linkedin.com/varun-tanwar-1383bb15a/)

---

*⭐ If you find this architecture insightful or helpful in your own enterprise setups, feel free to star this repository!*

```
