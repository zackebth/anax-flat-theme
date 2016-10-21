#!/usr/bin/make -f
#
#

# Colors and helptext
NO_COLOR	= \033[0m
ACTION		= \033[32;01m
OK_COLOR	= \033[32;01m
ERROR_COLOR	= \033[31;01m
WARN_COLOR	= \033[33;01m
HELPTEXT 	= /bin/echo -e "$(ACTION)--->" `egrep "^\# target: $(1) " Makefile | sed "s/\# target: $(1)[ ]\+- / /g"` "$(NO_COLOR)"

# Add local bin path for test tools
BIN 		= bin
VENDORBIN 	= vendor/bin
NPMBIN		= node_modules/.bin

# LESS and CSS
LESS 		 	= style.less
LESS_MODULES	= modules/
LESS_OPTIONS 	= --strict-imports --include-path=$(LESS_MODULES)
CSSLINT_OPTIONS = --quiet
FONT_AWESOME 	= modules/font-awesome/fonts/



# target: help               - Displays help.
.PHONY:  help
help:
	@$(call HELPTEXT,$@)
	@echo "Usage:"
	@echo " make [target] ..."
	@echo "target:"
	@egrep "^# target:" Makefile | sed 's/# target: / /g'



# target: prepare-build      - Clear and recreate the build directory.
.PHONY: prepare-build
prepare-build:
	@$(call HELPTEXT,$@)
	install -d build/css build/lint



# target: clean              - Remove all generated files.
.PHONY:  clean
clean:
	@$(call HELPTEXT,$@)
	rm -rf build
	rm -f npm-debug.log



# target: clean-all          - Remove all installed files.
.PHONY:  clean-all
clean-all: clean
	@$(call HELPTEXT,$@)
	rm -rf node_modules



# target: less               - Compile and minify the stylesheet.
.PHONY: less
less: prepare-build
	@$(call HELPTEXT,$@)
	$(NPMBIN)/lessc $(LESS_OPTIONS) $(LESS) build/css/style.css
	$(NPMBIN)/lessc --clean-css $(LESS_OPTIONS) $(LESS) build/css/style.min.css
	cp build/css/style*.css htdocs/css/



# target: less-install       - Installing the stylesheet.
.PHONY: less-install
less-install: less
	@$(call HELPTEXT,$@)
	if [ -d ../htdocs/css/ ]; then cp build/css/style.min.css ../htdocs/css/style.min.css; fi
	if [ -d ../htdocs/js/ ]; then rsync -a js/ ../htdocs/js/; fi



# target: less-lint          - Lint the less stylesheet.
.PHONY: less-lint
less-lint: less
	@$(call HELPTEXT,$@)
	$(NPMBIN)/lessc --lint $(LESS_OPTIONS) $(LESS) > build/lint/style.less
	- $(NPMBIN)/csslint $(CSSLINT_OPTIONS) build/css/style.css > build/lint/style.css
	ls -l build/lint/



# target: test               - Execute all tests.
.PHONY: test
test: less-lint
	@$(call HELPTEXT,$@)



# target: update             - Update codebase including submodules.
.PHONY: update
update:
	@$(call HELPTEXT,$@)
	git pull
	git pull --recurse-submodules && git submodule foreach git pull origin master



# target: npm-install        - Install npm development packages.
# target: npm-update         - Update npm development packages.
# target: npm-version        - Display version for each package.
.PHONY: npm-installl npm-update npm-version
npm-install: 
	@$(call HELPTEXT,$@)
	npm install

npm-update: 
	@$(call HELPTEXT,$@)
	npm update

npm-version:
	@$(call HELPTEXT,$@)
	$(NPMBIN)/lessc --version
	$(NPMBIN)/csslint --version
