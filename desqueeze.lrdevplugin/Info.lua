return {
  LrSdkVersion = 6.0,
  LrSdkMinimumVersion = 6.0,
  LrToolkitIdentifier = 'local.anamorphic.desqueeze',
  LrPluginName = 'Anamorphic Desqueeze',
  LrPluginInfoUrl = 'https://github.com/asayes-lab/Desqueeze-for-Lightroom',
  LrLibraryMenuItems = {
    {
      title = 'Desqueeze copy...',
      file = 'DesqueezeCopy.lua',
      enabledWhen = 'photosSelected',
    },
  },
  VERSION = { major = 1, minor = 1, revision = 0 },
}
