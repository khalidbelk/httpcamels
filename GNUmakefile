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

NAME = httpcamels
TARGET ?= unix

GMP_OLD = /usr/local/lib/libgmp.10.dylib
GMP_NEW = /opt/homebrew/lib/libgmp.10.dylib

all: $(NAME)

configure:
	@mirage configure -t $(TARGET) $(CONFIGURE_FLAGS)

deps: configure
	@echo "${GREEN}Installing dependencies...${RESET}"
	@$(MAKE) -f Makefile depends

js: deps
	@echo "${GREEN}Building the search script...${RESET}"
	@dune build --root . _build/default/client/search.bc.js
	@install -m 644 _build/default/client/search.bc.js static/assets/app/search.js

$(NAME): js
	@echo "${GREEN}Building${RESET} $(NAME)..."
	@$(MAKE) -f Makefile build
	@echo "${GREEN}✔ Done.${RESET}"

# Dev build for my Mac: host sockets (no /dev/net/tun) + relinked libgmp
macos: TARGET = unix
macos: CONFIGURE_FLAGS = --net host
macos: fix-gmp

fix-gmp: $(NAME)
	@install_name_tool -change $(GMP_OLD) $(GMP_NEW) dist/$(NAME) || true
	@codesign -f -s - dist/$(NAME)

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

.PHONY: all configure deps js macos fix-gmp format watch clean fclean re

endif