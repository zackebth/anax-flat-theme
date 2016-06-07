#!/usr/bin/make -f
#
#

# Colors
NO_COLOR		= \033[0m
TARGET_COLOR	= \033[32;01m
OK_COLOR		= \033[32;01m
ERROR_COLOR		= \033[31;01m
WARN_COLOR		= \033[33;01m
ACTION			= $(TARGET_COLOR)--> 

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



# target: help           - Displays help.
.PHONY:  help
help:
	@echo "$(ACTION)Displaying help for this Makefile.$(NO_COLOR)"
	@echo "Usage:"
	@echo " make [target] ..."
	@echo "target:"
	@egrep "^# target:" Makefile | sed 's/# target: / /g'



# target: prepare-build  - Clear and recreate the build directory.
.PHONY: prepare-build
prepare-build:
	@echo "$(ACTION)Preparing the build directory$(NO_COLOR)"
	install -d build/css build/lint



# target: clean          - Remove all generated files.
.PHONY:  clean
clean:
	@echo "$(ACTION)Remove all generated files$(NO_COLOR)"
	rm -rf build
	rm -f npm-debug.log



# target: clean-all      - Remove all installed files.
.PHONY:  clean-all
clean-all: clean
	@echo "$(ACTION)Remove all installed files$(NO_COLOR)"
	rm -rf node_modules



# target: less         - Compile and minify the stylesheet.
.PHONY: less
less: prepare-build
	@echo "$(ACTION)Compiling LESS stylesheet$(NO_COLOR)"
	lessc $(LESS_OPTIONS) $(LESS) build/css/style.css
	lessc --clean-css $(LESS_OPTIONS) $(LESS) build/css/style.min.css
	cp build/css/style*.css htdocs/css/



# target: less-install - Compile the stylesheet and update the site with it.
.PHONY: less-install
less-install: less
	@echo "$(ACTION)Installing LESS stylesheet$(NO_COLOR)"
	if [ -d ../htdocs/css/ ]; then cp build/css/style.min.css ../htdocs/css/style.min.css; fi
	if [ -d ../htdocs/js/ ]; then rsync -a js/ ../htdocs/js/; fi



# target: less-lint    - Lint the less stylesheet.
.PHONY: less-lint
less-lint: less
	@echo "$(ACTION)Linting LESS/CSS stylesheet$(NO_COLOR)"
	lessc --lint $(LESS_OPTIONS) $(LESS) > build/lint/style.less
	- csslint $(CSSLINT_OPTIONS) build/css/style.css > build/lint/style.css
	ls -l build/lint/



# target: test       - Execute all tests.
.PHONY: test
test: less-lint



# target: update     - Update codebase including submodules.
.PHONY: update
update:
	git pull
	git pull --recurse-submodules && git submodule foreach git pull origin master



# target: npm-install - Install npm development packages.
# target: npm-update  - Update npm development packages.
# target: npm-version - Display version for each package.
.PHONY: npm-installl npm-update npm-version
npm-install: 
	@echo "$(ACTION)npm install$(NO_COLOR)"
	npm install

npm-update: 
	@echo "$(ACTION)npm update$(NO_COLOR)"
	npm update

npm-version:
	@echo "$(ACTION)Versions for npm tools$(NO_COLOR)"
	$(NPMBIN)/lessc --version
	$(NPMBIN)/csslint --version
