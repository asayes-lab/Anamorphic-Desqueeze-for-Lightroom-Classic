-- Desqueeze copy: exports each selected photo as a 16-bit ProPhoto TIFF,
-- stretches it by the chosen squeeze factor with ImageMagick (Lanczos),
-- saves it next to the original as <name>_desqueezed.tif and adds it to the catalog.

local LrApplication     = import 'LrApplication'
local LrBinding         = import 'LrBinding'
local LrDialogs         = import 'LrDialogs'
local LrExportSession   = import 'LrExportSession'
local LrFileUtils       = import 'LrFileUtils'
local LrFunctionContext = import 'LrFunctionContext'
local LrPathUtils       = import 'LrPathUtils'
local LrPrefs           = import 'LrPrefs'
local LrProgressScope   = import 'LrProgressScope'
local LrTasks           = import 'LrTasks'
local LrView            = import 'LrView'

local prefs = LrPrefs.prefsForPlugin()

-- Orientations where the sensor's horizontal axis ends up vertical in the export
local VERTICAL = { BC = true, CB = true, DA = true, AD = true }

local function q(s) return '"' .. s .. '"' end

local function findMagick()
  if WIN_ENV then return 'magick' end -- relies on PATH
  for _, p in ipairs { '/opt/homebrew/bin/magick', '/usr/local/bin/magick', '/usr/bin/magick' } do
    if LrFileUtils.exists(p) then return p end
  end
  return ''
end

local function run(cmd, logPath)
  local full = cmd .. ' > ' .. q(logPath) .. ' 2>&1'
  if WIN_ENV then full = '"' .. full .. '"' end -- cmd.exe quoting quirk
  return LrTasks.execute(full)
end

local function getDimensions(magick, imgPath, logPath)
  local cmd = q(magick) .. ' identify -format "%w %h" ' .. q(imgPath)
  local rc = run(cmd, logPath)
  if not rc or rc >= 2 then return nil end
  local fh = io.open(logPath, 'r')
  if not fh then return nil end
  local text = fh:read('*a') or ''
  fh:close()
  local w, h = text:match('(%d+)%s+(%d+)')
  if not w then return nil end
  return tonumber(w), tonumber(h)
end

local function uniquePath(dir, base, ext)
  local p = LrPathUtils.child(dir, base .. '.' .. ext)
  local n = 2
  while LrFileUtils.exists(p) do
    p = LrPathUtils.child(dir, base .. '-' .. n .. '.' .. ext)
    n = n + 1
  end
  return p
end

local function askOptions(context)
  local f = LrView.osFactory()
  local props = LrBinding.makePropertyTable(context)
  props.factor = prefs.factor or 1.33
  props.magick = prefs.magick or findMagick()
  props.stack = (prefs.stack ~= false)
  props.setMeta = (prefs.setMeta == true)
  props.flag = prefs.flag or 'none'
  props.rating = prefs.rating or 'none'
  props.color = prefs.color or 'none'
  props.addKeyword = (prefs.addKeyword == true)
  props.keyword = prefs.keyword or 'Desqueezed'

  local contents = f:column {
    bind_to_object = props,
    spacing = f:control_spacing(),
    f:row {
      f:static_text { title = 'Squeeze factor:', width = LrView.share 'lbl' },
      f:popup_menu {
        value = LrView.bind 'factor',
        items = {
          { title = '1.33x', value = 1.33 },
          { title = '1.5x', value = 1.5 },
          { title = '1.6x', value = 1.6 },
          { title = '1.8x', value = 1.8 },
          { title = '2.0x', value = 2.0 },
        },
      },
      f:edit_field {
        value = LrView.bind 'factor', immediate = true,
        precision = 3, min = 1.0, max = 4.0, width_in_digits = 6,
      },
    },
    f:row {
      f:static_text { title = 'ImageMagick (magick):', width = LrView.share 'lbl' },
      f:edit_field { value = LrView.bind 'magick', width_in_chars = 34 },
      f:push_button {
        title = 'Browse...',
        action = function()
          local r = LrDialogs.runOpenPanel {
            title = 'Locate magick', canChooseFiles = true,
            canChooseDirectories = false, allowsMultipleSelection = false,
          }
          if r and r[1] then props.magick = r[1] end
        end,
      },
    },
    f:checkbox { title = 'Stack the copy with the original', value = LrView.bind 'stack' },
    f:checkbox { title = 'Set flag / rating / color on the copy', value = LrView.bind 'setMeta' },
    f:row {
      visible = LrView.bind 'setMeta',
      f:static_text { title = 'Flag:' },
      f:popup_menu {
        value = LrView.bind 'flag',
        items = {
          { title = 'None', value = 'none' },
          { title = 'Flagged', value = 'flagged' },
          { title = 'Rejected', value = 'rejected' },
        },
      },
      f:static_text { title = 'Rating:' },
      f:popup_menu {
        value = LrView.bind 'rating',
        items = {
          { title = 'None', value = 'none' },
          { title = '1', value = '1' }, { title = '2', value = '2' },
          { title = '3', value = '3' }, { title = '4', value = '4' }, { title = '5', value = '5' },
        },
      },
      f:static_text { title = 'Color:' },
      f:popup_menu {
        value = LrView.bind 'color',
        items = {
          { title = 'None', value = 'none' },
          { title = 'Red', value = 'red' }, { title = 'Yellow', value = 'yellow' },
          { title = 'Green', value = 'green' }, { title = 'Blue', value = 'blue' },
          { title = 'Purple', value = 'purple' },
        },
      },
    },
    f:checkbox { title = 'Add keyword to the copy', value = LrView.bind 'addKeyword' },
    f:row {
      visible = LrView.bind 'addKeyword',
      f:static_text { title = 'Keyword:' },
      f:edit_field { value = LrView.bind 'keyword', width_in_chars = 20 },
    },
  }

  local result = LrDialogs.presentModalDialog { title = 'Desqueeze copy', contents = contents }
  if result ~= 'ok' then return nil end
  prefs.factor, prefs.magick, prefs.stack = props.factor, props.magick, props.stack
  prefs.setMeta, prefs.flag, prefs.rating, prefs.color = props.setMeta, props.flag, props.rating, props.color
  prefs.addKeyword, prefs.keyword = props.addKeyword, props.keyword
  return props
end

LrFunctionContext.postAsyncTaskWithContext('desqueeze', function(context)
  local catalog = LrApplication.activeCatalog()
  local photos = {}
  for _, p in ipairs(catalog:getTargetPhotos()) do
    if not p:getRawMetadata('isVideo') then photos[#photos + 1] = p end
  end
  if #photos == 0 then
    LrDialogs.message('Desqueeze', 'Select at least one photo.', 'info')
    return
  end

  local opts = askOptions(context)
  if not opts then return end
  local factor, magick = tonumber(opts.factor), opts.magick
  if not factor or factor < 1 then
    LrDialogs.message('Desqueeze', 'Squeeze factor must be 1.0 or higher.', 'critical')
    return
  end
  if magick == '' or (magick ~= 'magick' and not LrFileUtils.exists(magick)) then
    LrDialogs.message('Desqueeze', 'ImageMagick 7 (magick) was not found. Install it or set its path.', 'critical')
    return
  end

  local tempDir = LrPathUtils.child(LrPathUtils.getStandardFilePath 'temp', 'lr_desqueeze_' .. os.time())
  LrFileUtils.createAllDirectories(tempDir)

  local session = LrExportSession {
    photosToExport = photos,
    exportSettings = {
      LR_export_destinationType = 'specificFolder',
      LR_export_destinationPathPrefix = tempDir,
      LR_export_useSubfolder = false,
      LR_collisionHandling = 'rename',
      LR_format = 'TIFF',
      LR_export_bitDepth = 16,
      LR_export_colorSpace = 'ProPhotoRGB',
      LR_tiff_compressionMethod = 'compressionMethod_None',
      LR_size_doConstrain = false,
      LR_outputSharpeningOn = false,
      LR_useWatermark = false,
      LR_minimizeEmbeddedMetadata = false,
      LR_reimportExportedPhoto = false,
    },
  }

  local progress = LrProgressScope { title = 'Desqueezing photos', functionContext = context }
  local toImport, failures = {}, {}
  local count = #photos

  for i, rendition in session:renditions { stopIfCanceled = true } do
    progress:setPortionComplete(i - 1, count)
    local ok, pathOrMsg = rendition:waitForRender()
    local photo = rendition.photo
    if not ok then
      failures[#failures + 1] = tostring(pathOrMsg)
    else
      local orientation = photo:getRawMetadata 'orientation'
      local dimLog = LrPathUtils.replaceExtension(pathOrMsg, 'dim.log')
      local w, h = getDimensions(magick, pathOrMsg, dimLog)
      if not w then
        failures[#failures + 1] = LrPathUtils.leafName(pathOrMsg) .. ': could not read image dimensions'
      else
      local newW, newH
      if VERTICAL[orientation] then
        newW, newH = w, math.floor(h * factor + 0.5)
      else
        newW, newH = math.floor(w * factor + 0.5), h
      end
      local geometry = newW .. 'x' .. newH .. '!'
      local logPath = LrPathUtils.replaceExtension(pathOrMsg, 'log')
      local srcDir = LrPathUtils.parent(photo:getRawMetadata 'path')
      local base = LrPathUtils.removeExtension(LrPathUtils.leafName(photo:getRawMetadata 'path'))
      local dest = uniquePath(srcDir, base .. '_desqueezed', 'tif')
      local cmd = q(magick) .. ' ' .. q(pathOrMsg) .. ' -filter Lanczos -resize ' .. q(geometry) ..
                  ' -depth 16 -compress zip ' .. q(dest)
      local rc = run(cmd, logPath)
      local detail = ''
      if LrFileUtils.exists(logPath) then
        local fh = io.open(logPath, 'r')
        if fh then
          detail = fh:read('*a') or ''
          fh:close()
        end
      end
      if rc and rc >= 2 then
        failures[#failures + 1] = LrPathUtils.leafName(pathOrMsg) .. ': ImageMagick failed: ' .. detail
      elseif not LrFileUtils.exists(dest) then
        failures[#failures + 1] = LrPathUtils.leafName(pathOrMsg) .. ': no output file written. ' .. detail
      else
        toImport[#toImport + 1] = { path = dest, original = photo }
      end
      end
    end
  end
  progress:done()
  LrFileUtils.delete(tempDir)

  if #toImport > 0 then
    catalog:withWriteAccessDo('Add desqueezed copies', function()
      for _, item in ipairs(toImport) do
        local ok, err = LrTasks.pcall(function()
          local newPhoto
          if opts.stack then
            newPhoto = catalog:addPhoto(item.path, item.original, 'above')
          else
            newPhoto = catalog:addPhoto(item.path)
          end
          if opts.setMeta then
            if opts.flag == 'flagged' then newPhoto:setRawMetadata('pickStatus', 1)
            elseif opts.flag == 'rejected' then newPhoto:setRawMetadata('pickStatus', -1) end
            if opts.rating ~= 'none' then newPhoto:setRawMetadata('rating', tonumber(opts.rating)) end
            if opts.color ~= 'none' then newPhoto:setRawMetadata('label', opts.color) end
          end
          if opts.addKeyword and opts.keyword and opts.keyword ~= '' then
            local kw = catalog:createKeyword(opts.keyword, {}, true, nil, true)
            newPhoto:addKeyword(kw)
          end
        end)
        if not ok then failures[#failures + 1] = item.path .. ': ' .. tostring(err) end
      end
    end)
  end

  local msg = string.format('Created %d desqueezed cop%s.', #toImport, #toImport == 1 and 'y' or 'ies')
  if #failures > 0 then
    msg = msg .. '\n\nProblems:\n' .. table.concat(failures, '\n')
  end
  LrDialogs.message('Desqueeze', msg, #failures > 0 and 'warning' or 'info')
end)
