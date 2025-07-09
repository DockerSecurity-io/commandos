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

_Requirement: This step requires the [Docker Init](#1-docker-init) step to be completed first._

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

## 3. Docker SBOM

_Requirement: This step requires the [Docker Init](#1-docker-init) step to be completed first._

In Docker Init step, we built an image with tag `flask-server:latest` when running `docker compose up --build`. Let's check the SBOM for this image.

Docker SBOM is integrated into Docker Desktop, but is also available for Docker CE as a CLI plugin that you need to install separately.

### Usage

To check the SBOM for the image, run:

```bash
docker sbom flask-server:latest
```

The output will show the SBOM in a table format. Try to export it to a SPDX file:

```bash
docker sbom --format spdx-json flask-server:latest > sbom.spdx.json
```

If you investigate the file, you will see that it contains a list of all the packages used in the image, their versions, and the licenses. It's especially useful for compliance and security purposes.

A more interesting example will be a C++ application.

Go to the C++ example directory:

```bash
cd cpp
```

Then, build the image:

```bash
docker build -t cpp-hello .
```

Now, check the SBOM for the image:

```bash
docker sbom cpp-hello
```

It will say there are no packages in the image, because the image is built from a `FROM scratch` base image. But, in the build stage, we installed many packages, and a vulnerability in those packages can affect the final image.

We'll get back to this later.

### Exercises

- 3.1. Try to create a Docker Bake file for the C++ example, and build the image using Docker Bake.
- 3.2. Use `docker sbom --help` to check available formats for the SBOM output.

## 4. SBOM Attestations

_Requirement: This step requires the [Docker SBOM](#3-docker-sbom) step to be completed first._


_Main article: [DockerDocs: Supply-Chain Security for C++ Images](https://docs.docker.com/guides/cpp/security/)_

SBOM attestations are SBOMs generated for Docker images and uploaded with them to the registry.

### Usage

SBOM attestations are generated during the build and pushed to the registry automatically:

```bash
docker buildx build --sbom=true --push -t aerabi/cpp-hello .
```

Now, let's check the CVEs with Docker Scout (we will cover it in the next section):

```bash
docker scout cves aerabi/cpp-hello
```

It will say:

```
SBOM obtained from attestation, 0 packages found
```

The SBOM has no packages, because we built the image from a `FROM scratch` base image, and the build stage packages are not included in the SBOM. We can fix this by including the build stage packages in the SBOM.

To do that, we need to add the following line to the beginning of the `Dockerfile`:

```dockerfile
ARG BUILDKIT_SBOM_SCAN_STAGE=true
```

This line goes before the `FROM` line, and it tells Docker to include the build stage packages in the SBOM.

Now, rebuild the image with the new Dockerfile:

```bash
docker buildx build --sbom=true --push -t aerabi/cpp-hello:with-build-stage .
```

Now, check the SBOM attestations for the image again:

```bash
docker scout cves aerabi/cpp-hello:with-build-stage
```

It will say:

```
SBOM of image already cached, 208 packages indexed
```

### Exercises

- 4.1. Here, the build command was super long. Try to create a Docker Bake file for the C++ example, and build the image using Docker Bake with SBOM attestations.