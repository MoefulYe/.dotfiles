{ retro-crt, ... }:
''
  [crt-guest-advanced-ntsc]
  profile-restore=copy-equal
  glsl-shaders=${retro-crt}/crt-guest-advanced-ntsc.glsl:${retro-crt}/crt-guest-advanced-ntsc-textures.glsl

  [crt-lottes]
  profile-restore=copy-equal
  glsl-shaders=${retro-crt}/crt-lottes.glsl

  [crt-royale-fb-intel]
  profile-restore=copy-equal
  glsl-shaders=${retro-crt}/crt-royale-fb-intel.glsl
  vo=gpu-next

  [gba]
  profile-restore=copy-equal
  scale=nearest
  glsl-shaders=${retro-crt}/gba.glsl
''
