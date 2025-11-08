{ antiAdDownloader, pkgs, lib, url, socks5 ? null, ... }:
pkgs.writeShellScript "ensure-anti-ad-exist" ''
  ANTI_AD_FILE=/var/lib/smartdns/anti-ad-smartdns.conf
  if [ ! -f "$ANTI_AD_FILE" ]; then
    echo "NOTICE: file not found. Triggering initial download..." >&2
    
    if ! ${antiAdDownloader} --dest "$ANTI_AD_FILE" --url '${url}' ${lib.optionalString (socks5 != null) "--socks5 '${socks5}'"}; then
      echo "ERROR: The initial download service failed to run." >&2
      exit 1
    fi
    
    if [ ! -f "$ANTI_AD_FILE" ]; then
      echo "ERROR: Initial download service ran, but the file is still missing." >&2
      exit 1
    fi
    echo "INFO: Initial download complete."
  else
    echo "INFO: file already exists. Skipping download."
  fi
''
