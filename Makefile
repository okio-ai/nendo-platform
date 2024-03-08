.PHONY: init init-dev setup setup-dev setup-cpu all flush build build-dev server-build web-build web-build-dev build-tools-gpu build-tools-gpu-dev build-tools-cpu server-logs web-logs server-shell web-shell run run-dev run-cpu stop update set-password invite-codes

all: help

docker_gid := $(shell grep docker /etc/group | cut -d: -f3 | if [ -z '$$(cat)' ]; then echo 999; else cat; fi)
uid := $(shell id -u)
gid := $(shell id -g)
@:$(eval USE_SSL=$(or $(USE_SSL),false))
@:$(eval SERVER_URL=$(or $(SERVER_URL),http://localhost))

init:
	cd ./scripts/ && ./init_env.sh && cd ..

init-dev:
	cd ./scripts/ && ./init_env.sh dev && cd ..

setup: init update build build-tools-gpu

setup-dev: init-dev update build-dev build-tools-gpu-dev

setup-cpu: init-dev update build-dev build-tools-cpu

flush:
	@docker ps | grep -q nendo-postgres || (echo "No running postgres detected. Please start Nendo before running this command." && exit 1)
	@/bin/bash -c 'read -p "Are you sure you want to delete all rows from the specified tables? [y/N] " confirm; \
	if [[ $$confirm == [yY] ]]; then \
		docker exec -i nendo-postgres psql -U nendo -d nendo -c "BEGIN; DELETE FROM embeddings; DELETE FROM collection_collection_relationships; DELETE FROM track_track_relationships; DELETE FROM track_collection_relationships; DELETE FROM plugin_data; DELETE FROM scenes; DELETE FROM collections; DELETE FROM tracks; COMMIT;"; \
		rm -rf library/*/*; \
	fi'

build-dev: server-build-dev web-build-dev

build: server-build web-build

server-build-dev:
	HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile dev build server-dev --build-arg UID=$(uid) --build-arg GID=$(gid) --build-arg DOCKER_GID=$(docker_gid)

server-build:
	HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile prod build server --build-arg UID=$(uid) --build-arg GID=$(gid) --build-arg DOCKER_GID=$(docker_gid)

web-build-dev:
	@echo Building with SERVER_URL=$(SERVER_URL)
	@HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile dev build --build-arg SERVER_URL=$(SERVER_URL) web-dev

web-build:
	@echo Building with SERVER_URL=$(SERVER_URL)
	@HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile prod build --build-arg SERVER_URL=$(SERVER_URL) web

build-tools-cpu:
	cd build && docker build -f Dockerfile.core --target dev-3.8-cpu --build-arg UID=$(uid) --build-arg GID=$(gid) -t nendo/core:3.8 .
	cd build && docker build -f Dockerfile.voiceanalysis --target dev-cpu -t nendo/voiceanalysis .
	cd build && docker build -f Dockerfile.polymath --target dev -t nendo/polymath .
	cd build && docker build -f Dockerfile.quantize --target dev -t nendo/quantize .
	cd build && docker build -f Dockerfile.webimport --target dev -t nendo/webimport .

build-tools-gpu:
	cd build && docker build -f Dockerfile.core --target prod-3.8-gpu --build-arg UID=$(uid) --build-arg GID=$(gid) -t nendo/core:3.8 .
	cd build && docker build -f Dockerfile.musicanalysis --target prod -t nendo/musicanalysis .
	cd build && docker build -f Dockerfile.voiceanalysis --target prod -t nendo/voiceanalysis .
	cd build && docker build -f Dockerfile.polymath --target prod -t nendo/polymath .
	cd build && docker build -f Dockerfile.quantize --target prod -t nendo/quantize .
	cd build && docker build -f Dockerfile.voicegen --target prod -t nendo/voicegen .
	cd build && docker build -f Dockerfile.musicgen --target prod -t nendo/musicgen .
	cd build && docker build -f Dockerfile.webimport --target prod -t nendo/webimport .

build-tools-gpu-dev:
	cd build && docker build -f Dockerfile.core --target dev-3.8-gpu --build-arg UID=$(uid) --build-arg GID=$(gid) -t nendo/core:3.8 .
	cd build && docker build -f Dockerfile.musicanalysis --target dev -t nendo/musicanalysis .
	cd build && docker build -f Dockerfile.voiceanalysis --target dev-gpu -t nendo/voiceanalysis .
	cd build && docker build -f Dockerfile.polymath --target dev -t nendo/polymath .
	cd build && docker build -f Dockerfile.quantize --target dev -t nendo/quantize .
	cd build && docker build -f Dockerfile.voicegen --target dev -t nendo/voicegen .
	cd build && docker build -f Dockerfile.musicgen --target dev -t nendo/musicgen .
	cd build && docker build -f Dockerfile.webimport --target dev -t nendo/webimport .

server-logs:
	docker logs nendo-server

web-logs:
	docker logs nendo-web

server-shell:
	docker exec -it nendo-server /bin/bash 

web-shell:
	docker exec -it nendo-web /bin/bash

run-dev:
	@echo Running with HOST_CWD=$(shell pwd), USE_GPU=$(USE_GPU)
	$(MAKE) stop
	@if [ -z "$$(docker images -q nendo-server)" ] || [ -z "$$(docker images -q nendo-web)" ]; then \
        echo "One or both images not found. Running setup..."; \
        $(MAKE) setup; \
    else \
        echo "Both images found. Running application..."; \
    fi
	@HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile dev up

run-cpu:
	@echo Running with HOST_CWD=$(shell pwd), USE_GPU=false
	$(MAKE) stop
	@if [ -z "$$(docker images -q nendo-server)" ] || [ -z "$$(docker images -q nendo-web)" ]; then \
        echo "One or both images not found. Running setup..."; \
        $(MAKE) setup-cpu; \
    else \
        echo "Both images found. Running application..."; \
    fi
	@HOST_CWD=$(shell pwd) USE_GPU=false docker compose -p nendo-platform --profile dev up

run:
	@echo Running with HOST_CWD=$(shell pwd)
	$(MAKE) stop
	@if [ -z "$$(docker images -q nendo-server)" ] || [ -z "$$(docker images -q nendo-web)" ]; then \
        echo "One or both images not found. Running setup..."; \
        $(MAKE) setup; \
    else \
        echo "Both images found. Running application..."; \
    fi
	@if [ "$(USE_SSL)" = "false" ]; then \
		echo "Running insecure mode (no SSL)"; \
		PROFILE=prod-http; \
	else \
		echo "Running with SSL"; \
		PROFILE=prod; \
	fi; \
	HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile $$PROFILE up -d

stop:
	@HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile dev down; \
	HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile prod-http down; \
	HOST_CWD=$(shell pwd) docker compose -p nendo-platform --profile prod down

update:
	git pull
	cd repo/nendo-server && git pull
	cd repo/nendo-web && git pull

update-tools-dev:
	cd build/dependencies/nendo && git pull
	cd build/dependencies/nendo_plugin_library_postgres && git pull
	cd build/dependencies/nendo_plugin_quantize_core && git pull
	cd build/dependencies/nendo_plugin_classify_core && git pull
	cd build/dependencies/nendo_plugin_loopify && git pull
	cd build/dependencies/nendo_plugin_stemify_demucs && git pull
	cd build/dependencies/nendo_plugin_musicgen && git pull
	cd build/dependencies/nendo_plugin_voicegen_styletts2 && git pull
	cd build/dependencies/nendo_plugin_textgen && git pull
	cd build/dependencies/nendo_plugin_import_core && git pull
	cd build/dependencies/nendo_plugin_embed_clap && git pull
	cd build/dependencies/nendo_plugin_caption_lpmusiccaps && git pull
	cd build/dependencies/nendo_plugin_transcribe_whisper && git pull

set-password:
	$(if $(NEW_PASSWORD),,@echo "NEW_PASSWORD is not set. Use 'make set-password NEW_PASSWORD=mynewpassword' to set it." && exit 1)
	@docker cp ./scripts/changepw.py nendo-server:/home/nendo && docker exec nendo-server python /home/nendo/changepw.py $(NEW_PASSWORD) > /dev/null 2>&1
	@docker exec nendo-server rm /home/nendo/changepw.py

invite-codes:
	@docker cp scripts/invcodes.sql nendo-postgres:/root
	@docker exec nendo-postgres psql -U nendo -d nendo -f /root/invcodes.sql
	@docker exec nendo-postgres psql -U nendo -d nendo -c 'SELECT * FROM user_invite_code'

help:
	@echo '==================='
	@echo '-- DOCUMENTATION --'
	@echo 'init                   - initialize the environment'
	@echo 'init                   - initialize the environment (development mode)'
	@echo 'setup                  - prepare the environment'
	@echo 'setup-dev              - prepare the development environment'
	@echo 'setup-cpu              - prepare the development environment (CPU-only)'
	@echo 'flush                  - flush the database and delete all files in the default user library'
	@echo 'build                  - build all images'
	@echo 'build-dev              - build all images for development'
	@echo 'server-build           - build nendo-server'
	@echo 'server-build-dev       - build nendo-server in development mode'
	@echo 'server-logs            - get the docker logs for nendo-server'
	@echo 'server-shell           - get a shell into nendo-server'
	@echo 'web-build              - build nendo-web'
	@echo 'web-build-dev          - build nendo-web in development mode'
	@echo 'web-logs               - get the docker logs for nendo-web'
	@echo 'web-shell              - get a shell into nendo-web'
	@echo 'build-tools-gpu        - build nendo tools (GPU enabled)'
	@echo 'build-tools-gpu-dev    - build nendo tools (GPU enabled, development mode)'
	@echo 'build-tools-cpu        - build nendo tools (CPU-only, development mode)'
	@echo 'run                    - run Nendo Platform'
	@echo 'run-dev                - run Nendo Platform in development mode with hot-reloading'
	@echo 'run-cpu                - run Nendo Platform in development mode with hot-reloading (CPU mode)'
	@echo 'stop                   - stop any running instances'
	@echo 'set-password           - set a new password for the default nendo user'
	@echo 'update                 - update development dependencies'
	@echo 'invite-codes           - Create 100 invite codes in the database and print them to the console'
	@echo '==================='
