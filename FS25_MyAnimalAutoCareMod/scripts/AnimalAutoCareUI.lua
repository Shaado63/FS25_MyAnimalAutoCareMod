AnimalAutoCareUI = {}
AnimalAutoCareUI_mt = Class(AnimalAutoCareUI)

function AnimalAutoCareUI:new(animalAutoCare)
    local self = setmetatable({}, AnimalAutoCareUI_mt)
    self.animalAutoCare = animalAutoCare
    self.visible = false

    -- Dimensions de la fenêtre (en ratio écran)
    self.x = 0.4
    self.y = 0.3
    self.width = 0.2
    self.height = 0.25

    -- Options avec cases à cocher
    self.options = {
        {name = "Nourriture", field = "autoFeedEnabled"},
        {name = "Eau", field = "autoWaterEnabled"},
        {name = "Paille", field = "autoStrawEnabled"}
    }

    return self
end

function AnimalAutoCareUI:toggleVisibility()
    self.visible = not self.visible
end

function AnimalAutoCareUI:keyEvent(unicode, sym, modifier, isDown)
    if not self.visible or not isDown then return end

    -- Fermer le menu avec ESC
    if sym == Input.KEY_ESCAPE then
        self.visible = false
    end
end

function AnimalAutoCareUI:draw()
    if not self.visible then return end

    -- Fond semi-transparent
    drawRect(self.x, self.y, self.width, self.height, 0.1, 0.1, 0.1, 0.8)

    -- Texte en blanc
    setTextColor(1, 1, 1, 1)

    -- Titre
    setTextBold(true)
    renderText(self.x + 0.02, self.y + self.height - 0.04, 0.02, "Gestion Auto Animaux")
    setTextBold(false)

    -- Cases à cocher
    local yOffset = 0.06
    for i, option in ipairs(self.options) do
        local isChecked = self.animalAutoCare[option.field]
        local checkboxX = self.x + 0.02
        local checkboxY = self.y + self.height - (yOffset + (i * 0.05))

        local text = string.format("[%s] %s", isChecked and "X" or " ", option.name)
        renderText(checkboxX, checkboxY, 0.018, text)
    end

    -- Instructions pour fermer
    renderText(self.x + 0.02, self.y + 0.01, 0.015, "Appuie sur Échap pour fermer")
end

function AnimalAutoCareUI:mouseEvent(posX, posY, isDown, isUp, button)
    if not self.visible then return false end

    for i, option in ipairs(self.options) do
        local checkboxX = self.x + 0.02
        local checkboxY = self.y + self.height - (0.06 + i * 0.05)
        local checkboxWidth = 0.15
        local checkboxHeight = 0.03

        if posX >= checkboxX and posX <= checkboxX + checkboxWidth and
           posY >= checkboxY and posY <= checkboxY + checkboxHeight then
            if isDown then
                self.animalAutoCare[option.field] = not self.animalAutoCare[option.field]
                print("[AnimalAutoCareUI] " .. option.name .. " " .. (self.animalAutoCare[option.field] and "activé" or "désactivé"))
            end
            return true
        end
    end

    return false
end
