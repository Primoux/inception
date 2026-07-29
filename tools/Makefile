SHELL=/bin/bash

RED = \033[0;31m
GREEN = \033[0;32m
BLUE = \033[0;34m
CYAN = \033[0;36m
NC = \033[0m

.PHONY: all copy deps

all: deps copy
	@echo -e "$(GREEN)✓ Setup finished$(NC)"

deps:
	@echo -e "$(BLUE)→ Checking dependencies...$(NC)"
	@echo -ne "Install docker.io, docker-compose, make? [Y/n] " && read A && if [[ $$A == [Yy] ]] || [[ $$A == "" ]]; then sudo apt update && sudo apt install -y docker.io docker-compose make && echo -e "$(GREEN)✓ Done$(NC)"; else echo -e "$(RED)[WARN]$(NC) Install manually"; fi
	@echo -ne "Add user to docker group? [Y/n] " && read B && if [[ $$B == [Yy] ]] || [[ $$B == "" ]]; then sudo usermod -aG docker $$USER && echo -e "$(GREEN)✓ Done$(NC) - restart shell"; else echo -e "$(RED)[WARN]$(NC) Run manually: $(CYAN)sudo usermod -aG docker $$USER$(NC)"; fi

copy:
	@echo -e "$(BLUE)→ Copying env files...$(NC)"
	cp ../srcs/.env.exemple ../srcs/.env
	cp ../secrets/.db_password.exemple ../secrets/.db_password
	@echo -e "$(RED)[WARN]$(NC) Update 'CHANGEME' values in .env and secrets files"