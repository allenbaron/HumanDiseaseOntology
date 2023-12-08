# ----------------------------------------
# ONTOLOGY METADATA
# ----------------------------------------

# Ontology ID (lowercase)
ONTID := doid

# product to display as <ONTID>.owl
# options: 'reasoned' or 'full' (i.e. reasoned + imports merged)
DEFAULT_PRODUCT := reasoned

# suffix to append to full/merged file
# options: 'full' or 'merged'
FULL_SUFFIX := merged

# Subsets to create as products during release
SUBSETS := DO_AGR_slim DO_FlyBase_slim DO_MGI_slim DO_GXD_slim \
 DO_cancer_slim TopNodes_DOcancerslim DO_CFDE_slim DO_IEDB_slim DO_RAD_slim \
 DO_rare_slim DO_infectious_disease_slim NCIthesaurus \
 GOLD gram-negative_bacterial_infectious_disease \
 gram-positive_bacterial_infectious_disease  \
 sexually_transmitted_infectious_disease tick-borne_infectious_disease \
 zoonotic_infectious_disease
  

# ----------------------------------------
# IMPORTS
# ----------------------------------------

# AUTOMATED IMPORTS
# List import ontology IDs with automated build rules based on the source file
# format, either OWL or OWL_GZ (if compressed)
#
# Note: Corresponding rules must be defined in the Makefile in the
# src/ontology/imports directory
IMP_OWL := cl eco foodon geno hp ro so symp trans uberon
IMP_OWL_GZ := chebi ncbitaxon

# MANUAL IMPORTS
# List import ontology IDs that are updated manually (used solely for versioning)
MANUAL_IMPS := disdriv omim_susc


# ----------------------------------------
# PRODUCT DIRECTORIES
# ----------------------------------------

# Release directory (and optional second directory for publishing release)
RELEASE_DIR := src/ontology
PUBLISH_DIR := $(RELEASE_DIR)/releases

# Dataset directory
DATASET_DIR := DOreports

# Verify products in directory
VERIFY_DIR := $(RELEASE_DIR)


# ----------------------------------------
# SOFTWARE DEPENDENCIES
# ----------------------------------------

# Version of ROBOT to use
ROBOT_VRS := 1.9.5