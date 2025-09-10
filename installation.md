
# Pre‑Workshop Installation Guide: 10 Docker Commandos

## 0. Pre‑Workshop Preparation

### a) Install Docker Desktop (recommended)
- **Download and install** Docker Desktop for your OS.
- **To switch context after installation**, open your terminal and run:
  ```bash
  docker context ls
  docker context use desktop-linux
  ```
  Make sure to replace `desktop-linux` with the appropriate context for your OS.

### b) If using Docker-CE (Engine) without Desktop
- You'll need to install necessary **CLI plugins manually** for commands like `docker sbom`, `docker scout`, and others.

---

## Installation & Availability by Command

| Command                                | GA or Beta / Availability        | Free / Paid / Open‑source                          | Docker Desktop Version (From)                                  | Notes / Install Steps                                          |
|----------------------------------------|----------------------------------|----------------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------|
| **docker init**                        | GA (was Beta)                    | Proprietary (only via Desktop)                     | Beta since Desktop 4.18; GA in ~early 2024 (v4.27+)            | No install needed in Desktop. For CE: not available.           |
| **docker buildx bake**                 | GA (part of Buildx v0.27.0+)     | Free / Open‑source                                 | Buildx updated in Desktop 4.45 (released 2025‑08‑28)           | Use `docker buildx bake`; ensure Buildx is updated.            |
| **docker sbom**                        | Plugin (CLI extension)           | Free / Open‑source                                 | Needs plugin install for CE; included in Desktop               | Install plugin manually (see below).                           |
| **SBOM attestation** (`buildx --sbom`) | BuildKit feature, open‑source    | Free / Open‑source                                 | Available since BuildKit enabled in Scout features (post‑2023) | Use `docker buildx build --sbom=true` with proper builder.     |
| **docker scout**                       | GA (CLI plugin)                  | Free tier; Scout platform may require subscription | Plugin included since Desktop 4.17                             | Install plugin if using CE manually.                           |
| **docker debug**                       | GA                               | Requires Pro, Team, or Business subscription       | Docker Desktop 4.33 or later                                   | Included in Desktop. CE: Not available.                        |
| **docker model run**                   | GA (Docker Model Runner)         | Free                                               | Available in CE, Desktop 4.40 for MacOS, and 4.41 for Windows  | Automatic in Desktop; CE: requires manual plugin installation. |
| **Ask Gordon** (`docker ai`)           | Beta                             | Proprietary (requires private account)             | Present in Desktop 4.38.0 or later                             | Desktop only.                                                  |
| **Docker's MCP catalog**               | AI Catalog (Marketplace) feature | Free (with Docker Hub account)                     | -                                                              | -                                                              |
| **CAgent**                             | Experimental                     | Free (for now)                                     | Standalone binary                                              | See below.                                                     |

---

## Manual Plugin Installation for Docker CE (non‑Desktop)

### 1. **Docker Scout**
To install Docker Scout manually:
```bash
curl -fsSL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh -o install-scout.sh
sh install-scout.sh
```

### 2. **Docker SBOM**
To install the Docker SBOM plugin:
```bash
# install the docker-sbom plugin
curl -sSfL https://raw.githubusercontent.com/docker/sbom-cli-plugin/main/install.sh | sh -s --

# use the sbom plugin
docker sbom <my-image>
```

### 3. **Docker Model Runner**
Installing Model Runner manually on Linux requires compiling a standalone binary:

```bash
git clone https://github.com/docker/model-cli.git
cd model-cli
make build
./model install-runner
```

Then, you can run models like this:

```bash
model run ai/gemma3
```

### 4. **CAgent**
CAgent is not extensively discussed in the workshop, so installation is optional. If you want to try it out, you can download the latest release from the [GitHub releases page](https://github.com/docker/cagent/releases).

---

## Summary & Tips for Attendees

- **Docker Desktop** is strongly recommended as it includes most features out of the box.
- For **Docker CE users**, manual installation of plugins is necessary for full functionality.
- Most of the commands won't work on alternative runtimes like **OrbStack**.