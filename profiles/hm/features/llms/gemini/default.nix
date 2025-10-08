{ pkgs, paths, ... }: {
	home.packages = with pkgs; [
		gemini-cli
	];
	home.".local/bin/load-gemini-token.sh".source = ./load-gemini-token.sh;
	sops.secrets = {
		GEMINI_TOKEN = { 
			sopsFile = "${paths.secrets}/api-tokens.yaml";
		};
	};
}
