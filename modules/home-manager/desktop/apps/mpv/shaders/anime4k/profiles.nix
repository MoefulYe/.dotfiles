{ anime4k }:
let
  # https://github.com/bloc97/Anime4K/blob/master/md/GLSL_Instructions_Advanced.md#modes
  profiles = {
    anime4kA = [
      "${anime4k}/Anime4K_Clamp_Highlights.glsl"
      "${anime4k}/Anime4K_Restore_CNN_VL.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
    ];
    anime4kB = [
      "${anime4k}/Anime4K_Clamp_Highlights.glsl"
      "${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
    ];
    anime4kC = [
      "${anime4k}/Anime4K_Clamp_Highlights.glsl"
      "${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
    ];
    anime4kAA = [
      "${anime4k}/Anime4K_Clamp_Highlights.glsl"
      "${anime4k}/Anime4K_Restore_CNN_VL.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl"
      "${anime4k}/Anime4K_Restore_CNN_M.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
    ];
    anime4kBB = [
      "${anime4k}/Anime4K_Clamp_Highlights.glsl"
      "${anime4k}/Anime4K_Restore_CNN_Soft_VL.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_VL.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
      "${anime4k}/Anime4K_Restore_CNN_Soft_M.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
    ];
    anime4kCA = [
      "${anime4k}/Anime4K_Clamp_Highlights.glsl"
      "${anime4k}/Anime4K_Upscale_Denoise_CNN_x2_VL.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x2.glsl"
      "${anime4k}/Anime4K_AutoDownscalePre_x4.glsl"
      "${anime4k}/Anime4K_Restore_CNN_M.glsl"
      "${anime4k}/Anime4K_Upscale_CNN_x2_M.glsl"
    ];
  };
  profilesList = builtins.attrValues (
    builtins.mapAttrs (name: shaders: {
      inherit name;
      shaders = builtins.concatStringsSep ":" shaders;
    }) profiles
  );
  result = builtins.foldl' (
    acc:
    { name, shaders }:
    ''
      ${acc}[${name}]
      profile-restore=copy-equal
      glsl-shaders=${shaders}

    ''
  ) "" profilesList;
in
result
