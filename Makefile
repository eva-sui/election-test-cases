# --- Variables

# Paths

ROOT_path := $(dir $(abspath $(MAKEFILE_LIST)))
ROOT_path := $(ROOT_path:%/=%)
DATA_path := $(ROOT_path)/data
DOCS_path := $(ROOT_path)/doc

# Samples

SAMPLES_path := $(DATA_path)/samples
SAMPLES_JSON_ext := _sample.json
SAMPLES_XML_ext := _sample.xml
SAMPLES_XML_TO_JSON_ext := _sample.xml-json
CVR_SAMPLES_path := $(SAMPLES_path)/cvr
CVR_SAMPLES_CONVERTED_path := $(CVR_SAMPLES_path)/converted
CVR_SAMPLES_JSON_files := $(wildcard $(CVR_SAMPLES_path)/*$(SAMPLES_JSON_ext))
CVR_SAMPLES_XML_files := $(wildcard $(CVR_SAMPLES_path)/*$(SAMPLES_XML_ext))
CVR_SAMPLES_XML_TO_JSON_files := $(patsubst %$(SAMPLES_XML_ext),%$(SAMPLES_XML_TO_JSON_ext),$(CVR_SAMPLES_XML_files))
CVR_SAMPLES_XML_TO_JSON_files := $(notdir $(CVR_SAMPLES_XML_TO_JSON_files))
CVR_SAMPLES_XML_TO_JSON_files := $(CVR_SAMPLES_XML_TO_JSON_files:%=$(CVR_SAMPLES_CONVERTED_path)/%)

# Schemas

SCHEMAS_path := $(DATA_path)/schemas
CVR_SCHEMAS_path := $(SCHEMAS_path)/cvr
CVR_XMLSCHEMA_ext := xmlschema.xml
CVR_XMLSCHEMA_file := $(CVR_SCHEMAS_path)/nist-cvr-v1_$(CVR_XMLSCHEMA_ext)

VALIDATE_XML := xmlschema-validate

XML_TO_JSON := xmlschema-xml2json

# --- Rules

help:
	@echo "Targets":
	@echo ""
	@echo "  Convert samples:"
	@echo ""
	@echo "    convert-samples:          Generate all converted samples"
	@echo "    convert-samples-xml-json: Generate converted JSON samples from XML samples"
	@echo "       Generated JSON is NOT valid. Use it for comparison."
	@echo "    clean-convert-samples:    Cleanup converted samples"
	@echo ""
	@echo "  Validation:"
	@echo ""
	@echo "    validate:              Validate all samples"
	@echo "    validate-xml:          Validate XML samples"


# Convert XML samples to JSON

convert-samples: convert-samples-xml-json


convert-samples-xml-json: $(CVR_SAMPLES_XML_TO_JSON_files)


$(CVR_SAMPLES_CONVERTED_path)/%.xml-json: $(CVR_SAMPLES_CONVERTED_path)/%.json
	jq '.' $< > $@


$(CVR_SAMPLES_CONVERTED_path)/%.json: $(CVR_SAMPLES_path)/%.xml
	@$(XML_TO_JSON) --schema $(CVR_XMLSCHEMA_file) $< -o $(CVR_SAMPLES_CONVERTED_path)


clean-converted-samples:
	rm $(CVR_SAMPLES_XML_TO_JSON_files)

.PHONY: clean-converted-samples


# Validation

validate: validate-xml


validate-xml: validate-cvr-xml


validate-cvr-xml: $(CVR_SAMPLES_XML_files)
	@for file in $^; do \
		$(VALIDATE_XML) --schema $(CVR_XMLSCHEMA_file) $$file; \
	done
