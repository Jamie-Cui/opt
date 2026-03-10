.PHONY: help repo repo-clean font font-clean

# Read FONT_SIZE from config.toml [dotfiles] section; default to 10 if absent.
# Override on the command line: make font FONT_SIZE=12
# Templates use @FONT_SIZE@ placeholder (autoconf convention)
FONT_SIZE ?= $(shell awk -F'=' '/^\[dotfiles\]/{s=1} s && /^font_size/{match($$2, /[0-9]+/); print substr($$2, RSTART, RLENGTH); exit}' config.toml)
FONT_SIZE ?= 10

# ── Help ─────────────────────────────────────────────────────────────────────

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Dotfiles font size: $(FONT_SIZE)  (edit [dotfiles] font_size in config.toml to change)"

# ── Repository management ─────────────────────────────────────────────────────

repo: ## Clone all repositories defined in config.toml
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) _update_gitignore
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) _clone_repos

_update_gitignore:
	@{ \
	awk -F'"' '/^dir/ {print $$2}' config.toml | while read dir; do \
		if [ -n "$$dir" ]; then \
			grep -qx "$$dir" .gitignore 2>/dev/null || echo "$$dir"; \
		fi \
	done; \
	} >> .gitignore

_clone_repos:
	@set -e; \
	_temp_script=$$(mktemp); \
	{ \
	echo "while IFS= read -r line; do"; \
	echo '  case "$$line" in'; \
	echo '    "[repo."*)'; \
	echo '      if [ -n "$$url" ] && [ -n "$$dir" ]; then'; \
	echo '        cloned=false'; \
	echo '        if [ -d "$$dir/.git" ]; then'; \
	echo '          echo "✓ $$repo already cloned at $$dir"'; \
	echo '        else'; \
	echo '          echo "→ Cloning $$repo to $$dir..."'; \
	echo '          mkdir -p "$$(dirname "$$dir")"'; \
	echo '          clone_args="$$url $$dir"'; \
	echo '          if [ -n "$$tag" ]; then'; \
	echo '            clone_args="--branch $$tag $$clone_args"'; \
	echo '          elif [ -n "$$branch" ]; then'; \
	echo '            clone_args="--branch $$branch $$clone_args"'; \
	echo '          fi'; \
	echo '          if [ -n "$$depth" ]; then clone_args="--depth $$depth $$clone_args"; fi'; \
	echo '          echo "  git clone $$clone_args"'; \
	echo '          git clone $$clone_args'; \
	echo '          cloned=true'; \
	echo '          if [ -n "$$commit" ]; then'; \
	echo '            echo "  Checking out commit $$commit..."'; \
	echo '            git -C "$$dir" checkout -q "$$commit"'; \
	echo '          fi'; \
	echo '        fi'; \
	echo '      fi'; \
	echo '      repo=$$(echo "$$line" | sed "s/\[repo\.//; s/\]//")'; \
	echo '      url=""; dir=""; depth=""; branch=""; tag=""; commit="";'; \
	echo '      ;;'; \
	echo '    "url ="*) url=$$(echo "$$line" | sed "s/url = \"//; s/\"$$//");;'; \
	echo '    "dir ="*) dir=$$(echo "$$line" | sed "s/dir = \"//; s/\"$$//");;'; \
	echo '    "depth ="*) depth=$$(echo "$$line" | sed "s/depth = //; s/\"$$//");;'; \
	echo '    "branch ="*) branch=$$(echo "$$line" | sed "s/branch = \"//; s/\"$$//");;'; \
	echo '    "tag ="*) tag=$$(echo "$$line" | sed "s/tag = \"//; s/\"$$//");;'; \
	echo '    "commit ="*) commit=$$(echo "$$line" | sed "s/commit = \"//; s/\"$$//");;'; \
	echo '  esac'; \
	echo 'done < config.toml'; \
	echo 'if [ -n "$$url" ] && [ -n "$$dir" ]; then'; \
	echo '  cloned=false'; \
	echo '  if [ -d "$$dir/.git" ]; then'; \
	echo '    echo "✓ $$repo already cloned at $$dir"'; \
	echo '  else'; \
	echo '    echo "→ Cloning $$repo to $$dir..."'; \
	echo '    mkdir -p "$$(dirname "$$dir")"'; \
	echo '    clone_args="$$url $$dir"'; \
	echo '    if [ -n "$$tag" ]; then'; \
	echo '      clone_args="--branch $$tag $$clone_args"'; \
	echo '    elif [ -n "$$branch" ]; then'; \
	echo '      clone_args="--branch $$branch $$clone_args"'; \
	echo '    fi'; \
	echo '    if [ -n "$$depth" ]; then clone_args="--depth $$depth $$clone_args"; fi'; \
	echo '    echo "  git clone $$clone_args"'; \
	echo '    git clone $$clone_args'; \
	echo '    cloned=true'; \
	echo '    if [ -n "$$commit" ]; then'; \
	echo '      echo "  Checking out commit $$commit..."'; \
	echo '      git -C "$$dir" checkout -q "$$commit"'; \
	echo '    fi'; \
	echo '  fi'; \
	echo 'fi'; \
	} > "$$_temp_script"; \
	sh "$$_temp_script"; \
	rm "$$_temp_script"

repo-clean: ## Remove all cloned repositories
	@awk -F'"' '/^dir/ {dir=$$2; system("rm -rf " dir)}' config.toml
	@echo "Cleaned all vendor directories"

# ── Dotfiles ──────────────────────────────────────────────────────────────────

font: ## Generate dotfiles from .in templates with FONT_SIZE from config.toml
	@find dotfiles -type f -name "*.in" -not -path "dotfiles/.git/*" \
		-exec sh -c 'for f; do out=$${f%.in}; sed "s/@FONT_SIZE@/$(FONT_SIZE)/g" "$$f" > "$$out"; done' _ {} \;
	@echo "Generated dotfiles with font_size=$(FONT_SIZE)"

font-clean: ## Remove generated dotfiles (restore to template-only state)
	@find dotfiles -type f -name "*.in" -not -path "dotfiles/.git/*" \
		-exec sh -c 'for f; do out=$${f%.in}; rm -f "$$out"; done' _ {} \;
	@echo "Cleaned generated dotfiles"
