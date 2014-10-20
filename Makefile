VERSION=$(shell node -e 'console.log(require("./package.json")["version"])')


.PHONY: dist
dist: dist/mocha-when-then.js dist/browser-bundle.js

dist/browser-bundle.js:
	node_modules/.bin/browserify \
		--transform coffeeify \
		--require ./src/global-mocha:mocha \
		--require es5-shim \
		src/mocha-when-then.coffee \
		--standalone mocha-when-then \
		--outfile $@

dist/%.js: src/%.coffee
	coffee --compile --print $< > $@



.PHONY: test publish precommit
test: dist
	node_modules/.bin/mocha test

publish: test assert-clean-tree assert-proper-version
	git tag "v${VERSION}"
	npm publish

precommit: dist
	git add $<



.PHONY: assert-clean-tree
assert-clean-tree:
	@(git diff --exit-code --no-patch \
    && git diff --cached --exit-code --no-patch) \
		|| (echo "There are uncommited files" && false)

.PHONY: assert-proper-version
assert-proper-version:
	@if echo "${VERSION}" | grep --quiet '.*-dev'; \
	 then echo "Found development version" && false; fi
