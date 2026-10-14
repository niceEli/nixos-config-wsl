HOST ?= $(shell hostname)

switch:
	nh os switch . -H $(HOST)
boot:
	nh os boot . -H $(HOST)
update:
	nh os switch . -H $(HOST) -u
update-boot:
	nh os boot . -H $(HOST) -u

bootstrap:
	sudo nixos-rebuild switch --flake .#$(HOST)

.PHONY: switch boot bootstrap
