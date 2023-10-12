# Create skos:exactMatch from all existing xrefs
#
# This is a flexbile query that cannot be used directly.
# To use it replace the placeholders (bounded by !<< and >>!) with the
# appropriate values. If all xrefs are to be converted to skos:exactMatch
# delete the VALUES ?mapping line entirely.
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX DOID: <http://purl.obolibrary.org/obo/DOID_>

INSERT { ?class skos:exactMatch ?mapping . }
WHERE {
	VALUES ?class { !<<class_curies>>! }
	VALUES ?mapping { !<<xref_strings>>! }
	?class oboInOwl:hasDbXref ?mapping .
}