{ lib }:
{
  nixosConfigurations,
  providers ? { },
  zoneProviders ? { },
  extraRecords ? { },
  defaultProvider ? "default",
}:
let
  inherit (lib) attrValues foldl' unique;

  mergeRecordLists =
    records:
    records
    |> foldl' (
      acc: record:
      let
        key = builtins.toJSON {
          inherit (record) name type;
        };
        existing = acc.${key} or record;
      in
      acc
      // {
        ${key} = existing // {
          values = unique (existing.values ++ record.values);
        };
      }
    ) { }
    |> builtins.attrValues;

  hostRecordsByZone =
    nixosConfigurations
    |> attrValues
    |> foldl' (
      acc: nixosConfiguration:
      let
        zone = nixosConfiguration.config.infra.dnsctl.domain or null;
        records = nixosConfiguration.config.infra.dnsctl.records or [ ];
      in
      if zone == null || zone == "" || records == [ ] then
        acc
      else
        acc
        // {
          ${zone} = (acc.${zone} or [ ]) ++ records;
        }
    ) { };

  allZoneNames = unique ((builtins.attrNames hostRecordsByZone) ++ (builtins.attrNames extraRecords));

  zones =
    allZoneNames
    |> foldl' (
      acc: zoneName:
      let
        records = mergeRecordLists ((hostRecordsByZone.${zoneName} or [ ]) ++ (extraRecords.${zoneName} or [ ]));
      in
      if records == [ ] then
        acc
      else
        acc
        // {
          ${zoneName} = {
            provider = zoneProviders.${zoneName} or defaultProvider;
            inherit records;
          };
        }
    ) { };
in
{
  inherit providers zones;
}
