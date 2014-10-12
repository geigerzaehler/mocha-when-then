.PHONY: dist
dist: dist/mocha-steps.js

dist/%.js: src/%.coffee
	coffee --compile --print $< > $@

.PHONY: test
test: dist
	npm test
