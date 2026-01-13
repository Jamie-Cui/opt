.PHONY: help repos clean

help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

repos: ## Clone all repositories defined in repo.toml
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) _update_gitignore
	@$(MAKE) --no-print-directory -f $(firstword $(MAKEFILE_LIST)) _clone_repos

_update_gitignore:
	@{ \
	awk -F'"' '/^dir/ {print $$2}' repo.toml | while read dir; do \
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
	echo 'done < repo.toml'; \
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

clean: ## Remove all cloned repositories
	@awk -F'"' '/^dir/ {dir=$$2; system("rm -rf " dir)}' repo.toml
	@echo "Cleaned all vendor directories"
