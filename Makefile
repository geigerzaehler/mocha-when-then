.PHONY: dist
dist: dist/mocha-when-then.js

dist/%.js: src/%.coffee
	coffee --compile --print $< > $@

.PHONY: test prepublish precommit
test: dist
	node_modules/.bin/mocha test

prepublish: test
	git tag "v${npm_package_version}"

precommit: dist
	git add $<
