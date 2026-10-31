##
## @khalidbelk, 2026
## File description:
## Makefile
##

## Sub-makes like the generated Makefile's '$(MAKE) lock'
## read this file first. This forces them to use the generated Makefile instead.
ifneq ($(MAKELEVEL),0)
	include Makefile
else

## Colors
GREEN=\033[0;32m
RESET=\033[0m
##

NAME = httpcodes
TARGET ?= unix

all: $(NAME)

configure:
	@mirage configure -t ${TARGET}

deps: configure
	@echo "${GREEN}Installing dependencies...${RESET}"
	@$(MAKE) -f Makefile depends

$(NAME): deps
	@echo "${GREEN}Building${RESET} $(NAME)..."
	@$(MAKE) -f Makefile build
	@echo "${GREEN}✔ Done.${RESET}"

watch:
	@echo "${GREEN}Starting watcher...${RESET}"
	@dune build -w dist

# The "|| true" is there just to hide the "make: *** [format] Error 1"
# thrown by the 'dune fmt' when it detects some changes to be made
format:
	@dune fmt --auto-promote || true

clean:
	@echo "Cleaning..."
	@mirage clean

fclean: clean

re: fclean all

.PHONY: all configure deps format watch clean fclean re

endif