-include .env
-include deployments.local.env

.PHONY: all test clean deploy-anvil

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# use the "@" to hide the command from your shell
run :; @forge script script/My${demo}.s.sol:Demo${demo}
