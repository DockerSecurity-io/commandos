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

On the repo, go to the Flask example directory:

```bash
cd flask
```

Then, run the Docker Init command:

```bash
docker init
```

The command will ask you 4 questions, accept the defaults:

- ? What application platform does your project use? **Python**
- ? What version of Python do you want to use? **3.13.2**
- ? What port do you want your app to listen on? **8000**
- ? What is the command you use to run your app? **gunicorn 'hello:app' --bind=0.0.0.0:8000**

Then, start Docker Compose with build:

```bash
docker compose up --build
```

The application will be available at [http://localhost:8000](http://localhost:8000).

### Exercises

- 1.1. If you want a more tricky example, try Dockerizing a Java 24 application using Docker Init. You can follow the instructions in the [JAVAPRO article](https://javapro.io/2025/07/03/how-to-containerize-a-java-application-securely/) that I published last week.
- 1.2. Compare the Dockerfile created for the Java application with the one created for the Python application. What are the differences?

## 2. Docker Bake

_Requirement: This step requires the Docker Init step to be completed first._

Docker Bake is to Docker Build, what Docker Compose is to Docker Run. It allows you to build multiple images at once, using a single command.

Docker Bake is available on Docker CE and Docker Desktop, and is generally available.

### Usage

In the repo, go to the Flask example directory:

```bash
cd flask
```

Then, try to build the image using Docker Bake:

```bash
docker buildx bake
```

The command will build the image using the `docker-bake.hcl` file in the current directory. At the end, there is a Docker Desktop link shown in the output, with which you can see the build progress in the Docker Desktop UI.

Also, there are probably some warnings about the Dockerfile.

### Exercises

- 2.1. Try to fix the warnings in the Dockerfile.
- 2.2. By changing the `docker-bake.hcl` file, try building for multiple platforms, e.g., `linux/amd64` and `linux/arm64`. 
- 2.3. Try to build the image with a different Python version, e.g., `3.13.1` (the Python version is defined in the Dockerfile as a build argument, `PYTHON_VERSION`).
