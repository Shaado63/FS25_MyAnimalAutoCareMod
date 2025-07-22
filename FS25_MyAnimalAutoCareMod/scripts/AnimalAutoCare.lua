AnimalAutoCare = {}
AnimalAutoCare.MOD_NAME = "AnimalAutoCare"
AnimalAutoCare.MOD_DIR = g_currentModDirectory

local AnimalAutoCare_mt = Class(AnimalAutoCare)

function AnimalAutoCare:new()
    local self = setmetatable({}, AnimalAutoCare_mt)
    self.isEnabled = true
    self.autoFeedEnabled = true
    self.autoWaterEnabled = true
    self.autoStrawEnabled = true

    self.dailyFeedCost = 100
    self.dailyWaterCost = 50
    self.dailyStrawCost = 75

    self.lastUpdateDay = -1
    self.actionEvents = {}

    return self
end

function AnimalAutoCare:loadMap(name)
	self.isClient = g_client ~= nil
	print("[AnimalAutoCare] ➤ loadMap appelé")
    print("[" .. self.MOD_NAME .. "] Mod chargé.")
    self.lastUpdateDay = g_currentMission.environment.currentDay or 0

    -- Créer UI
    if g_animalAutoCareUI == nil then
        g_animalAutoCareUI = AnimalAutoCareUI:new(self)
    end

    -- Enregistrer touches
    self:registerActionEvents()
	if self.isClient then
	end
end

function AnimalAutoCare:deleteMap()
    for _, eventId in ipairs(self.actionEvents) do
        g_inputBinding:removeActionEvent(eventId)
    end
end

function AnimalAutoCare:registerActionEvents()
    if self.isClient then
        local _, openMenuEventId = g_inputBinding:registerActionEvent('OPEN_AUTOCARE_MENU', self, AnimalAutoCare.onOpenMenu, false, true, false, true)
        table.insert(self.actionEvents, openMenuEventId)

        local _, toggleAutoEventId = g_inputBinding:registerActionEvent('TOGGLE_AUTOCARE', self, AnimalAutoCare.onToggleAutoCare, false, true, false, true)
        table.insert(self.actionEvents, toggleAutoEventId)
    end
end

function AnimalAutoCare:onOpenMenu(actionName, inputValue, callbackState, isAnalog)
    if g_animalAutoCareUI then
        g_animalAutoCareUI:toggleVisibility()
    end
end

function AnimalAutoCare:onToggleAutoCare(actionName, inputValue, callbackState, isAnalog)
    self.isEnabled = not self.isEnabled
    print("[" .. self.MOD_NAME .. "] Automatisation " .. (self.isEnabled and "activée" or "désactivée"))
end

function AnimalAutoCare:keyEvent(unicode, sym, modifier, isDown)
    if g_animalAutoCareUI then
        g_animalAutoCareUI:keyEvent(unicode, sym, modifier, isDown)
    end
end

function AnimalAutoCare:mouseEvent(posX, posY, isDown, isUp, button)
    if g_animalAutoCareUI then
        return g_animalAutoCareUI:mouseEvent(posX, posY, isDown, isUp, button)
    end
    return false
end

function AnimalAutoCare:update(dt)
     -- Affiche un texte temporaire à l'écran
    renderText(0.4, 0.9, 0.02, "[AutoCare actif]")

    if g_animalAutoCareUI ~= nil then
        g_animalAutoCareUI:draw()
    end

    local currentDay = g_currentMission.environment.currentDay or 0
    if currentDay ~= self.lastUpdateDay then
        self.lastUpdateDay = currentDay
        self:performDailyCare()
    end
end

function AnimalAutoCare:draw()
    if g_animalAutoCareUI then
        g_animalAutoCareUI:draw()
    end
end

function AnimalAutoCare:performDailyCare()
    if not self.isEnabled then return end
	if g_currentMission.husbandrySystem == nil or g_currentMission.husbandrySystem.husbandries == nil then return end

    local cost = 0

    if self.autoFeedEnabled then
        self:feedAnimals()
        cost = cost + self.dailyFeedCost
    end

    if self.autoWaterEnabled then
        self:waterAnimals()
        cost = cost + self.dailyWaterCost
    end

    if self.autoStrawEnabled then
        self:addStraw()
        cost = cost + self.dailyStrawCost
    end

    if cost > 0 then
        g_currentMission:addMoney(-cost, g_currentMission:getFarmId(), "expense", true)
        print("[" .. self.MOD_NAME .. "] Coût journalier : -" .. cost .. " €")
    end
end

function AnimalAutoCare:feedAnimals()
    for _, husbandry in pairs(g_currentMission.husbandrySystem.husbandries) do
        if husbandry.spec_fillLevels ~= nil then
            local fillType = husbandry:getFoodFillType()
            local capacity = husbandry:getFoodCapacity()
            husbandry:addFillLevel(g_currentMission:getFarmId(), capacity, fillType, ToolType.UNDEFINED, nil)
        end
    end
    print("[" .. self.MOD_NAME .. "] Animaux nourris.")
end

function AnimalAutoCare:waterAnimals()
    for _, husbandry in pairs(g_currentMission.husbandrySystem.husbandries) do
        if husbandry.spec_fillLevels ~= nil then
            local capacity = husbandry:getFillLevelCapacity(FillType.WATER)
            husbandry:addFillLevel(g_currentMission:getFarmId(), capacity, FillType.WATER, ToolType.UNDEFINED, nil)
        end
    end
    print("[" .. self.MOD_NAME .. "] Eau ajoutée.")
end

function AnimalAutoCare:addStraw()
    for _, husbandry in pairs(g_currentMission.husbandrySystem.husbandries) do
        if husbandry.spec_fillLevels ~= nil then
            local capacity = husbandry:getFillLevelCapacity(FillType.STRAW)
            husbandry:addFillLevel(g_currentMission:getFarmId(), capacity, FillType.STRAW, ToolType.UNDEFINED, nil)
        end
    end
    print("[" .. self.MOD_NAME .. "] Paille ajoutée.")
end

-- Enregistrement du mod
g_animalAutoCare = AnimalAutoCare:new()
addModEventListener(g_animalAutoCare)
