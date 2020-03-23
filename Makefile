#############################################################################################
# Build Documentation
#############################################################################################

NAME=`./setup.py --name`
VERSION=`./setup.py --version`

help:
	@echo "Documentation"
	@echo "  docs      : build sphinx documentation"
	@echo "  clean      : clean temporary directories"

docs:
	sphinx-build -E -b html doc doc/html

clean:
	-rm -rf doc/html

.PHONY: docs clean
