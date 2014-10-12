.PHONY: dist
dist: dist/mocha-when-then.js

dist/%.js: src/%.coffee
	coffee --compile --print $< > $@

.PHONY: test
test: dist
	npm test
