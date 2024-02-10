help :: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+\s*:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

info ::
	@echo Makefiles: $(MAKEFILE_LIST)
	@echo Default goal: $(.DEFAULT_GOAL)
	@echo Variables: "$(.VARIABLES)"

define _gen-reveal-yaml
cat > pandoc-reveal.yaml <<EOF
to: revealjs
standalone: true
fail-if-warnings: false
variables:
  revealjs-url: https://public.thorstenvitt.de/reveal
  theme: tvsimple
metadata:
  author: Thorsten Vitt
EOF
endef
export gen_reveal_yaml = $(value _gen-reveal-yaml)

config:: 
	eval "$$gen_reveal_yaml"

