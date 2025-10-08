{ pkgs, paths, ... }: {
	home.packages = with pkgs; [
		gemini-cli
	];
	home.file.".local/bin/gem".source = ./gem.sh;
	sops.secrets = {
		GEMINI_TOKEN = { 
			sopsFile = "${paths.secrets}/api-tokens.yaml";
		};
	};
}
