


local ui = require('openmw.ui')
local input = require('openmw.input')
local localiation = require('openmw.core')
local I = require("openmw.interfaces")
local settings = I.Settings



local DB = require("scripts.ArshvirGoraya.tabToClose.dbug")

l10n = "tabToClose"
local localize = localiation.l10n(l10n, "en")


local settingsPage = {}
settingsPage.description = localize("ModDescription")
settingsPage.name = localize("ModName")
settingsPage.key = "tabToClosePage"
settingsPage.l10n = l10n
settings.registerPage(settingsPage)

local settingsSection_CloseKey = {}
settingsSection_CloseKey.order = 1
settingsSection_CloseKey.l10n = l10n
settingsSection_CloseKey.name = localize("SectionName_CloseKey")
settingsSection_CloseKey.description = localize("SectionDescription_CloseKey")
settingsSection_CloseKey.key = "tabToCloseSection_CloseKey"
settingsSection_CloseKey.page = settingsPage.key
settingsSection_CloseKey.permanentStorage = false

local RendererEnum = {
   textLine = "textLine",
   checkbox = "checkbox",
   number = "number",
   select = "select",
   color = "color",
   inputBinding = "inputBinding",
}
local setting_closeKey = {}
setting_closeKey.renderer = RendererEnum.select
setting_closeKey.name = localize("SettingsName_KeyChoice")
local setting_closeKeyList = {
   localize("KeyChoices_InventoryKey"),
   localize("KeyChoices_TabKey"),
   localize("KeyChoices_CustomKey"),
}
setting_closeKey.argument = {
   l10n = l10n,
   items = setting_closeKeyList,
}
setting_closeKey.default = localize("KeyChoices_InventoryKey")
setting_closeKey.description = localize("SettingsDescription_KeyChoice", {
   KeyChoices_InventoryKey = localize("KeyChoices_InventoryKey"),
   KeyChoices_TabKey = localize("KeyChoices_TabKey"),
   KeyChoices_CustomKey = localize("KeyChoices_CustomKey"),
   SettingsName_CustomKey = localize("SettingsName_CustomKey"),
})
setting_closeKey.key = "tabToCloseSetting_CloseKey"



local customKey = {}
customKey.defaultValue = false
customKey.description = localize("KeyDesciption_CustomKey")
customKey.name = localize("SettingsName_CustomKey")
customKey.key = "TabToClose_CustomKey"
customKey.l10n = l10n
customKey.type = input.ACTION_TYPE.Boolean
input.registerAction(customKey)

local setting_customKey = {}
setting_customKey.renderer = RendererEnum.inputBinding
setting_customKey.name = localize("SettingsName_CustomKey")
setting_customKey.description = localize("SettingsDescription_CustomKey", {
   SettingsName_KeyChoice = localize("SettingsName_KeyChoice"),
   KeyChoices_CustomKey = localize("KeyChoices_CustomKey"),
})
setting_customKey.key = "tabToCloseSetting_CustomKey"
setting_customKey.default = "tab"
setting_customKey.argument = {
   key = customKey.key,
   type = "action",
}


local setting_onRelease = {}
setting_onRelease.name = localize("SettingsName_OnRelease")
setting_onRelease.description = localize("SettingsDescription_OnRelease")
setting_onRelease.renderer = RendererEnum.checkbox
setting_onRelease.default = false
setting_onRelease.key = "tablToCloseSetting_OnRelease"



settingsSection_CloseKey.settings = {
   setting_closeKey,
   setting_customKey,
   setting_onRelease,
}
settings.registerGroup(settingsSection_CloseKey)


local settingsSection_UI = {}
settingsSection_UI.order = 2
settingsSection_UI.l10n = l10n
settingsSection_UI.name = localize("SectionName_UI")
settingsSection_UI.description = localize("SectionDescription_UI", { SectionName_CloseKey = localize("SectionName_CloseKey") })
settingsSection_UI.key = "tabToCloseSection_UI"
settingsSection_UI.page = settingsPage.key
settingsSection_UI.permanentStorage = false

local defaultUI = {
   Interface = true,
   Container = true,
}

settingsSection_UI.settings = {}
for k, _ in pairs(I.UI.MODE) do
   local modeName = tostring(k)
   local setting_UI = {}
   setting_UI.renderer = RendererEnum.checkbox
   setting_UI.name = localize("SettingsUI_" .. modeName)
   setting_UI.default = false or defaultUI[modeName]
   setting_UI.key = "tabToCloseSetting_UI_" .. modeName
   table.insert(settingsSection_UI.settings, setting_UI)
end
settings.registerGroup(settingsSection_UI)





local storage = require("openmw.storage")
local closeKey = storage.playerSection(settingsSection_CloseKey.key)
local closeKeySelect = closeKey.get(closeKey, setting_closeKey.key)
local selectedFoundInList = false
for _, v in ipairs(setting_closeKeyList) do
   if closeKeySelect == v then
      DB.log("seleted was found in list, no need to reset to default")
      selectedFoundInList = true
      break
   end
end
if not selectedFoundInList then
   closeKey.set(closeKey, setting_closeKey.key, setting_closeKey.default)
end


local tabReleasedThisFrame = false
local customKeyPressedPreviousFrame = false
local customKeyReleasedThisFrame = false
local customKeyPressedThisFrame = input.getBooleanActionValue(customKey.key)
local inventoryPressedPreviousFrame = false
local inventoryReleasedThisFrame = false
local inventoryPressedThisFrame = false

return {

   engineHandlers = {

      onKeyRelease = function(key)
         tabReleasedThisFrame = key.code == input.KEY.Tab
      end,
      onFrame = function()
         inventoryPressedThisFrame = input.isActionPressed(input.ACTION.Inventory)
         inventoryReleasedThisFrame = not inventoryPressedThisFrame and inventoryPressedPreviousFrame
         inventoryPressedPreviousFrame = inventoryPressedThisFrame

         customKeyPressedThisFrame = input.getBooleanActionValue(customKey.key)
         customKeyReleasedThisFrame = not customKeyPressedThisFrame and customKeyPressedPreviousFrame
         customKeyPressedPreviousFrame = customKeyPressedThisFrame

         if inventoryReleasedThisFrame then
            print("inventory released this frame")
         end
         if customKeyReleasedThisFrame then
            print("custom key released this frame")
         end
         if tabReleasedThisFrame then
            print("tab released this frame")
         end
         tabReleasedThisFrame = false
      end,
   },







}
