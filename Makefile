.PHONY: dist
dist: dist/mocha-when-then.js

dist/%.js: src/%.coffee
	coffee --compile --print $< > $@

.PHONY: test prepublish precommit
test: dist
	node_modules/.bin/mocha test


prepublish: test
	@# Check for uncommited files
	@(git diff --exit-code --no-patch \
    && git diff --cached --exit-code --no-patch) \
		|| (echo "There are uncommited files" && false)

	@# Version should not have -dev postfix
	@if grep --quiet '"version": .*-dev' package.json; \
	 then echo "Found development version"; false; fi

	git tag "v${npm_package_version}"

precommit: dist
	git add $<
