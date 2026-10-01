switch:
	nh os switch .
boot:
	nh os boot .

bootstrap:
	nixos-rebuild switch --flake .

.PHONY: switch boot bootstrap
