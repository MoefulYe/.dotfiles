{ lib, ... }:
{
  hosts = import ./hosts;
  users = import ./users;
  topology = import ./topology;
}
