HOST ?= $(shell hostname)

switch:
	nh os switch . -H $(HOST)
boot:
	nh os boot . -H $(HOST)

bootstrap:
	sudo nixos-rebuild switch --flake .#$(HOST)

.PHONY: switch boot bootstrap
