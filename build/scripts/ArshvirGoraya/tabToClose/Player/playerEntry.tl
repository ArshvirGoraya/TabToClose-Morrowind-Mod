-- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/index.html

-- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/api.html
local ui = require('openmw.ui')
local input = require('openmw.input')
local localiation = require('openmw.core')
local I = require("openmw.interfaces")
local settings = I.Settings
-- local types = require("openmw.types")

-- local DB = require("build.scripts.ArshvirGoraya.tabToClose.dbug")
local DB = require("scripts.ArshvirGoraya.tabToClose.dbug")

global l10n: string = "tabToClose"
local localize = localiation.l10n(l10n, "en")

-- SettingPAge
local settingsPage : settings.PageOptions = {}
settingsPage.description = localize("ModDescription")
settingsPage.name = localize("ModName")
settingsPage.key = "tabToClosePage"
settingsPage.l10n = l10n
settings.registerPage(settingsPage)
-- SettingsSection: closeKey
local settingsSection_CloseKey : settings.GroupOptions = {}
settingsSection_CloseKey.order = 1
settingsSection_CloseKey.l10n = l10n
settingsSection_CloseKey.name = localize("SectionName_CloseKey")
settingsSection_CloseKey.description = localize("SectionDescription_CloseKey")
settingsSection_CloseKey.key = "tabToCloseSection_CloseKey"
settingsSection_CloseKey.page = settingsPage.key
settingsSection_CloseKey.permanentStorage = false
-- Setting: CloseKey
local RendererEnum = {
  textLine =  "textLine",
  checkbox = "checkbox",
  number = "number",
  select = "select",
  color = "color",
  inputBinding = "inputBinding",
}
local setting_closeKey : settings.SettingOptions = {}
setting_closeKey.renderer = RendererEnum.select
setting_closeKey.name = localize("SettingsName_KeyChoice")
local setting_closeKeyList : table = {
  localize("KeyChoices_InventoryKey"),
  localize("KeyChoices_TabKey"),
  localize("KeyChoices_CustomKey"),
}
setting_closeKey.argument = setting_closeKeyList
setting_closeKey.default = localize("KeyChoices_InventoryKey")
setting_closeKey.description = localize("SettingsDescription_KeyChoice", {
  KeyChoices_InventoryKey = localize("KeyChoices_InventoryKey"),
  KeyChoices_TabKey = localize("KeyChoices_TabKey"),
  KeyChoices_CustomKey = localize("KeyChoices_CustomKey"),
  SettingsName_CustomKey = localize("SettingsName_CustomKey")
})
setting_closeKey.key = "tabToCloseSetting_CloseKey"
-- Setting: CustomKey
local setting_customKey : settings.SettingOptions = {}
setting_customKey.renderer = RendererEnum.inputBinding
setting_customKey.name = localize("SettingsName_CustomKey")
setting_customKey.description = localize("SettingsDescription_CustomKey", {
  SettingsName_KeyChoice =  localize("SettingsName_KeyChoice"),
  KeyChoices_CustomKey = localize("KeyChoices_CustomKey")
})
setting_customKey.key = "tabToCloseSetting_CustomKey"
-- setting_customKey.default = "" -- default should be whatever it is for opening inventory -> dont have that in input.Actions yet as of 0.49
--- complete section: CloseKey
settingsSection_CloseKey.settings = {
  setting_closeKey,
  setting_customKey
}
settings.registerGroup(settingsSection_CloseKey)


-- SettingsSection: UI
local settingsSection_UI : settings.GroupOptions = {}
settingsSection_UI.order = 2
settingsSection_UI.l10n = l10n
settingsSection_UI.name = localize("SectionName_UI")
settingsSection_UI.description = localize("SectionDescription_UI", {SectionName_CloseKey = localize("SectionName_CloseKey")})
settingsSection_UI.key = "tabToCloseSection_UI"
settingsSection_UI.page = settingsPage.key
settingsSection_UI.permanentStorage = false
-- settings (modes for now - window in next openmw release)
local defaultUI : {string:boolean} = {
  Interface = true,
  Container = true,
}
-- table.sort(I.UI.MODE)
settingsSection_UI.settings = {}
for k, _ in pairs(I.UI.MODE) do
  local modeName : string = tostring(k)
  local setting_UI : settings.SettingOptions = {}
  setting_UI.renderer = RendererEnum.checkbox
  setting_UI.name = localize("SettingsUI_" .. modeName)
  setting_UI.default = false or defaultUI[modeName]
  setting_UI.key = "tabToCloseSetting_UI_" .. modeName
  table.insert(settingsSection_UI.settings, setting_UI)
end
settings.registerGroup(settingsSection_UI)

-- I.UI.isWindowVisible("Inventory") -- Available in future, but not in 4.9


-- VALIDATE SELECT settings
local storage = require("openmw.storage")
local closeKey = storage.playerSection(settingsSection_CloseKey.key)
local closeKeySelect = closeKey.get(closeKey, setting_closeKey.key)
local selectedFoundInList = false
for _, v in ipairs(setting_closeKeyList)do
  if closeKeySelect == v then
    DB.log("seleted was found in list, no need to reset to default")
    selectedFoundInList = true
    break
  end
end
if not selectedFoundInList then
  closeKey.set(closeKey, setting_closeKey.key, setting_closeKey.default)
end

return {
  -- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/overview.html#script-structure
  engineHandlers = {
    -- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/engine_handlers.html#engine-handlers-reference
    onKeyRelease = function (key : input.KeyboardEvent)
      -- ui.showMessage("key pressed: " .. tostring(key.code))
      -- if key.symbol == "tab" then
      --   ui.showMessage("tab pressed")
      -- end
    end,
  },
  -- eventHandlers = {
  --   -- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/events.html
  --   UiModeChanged = function(data: {string: any})
  --     -- anything from I.UI.MODE
  --     ui.showMessage("new mode: " .. tostring(data.newMode), {})
  --   end
  -- },
}
