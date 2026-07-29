SHELL=/bin/bash

# COLOR
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
MAGENTA = \033[0;35m
CYAN = \033[0;36m
WHITE = \033[0;37m

# BOLD COLOR
BOLD_RED = \033[1;31m
BOLD_GREEN = \033[1;32m
BOLD_YELLOW = \033[1;33m
BOLD_BLUE = \033[1;34m
BOLD_CYAN = \033[1;36m

# RESET
NC = \033[0m

.PHONY: all copy deps

all: copy deps
	@echo -e "$(GREEN)✓ FINISHED$(NC) (look at the $(RED)⚠ [WARN]$(NC))"

deps:
	@echo -e "For the project to run you should install deps"
	@echo -ne "Run 'sudo apt update && sudo apt install docker.io docker-compose make' ? [Y/n] " && read A && if [[ $$A == "Y" ]] || [[ $$A == "y" ]] || [[ $$A == "" ]]; then sudo apt update && sudo apt install docker.io docker-compose make; else echo -e "$(RED)[WARN]$(NC) Install manually docker.io docker-compose make"; fi
	@echo -e "$(RED)[WARN]$(NC) If you just installed docker you should add your user to the docker group"

copy:
	@echo -e "$(CYAN)────────────────────────────────────────────────────────$(NC)"
	@echo -e "$(BLUE)Copying .env and secrets files...$(NC)"
	@echo ""
	cp ../srcs/.env.exemple ../srcs/.env
	cp ../secrets/.db_password.exemple ../secrets/.db_password
	@echo ""
	@echo -e "$(RED)[WARN]$(NC) You should change all the 'CHANGEME' in .env and secrets files"
	@echo -e "$(CYAN)────────────────────────────────────────────────────────$(NC)"