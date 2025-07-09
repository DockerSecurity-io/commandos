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

## 5. Docker Scout

_Requirement: This step requires the [SBOM Attestations](#4-sbom-attestations) step to be completed first._

Docker Scout is a tool to analyze Docker images and check for vulnerabilities, misconfigurations, and other issues. It uses the SBOM attestations, when available, to provide more accurate results.

Docker Scout is available on Docker Desktop, and as a CLI plugin for Docker CE.

### Usage

To check the vulnerabilities in the image, run:

```bash
docker scout cves aerabi/cpp-hello:with-build-stage
```

You can also check the vulnerabilities in the image using the Docker Desktop UI. Just go to the "Images" tab, select the image, and click on "Scout".

There are also recommendations for the image, which you can check by running:

```bash
docker scout recommendations flask-server
```

### Exercises

- 5.1. Try to fix the vulnerabilities in the Flask image using the recommendations from Docker Scout.

## 6. Docker Debug

_Requirement: This step requires the [Docker SBOM](#3-docker-sbom) step to be completed first._

Docker Debug is a tool to debug Docker images and containers. It allows you to run a container with a debug shell, and inspect the image and the container.

Docker Debug is a paid feature available on Docker Desktop.

### Usage

Docker Debug can be used to investigate images or containers, when `docker exec` is not enough. For example, you can use it to inspect a scratch image:

```bash
docker debug aerabi/cpp-hello:with-build-stage
```

### Exercises

- 6.1. Use Docker Debug to inspect the C++ image.
- 6.2. Use Docker Debug to inspect the Flask image.
- 6.3. Run the Flask image and inspect it with Docker Debug.
- 6.4. Install a tool like Vim using Docker Debug. The tools persist between different inspections. Try to inspect another container and check if the tool is still there.

## 7. Docker Model Runner

_Main article: [Run GenAI Models Locally with Docker Model Runner](https://dev.to/docker/run-genai-models-locally-with-docker-model-runner-5elb)_

Docker Model Runner is a tool to run GenAI models locally using Docker. The feature is still in beta, but is available on Linux, macOS, and Windows.

- Linux: Docker CE
- macOS: Docker Desktop 4.40 or later
- Windows: Docker Desktop 4.41 or later

On Docker CE, you need to install the Docker Model Runner plugin:

```bash
sudo apt-get install docker-model-plugin
```



### Usage

```bash
docker model run ai/gemma3
```

To use Docker Model Runner for developing GenAI applications, you can pull the models, and they will become available locally. Whenever an application needs to use a model, it can use the local models.

And example application is available here:

```bash
git clone https://github.com/aerabi/genai-app-demo
cd genai-app-demo
```

Edit the file `backend.env` and make it match the following content:

```dotenv
BASE_URL: http://model-runner.docker.internal/engines/llama.cpp/v1/
MODEL: ai/gemma3
API_KEY: ${API_KEY:-dockermodelrunner}
````

Then, run the application:

```bash
docker compose up -d
```

### Exercises

- 7.1. Docker Compose now supports the `model` service type ([learn more](https://docs.docker.com/ai/compose/models-and-compose/)). Try to adapt the Compose file in the repo to declare the model as a service.