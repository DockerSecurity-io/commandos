# Docker Deep Dive with a Docker Captain at WAP 2025

This repository contains the source code and resources for the Docker Deep Dive workshop at WAP 2025. The workshop will cover the following topics:

- Docker Init
- Docker Bake
- Docker SBOM
- SBOM attestations
- Docker Scout
- Docker Debug
- Docker Model Runner
- Ask Gordon

## Links

- [Docker Deep Dive with a Docker Captain](https://app.wearedevelopers.com/events/14/session/35)
- [DockerHour.com](https://dockerhour.com/)
- [Docker and Kubernetes Security Book](https://DockerSecurity.io/)


## Technical Requirements

- Docker Desktop latest version
- Git
- A Bash shell (e.g., Git Bash, WSL, or any Linux terminal)

On Windows, you can install Git Bash.

## 1. Docker Init

_Main article: [Dockerizing a Java 24 Project with Docker Init](https://dockerhour.com/dockerizing-a-java-24-project-with-docker-init-6f6465758c55)_

_Main article: [JAVAPRO: How to Containerize a Java Application Securely](https://javapro.io/2025/07/03/how-to-containerize-a-java-application-securely/)

Docker Init is a command to initialize a Docker project with a Dockerfile and other necessary files:

- `Dockerfile`
- `compose.yaml`
- `.dockerignore`
- `README.Docker.md`

The command doesn't use GenAI, so is deterministic, and employs best practices for Dockerfile creation.

Docker Init is available on Docker Desktop 4.27 or later and is generally available.

### Usage

On the repo, go to the directory `init` and run:

```bash
docker init
```

### Exercises

- 1.1. Create a Dockerfile for a Java 24 project using Docker Init.
- 1.2. Create a Dockerfile for a Python 3.12 project using Docker Init.
- 1.3. Compare the Dockerfile created for the Java application with the one created for the Python application. What are the differences?

## 2. Docker Bake

