.PHONY: help list install

SKILLS := create-ticket start-ticket ticket-markdown
AGENTS ?= opencode codex claude-code
SOURCE := .

help:
	@printf "Local skill install commands (no remote git repo required)\n\n"
	@printf "Usage:\n"
	@printf "  make list\n"
	@printf "  make install SKILL=<skill-name>\n\n"
	@printf "Examples:\n"
	@printf "  npx skills add %s -g --skill create-ticket --agent %s -y\n" "$(SOURCE)" "$(AGENTS)"
	@printf "  npx skills add %s -g --skill ticket-markdown --agent %s -y\n\n" "$(SOURCE)" "$(AGENTS)"
	@printf "Available skills:\n"
	@printf "  %s\n" $(SKILLS)

list:
	@printf "%s\n" $(SKILLS)

install:
	@test -n "$(SKILL)" || (printf "Set SKILL=<skill-name>.\\n" && exit 1)
	npx skills add $(SOURCE) -g --skill $(SKILL) --agent $(AGENTS) -y
