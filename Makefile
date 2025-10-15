SHELL := /bin/bash

.PHONY: up down logs backup restore-drill verify

up:
	cd compose && docker compose up -d

down:
	cd compose && docker compose down

logs:
	cd compose && docker compose logs -f

backup:
	bash scripts/backup.sh

restore-drill:
	bash scripts/restore_drill.sh

verify:
	docker exec kopia sh -lc 'kopia maintenance run --quick && kopia snapshots list'
