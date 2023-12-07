# This file includes variables that are used by more than one Makefile in this
# repository.

# Extract the versionIRI from pre-opened OWL file (works for local & remote
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

# Check for the latest version of an OBO Foundry ontology and, if newer than
# the last check, saves it to a corresponding .version file (requires internet).
#
# Expects the following inputs (in order):
# 1. <ontology>.version - should also be the rule target
# 2. <ontology_IRI> - must be .owl or owl.gz file
#
# Example: $(call which_latest,build/hp.version,http://purl.obolibrary.org/obo/hp.owl)
#
# NOTE:
# IRI must point to OWL (RDF/XML) formatted file (optionally gzipped with .gz ending)
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

# Concatenate files
#
# Expects the following inputs (in order):
# 1. Path for desired concatenated file.
# 2. List of files to concatenate, possibly as a wildcard recognized by ls.
# 4. Whether input files should be deleted, true or false.
#
# Example: $(call concat_files,build/reports/quarter_test.csv,$(wildcard build/reports/temp/verify-quarterly-*.csv,true)
define concat_files
	@TMP_FILES=$$(ls $(2)) ; \
	 if [ "$$TMP_FILES" ]; then \
		awk 'BEGIN { OFS = FS = "," } ; { \
			if (FNR == 1) { \
				if (NR != 1) { print "" } ; \
				print "TEST: " FILENAME ; print $$0 \
			} \
			else { print $$0 } \
		}' $$TMP_FILES > $(1) && \
		if [[ $$? -eq 0 && $(3) ]]; then rm -f $$TMP_FILES ; fi ; \
	 fi ;
endef
