# This file includes variables that are used by more than one Makefile in this
# repository.

# Extracts versionIRI from pre-opened OWL files (works for local & remote
# files). No input required.
#
# NOTES:
# 1. Reads stdin ONLY until it reaches the versionIRI -> req'd to avoid long
#	read time of large files (e.g. chebi).
# 2. The last `sed` replaces a custom XML entity (used in foodon) with the OBO
#	URI it represents (i.e. '&obo;' -> 'http://purl.obolibrary.org/obo/'),
#	see https://www.w3schools.com/xml/xml_dtd_entities.asp for bkgd info.
define extract_versionIRI
	sed -n '/owl:versionIRI/p;/owl:versionIRI/q' | \
	sed -E 's/.*"([^"]+)".*/\1/' | \
	sed 's|&obo;|http://purl.obolibrary.org/obo/|'
endef

# Checks for the latest version of an OBO Foundry ontology and, if newer than
# the last check, saves it to a corresponding .version file (requires internet).
#
# Expects the following inputs (in order):
# 1. <ontology>.version - should also be the rule target
# 2. <ontology_IRI> - must be .owl or owl.gz file
#
# NOTE:
# IRI must point to RDF/XML formatted file (optionally gzipped with .gz ending)
define which_latest
	if [[ $(2) = *".gz" ]]; then \
		LATEST=$$(curl -sLk $(2) | gzcat | $(extract_versionIRI)) ; \
	else \
		LATEST=$$(curl -sLk $(2) | $(extract_versionIRI)) ; \
	fi ; \
	if [[ -f $(1) ]]; then \
		SRC_VERS=$$(sed '1q' $(1)) ; \
		if [[ $${SRC_VERS} != $${LATEST} ]]; then \
			echo $${LATEST} > $(1) ; \
		fi ; \
	else \
		echo $${LATEST} > $(1) ; \
	fi
endef
