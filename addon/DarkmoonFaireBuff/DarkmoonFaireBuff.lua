----------------------------------------------------------------------
-- DarkmoonFaireBuff (DFB) - WoW Classic Addon
-- Automates Sayge's buff selection at the Darkmoon Faire
-- Works in ALL game languages via NPC ID and Spell ID detection
----------------------------------------------------------------------

local addonName = "DarkmoonFaireBuff"

----------------------------------------------------------------------
-- CONSTANTS
----------------------------------------------------------------------
local SAYGE_NPC_ID = 14822
local COOLDOWN_DURATION = 14400 -- 4 hours in seconds

-- Sayge's Dark Fortune spell IDs
local SAYGE_SPELL_IDS = {
    23768, -- Damage +10%
    23769, -- Resistance +25
    23738, -- Armor +10%
    23737, -- Spirit +10%
    23766, -- Intelligence +10%
    23735, -- Stamina +10%
    23736, -- Agility +10%
    23767, -- Strength +10%
}

-- Buff definitions: key = internal ID, spellId, answer1, answer2
local BUFF_TABLE = {
    { id = "DMG",  spellId = 23768, a1 = 1, a2 = 1 }, -- +10% Damage
    { id = "RES",  spellId = 23769, a1 = 1, a2 = 2 }, -- +25 All Resistances
    { id = "ARM",  spellId = 23738, a1 = 1, a2 = 3 }, -- +10% Armor
    { id = "SPI",  spellId = 23737, a1 = 2, a2 = 1 }, -- +10% Spirit
    { id = "INT",  spellId = 23766, a1 = 2, a2 = 2 }, -- +10% Intelligence
    { id = "STA",  spellId = 23735, a1 = 3, a2 = 1 }, -- +10% Stamina
    { id = "STR",  spellId = 23767, a1 = 3, a2 = 2 }, -- +10% Strength
    { id = "AGI",  spellId = 23736, a1 = 3, a2 = 3 }, -- +10% Agility
}

-- Spell ID lookup set for fast checking
local SAYGE_SPELL_SET = {}
for _, sid in ipairs(SAYGE_SPELL_IDS) do
    SAYGE_SPELL_SET[sid] = true
end

----------------------------------------------------------------------
-- LOCALIZATION
----------------------------------------------------------------------
local L = {}

-- Default (English)
L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff loaded. Type /dfb for options."
L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r The Darkmoon Faire is |cFF00FF00active|r!"
L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r The Darkmoon Faire is |cFFFF0000not active|r."
L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Selected buff: |cFF00CCFF%s|r"
L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r No buff pre-selected for this character."
L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Sayge buff: |cFF00FF00ready|r!"
L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Addon timer: |cFFFF6600%s|r remaining (does not block auto-click)."
L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r Buff obtained! Cooldown: 4 hours."
L["AUTO_CLICK_ON"]           = "Auto-click: ON"
L["AUTO_CLICK_OFF"]          = "Auto-click: OFF"
L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
L["OPTIONS_DESC"]            = "Select the buff you wish to automatically obtain from Sayge."
L["OPTIONS_AUTOCLICK"]       = "Enable auto-click on Sayge dialogue"
L["OPTIONS_AUTOCLICK_TT"]    = "When enabled, the addon will automatically select the gossip options when you talk to Sayge."
L["OPTIONS_FORTUNE"]         = "Ask for the Darkmoon Faire Fortune"
L["OPTIONS_FORTUNE_TT"]      = "After the buff path, click the final dialogue option to request Sayge's written fortune."
L["FORTUNE_OBTAINED"]        = "|cFFD4AF37[DFB]|r Darkmoon Faire Fortune requested."
L["FORTUNE_SKIPPED"]         = "|cFFD4AF37[DFB]|r Darkmoon Faire Fortune was not requested because the option is disabled."
L["OPTIONS_NONE"]            = "None"
L["OPTIONS_NONE_DESC"]       = "Disable automatic buff selection"
L["RECOMMENDED_BADGE"]       = "Reco"
L["ALTERNATIVE_BADGE"]       = "Alt"
L["RECOMMENDATION_NONE"]     = "Recommendation: choose a buff manually."
L["RECOMMENDATION_FORMAT"]   = "Recommended: %s - %s"
L["RECOMMEND_REASON_STR"]    = "melee leveling."
L["RECOMMEND_REASON_AGI"]    = "physical scaling."
L["RECOMMEND_REASON_INT"]    = "mana/spell throughput."
L["RECOMMEND_REASON_STA"]    = "tank/survival."
L["RECOMMEND_REASON_ARM"]    = "physical defense."
L["RECOMMEND_REASON_DMG"]    = "faster kills."
L["RECOMMEND_REASON_SPI"]    = "less mana downtime."
L["BUFF_DMG"]                = "+10% Damage"
L["BUFF_RES"]                = "+25 All Resistances"
L["BUFF_ARM"]                = "+10% Armor"
L["BUFF_SPI"]                = "+10% Spirit"
L["BUFF_INT"]                = "+10% Intelligence"
L["BUFF_STA"]                = "+10% Stamina"
L["BUFF_STR"]                = "+10% Strength"
L["BUFF_AGI"]                = "+10% Agility"

local locale = GetLocale()

if locale == "frFR" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff chargé. Tapez /dfb pour les options."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r La Foire de Sombrelune est |cFF00FF00active|r !"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r La Foire de Sombrelune n'est |cFFFF0000pas active|r."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Buff sélectionné : |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r Aucun buff présélectionné pour ce personnage."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Buff de Sayge : |cFF00FF00disponible|r !"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Buff de Sayge : |cFFFF6600%s|r avant la prochaine récupération."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r Buff obtenu ! Cooldown : 4 heures."
    L["AUTO_CLICK_ON"]           = "Auto-clic : ACTIVÉ"
    L["AUTO_CLICK_OFF"]          = "Auto-clic : DÉSACTIVÉ"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "Sélectionnez le buff que vous souhaitez obtenir automatiquement auprès de Sayge."
    L["OPTIONS_AUTOCLICK"]       = "Activer l'auto-clic sur les dialogues de Sayge"
    L["OPTIONS_AUTOCLICK_TT"]    = "Lorsqu'activé, l'addon sélectionnera automatiquement les options de dialogue lorsque vous parlez à Sayge."
    L["OPTIONS_FORTUNE"]         = "Demander la prédiction de la foire de Sombrelune"
    L["OPTIONS_FORTUNE_TT"]      = "Après le chemin du buff, clique sur la dernière option de dialogue pour demander la prédiction écrite de Sayge."
    L["FORTUNE_OBTAINED"]        = "|cFFD4AF37[DFB]|r Prédiction de la foire de Sombrelune récupérée."
    L["FORTUNE_SKIPPED"]         = "|cFFD4AF37[DFB]|r Prédiction non récupérée : l'option est désactivée."
    L["OPTIONS_NONE"]            = "Aucun"
    L["OPTIONS_NONE_DESC"]       = "Désactiver la sélection automatique de buff"
    L["RECOMMENDED_BADGE"]       = "Reco"
    L["ALTERNATIVE_BADGE"]       = "Alt"
    L["RECOMMENDATION_NONE"]     = "Recommandation : choisissez un buff manuellement."
    L["RECOMMENDATION_FORMAT"]   = "Recommande : %s - %s"
    L["RECOMMEND_REASON_STR"]    = "leveling melee."
    L["RECOMMEND_REASON_AGI"]    = "scaling physique."
    L["RECOMMEND_REASON_INT"]    = "mana/sorts."
    L["RECOMMEND_REASON_STA"]    = "tank/survie."
    L["RECOMMEND_REASON_ARM"]    = "defense physique."
    L["RECOMMEND_REASON_DMG"]    = "kills plus rapides."
    L["RECOMMEND_REASON_SPI"]    = "moins de downtime mana."
    L["BUFF_DMG"]                = "+10% de Dégâts"
    L["BUFF_RES"]                = "+25 à toutes les Résistances"
    L["BUFF_ARM"]                = "+10% d'Armure"
    L["BUFF_SPI"]                = "+10% d'Esprit"
    L["BUFF_INT"]                = "+10% d'Intelligence"
    L["BUFF_STA"]                = "+10% d'Endurance"
    L["BUFF_STR"]                = "+10% de Force"
    L["BUFF_AGI"]                = "+10% d'Agilité"
elseif locale == "deDE" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff geladen. Tippe /dfb für Optionen."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r Der Dunkelmond-Jahrmarkt ist |cFF00FF00aktiv|r!"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r Der Dunkelmond-Jahrmarkt ist |cFFFF0000nicht aktiv|r."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Ausgewählter Buff: |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r Kein Buff für diesen Charakter voreingestellt."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Sayge-Buff: |cFF00FF00bereit|r!"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Sayge-Buff: |cFFFF6600%s|r verbleibend."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r Buff erhalten! Abklingzeit: 4 Stunden."
    L["AUTO_CLICK_ON"]           = "Auto-Klick: AN"
    L["AUTO_CLICK_OFF"]          = "Auto-Klick: AUS"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "Wähle den Buff, den du automatisch von Sayge erhalten möchtest."
    L["OPTIONS_AUTOCLICK"]       = "Auto-Klick auf Sayge-Dialoge aktivieren"
    L["OPTIONS_AUTOCLICK_TT"]    = "Wenn aktiviert, wählt das Addon automatisch die Dialogoptionen, wenn du mit Sayge sprichst."
    L["OPTIONS_NONE"]            = "Keiner"
    L["OPTIONS_NONE_DESC"]       = "Automatische Buff-Auswahl deaktivieren"
    L["BUFF_DMG"]                = "+10% Schaden"
    L["BUFF_RES"]                = "+25 Alle Widerstände"
    L["BUFF_ARM"]                = "+10% Rüstung"
    L["BUFF_SPI"]                = "+10% Willenskraft"
    L["BUFF_INT"]                = "+10% Intelligenz"
    L["BUFF_STA"]                = "+10% Ausdauer"
    L["BUFF_STR"]                = "+10% Stärke"
    L["BUFF_AGI"]                = "+10% Beweglichkeit"
elseif locale == "esES" or locale == "esMX" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff cargado. Escribe /dfb para opciones."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r La Feria de la Luna Negra está |cFF00FF00activa|r!"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r La Feria de la Luna Negra |cFFFF0000no está activa|r."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Buff seleccionado: |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r Ningún buff preseleccionado para este personaje."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Buff de Sayge: |cFF00FF00listo|r!"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Buff de Sayge: |cFFFF6600%s|r restante."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r ¡Buff obtenido! Enfriamiento: 4 horas."
    L["AUTO_CLICK_ON"]           = "Auto-clic: ACTIVADO"
    L["AUTO_CLICK_OFF"]          = "Auto-clic: DESACTIVADO"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "Selecciona el buff que deseas obtener automáticamente de Sayge."
    L["OPTIONS_AUTOCLICK"]       = "Activar auto-clic en los diálogos de Sayge"
    L["OPTIONS_AUTOCLICK_TT"]    = "Cuando está activado, el addon seleccionará automáticamente las opciones de diálogo al hablar con Sayge."
    L["OPTIONS_NONE"]            = "Ninguno"
    L["OPTIONS_NONE_DESC"]       = "Desactivar la selección automática de buff"
    L["BUFF_DMG"]                = "+10% Daño"
    L["BUFF_RES"]                = "+25 Todas las Resistencias"
    L["BUFF_ARM"]                = "+10% Armadura"
    L["BUFF_SPI"]                = "+10% Espíritu"
    L["BUFF_INT"]                = "+10% Inteligencia"
    L["BUFF_STA"]                = "+10% Aguante"
    L["BUFF_STR"]                = "+10% Fuerza"
    L["BUFF_AGI"]                = "+10% Agilidad"
elseif locale == "itIT" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff caricato. Digita /dfb per le opzioni."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r La Fiera di Lunacupa è |cFF00FF00attiva|r!"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r La Fiera di Lunacupa |cFFFF0000non è attiva|r."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Buff selezionato: |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r Nessun buff preselezionato per questo personaggio."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Buff di Sayge: |cFF00FF00pronto|r!"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Buff di Sayge: |cFFFF6600%s|r rimanente."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r Buff ottenuto! Ricarica: 4 ore."
    L["AUTO_CLICK_ON"]           = "Auto-clic: ATTIVO"
    L["AUTO_CLICK_OFF"]          = "Auto-clic: DISATTIVO"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "Seleziona il buff che desideri ottenere automaticamente da Sayge."
    L["OPTIONS_AUTOCLICK"]       = "Attivare auto-clic sui dialoghi di Sayge"
    L["OPTIONS_AUTOCLICK_TT"]    = "Quando attivato, l'addon selezionerà automaticamente le opzioni di dialogo quando parli con Sayge."
    L["OPTIONS_NONE"]            = "Nessuno"
    L["OPTIONS_NONE_DESC"]       = "Disattivare la selezione automatica del buff"
    L["BUFF_DMG"]                = "+10% Danni"
    L["BUFF_RES"]                = "+25 Tutte le Resistenze"
    L["BUFF_ARM"]                = "+10% Armatura"
    L["BUFF_SPI"]                = "+10% Spirito"
    L["BUFF_INT"]                = "+10% Intelletto"
    L["BUFF_STA"]                = "+10% Tempra"
    L["BUFF_STR"]                = "+10% Forza"
    L["BUFF_AGI"]                = "+10% Agilità"
elseif locale == "ptBR" or locale == "ptPT" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff carregado. Digite /dfb para opções."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r A Feira de Negraluna está |cFF00FF00ativa|r!"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r A Feira de Negraluna |cFFFF0000não está ativa|r."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Buff selecionado: |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r Nenhum buff pré-selecionado para este personagem."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Buff de Sayge: |cFF00FF00pronto|r!"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Buff de Sayge: |cFFFF6600%s|r restante."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r Buff obtido! Recarga: 4 horas."
    L["AUTO_CLICK_ON"]           = "Clique automático: ATIVADO"
    L["AUTO_CLICK_OFF"]          = "Clique automático: DESATIVADO"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "Selecione o buff que deseja obter automaticamente de Sayge."
    L["OPTIONS_AUTOCLICK"]       = "Ativar clique automático nos diálogos de Sayge"
    L["OPTIONS_AUTOCLICK_TT"]    = "Quando ativado, o addon selecionará automaticamente as opções de diálogo ao falar com Sayge."
    L["OPTIONS_NONE"]            = "Nenhum"
    L["OPTIONS_NONE_DESC"]       = "Desativar a seleção automática de buff"
    L["BUFF_DMG"]                = "+10% Dano"
    L["BUFF_RES"]                = "+25 Todas as Resistências"
    L["BUFF_ARM"]                = "+10% Armadura"
    L["BUFF_SPI"]                = "+10% Espírito"
    L["BUFF_INT"]                = "+10% Inteligência"
    L["BUFF_STA"]                = "+10% Estamina"
    L["BUFF_STR"]                = "+10% Força"
    L["BUFF_AGI"]                = "+10% Agilidade"
elseif locale == "ruRU" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff загружен. Введите /dfb для настроек."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r Ярмарка Новолуния |cFF00FF00активна|r!"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r Ярмарка Новолуния |cFFFF0000не активна|r."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r Выбранный бафф: |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r Бафф не выбран для этого персонажа."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r Бафф Сейджа: |cFF00FF00готов|r!"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r Бафф Сейджа: |cFFFF6600%s|r до следующего."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r Бафф получен! Перезарядка: 4 часа."
    L["AUTO_CLICK_ON"]           = "Авто-клик: ВКЛ"
    L["AUTO_CLICK_OFF"]          = "Авто-клик: ВЫКЛ"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "Выберите бафф, который хотите автоматически получить от Сейджа."
    L["OPTIONS_AUTOCLICK"]       = "Включить авто-клик в диалогах Сейджа"
    L["OPTIONS_AUTOCLICK_TT"]    = "Если включено, аддон автоматически выберет варианты диалога при разговоре с Сейджем."
    L["OPTIONS_NONE"]            = "Нет"
    L["OPTIONS_NONE_DESC"]       = "Отключить автоматический выбор баффа"
    L["BUFF_DMG"]                = "+10% Урон"
    L["BUFF_RES"]                = "+25 Все сопротивления"
    L["BUFF_ARM"]                = "+10% Броня"
    L["BUFF_SPI"]                = "+10% Дух"
    L["BUFF_INT"]                = "+10% Интеллект"
    L["BUFF_STA"]                = "+10% Выносливость"
    L["BUFF_STR"]                = "+10% Сила"
    L["BUFF_AGI"]                = "+10% Ловкость"
elseif locale == "koKR" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r Darkmoon Faire Buff 로드됨. /dfb 를 입력하여 옵션을 엽니다."
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r 다크문 축제가 |cFF00FF00활성화|r 중입니다!"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r 다크문 축제가 |cFFFF0000비활성화|r 상태입니다."
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r 선택된 버프: |cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r 이 캐릭터에 대해 미리 선택된 버프가 없습니다."
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r 사이지 버프: |cFF00FF00준비됨|r!"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r 사이지 버프: |cFFFF6600%s|r 남음."
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r 버프 획득! 재사용 대기시간: 4시간."
    L["AUTO_CLICK_ON"]           = "자동 클릭: 켜짐"
    L["AUTO_CLICK_OFF"]          = "자동 클릭: 꺼짐"
    L["OPTIONS_TITLE"]           = "Darkmoon Faire Buff"
    L["OPTIONS_DESC"]            = "사이지에게서 자동으로 받을 버프를 선택하세요."
    L["OPTIONS_AUTOCLICK"]       = "사이지 대화에서 자동 클릭 활성화"
    L["OPTIONS_AUTOCLICK_TT"]    = "활성화하면, 사이지와 대화할 때 애드온이 자동으로 대화 옵션을 선택합니다."
    L["OPTIONS_NONE"]            = "없음"
    L["OPTIONS_NONE_DESC"]       = "자동 버프 선택 비활성화"
    L["BUFF_DMG"]                = "+10% 공격력"
    L["BUFF_RES"]                = "+25 모든 저항력"
    L["BUFF_ARM"]                = "+10% 방어력"
    L["BUFF_SPI"]                = "+10% 정신력"
    L["BUFF_INT"]                = "+10% 지능"
    L["BUFF_STA"]                = "+10% 체력"
    L["BUFF_STR"]                = "+10% 힘"
    L["BUFF_AGI"]                = "+10% 민첩성"
elseif locale == "zhCN" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r 暗月马戏团增益已加载。输入 /dfb 打开选项。"
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r 暗月马戏团 |cFF00FF00正在进行|r！"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r 暗月马戏团 |cFFFF0000未开启|r。"
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r 已选增益：|cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r 此角色未预选增益。"
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r 塞吉增益：|cFF00FF00就绪|r！"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r 塞吉增益：还需 |cFFFF6600%s|r。"
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r 已获得增益！冷却时间：4小时。"
    L["AUTO_CLICK_ON"]           = "自动点击：开启"
    L["AUTO_CLICK_OFF"]          = "自动点击：关闭"
    L["OPTIONS_TITLE"]           = "暗月马戏团增益"
    L["OPTIONS_DESC"]            = "选择您希望从塞吉自动获得的增益。"
    L["OPTIONS_AUTOCLICK"]       = "启用塞吉对话自动点击"
    L["OPTIONS_AUTOCLICK_TT"]    = "启用后，与塞吉对话时插件将自动选择对话选项。"
    L["OPTIONS_NONE"]            = "无"
    L["OPTIONS_NONE_DESC"]       = "禁用自动增益选择"
    L["BUFF_DMG"]                = "+10% 伤害"
    L["BUFF_RES"]                = "+25 所有抗性"
    L["BUFF_ARM"]                = "+10% 护甲"
    L["BUFF_SPI"]                = "+10% 精神"
    L["BUFF_INT"]                = "+10% 智力"
    L["BUFF_STA"]                = "+10% 耐力"
    L["BUFF_STR"]                = "+10% 力量"
    L["BUFF_AGI"]                = "+10% 敏捷"
elseif locale == "zhTW" then
    L["ADDON_LOADED"]            = "|cFFD4AF37[DFB]|r 暗月馬戲團增益已載入。輸入 /dfb 開啟選項。"
    L["DMF_ACTIVE"]              = "|cFFD4AF37[DFB]|r 暗月馬戲團 |cFF00FF00正在進行|r！"
    L["DMF_NOT_ACTIVE"]          = "|cFFD4AF37[DFB]|r 暗月馬戲團 |cFFFF0000未開啟|r。"
    L["BUFF_SELECTED"]           = "|cFFD4AF37[DFB]|r 已選增益：|cFF00CCFF%s|r"
    L["NO_BUFF_SELECTED"]        = "|cFFD4AF37[DFB]|r 此角色未預選增益。"
    L["COOLDOWN_READY"]          = "|cFFD4AF37[DFB]|r 乘吉增益：|cFF00FF00就緒|r！"
    L["COOLDOWN_REMAINING"]      = "|cFFD4AF37[DFB]|r 乘吉增益：還需 |cFFFF6600%s|r。"
    L["BUFF_OBTAINED"]           = "|cFFD4AF37[DFB]|r 已獲得增益！冷卻時間：4小時。"
    L["AUTO_CLICK_ON"]           = "自動點擊：開啟"
    L["AUTO_CLICK_OFF"]          = "自動點擊：關閉"
    L["OPTIONS_TITLE"]           = "暗月馬戲團增益"
    L["OPTIONS_DESC"]            = "選擇您希望從乘吉自動獲得的增益。"
    L["OPTIONS_AUTOCLICK"]       = "啟用乘吉對話自動點擊"
    L["OPTIONS_AUTOCLICK_TT"]    = "啟用後，與乘吉對話時插件將自動選擇對話選項。"
    L["OPTIONS_NONE"]            = "無"
    L["OPTIONS_NONE_DESC"]       = "停用自動增益選擇"
    L["BUFF_DMG"]                = "+10% 傷害"
    L["BUFF_RES"]                = "+25 所有抗性"
    L["BUFF_ARM"]                = "+10% 護甲"
    L["BUFF_SPI"]                = "+10% 精神"
    L["BUFF_INT"]                = "+10% 智力"
    L["BUFF_STA"]                = "+10% 耐力"
    L["BUFF_STR"]                = "+10% 力量"
    L["BUFF_AGI"]                = "+10% 敏捷"
end

-- Buff label lookup
local BUFF_LABELS = {
    DMG = "BUFF_DMG",
    RES = "BUFF_RES",
    ARM = "BUFF_ARM",
    SPI = "BUFF_SPI",
    INT = "BUFF_INT",
    STA = "BUFF_STA",
    STR = "BUFF_STR",
    AGI = "BUFF_AGI",
}

----------------------------------------------------------------------
-- DARKMOON FAIRE DETECTION (language-independent keywords)
----------------------------------------------------------------------
-- We use substrings that appear in the calendar event title in each locale.
-- The calendar returns the localized event title so we check against all.
local DMF_KEYWORDS = {
    "darkmoon",     -- enUS/enGB
    "sombrelune",   -- frFR
    "dunkelmond",   -- deDE
    "luna negra",   -- esES/esMX
    "lunacupa",     -- itIT
    "negraluna",    -- ptBR/ptPT
    "новолуния",    -- ruRU (lowercase)
    "다크문",        -- koKR
    "暗月",          -- zhCN/zhTW
}

----------------------------------------------------------------------
-- STATE
----------------------------------------------------------------------
local DFB = CreateFrame("Frame", "DFBMainFrame", UIParent)
local db                       -- reference to DFBCharSettings after ADDON_LOADED
local isDMFActive = false
local gossipStep = 0           -- 0 = idle, 1 = answered Q1, 2 = answered Q2
local pendingFortune = false    -- true after Q2 until the final fortune screen is handled
local lastGossipTime = 0       -- GetTime() of last Sayge interaction
local optionsCategory = nil    -- Settings category object
local optionsPanel = nil       -- options frame
local buffButtons = {}         -- UI buttons in options panel
local autoclickCheckbox = nil
local fortuneCheckbox = nil
local recommendationText = nil
local lastMainMenuClick = 0

----------------------------------------------------------------------
-- UTILITY
----------------------------------------------------------------------
local function Print(msg)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

local function GetSpellDisplayInfo(spellId)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellId)
        if info then
            return info.name, info.iconID
        end
    end

    if GetSpellInfo then
        local name, _, icon = GetSpellInfo(spellId)
        return name, icon
    end

    return nil, nil
end

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then
        return string.format("%dh %02dm %02ds", h, m, s)
    elseif m > 0 then
        return string.format("%dm %02ds", m, s)
    else
        return string.format("%ds", s)
    end
end
local function GetCooldownRemaining()
    if not db or not db.cooldownExpiresAt then return 0 end
    local remaining = db.cooldownExpiresAt - time()
    if remaining <= 0 then
        db.cooldownExpiresAt = nil
        db.cooldownRemaining = 0
        return 0
    end
    return remaining
end

local function GetNPCIdFromGUID(guid)
    if not guid then return nil end
    -- GUID format: "Creature-0-xxxx-xxxx-xxxx-<npcId>-<spawnId>"
    local npcId = select(6, strsplit("-", guid))
    return tonumber(npcId)
end

local function IsSayge()
    local guid = UnitGUID("npc")
    return GetNPCIdFromGUID(guid) == SAYGE_NPC_ID
end

local function GetSelectedBuff()
    if not db or not db.selectedBuff or db.selectedBuff == "NONE" then
        return nil
    end
    for _, buff in ipairs(BUFF_TABLE) do
        if buff.id == db.selectedBuff then
            return buff
        end
    end
    return nil
end

local function GetBuffLabel(buffId)
    if not buffId or buffId == "NONE" then return nil end
    local key = BUFF_LABELS[buffId]
    if key then return L[key] end
    return nil
end
local function DebugPrint(...)
    if not db or not db.debug then return end
    Print("|cFF8888FFDEBUG|r " .. table.concat({ ... }, " "))
end

----------------------------------------------------------------------
-- PLAYER-AWARE BUFF RECOMMENDATION
----------------------------------------------------------------------
local REASON_BY_BUFF = {
    DMG = "RECOMMEND_REASON_DMG",
    ARM = "RECOMMEND_REASON_ARM",
    SPI = "RECOMMEND_REASON_SPI",
    INT = "RECOMMEND_REASON_INT",
    STA = "RECOMMEND_REASON_STA",
    STR = "RECOMMEND_REASON_STR",
    AGI = "RECOMMEND_REASON_AGI",
}

-- Determine the player's primary spec across client flavours.
-- Returns: index, name, weight (weight >= 10 means a real spec is chosen).
local function GetPrimaryTalentTab()
    -- Mists of Pandaria and later replaced the talent-tree/points API with the
    -- specialization API. On those clients GetNumTalentTabs() still EXISTS but
    -- throws ("API unsupported"), so prefer the spec API and guard every call.
    if GetSpecialization then
        local ok, specIndex = pcall(GetSpecialization)
        if ok and specIndex then
            local specName
            if GetSpecializationInfo then
                local infoOk, _, name = pcall(GetSpecializationInfo, specIndex)
                if infoOk then specName = name end
            end
            return specIndex, specName, 999
        end
    end

    -- Classic (Vanilla / Wrath-era) talent-tree API.
    if GetNumTalentTabs and GetTalentTabInfo then
        local ok, count = pcall(GetNumTalentTabs)
        if ok and count then
            local bestIndex, bestName, bestPoints = nil, nil, 0
            for i = 1, count do
                local name, _, pointsSpent = GetTalentTabInfo(i)
                pointsSpent = tonumber(pointsSpent) or 0
                if pointsSpent > bestPoints then
                    bestIndex = i
                    bestName = name
                    bestPoints = pointsSpent
                end
            end
            return bestIndex, bestName, bestPoints
        end
    end

    return nil, nil, 0
end

local function BuildRecommendation(primary, alternatives)
    return {
        primary = primary,
        alternatives = alternatives or {},
        reasonKey = REASON_BY_BUFF[primary] or "RECOMMEND_REASON_DMG",
    }
end

local function GetRecommendedBuffInfo()
    local _, classFile = UnitClass("player")
    local level = UnitLevel("player") or 1
    local specIndex, specName, specPoints = GetPrimaryTalentTab()
    local hasSpec = specPoints >= 10
    local isLeveling = level < 60
    local recommendation

    if classFile == "WARRIOR" then
        if hasSpec and specIndex == 3 then
            recommendation = BuildRecommendation("STA", { "ARM", "DMG" })
        else
            recommendation = BuildRecommendation("DMG", { "STR", "STA" })
        end
    elseif classFile == "ROGUE" then
        recommendation = BuildRecommendation("DMG", { "AGI", "STA" })
    elseif classFile == "HUNTER" then
        recommendation = BuildRecommendation("DMG", { "AGI", "STA" })
    elseif classFile == "MAGE" then
        if isLeveling then
            recommendation = BuildRecommendation("SPI", { "DMG", "INT" })
        else
            recommendation = BuildRecommendation("DMG", { "INT", "SPI" })
        end
    elseif classFile == "WARLOCK" then
        if isLeveling then
            recommendation = BuildRecommendation("DMG", { "STA", "SPI" })
        else
            recommendation = BuildRecommendation("DMG", { "STA", "INT" })
        end
    elseif classFile == "PRIEST" then
        if isLeveling or (hasSpec and specIndex == 3) then
            recommendation = BuildRecommendation("SPI", { "DMG", "INT" })
        else
            recommendation = BuildRecommendation("INT", { "SPI", "STA" })
        end
    elseif classFile == "PALADIN" then
        if hasSpec and specIndex == 1 then
            recommendation = BuildRecommendation("INT", { "SPI", "STA" })
        elseif hasSpec and specIndex == 2 then
            recommendation = BuildRecommendation("STA", { "ARM", "DMG" })
        else
            recommendation = BuildRecommendation("DMG", { "STR", "STA" })
        end
    elseif classFile == "SHAMAN" then
        if hasSpec and specIndex == 3 then
            recommendation = BuildRecommendation("INT", { "SPI", "STA" })
        elseif hasSpec and specIndex == 1 then
            recommendation = BuildRecommendation("DMG", { "INT", "STA" })
        else
            recommendation = BuildRecommendation("DMG", { "STR", "STA" })
        end
    elseif classFile == "DRUID" then
        if hasSpec and specIndex == 3 then
            recommendation = BuildRecommendation("INT", { "SPI", "STA" })
        elseif hasSpec and specIndex == 1 then
            recommendation = BuildRecommendation("DMG", { "INT", "STA" })
        elseif hasSpec and specIndex == 2 then
            recommendation = BuildRecommendation("DMG", { "AGI", "STA" })
        else
            recommendation = BuildRecommendation("DMG", { "AGI", "INT" })
        end
    else
        recommendation = BuildRecommendation("DMG", { "STA", "INT" })
    end

    recommendation.level = level
    recommendation.specName = hasSpec and specName or nil
    recommendation.isLeveling = isLeveling or not hasSpec

    return recommendation
end

local function GetRecommendationText(recommendation)
    if not recommendation or not recommendation.primary then
        return L["RECOMMENDATION_NONE"]
    end

    local label = GetBuffLabel(recommendation.primary) or recommendation.primary
    local reason = L[recommendation.reasonKey] or L["RECOMMEND_REASON_DMG"]

    return string.format(L["RECOMMENDATION_FORMAT"], label, reason)
end

local function RecommendationRank(buffId, recommendation)
    if not recommendation then return 50 end
    if buffId == recommendation.primary then return 1 end
    for idx, altId in ipairs(recommendation.alternatives or {}) do
        if buffId == altId then return 10 + idx end
    end
    return 30
end
local FORTUNE_KEYWORDS = {
    "fortune",
    "destin",
    "schicksal",
    "fortuna",
    "destino",
    "sorte",
    " ÑÑƒÐ´ÑŒ",
    "é‹å‹¢",
    "å‘½è¿",
    "å‘½é‹",
}

local function OptionLooksLikeFortuneStart(option)
    local text = option and (option.name or option.text or option.label)
    if not text then return false end

    local textLower = string.lower(text)
    for _, keyword in ipairs(FORTUNE_KEYWORDS) do
        if string.find(textLower, string.lower(keyword), 1, true) then
            return true
        end
    end

    return false
end

----------------------------------------------------------------------
-- DARKMOON FAIRE CALENDAR CHECK
----------------------------------------------------------------------
local function GetCurrentCalendarDate()
    if C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        local current = C_DateAndTime.GetCurrentCalendarTime()
        if current and current.year and current.month and current.monthDay then
            return current.year, current.month, current.monthDay
        end
    end

    local current = date("*t")
    if current then
        return current.year, current.month, current.day
    end

    return nil, nil, nil
end

local function IsDarkmoonFaireActiveBySchedule()
    local year, month, monthDay = GetCurrentCalendarDate()
    if not year or not month or not monthDay then return false end

    -- Classic Era Darkmoon Faire starts on the first Sunday of each month
    -- and stays open for 7 days.
    local firstDayTime = time({ year = year, month = month, day = 1, hour = 12 })
    if not firstDayTime then return false end

    local firstWeekday = tonumber(date("%w", firstDayTime)) -- 0 = Sunday
    if not firstWeekday then return false end

    local firstSunday = firstWeekday == 0 and 1 or (8 - firstWeekday)
    return monthDay >= firstSunday and monthDay <= (firstSunday + 6)
end

local function IsDarkmoonFaireCalendarEventToday()
    if not C_DateAndTime or not C_DateAndTime.GetCurrentCalendarTime then return false end
    if not C_Calendar or not C_Calendar.GetNumDayEvents or not C_Calendar.GetDayEvent then return false end

    local today = C_DateAndTime.GetCurrentCalendarTime()
    if not today or not today.monthDay then return false end

    local ok, numEvents = pcall(C_Calendar.GetNumDayEvents, 0, today.monthDay)
    if not ok or not numEvents then return false end

    for i = 1, numEvents do
        local event = C_Calendar.GetDayEvent(0, today.monthDay, i)
        if event and event.title then
            local titleLower = string.lower(event.title)
            for _, keyword in ipairs(DMF_KEYWORDS) do
                if string.find(titleLower, keyword, 1, true) then
                    return true
                end
            end
        end
    end

    return false
end

local function CheckDarkmoonFaire()
    return IsDarkmoonFaireCalendarEventToday() or IsDarkmoonFaireActiveBySchedule()
end

----------------------------------------------------------------------
-- STATUS ANNOUNCEMENT (on login / reload)
----------------------------------------------------------------------
local function AnnounceStatus()
    if isDMFActive then
        Print(L["DMF_ACTIVE"])
    else
        Print(L["DMF_NOT_ACTIVE"])
        return
    end

    -- Selected buff and cooldown are only useful while Sayge can actually be used.
    local buff = GetSelectedBuff()
    if buff then
        local label = GetBuffLabel(buff.id)
        if label then
            Print(string.format(L["BUFF_SELECTED"], label))
        end
    else
        Print(L["NO_BUFF_SELECTED"])
    end

    local cooldownRemaining = GetCooldownRemaining()
    if cooldownRemaining > 0 then
        Print(string.format(L["COOLDOWN_REMAINING"], FormatTime(cooldownRemaining)))
    else
        Print(L["COOLDOWN_READY"])
    end
end

----------------------------------------------------------------------
-- COOLDOWN TRACKING (OnUpdate timer)
----------------------------------------------------------------------
local elapsed_accumulator = 0
local lastCooldownReadyState = true

local function OnUpdateCooldown(self, elapsed)
    if not db then return end

    elapsed_accumulator = elapsed_accumulator + elapsed
    if elapsed_accumulator < 1.0 then return end
    elapsed_accumulator = 0

    local remaining = GetCooldownRemaining()
    local isReady = remaining <= 0
    if isReady and not lastCooldownReadyState then
        lastCooldownReadyState = true
        Print(L["COOLDOWN_READY"])
    elseif not isReady then
        lastCooldownReadyState = false
    end
end

----------------------------------------------------------------------
-- BUFF DETECTION (UNIT_AURA)
----------------------------------------------------------------------
local function CheckForSaygeBuff()
    if not db then return end
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i, "HELPFUL")
        if not name then break end
        if spellId and SAYGE_SPELL_SET[spellId] then
            -- Only set cooldown if we interacted with Sayge recently (within 15s)
            local now = GetTime()
            if (now - lastGossipTime) < 15 then
                db.cooldownExpiresAt = time() + COOLDOWN_DURATION
                db.cooldownRemaining = COOLDOWN_DURATION
                Print(L["BUFF_OBTAINED"])
                if not pendingFortune then
                    gossipStep = 0
                    lastGossipTime = 0
                end
            end
            return
        end
        i = i + 1
    end
end

----------------------------------------------------------------------
-- GOSSIP AUTOMATION
----------------------------------------------------------------------
local function GetOrderedGossipOptions()
    local rawOptions = C_GossipInfo.GetOptions()
    if not rawOptions then return nil end

    local ordered = {}
    for i, option in ipairs(rawOptions) do
        option._dfbIndex = i
        table.insert(ordered, option)
    end

    table.sort(ordered, function(a, b)
        local ao = a.orderIndex or a.order or a.index or a._dfbIndex or 0
        local bo = b.orderIndex or b.order or b.index or b._dfbIndex or 0
        if ao == bo then
            return (a._dfbIndex or 0) < (b._dfbIndex or 0)
        end
        return ao < bo
    end)

    return ordered
end

local function GetGossipText(option)
    return option and (option.name or option.text or option.gossipOptionText or option.optionText or "?") or "?"
end

local function DebugGossipOptions(context, options)
    if not db or not db.debug then return end
    DebugPrint(context)
    for i, option in ipairs(options or {}) do
        DebugPrint(string.format(
            "#%d id=%s order=%s text=%s",
            i,
            tostring(option.gossipOptionID),
            tostring(option.orderIndex or option.order or option.index),
            tostring(GetGossipText(option))
        ))
    end
end

local function SelectOrderedOption(options, targetIndex, context)
    local option = options and options[targetIndex]
    if not option or not option.gossipOptionID then return false end

    DebugPrint(string.format(
        "%s -> #%d id=%s order=%s text=%s",
        context or "Select",
        targetIndex,
        tostring(option.gossipOptionID),
        tostring(option.orderIndex or option.order or option.index),
        tostring(GetGossipText(option))
    ))
    C_GossipInfo.SelectOption(option.gossipOptionID)
    return true
end
local function CloseSaygeGossip()
    if C_GossipInfo and C_GossipInfo.CloseGossip then
        C_GossipInfo.CloseGossip()
    elseif CloseGossip then
        CloseGossip()
    end
end

local function HandleGossip()
    if not db then return end
    if not db.autoClick then return end
    if not IsSayge() then return end

    local buff = GetSelectedBuff()
    if not buff then return end

    -- The addon timer is informational only; Sayge/server state decides availability.
    if not C_GossipInfo or not C_GossipInfo.GetOptions or not C_GossipInfo.SelectOption then return end

    -- Use C_GossipInfo (WoW Classic 1.15+) and normalize to visible order.
    local options = GetOrderedGossipOptions()
    if not options or #options == 0 then return end

    local numOptions = #options
    DebugGossipOptions("step " .. tostring(gossipStep) .. " / " .. tostring(numOptions), options)

    -- Determine which step we're at based on number of gossip options
    if numOptions >= 4 and gossipStep == 0 then
        -- Question 1: the moral dilemma branch.
        local targetIndex = buff.a1
        if targetIndex >= 1 and targetIndex <= numOptions then
            gossipStep = 1
            lastGossipTime = GetTime()
            SelectOrderedOption(options, targetIndex, "Q1")
            return
        end
    elseif numOptions == 3 and gossipStep == 1 then
        -- Question 2: the follow-up choice inside the selected branch.
        local targetIndex = buff.a2
        if targetIndex >= 1 and targetIndex <= numOptions then
            gossipStep = 2
            pendingFortune = true
            lastGossipTime = GetTime()
            SelectOrderedOption(options, targetIndex, "Q2")
            return
        end
    elseif numOptions <= 2 and gossipStep == 0 and not pendingFortune then
        -- Main menu: always click the first Sayge dialogue line.
        local now = GetTime()
        if (now - lastMainMenuClick) < 2 then return end

        lastMainMenuClick = now
        lastGossipTime = now
        SelectOrderedOption(options, 1, "Main")
        return
    elseif numOptions <= 2 and (gossipStep == 2 or pendingFortune) then
        -- After Q2: optionally ask Sayge for the written Darkmoon Faire Fortune.
        gossipStep = 0
        pendingFortune = false
        lastGossipTime = GetTime()
        if db.requestFortune then
            SelectOrderedOption(options, numOptions, "Fortune")
            Print(L["FORTUNE_OBTAINED"])
        else
            CloseSaygeGossip()
            Print(L["FORTUNE_SKIPPED"])
        end
        return
    end
end

----------------------------------------------------------------------
-- OPTIONS PANEL (Premium Design)
----------------------------------------------------------------------
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "DFBOptionsPanel", UIParent)
    panel:SetSize(400, 570)
    panel:Hide()

    -- Buff grid geometry (computed once, reused for the grid itself and to align
    -- the description/checkbox column above it on the same left margin).
    local gridCols = 3
    local buttonW = 95
    local buttonH = 90
    local padX = 10
    local padY = 9
    local gridWidth = gridCols * buttonW + (gridCols - 1) * padX

    -- Dark background
    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.02, 0.14, 1) -- deep purple-black

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", panel, "TOP", 0, -16)
    title:SetText("|cFFD4AF37" .. L["OPTIONS_TITLE"] .. "|r")
    title:SetFont(title:GetFont(), 18, "OUTLINE")

    -- Decorative line under title
    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOP", title, "BOTTOM", 0, -6)
    line:SetSize(300, 2)
    line:SetColorTexture(0.83, 0.69, 0.22, 0.8) -- gold

    -- Description
    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOP", line, "BOTTOM", 0, -10)
    desc:SetWidth(gridWidth)
    desc:SetText(L["OPTIONS_DESC"])
    desc:SetTextColor(0.75, 0.75, 0.85)

    recommendationText = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    recommendationText:SetPoint("TOP", desc, "BOTTOM", 0, -10)
    recommendationText:SetWidth(gridWidth)
    recommendationText:SetTextColor(0.9, 0.8, 0.45)
    recommendationText:SetJustifyH("LEFT")
    recommendationText:SetText(GetRecommendationText(GetRecommendedBuffInfo()))

    -- Auto-click checkbox (left edge aligned with the grid's left column)
    local checkFrame = CreateFrame("CheckButton", "DFBAutoClickCheck", panel, "UICheckButtonTemplate")
    checkFrame:SetPoint("TOPLEFT", recommendationText, "BOTTOMLEFT", 0, -14)
    checkFrame:SetSize(26, 26)
    local checkLabel = checkFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkLabel:SetPoint("LEFT", checkFrame, "RIGHT", 4, 0)
    checkLabel:SetText(L["OPTIONS_AUTOCLICK"])
    checkLabel:SetTextColor(0.9, 0.85, 0.7)
    checkFrame:SetScript("OnClick", function(self)
        if db then
            db.autoClick = self:GetChecked()
            if db.autoClick then
                Print(L["AUTO_CLICK_ON"])
            else
                Print(L["AUTO_CLICK_OFF"])
            end
        end
    end)
    checkFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["OPTIONS_AUTOCLICK_TT"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    checkFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    autoclickCheckbox = checkFrame

    -- Fortune checkbox
    local fortuneFrame = CreateFrame("CheckButton", "DFBFortuneCheck", panel, "UICheckButtonTemplate")
    fortuneFrame:SetPoint("TOPLEFT", checkFrame, "BOTTOMLEFT", 0, -8)
    fortuneFrame:SetSize(26, 26)
    local fortuneLabel = fortuneFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fortuneLabel:SetPoint("LEFT", fortuneFrame, "RIGHT", 4, 0)
    fortuneLabel:SetText(L["OPTIONS_FORTUNE"])
    fortuneLabel:SetTextColor(0.9, 0.85, 0.7)
    fortuneFrame:SetScript("OnClick", function(self)
        if db then
            db.requestFortune = self:GetChecked()
        end
    end)
    fortuneFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L["OPTIONS_FORTUNE_TT"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    fortuneFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    fortuneCheckbox = fortuneFrame

    -- Buff grid: 3 columns x 3 rows (8 buffs + 1 "None")
    local recommendation = GetRecommendedBuffInfo()

    local gridEntries = {}
    for _, buff in ipairs(BUFF_TABLE) do
        local key = BUFF_LABELS[buff.id]
        table.insert(gridEntries, {
            id = buff.id,
            label = L[key],
            desc = L[key],
            spellId = buff.spellId,
            rank = RecommendationRank(buff.id, recommendation),
        })
    end
    table.sort(gridEntries, function(a, b)
        if a.rank == b.rank then
            return a.id < b.id
        end
        return a.rank < b.rank
    end)
    table.insert(gridEntries, { id = "NONE", label = L["OPTIONS_NONE"], desc = L["OPTIONS_NONE_DESC"], spellId = nil, rank = 99 })

    -- Colors
    local COLOR_SELECTED     = { r = 0.92, g = 0.72, b = 0.18 }
    local COLOR_HOVER        = { r = 0.34, g = 0.24, b = 0.48 }
    local COLOR_NORMAL       = { r = 0.22, g = 0.13, b = 0.34 }
    local COLOR_RECOMMENDED  = { r = 0.25, g = 0.15, b = 0.38 }
    local COLOR_ALTERNATIVE  = { r = 0.23, g = 0.14, b = 0.35 }
    local COLOR_BORDER_SEL   = { r = 0.92, g = 0.72, b = 0.18 }
    local COLOR_BORDER_REC   = { r = 0.48, g = 0.34, b = 0.18 }
    local COLOR_BORDER_ALT   = { r = 0.42, g = 0.36, b = 0.44 }
    local COLOR_BORDER_NORM  = { r = 0.32, g = 0.22, b = 0.46 }
    -- Blizzard's own square icon-frame atlas: a ring texture whose bounds are
    -- guaranteed to line up with a square icon at any size/UI scale, tinted
    -- per state instead of relying on custom raster art.
    local ICON_FRAME_TEXTURE = "Interface\\Common\\WhiteIconFrame"
    local COLOR_FRAME_SEL    = { r = 1.00, g = 0.82, b = 0.30 }
    local COLOR_FRAME_REC    = { r = 0.90, g = 0.72, b = 0.35 }
    local COLOR_FRAME_ALT    = { r = 0.75, g = 0.76, b = 0.82 }
    local COLOR_FRAME_NORM   = { r = 0.42, g = 0.38, b = 0.48 }
    -- Crown toppers: gold marks the recommendation, silver the alternatives.
    local CROWN_RECO_TEXTURE = "Interface\\AddOns\\DarkmoonFaireBuff\\Media\\Crown_Reco"
    local CROWN_ALT_TEXTURE  = "Interface\\AddOns\\DarkmoonFaireBuff\\Media\\Crown_Alt"

    local function UpdateButtonStates()
        for _, btn in ipairs(buffButtons) do
            local isSelected = db and db.selectedBuff == btn.buffId
            local isRecommended = btn.recommendationRank == 1
            local isAlternative = btn.recommendationRank and btn.recommendationRank > 10 and btn.recommendationRank < 20
            if isSelected then
                btn.border:SetColorTexture(COLOR_BORDER_SEL.r, COLOR_BORDER_SEL.g, COLOR_BORDER_SEL.b, 1)
                btn.bg:SetColorTexture(COLOR_NORMAL.r, COLOR_NORMAL.g, COLOR_NORMAL.b, 0.92)
                btn.selectedGlow:SetColorTexture(0.92, 0.72, 0.18, 0.12)
                btn.selectedGlow:Show()
                btn.frameRing:SetVertexColor(COLOR_FRAME_SEL.r, COLOR_FRAME_SEL.g, COLOR_FRAME_SEL.b, 1)
                btn.label:SetTextColor(1, 0.86, 0.36)
            elseif isRecommended then
                btn.border:SetColorTexture(COLOR_BORDER_REC.r, COLOR_BORDER_REC.g, COLOR_BORDER_REC.b, 1)
                btn.bg:SetColorTexture(COLOR_RECOMMENDED.r, COLOR_RECOMMENDED.g, COLOR_RECOMMENDED.b, 0.38)
                btn.selectedGlow:Hide()
                btn.frameRing:SetVertexColor(COLOR_FRAME_REC.r, COLOR_FRAME_REC.g, COLOR_FRAME_REC.b, 0.95)
                btn.label:SetTextColor(0.98, 0.86, 0.46)
            elseif isAlternative then
                btn.border:SetColorTexture(COLOR_BORDER_ALT.r, COLOR_BORDER_ALT.g, COLOR_BORDER_ALT.b, 1)
                btn.bg:SetColorTexture(COLOR_ALTERNATIVE.r, COLOR_ALTERNATIVE.g, COLOR_ALTERNATIVE.b, 0.35)
                btn.selectedGlow:Hide()
                btn.frameRing:SetVertexColor(COLOR_FRAME_ALT.r, COLOR_FRAME_ALT.g, COLOR_FRAME_ALT.b, 0.85)
                btn.label:SetTextColor(0.86, 0.82, 0.72)
            else
                btn.border:SetColorTexture(COLOR_BORDER_NORM.r, COLOR_BORDER_NORM.g, COLOR_BORDER_NORM.b, 0.65)
                btn.bg:SetColorTexture(COLOR_NORMAL.r, COLOR_NORMAL.g, COLOR_NORMAL.b, 0.88)
                btn.selectedGlow:Hide()
                btn.frameRing:SetVertexColor(COLOR_FRAME_NORM.r, COLOR_FRAME_NORM.g, COLOR_FRAME_NORM.b, 0.55)
                btn.label:SetTextColor(0.82, 0.80, 0.90)
            end
        end
    end

    -- Timer/cooldown text lives at the very bottom; create it up front so the
    -- grid can be vertically centred in the gap between the checkboxes and it.
    local cdText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cdText:SetPoint("BOTTOM", panel, "BOTTOM", 0, 20)
    cdText:SetWidth(360)
    cdText:SetTextColor(0.7, 0.7, 0.8)
    panel.cooldownText = cdText

    -- Grid metrics and crown sizing.
    local gridRows = math.ceil(#gridEntries / gridCols)
    local gridHeight = gridRows * buttonH + (gridRows - 1) * padY
    local CROWN_W, CROWN_H, CROWN_OVERLAP = 102, 51, 8
    local crownPoke = CROWN_H - CROWN_OVERLAP  -- how far a crown rises above its card

    -- Centre the whole block (crown toppers + card grid) in the vertical gap
    -- between the fortune checkbox and the timer. Anchoring both edges to real
    -- frames keeps it correct at any resolution / UI scale. The +X offset on the
    -- top anchor re-centres from the left-aligned checkbox onto the panel axis.
    local gridHolder = CreateFrame("Frame", nil, panel)
    gridHolder:SetWidth(gridWidth)
    gridHolder:SetPoint("TOP", fortuneFrame, "BOTTOM", gridWidth / 2 - 13, 0)
    gridHolder:SetPoint("BOTTOM", cdText, "TOP", 0, 6)

    for idx, entry in ipairs(gridEntries) do
        local col = ((idx - 1) % gridCols)
        local row = math.floor((idx - 1) / gridCols)
        local colX = (col - (gridCols - 1) / 2) * (buttonW + padX)
        -- Row 0 sits above centre; shift the whole grid down by half the crown
        -- height so the crowns-plus-cards block is centred as a unit.
        local rowY = (gridHeight / 2 - buttonH / 2) - row * (buttonH + padY) - crownPoke / 2

        local btn = CreateFrame("Button", "DFBBuff_" .. entry.id, panel)
        btn:SetSize(buttonW, buttonH)
        btn:SetPoint("CENTER", gridHolder, "CENTER", colX, rowY)
        btn.buffId = entry.id
        btn.recommendationRank = entry.rank
        btn.isRecommended = entry.rank == 1
        btn.isAlternative = entry.rank and entry.rank > 10 and entry.rank < 20

        -- Border (outer)
        local border = btn:CreateTexture(nil, "BORDER")
        border:SetPoint("TOPLEFT", -2, 2)
        border:SetPoint("BOTTOMRIGHT", 2, -2)
        border:SetColorTexture(COLOR_BORDER_NORM.r, COLOR_BORDER_NORM.g, COLOR_BORDER_NORM.b, 0.65)
        btn.border = border

        -- Background (inner)
        local btnBg = btn:CreateTexture(nil, "ARTWORK")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(COLOR_NORMAL.r, COLOR_NORMAL.g, COLOR_NORMAL.b, 0.8)
        btn.bg = btnBg

        -- Selected glow (subtle golden overlay)
        local glow = btn:CreateTexture(nil, "ARTWORK", nil, 2)
        glow:SetAllPoints()
        glow:SetColorTexture(0.83, 0.69, 0.22, 0.12)
        glow:Hide()
        btn.selectedGlow = glow

        -- Frame ring: a Blizzard atlas texture tinted per state, anchored purely
        -- via relative offsets so it always lines up with the square and scales
        -- correctly at any resolution/UI scale (no custom raster art involved).
        local frameRing = btn:CreateTexture(nil, "OVERLAY", nil, -1)
        frameRing:SetPoint("TOPLEFT", -3, 3)
        frameRing:SetPoint("BOTTOMRIGHT", 3, -3)
        frameRing:SetTexture(ICON_FRAME_TEXTURE)
        btn.frameRing = frameRing

        -- Crown topper: gold for the recommendation, silver for the two
        -- alternatives. Sized in UI units, so it scales with any resolution.
        if entry.rank == 1 or (entry.rank and entry.rank > 10 and entry.rank < 20) then
            local crown = btn:CreateTexture(nil, "OVERLAY", nil, 3)
            crown:SetSize(CROWN_W, CROWN_H)
            crown:SetPoint("BOTTOM", btn, "TOP", 0, -CROWN_OVERLAP)
            crown:SetTexture(entry.rank == 1 and CROWN_RECO_TEXTURE or CROWN_ALT_TEXTURE)
            btn.crown = crown
        end

        -- Icon
        local icon = btn:CreateTexture(nil, "OVERLAY")
        icon:SetSize(36, 36)
        -- Icon/X centred low in the card (~44% down); as far down as the
        -- two-line labels below it allow without overlap.
        icon:SetPoint("CENTER", btn, "TOP", 0, -40)
        if entry.spellId then
            local _, spellIcon = GetSpellDisplayInfo(entry.spellId)
            if spellIcon then
                icon:SetTexture(spellIcon)
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
        else
            -- "None" button: a red X (native ready-check texture, scales
            -- cleanly). Sized up slightly to offset its transparent padding.
            icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
            icon:SetSize(42, 42)
        end
        btn.icon = icon

        -- (The "Reco" / "Alt" label is baked into the crown texture's banner.)

        -- Label
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("BOTTOM", btn, "BOTTOM", 0, 6)
        lbl:SetWidth(buttonW - 8)
        lbl:SetText(entry.label)
        lbl:SetTextColor(0.8, 0.8, 0.9)
        btn.label = lbl
        -- Click handler
        btn:SetScript("OnClick", function()
            if db then
                db.selectedBuff = entry.id
                UpdateButtonStates()
                C_Timer.After(0, UpdateButtonStates)
                if entry.id == "NONE" then
                    Print(L["NO_BUFF_SELECTED"])
                else
                    Print(string.format(L["BUFF_SELECTED"], entry.label))
                end
            end
        end)

        -- Hover effects
        btn:SetScript("OnEnter", function(self)
            local isSelected = db and db.selectedBuff == self.buffId
            if not isSelected then
                self.bg:SetColorTexture(COLOR_HOVER.r, COLOR_HOVER.g, COLOR_HOVER.b, 0.5)
                self.border:SetColorTexture(COLOR_HOVER.r, COLOR_HOVER.g, COLOR_HOVER.b, 0.8)
            end
            -- Tooltip with spell name if applicable
            if entry.spellId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                local spellName = GetSpellDisplayInfo(entry.spellId)
                if spellName then
                    GameTooltip:SetText(spellName, 1, 0.84, 0)
                    GameTooltip:AddLine(entry.desc, 1, 1, 1, true)
                else
                    GameTooltip:SetText(entry.desc, 1, 1, 1)
                end
                GameTooltip:Show()
            elseif entry.desc then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(entry.desc, 1, 1, 1)
                GameTooltip:Show()
            end
        end)

        btn:SetScript("OnLeave", function(self)
            UpdateButtonStates()
            GameTooltip:Hide()
        end)

        table.insert(buffButtons, btn)
    end

    -- Update cooldown text periodically
    panel:SetScript("OnUpdate", function(self, elapsed)
        if not self:IsShown() or not db then return end
        local cooldownRemaining = GetCooldownRemaining()
        if cooldownRemaining > 0 then
            self.cooldownText:SetText(string.format(L["COOLDOWN_REMAINING"], FormatTime(cooldownRemaining)))
        else
            self.cooldownText:SetText(L["COOLDOWN_READY"])
        end
    end)

    -- Store UpdateButtonStates on panel for later refresh
    panel.UpdateButtonStates = UpdateButtonStates

    return panel
end

local function RefreshOptionsPanel()
    if not optionsPanel then return end
    if autoclickCheckbox and db then
        autoclickCheckbox:SetChecked(db.autoClick)
    end
    if fortuneCheckbox and db then
        fortuneCheckbox:SetChecked(db.requestFortune)
    end
    if recommendationText then
        recommendationText:SetText(GetRecommendationText(GetRecommendedBuffInfo()))
    end
    if optionsPanel.UpdateButtonStates then
        optionsPanel.UpdateButtonStates()
    end
end

----------------------------------------------------------------------
-- REGISTER OPTIONS
----------------------------------------------------------------------
local function RegisterOptions()
    optionsPanel = CreateOptionsPanel()
    optionsPanel.name = L["OPTIONS_TITLE"]

    if not Settings or not Settings.RegisterCanvasLayoutCategory or not Settings.RegisterAddOnCategory then
        return
    end

    local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, optionsPanel.name, optionsPanel.name)
    category.ID = category.ID or addonName
    Settings.RegisterAddOnCategory(category)
    optionsCategory = category

    -- Show callback: refresh state when panel becomes visible
    optionsPanel:SetScript("OnShow", function()
        RefreshOptionsPanel()
    end)
end

----------------------------------------------------------------------
-- SLASH COMMANDS
----------------------------------------------------------------------
SLASH_DFB1 = "/dfb"
SLASH_DFB2 = "/DFB"
SlashCmdList["DFB"] = function(msg)
    msg = string.lower(strtrim(msg or ""))

    if msg == "debug" then
        db.debug = not db.debug
        Print("Debug: " .. (db.debug and "ON" or "OFF"))
        return
    elseif msg == "status" then
        local buff = GetSelectedBuff()
        local selectedText = buff and (GetBuffLabel(buff.id) or buff.id) or L["OPTIONS_NONE"]
        local selectedColor = buff and "|cFF00CCFF" or "|cFFFF5555"

        Print("|cFFD4AF37[DFB]|r |cFFFFFFFFStatus|r")
        Print("  Selected: " .. selectedColor .. tostring(selectedText) .. "|r (" .. tostring(db.selectedBuff) .. ")")
        if buff then
            Print("  Sayge path: |cFF00FF00" .. tostring(buff.a1) .. "." .. tostring(buff.a2) .. "|r  spellId=|cFFAAAAFF" .. tostring(buff.spellId) .. "|r")
        end
        local cooldownRemaining = GetCooldownRemaining()
        if cooldownRemaining > 0 then
            Print("  Addon timer: |cFFFF6600" .. FormatTime(cooldownRemaining) .. "|r remaining (informational)")
        else
            Print("  Addon timer: |cFF00FF00no addon lock|r")
        end
        Print("  Auto-click: " .. (db.autoClick and "|cFF00FF00ON|r" or "|cFFFF5555OFF|r") .. "  Fortune: " .. (db.requestFortune and "|cFF00FF00ON|r" or "|cFFFF5555OFF|r") .. "  Debug: " .. (db.debug and "|cFF00FF00ON|r" or "|cFFFF5555OFF|r"))
        return
    elseif msg == "reset" then
        db.cooldownRemaining = 0
        db.cooldownExpiresAt = nil
        gossipStep = 0
        pendingFortune = false
        Print("Addon timer reset.")
        return
    end

    if optionsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(optionsCategory.ID or optionsCategory)
    end
end

----------------------------------------------------------------------
-- EVENT HANDLING
----------------------------------------------------------------------
DFB:RegisterEvent("ADDON_LOADED")
DFB:RegisterEvent("PLAYER_ENTERING_WORLD")
DFB:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
DFB:RegisterEvent("GOSSIP_SHOW")
DFB:RegisterEvent("GOSSIP_CLOSED")
DFB:RegisterEvent("UNIT_AURA")

local hasAnnounced = false
local calendarRequested = false

DFB:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            -- Initialize saved variables
            if not DFBCharSettings then
                DFBCharSettings = {}
            end
            db = DFBCharSettings

            -- Defaults
            if db.selectedBuff == nil then db.selectedBuff = "NONE" end
            if db.autoClick == nil then db.autoClick = true end
            if db.requestFortune == nil then db.requestFortune = true end
            -- Old versions stored an online-only remaining timer. Drop it once and use real-time expiry instead.
            if db.cooldownExpiresAt == nil then db.cooldownRemaining = 0 end
            if db.debug == nil then db.debug = false end

            -- Register options panel
            RegisterOptions()

            -- Start cooldown timer
            self:SetScript("OnUpdate", OnUpdateCooldown)

            Print(L["ADDON_LOADED"])
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Request calendar data
        if not calendarRequested and C_Calendar and C_Calendar.OpenCalendar then
            C_Calendar.OpenCalendar()
            calendarRequested = true
        end
        -- Reset gossip step on zone change
        gossipStep = 0

        C_Timer.After(3, function()
            if not hasAnnounced and db then
                isDMFActive = CheckDarkmoonFaire()
                hasAnnounced = true
                AnnounceStatus()
            end
        end)

    elseif event == "CALENDAR_UPDATE_EVENT_LIST" then
        -- Check DMF status
        isDMFActive = CheckDarkmoonFaire()
        -- Announce once after login
        if not hasAnnounced and db then
            hasAnnounced = true
            AnnounceStatus()
        end

    elseif event == "GOSSIP_SHOW" then
        -- Small delay to let the UI populate
        C_Timer.After(0.1, function()
            HandleGossip()
        end)

    elseif event == "GOSSIP_CLOSED" then
        -- Reset gossip step if the window was closed manually
        -- Only reset if we haven't completed the full flow
        if gossipStep ~= 2 then
            gossipStep = 0
        end

    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            CheckForSaygeBuff()
        end
    end
end)

