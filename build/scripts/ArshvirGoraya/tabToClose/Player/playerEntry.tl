-- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/index.html

-- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/api.html
-- local ui = require('openmw.ui')
local input = require('openmw.input')
local localiation = require('openmw.core')
local I = require("openmw.interfaces")
local settings = I.Settings
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

local record CloseKeyTable 
  inventoryKey: string
  selectKey: string
  customKey: string
end
local setting_closeKeyTable : CloseKeyTable = {
  inventoryKey = localize("KeyChoices_InventoryKey"),
  selectKey = localize("KeyChoices_SelectKey"),
  customKey = localize("KeyChoices_CustomKey"),
}

local setting_closeKeyList : {string} = {
  localize("KeyChoices_InventoryKey"),
  localize("KeyChoices_CustomKey"),
  localize("KeyChoices_SelectKey"),
}
setting_closeKey.argument = {
  l10n = l10n,
  items = setting_closeKeyList
}
setting_closeKey.default = localize("KeyChoices_SelectKey")
setting_closeKey.description = localize("SettingsDescription_KeyChoice", {
  KeyChoices_InventoryKey = localize("KeyChoices_InventoryKey"),
  KeyChoices_SelectKey = localize("KeyChoices_SelectKey"),
  KeyChoices_CustomKey = localize("KeyChoices_CustomKey"),
  SettingsName_CustomKey = localize("SettingsName_CustomKey"),
  SettingsName_SelectKey = localize("SettingsName_SelectKey")
})
setting_closeKey.key = "tabToCloseSetting_CloseKey"
-- Setting: SelectKey
local setting_selectKey : settings.SettingOptions = {}
setting_selectKey.renderer = RendererEnum.select
setting_selectKey.name = localize("SettingsName_SelectKey")
setting_selectKey.description = localize("SettingsDescription_SelectKey", {
  SettingsName_KeyChoice = localize("SettingsName_KeyChoice"), 
  KeyChoices_SelectKey = localize("KeyChoices_SelectKey")
})
setting_selectKey.key = "tabToCloseSetting_SelectKey"

local input_KeyNames = {}
local input_KeyTable = {}
for k, v in pairs(input.KEY as {string:input.KeyCode}) do 
  table.insert(input_KeyNames, k)
  input_KeyTable[k] = v
end

setting_selectKey.default = input.getKeyName(input.KEY.Tab)
setting_selectKey.argument = {
  l10n = l10n,
  items = input_KeyNames,
}


-- DB.printTable(input.KEY)

-- Setting: CustomKey
-- CustomKey Setting: Input
local customKey : input.ActionInfo = {}
customKey.defaultValue = false
customKey.description = localize("KeyDesciption_CustomKey")
customKey.name = localize("SettingsName_CustomKey")
customKey.key = "TabToClose_CustomKey"
customKey.l10n = l10n
customKey.type = input.ACTION_TYPE.Boolean
input.registerAction(customKey)

local setting_customKey : settings.SettingOptions = {}
setting_customKey.renderer = RendererEnum.inputBinding
setting_customKey.name = localize("SettingsName_CustomKey")
setting_customKey.description = localize("SettingsDescription_CustomKey", {
  SettingsName_KeyChoice =  localize("SettingsName_KeyChoice"),
  KeyChoices_CustomKey = localize("KeyChoices_CustomKey")
})
setting_customKey.key = "tabToCloseSetting_CustomKey"
setting_customKey.default = "tab"
setting_customKey.argument = {
  key = customKey.key,
  type = "action"
}

-- setting: OnRelease
local setting_onRelease : settings.SettingOptions = {}
setting_onRelease.name = localize("SettingsName_OnRelease")
setting_onRelease.description= localize("SettingsDescription_OnRelease")
setting_onRelease.renderer = RendererEnum.checkbox
setting_onRelease.default = false
setting_onRelease.key = "tablToCloseSetting_OnRelease"
-- SettingsName_OnRelease

--- complete section: CloseKey
settingsSection_CloseKey.settings = {
  setting_closeKey,
  setting_selectKey,
  setting_customKey,
  setting_onRelease
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
  closeKeySelect = setting_closeKey.default
end

-- Detector
local selectKeyPressedPreviousFrame : boolean = false
local selectKeyPressedThisFrame : boolean = false
local selectKeyReleasedThisFrame : boolean = false

local customKeyPressedPreviousFrame : boolean = false
local customKeyReleasedThisFrame : boolean = false
local customKeyPressedThisFrame : boolean = input.getBooleanActionValue(customKey.key)
local inventoryPressedPreviousFrame : boolean = false
local inventoryReleasedThisFrame : boolean = false
local inventoryPressedThisFrame : boolean = false

local tabJustPressed : boolean = false
local inventoryJustPressed : boolean = false
local customKeyJustPressed : boolean = false

local storage_UISection= storage.playerSection(settingsSection_UI.key)
local function closeUITrigger()
  DB.log("Checking UI")
  for k, _ in pairs(I.UI.MODE) do
    local modeName : string = tostring(k)
    local selectedUI : boolean = storage_UISection.get(storage_UISection, "tabToCloseSetting_UI_" .. modeName) as boolean
    if selectedUI and modeName == I.UI.getMode() then
      DB.log("Closing UI: " .. modeName)
      I.UI.setMode(nil)
      return
    end
  end
end

-- I.Controls.overrideUiControls(true)
-- I.UI.setMode("Interface", {"Inventory"})

return {
  -- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/overview.html#script-structure
  engineHandlers = {
    -- https://openmw.readthedocs.io/en/openmw-0.49.0/reference/lua-scripting/engine_handlers.html#engine-handlers-reference
    --@NOTE: certain keys do not register when in a textLine (such as the one in inventory) and this includes Tab! So cant detect tab though key handlers here
    -- onKeyPress = function (key : input.KeyboardEvent)
    --   -- DB.log("key pressed: ", key.code)
    --   selectKeyPressedThisFrame = key.code == input.KEY.Tab
    -- end,
    -- onKeyRelease = function (key : input.KeyboardEvent)
    --   selectKeyReleasedThisFrame = key.code == input.KEY.Tab
    -- end,
    onFrame = function()
      closeKeySelect = closeKey.get(closeKey, setting_closeKey.key)
      local onRelease = closeKey.get(closeKey, setting_onRelease.key)
      if closeKeySelect == setting_closeKeyTable.inventoryKey then
        inventoryPressedThisFrame = input.isActionPressed(input.ACTION.Inventory)
        if not onRelease then
          inventoryJustPressed = inventoryPressedThisFrame and not inventoryPressedPreviousFrame
          if inventoryJustPressed then
            closeUITrigger()
          end
        else
          inventoryReleasedThisFrame = not inventoryPressedThisFrame and inventoryPressedPreviousFrame
          if inventoryReleasedThisFrame then
            closeUITrigger()
          end
        end
        inventoryPressedPreviousFrame = inventoryPressedThisFrame
      ---
      elseif closeKeySelect == setting_closeKeyTable.selectKey then
        local selectedKey = closeKey.get(closeKey, setting_selectKey.key)
        selectKeyPressedThisFrame = input.isKeyPressed(input_KeyTable[selectedKey as string])
        if not onRelease then
          tabJustPressed = selectKeyPressedThisFrame and not selectKeyPressedPreviousFrame
          if tabJustPressed then
            closeUITrigger()
          end
        else
          selectKeyReleasedThisFrame = not selectKeyPressedThisFrame and selectKeyPressedPreviousFrame
          if selectKeyReleasedThisFrame then
            closeUITrigger()
          end
        end
        selectKeyPressedPreviousFrame = selectKeyPressedThisFrame
      elseif closeKeySelect == setting_closeKeyTable.customKey then
        customKeyPressedThisFrame = input.getBooleanActionValue(customKey.key)
        if not onRelease then
          customKeyJustPressed = customKeyPressedThisFrame and not customKeyPressedPreviousFrame
          if customKeyJustPressed then 
            closeUITrigger()
          end
        else
          customKeyReleasedThisFrame = not customKeyPressedThisFrame and customKeyPressedPreviousFrame
          if customKeyReleasedThisFrame then
            closeUITrigger()
          end
        end
        customKeyPressedPreviousFrame = customKeyPressedThisFrame
      end
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
