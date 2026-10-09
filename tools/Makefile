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
	@echo -e "$(BLUE)→ Creating env and secrets files...$(NC)"
	@if [ -f ../srcs/.env ]; then \
		echo -e "$(CYAN)[SKIP]$(NC) srcs/.env already exists"; \
	else \
		cp ../srcs/.env.exemple ../srcs/.env && echo -e "$(GREEN)✓ Created$(NC) srcs/.env"; \
	fi
	@for f in secrets/.db_password secrets/.db_root_password secrets/.wp_password_admin secrets/.wp_password_user; do \
		if [ -f ../$$f ]; then \
			echo -e "$(CYAN)[SKIP]$(NC) $$f already exists"; \
		else \
			(umask 077 && tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 24 > ../$$f) && echo -e "$(GREEN)✓ Generated$(NC) $$f (random password)"; \
		fi; \
	done
	@echo -e "$(RED)[WARN]$(NC) Update the 'CHANGEME' values in srcs/.env (secrets are already random)"
	@echo -e "$(RED)[WARN]$(NC) The WordPress admin password is in secrets/.wp_password_admin"
