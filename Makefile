.PHONY: clean atom

readrof:
	stack build

clean:
	stack clean

atom:
	stack exec atom .
