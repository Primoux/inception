SHELL=/bin/bash
.PHONY: all copy

all: copy deps
	@echo "FINISHED (look at the [WARN])"

deps:
	@echo "For the project to run you should install deps"
	@echo -n "Run 'sudo apt update && apt install docker.io docker-compose make' ? [Y/n]" && read A &&  if [[ $$A == "Y" ]] || [[ $$A == "y" ]] || [[ $$A == "" ]]; then sudo apt update && sudo apt install docker.io docker-compose make ;else echo "[WARN]Install manually dokcer.io docker-compose make"; fi
	@echo "[WARN]If you just installed docker you should look to add your user to the docker group"

copy:
	@echo "-------------------------------------------------------------------------"
	@echo "Copying .env and secrets files..."
	@echo ""
	cp ../srcs/.env.exemple ../srcs/.env
	cp ../secrets/.db_password.exemple ../secrets/.db_password
	@echo ""
	@echo "[WARN]You should change all the 'CHANGEME' in the .env and the secrets files"
	@echo "-------------------------------------------------------------------------"
