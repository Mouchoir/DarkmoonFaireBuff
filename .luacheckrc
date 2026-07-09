-- Luacheck config for WoW Classic addon Lua (Lua 5.1 runtime).
std = "lua51"
max_line_length = false   -- localization tables have long string lines
unused_args = false       -- WoW callbacks pass self/elapsed we often ignore

read_globals = {
    -- WoW API surface used by this addon
    "CreateFrame", "UIParent", "GameTooltip",
    "Settings", "C_Timer", "C_Calendar", "C_DateAndTime", "C_GossipInfo", "C_Spell",
    "GetSpellInfo", "UnitAura", "UnitGUID", "UnitClass", "UnitLevel",
    "GetLocale", "GetNumTalentTabs", "GetTalentTabInfo",
    "DEFAULT_CHAT_FRAME", "CloseGossip", "GetTime",
    "strsplit", "strtrim", "time", "date",
}

globals = {
    -- SavedVariable + slash handlers (globals WoW reads/writes)
    "DFBCharSettings", "SLASH_DFB1", "SLASH_DFB2", "SlashCmdList",
}
