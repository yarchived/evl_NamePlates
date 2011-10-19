-- Credit: evl, Caellian

local NORMAL_TEXTURE = [[Interface\Addons\evl_NamePlates\Minimalist]]
local GLOW_TEXTURE = [[Interface\Addons\evl_NamePlates\glowTex]]

local UPDATE_FREQUENCY = 0.2
local f = CreateFrame('Frame', 'evl_NamePlates', UIParent)
f.Frames = {}
local framesShown = {}

local backdrop = {
    edgeFile = GLOW_TEXTURE, edgeSize = 5,
    insets = {left = 3, right = 3, top = 3, bottom = 3}
}

--local function updateGlow(self)
--    --self.glow:SetBackdropBorderColor(0,0,0)
--    if self.old_glow:IsShown() then
--        self.glow:Show()
--        self.glow:SetBackdropBorderColor(self.old_glow:GetVertexColor())
--    else
--        self.glow:Hide()
--    end
--end

local function Glow_SetVertexColor(self, ...)
    self.frame.glow:SetBackdropBorderColor(...)
end

local function Glow_Show(self)
    self.frame.glow:Show()
end

local function Glow_Hide(self)
    self.frame.glow:Hide()
end

--local function showCheck(self)
--    if self:IsVisible() then
--        self.healthBar:SetHeight(5)
--        updateGlow(self)
--        framesShown[self] = true
--    else
--        framesShown[self] = nil
--    end
--end

function updateFrame(frame)
    local healthBar, castBar = frame:GetChildren()

    local glowRegion, overlayRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()
    local _, castbarOverlay, shieldedRegion, spellIconRegion = castBar:GetRegions()

    frame.healthBar = healthBar
    frame.castBar = castBar

    -- Border on top
    overlayRegion:Hide()

    -- Icons
    --bossIconRegion:Hide()
    --stateIconRegion:Hide()

    -- Name text
    nameTextRegion:ClearAllPoints()
    nameTextRegion:SetPoint('BOTTOM', healthBar, 'TOP', 3, 3)
    nameTextRegion:SetFont(DAMAGE_TEXT_FONT, 9, 'OUTLINE') -- THINOUTLINE NAMEPLATE_FONT
    nameTextRegion:SetShadowColor(1,1,1,0)

    -- Level text
    levelTextRegion:ClearAllPoints()
    levelTextRegion:SetPoint('LEFT', healthBar, 'RIGHT', 2, 0)
    levelTextRegion:SetFont(DAMAGE_TEXT_FONT, 9, 'OUTLINE')
    levelTextRegion:SetShadowColor(1,1,1,0)

    -- Highlight which shows up on mouseover
    highlightRegion:SetHeight(8)
    highlightRegion:SetTexture(NORMAL_TEXTURE)
    highlightRegion:SetAlpha(0)

    -- Health bar
    healthBar:SetStatusBarTexture(NORMAL_TEXTURE)

    -- Threat
    glowRegion:SetTexture('')
    frame.old_glow = glowRegion

    frame.glow = CreateFrame("Frame", nil, healthBar)
    frame.glow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -4.5, 4)
    frame.glow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 4.5, -4.5)
    frame.glow:SetBackdrop(backdrop)
    frame.glow:SetBackdropColor(0, 0, 0)
    frame.glow:SetBackdropBorderColor(0, 0, 0)

    glowRegion.__owner = frame
    hooksecurefunc(glowRegion, SetVertexColor, Glow_SetVertexColor)
    hooksecurefunc(glowRegion, Show, Glow_Show)
    hooksecurefunc(glowRegion, Hide, Glow_Hide)

    --frame:SetScript('OnShow', showCheck)
    --frame:SetScript('OnHide', showCheck)
    --showCheck(frame)

    -- Cast bar
    --castBar:SetHeight(5)
    --castBar:SetStatusBarTexture(NORMAL_TEXTURE)

    -- Background
    frame.nameplates_background = healthBar:CreateTexture(nil, 'BORDER')
    frame.nameplates_background:SetAllPoints(healthBar)
    frame.nameplates_background:SetTexture(NORMAL_TEXTURE)
    frame.nameplates_background:SetVertexColor(.1, .1, .1, .9)

    f.Frame[frame] = true
end

local isValidFrame = function(frame)
    local overlayRegion = select(2, frame:GetRegions())

    if overlayRegion and (overlayRegion:GetObjectType() == 'Texture') and (overlayRegion:GetTexture() == [[Interface\Tooltips\Nameplate-Border]]) then
        return true
    end
end

local total = .5
local numChildren = 0
f:SetScript('OnUpdate', function(self, elapsed)
    total = total - elapsed
    if total > 0 then return end
    total = UPDATE_FREQUENCY

    --for frame in next, framesShown do
    --    updateGlow(frame)
    --end

    local num = WorldFrame:GetNumChildren()
    if num > numChildren then
        numChildren = num
        self:Update()
    end
end)

function f:Update()
    for i = 1, select('#', WorldFrame:GetChildren()) do
        frame = select(i, WorldFrame:GetChildren())

        if(not self.Frames[frame]) and (not frame:GetName()) and isValidFrame(frame) then
            makeup(frame)
        end
    end		
end

