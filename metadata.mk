# Ontology ID (lowercase)
ONTID := doid

# Version of ROBOT to use
ROBOT_VRS := 1.9.5

# product to display as <ONTID>.owl
# options: 'reasoned' or 'full' (i.e. reasoned + imports merged)
DEFAULT_PRODUCT := reasoned

# suffix to append to full/merged file
# options: 'full' or 'merged'
FULL_SUFFIX := merged

# List import ontology IDs with build rules (i.e. automated with ROBOT)
IMPS := chebi cl eco foodon geno hp ncbitaxon ro so symp trans uberon

# List import ontology IDs that are updated manually, used solely for versioning
MANUAL_IMPS := disdriv omim_susc

# Release directory (and optional second directory for publishing release)
RELEASE_DIR := src/ontology
PUBLISH_DIR := $(RELEASE_DIR)/releases

# Dataset directory
DATASET_DIR := DOreports

# Verify products in directory
VERIFY_DIR := $(RELEASE_DIR)