# Nendo Platform

<br>
<p align="left">
    <img src="https://okio.ai/docs/assets/nendo_logo.png" width="500" alt="Nendo Core">
</p>
<br>

<p align="left">
<a href="https://okio.ai" target="_blank">
    <img src="https://img.shields.io/website/https/okio.ai" alt="Website">
</a>
<a href="https://twitter.com/okio_ai" target="_blank">
    <img src="https://img.shields.io/twitter/url/https/twitter.com/okio_ai.svg?style=social&label=Follow%20%40okio_ai" alt="Twitter">
</a>
<a href="https://discord.gg/gaZMZKzScj" target="_blank">
    <img src="https://dcbadge.vercel.app/api/server/XpkUsjwXTp?compact=true&style=flat" alt="Discord">
</a>
</p>

---

Nendo is an open source platform for AI-driven audio management, intelligence, and generation. It is a feature-rich web application stack to develop and run tools that are based on [Nendo Core](https://github.com/okio-ai/nendo) and it's [plugin ecosystem](https://okio.ai/docs/plugins/).


**[Requirements](#requirements)** - **[Quickstart](#quickstart)** - **[Server Deployment](#server-deployment)** - **[Development](#development)** - **[Troubleshooting](#troubleshooting)**

## Requirements

To run Nendo Platform on Unix-based systems, make sure you have `docker` and `docker-compose` (`>=1.28.0`) installed. Make sure the user with which you intend to run Nendo Platform is a member of the `docker` group, otherwise the `make` commands will fail with `permission denied`.

### GPU Compatibility

> **Note**: If your system does not have a GPU available, you can still run Nendo Platform in [CPU mode](#cpu-mode) but expect certain tools to fail.

#### Minimum Requirements

Nendo Platform needs a GPU with 8 GB of VRAM for the most basic AI features to work properly.
Expect certain tools to be significantly slower or even to fail when running with the minimum requirements.

Also note that audio files over 15 minutes in length might not be processable with the minimum requirements.

#### Recommended Requirements

Nendo Platform needs a GPU with at least 24 GB of VRAM for its whole feature set to work properly. 
The list of supported hardware includes, but is not limited to: RTX 3090 (Ti), RTX 4090 (Ti), RTX 8000, RTX A5000, RTX A6000, Tesla V100, A10, A100, H100.

The default images for the GPU-enabled tools in Nendo use the **`nvcr.io/nvidia/pytorch:22.08-py3`** image which is based on **`CUDA 11.7.1`** and requires **`NVIDIA Driver release 515`**. Depending on your hardware setup, it might be necessary to build Nendo's tools with another nvidia container toolkit image as base. Refer to the [nvidia frameworks support matrix](https://docs.nvidia.com/deeplearning/frameworks/support-matrix/index.html) to find the right base image and tag for your hardware and make sure to use a version that includes `pytorch`. Then, replace the image and tag at the top of `build/core/3.8-gpu/Dockerfile` with the one that fits your system and call `make build-tools-gpu`.


## Quickstart

Everything can be controlled using `make`. To get an overview of the available commands, just call it directly:

```bash
make
```

Before you start Nendo for the first time, you have to build the images:

```bash
make setup
```

Then you can start Nendo Platform by simply calling:

```bash
make run
```

Now start your browser and navigate to `http://localhost` to view the Nendo Platform.

The default username / password combination for the dev superuser is:

> **Username**: `dev@okio.ai`

> **Password**: `AIaudio4all!`

To change the password of the default user, refer to the [server deployment section](#server-deployment).

### CPU mode

If your machine does not have a GPU, you can run Nendo Platform in CPU-only mode.

First, build the CPU-mode images:

```bash
make setup-cpu
```

Then start Nendo by calling:

```bash
make run-cpu
```

> **Note**: Many of the AI capabilities of a Nendo Platform require a GPU to run properly or at all. Expect most tools to fail in CPU-only mode.


## Server deployment

To deploy Nendo Platform to your server, you need to set a few configuration variables before starting the server. 

First, you should decide whether or not you'd like to have SSL enabled. **Running Nendo Platform on a server without SSL enabled is strongly discouraged for security reasons.** The default is to have SSL enabled so you need to configure the correct location of your SSL certificate and private key:

```bash
export SSL_CERTIFICATE_PATH=/path/to/my/certificate.crt
export SSL_KEY_PATH=/path/to/my/key.key
```

Alternatively, you can create the local directory `./cert` and add your certificate and key as `./conf/nginx/certs/nendo.crt` and `./conf/nginx/certs/nendo.key` and it will be picked up without the need to specify the above environment variables.

If you want to run Nendo Platform on your server without SSL enabled, you can skip defining the above environment variables and instead just set `USE_SSL` to `false`:

```bash
export USE_SSL=false
```

Set the DNS domain or IP address on which your server is listening. Make sure to differentiate between `https://` and `http://` depending on whether you have SSL enabled.

```bash
# if your server has a domain name:
export SERVER_URL=https://my-nendo-server.com
# OR, if your server has only an IP address:
export SERVER_URL=https://192.168.0.1
```

When everything is configured according to your setup, simply use `make run` again to start the stack, open your browser and navigate to your domain / IP address to start using Nendo Platform.

Finally, change the password of the default user:

```bash
make set-password NEW_PASSWORD=mynewpassword
```

## Development

> **Warning**: Development mode is unsecure and should only be used in local environments.

Nendo Platform comes with a _development mode_ in which the Nendo Web frontend and the Nendo API Server are started with debugging output and hot-reloading enabled.

First, build the development-mode images:

```bash
make setup-dev
```

Then start Nendo by calling:

```bash
make run-dev
```

> **Note**: The hot-reloading only works with changes that are done to the application code, i.e. code that resides in the `nendo_server/` subdirectory of `nendo-server` and in the `src/` subdirectory of `nendo-web` accordingly. All changes to files outside those directories require [rebuilding of the images, as explained below](#building).

Now you can start developing your app by changing files in the `repo/nendo-server` and `repo/nendo-web` directories.

### Tool development

Tools also come with _development mode_ in which Nendo core and its plugins built into them from directories instead of by installing them directly from pypi. If you have used `make setup-dev`, you should see the directory `build/dependencies/` which contains Nendo core and all the plugins used in the platform. Now you can make modifications to in those directories and then call `make build-tools-gpu-dev` (GPU mode) or `make build-tools-cpu` (CPU mode) to build them into the tools and have them available in the platform upon calling `make run-dev`.

> **Note**: Since tools use pre-built docker images, you have to explicitly build the changes made to Nendo core or any of its plugins into the images. Hot-reloading is not supported here and will not be supported in the future. 

### Building

If you end up changing something about `nendo-server` or `nendo-web` that requires (re-)building of the images, you should use the respective `make` commands for that. To build both images (server _and_ web):

```bash
make build-dev
```

To only build `nendo-server`:

```bash
make server-build
# OR, for development mode
make server-build-dev
```

To only build `nendo-web`:

```bash
make web-build
# OR, for development mode
make web-build-dev
```

### Updating

To get the latest version of all involved repos and packages, use:

```bash
make update
```

Then you need to rebuild the stack:

```bash
make build
# OR, for development mode
make build-dev
```

### Resetting

To completely erase the database and all associated audio files in the library, make sure the Nendo Platform is running and then call:

```bash
make flush
```

**CAUTION: This will erase all data in your database and all audio files in the `library/` folder. Make sure you understand the consequences before executing this command.**

### Debugging

To get the logs of the `nendo-server` docker container:

```bash
make server-logs
```

To get the logs of the `nendo-web` docker container:

```bash
make web-logs
```

To get a shell into the running `nendo-server` container:

```bash
make server-shell
```

To get a shell into the running `nendo-web` container:

```bash
make web-shell
```

## Troubleshooting

### I added/updated a package in `nendo-web` but it won't update the app

This is due to docker build caching. When chaning `package.json`, run once:

```bash
rm repo/nendo-web/package-lock.json repo/nendo-web/node_modules
make web-build-dev
```

To update the image.

### The building of `nendo-server` fails with a checksum error

Try to build from scratch by first removing the existing image and clearing the docker build cache:

```bash
docker image rm nendo-server
docker builder prune
make server-build
```

### I started Nendo but when I try to log in, I get the error `Error logging in: {}`

Most likely, Nendo has not fully booted up yet. To check, run `make server-logs` and verify that you see the line `INFO Application startup complete.`. Then try to log in again. 

### When I start Nendo, the server fails to build with `UID 0 is not unique`

When you encounter the following error during startup of Nendo:

```bash
=> ERROR [server-dev nendo-server-base 6/16] RUN useradd nendo --create-home -u 0 -g 0 -m -s /bin/bash 0.3s
0.318 useradd: UID 0 is not unique
```

Then you most likely tried to run the `make build` or `make run` as the `root` user or are using `sudo` to run it. This is not supported by Nendo. Please make sure you run any of the `make` commands as a non-root user and also make sure that the user you are running the commands with is in the `docker` group. To verify that, check the output of the `id` command and make sure you see `(docker)` there. Then proceed to run your `make` calls without `sudo`.

### When I try to run a tool, I get a CUDA version mismatch error

Make sure you are using the right version of the NVIDIA container toolkit images for your hardware. Refer to the [GPU requirements section](#gpu-compatibility) for more information.

### I have updated Nendo a few times and now Docker is using a lot of disk space

Upon rebuilding the images with newer versions of the Nendo platform a few times, docker can quickly start taking up a lot of disk space. What helps in these situations is to call `docker system prune`.
