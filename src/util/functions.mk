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

# Concatenate Tabular (CSV/TSV) files
#
# Expects the following inputs (in order):
# 1. Path for desired concatenated file.
# 2. List of space-separated files to concatenate, possibly one or more wildcards recognized by ls.
# 3. Whether input files should be deleted, true or false.
#
# Output will always be TSV
# Example: $(call concat_tbls,build/reports/quarter_test.csv,$(wildcard build/reports/temp/verify-quarterly-*.csv,true)
define concat_tbls
	@TMP_FILES=$$(ls $(2)) ; \
	 if [ "$$TMP_FILES" ]; then \
		if [[ "$$TMP_FILES" = *".csv" ]]; then SEP="," ; else SEP="\t"; fi ; \
		awk -v sep=$${SEP} 'BEGIN { FS = sep; OFS = "\t" } ; { \
			if (FNR == 1) { \
				if (NR != 1) { print "" } ; \
				print "TEST: " FILENAME ; print $$0 \
			} \
			else { print $$0 } \
		}' $$TMP_FILES > $(1) && \
		if [[ $$? -eq 0 && $(3) ]]; then rm -f $$TMP_FILES ; fi ; \
	 fi ;
endef

# Join Last/New Tabular (CSV/TSV) files
#
# Expects the following inputs (in order):
# 1. Delimiter of files ("," for CSV, "\t" for TSV; must be quoted).
# 2. Path to "last" file.
# 3. Path to "new" file.
# 4. Path for desired joined file.
#
# Output will always be TSV
# Example: $(call concat_tbls,",",build/reports/quarter_test.csv,$(wildcard build/reports/temp/verify-quarterly-*.csv,true)
define join_last_new
	@sed -i '' '1 s/count/new_count/' $(1)
	@sed -i '' '1 s/count/last_count/' $(2)
	@join $(1) $(2)
	@awk -F'","'  '{ print $2 - $3 }' filename.csv

endef

# Merge all but last column in Tabular (CSV/TSV) files
#
# Expects the following inputs (in order):
# 1. Delimiter of files ("," for CSV, "\t" for TSV; must be quoted).
# 2. Path to "last" file.
# 3. Path to "new" file.
# 4. Path for desired joined file.
#
# Output will always be TSV
# Example: $(call merge_cols,build/reports/DEL.tsv)
define merge_cols
	@if [[ $(1) = *".csv" ]]; then SEP="," ; else SEP="\t"; fi ; \
	awk -v sep=$${SEP} 'BEGIN { OFS = FS = sep } ; \
	{ \
		for (i=1; i<NF; ++i) { printf "%s|", $$i } ; \
		printf "%s%s\n",OFS,$$NF \
	}' $(1) > $(1).tmp && \
	mv $(1).tmp $(1)
endef

# awk 'BEGIN { OFS = FS "\t" } ; \
# { \
# 	for (i=1; i<NF; ++i) { printf "%s|", $i } ; \
# 	printf "%s%s\n",OFS,$NF \
# }' build/reports/DEL.tsv

# awk 'BEGIN { OFS = FS "\t" } ; {for (i=1; i<NF; ++i) { printf "%s|", $i } ; printf "%s%s\n",OFS,$NF }' build/reports/DEL.tsv