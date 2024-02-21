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

## Requirements

To run Nendo Platform on Unix-based systems, make sure you have `docker` and `docker-compose` (`>=1.28.0`) installed. Make sure the user with which you intend to run Nendo Platform is a member of the `docker` group, otherwise the `make` commands will fail with `permission denied`.

> **Note**: Nendo Platform needs a GPU with at least 24 GB of VRAM for all of its features to work properly. If your system does not have a GPU available, you can still run Nendo Platform in [CPU mode](#cpu-mode) but expect certain tools to fail.

## Quickstart

Everything can be controlled using `make`. To get an overview of the available commands, just call it directly:

```bash
make
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

If your machine does not have a GPU, you can run Nendo Platform in CPU-only mode:

```bash
make setup-cpu
make run-cpu
```

> **Note**: Many of the AI capabilities of a Nendo Platform require a GPU to run properly or at all. Expect most tools to fail in CPU-only mode.

### Development mode

To run Nendo Platform in development mode, call:

```bash
make run-dev
```

> **Warning**: Development mode is unsecure and should only be used in local environments.

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

To start Nendo Platform in development mode, run:

```bash
make run-dev
```

This will run Nendo Platform in development mode with more verbose logging and hot-reloading of components upon code changes.

> **Note**: The hot-reloading only works with changes that are done to the application code, i.e. code that resides in the `nendo_server/` subdirectory of `nendo-server` and in the `src/` subdirectory of `nendo-web` accordingly. All changes to files outside those directories require [rebuilding of the images, as explained below](#building).

Now you can start developing your app by changing files in the `repo/nendo-server` and `repo/nendo-web` directories.

### Building

If you end up changing something about `nendo-server` or `nendo-web` that requires (re-)building of the images, you should use the respective `make` commands for that. To build both images (server _and_ web):

```bash
make build
```

To only build `nendo-server`:

```bash
make server-build
# OR
make server-build-dev
```

To only build `nendo-web`:

```bash
make web-build
# OR
make web-build-dev
```

### Updating

To get the latest version of all involved repos and packages, use:

```bash
make update-dependencies
```

Then, in many cases, you need to rebuild the stack:

```bash
make build
# OR
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
