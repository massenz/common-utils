# Example Makefile demonstrating the use of the emojify function
# Make sure COMMON_UTILS is set to the directory containing common-utils
# export COMMON_UTILS=/path/to/common-utils

include $(COMMON_UTILS)/templates/common.mk

.PHONY: demo demo-standalone
demo:  ## Demonstrates the use of the emojify function
	$(call emojify,Testing the emojify function)
	@echo "Regular echo command"

demo-standalone:  ## Demonstrates the use the standalone emojify command
	emojify "Testing the standalone emojify command"
	@echo "Regular echo command"
