return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,
  LrToolkitIdentifier = 'local.anamorphic.desqueeze',
  LrPluginName = 'Desqueeze TIFF Copy',
  LrPluginInfoUrl = 'https://github.com/asayes-lab/Anamorphic-Desqueeze-for-Lightroom-Classic', 
  LrLibraryMenuItems = {
    {
      title = 'Desqueeze to TIFF copy...',
      file = 'DesqueezeCopy.lua',
      enabledWhen = 'photosSelected',
    },
  },
  VERSION = { major = 1, minor = 2, revision = 0 },
}
