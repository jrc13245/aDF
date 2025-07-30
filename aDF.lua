--########### armor and Debuff Frame
--########### By Atreyyo @ Vanillagaming.org

local has_superwow = SetAutoloot and true or false
aDF = CreateFrame('Button', "aDF", UIParent); -- Event Frame
aDF.Options = CreateFrame("Frame",nil,UIParent) -- Options frame

--register events 
aDF:RegisterEvent("ADDON_LOADED")
aDF:RegisterEvent("UNIT_AURA")
aDF:RegisterEvent("PLAYER_TARGET_CHANGED")
aDF:RegisterEvent("UNIT_CASTEVENT")
aDF:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
aDF:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
aDF:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")

function aDF:SendChatMessage(msg,chan)
  if chan and chan ~= "None" and chan ~= "" then
		SendChatMessage(msg,chan)
	end
end

-- tables 
aDF_frames = {} -- we will put all debuff frames in here
aDF_guiframes = {} -- we wil put all gui frames here
gui_Options = gui_Options or {} -- checklist options
gui_Optionsxy = gui_Optionsxy or 1
gui_chantbl = {
	"None",
	"Say",
	"Yell",
	"Party",
	"Raid",
	"Raid_Warning"
 }

local last_target_change_time = GetTime()

-- translation table for debuff check on target

aDFSpells = {
	["Sunder Armor"] = "Sunder Armor",
	["Armor Shatter"] = "Armor Shatter",
	["Faerie Fire"] = "Faerie Fire",
	["Faerie Fire (Feral)"] = "Faerie Fire (Feral)",
	["Nightfall"] = "Spell Vulnerability",
	["Flame Buffet"] = "Flame Buffet",
	["Scorch"] = "Fire Vulnerability",
	["Ignite"] = "Ignite",
	["Curse of Recklessness"] = "Curse of Recklessness",
	["Curse of the Elements"] = "Curse of the Elements",
	["Curse of Shadows"] = "Curse of Shadow",
	["Shadow Bolt"] = "Shadow Vulnerability",
	["Shadow Weaving"] = "Shadow Weaving",
	["Expose Armor"] = "Expose Armor",
}
	--["Vampiric Embrace"] = "Vampiric Embrace",
	--["Crystal Yield"] = "Crystal Yield",
	--["Mage T3 6/9 Bonus"] = "Elemental Vulnerability",
-- table with names and textures 

aDFDebuffs = {
	["Sunder Armor"] = "Interface\\Icons\\Ability_Warrior_Sunder",
	["Armor Shatter"] = "Interface\\Icons\\INV_Axe_12",
	["Faerie Fire"] = "Interface\\Icons\\Spell_Nature_FaerieFire",
	["Faerie Fire (Feral)"] = "Interface\\Icons\\Spell_Nature_FaerieFire",
	["Nightfall"] = "Interface\\Icons\\Spell_Holy_ElunesGrace",
	["Flame Buffet"] = "Interface\\Icons\\Spell_Fire_Fireball",
	["Scorch"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
	["Ignite"] = "Interface\\Icons\\Spell_Fire_Incinerate",
	["Curse of Recklessness"] = "Interface\\Icons\\Spell_Shadow_UnholyStrength",
	["Curse of the Elements"] = "Interface\\Icons\\Spell_Shadow_ChillTouch",
	["Curse of Shadows"] = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
	["Shadow Bolt"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
	["Shadow Weaving"] = "Interface\\Icons\\Spell_Shadow_BlackPlague",
	["Expose Armor"] = "Interface\\Icons\\Ability_Warrior_Riposte",
}
	--["Vampiric Embrace"] = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
	--["Crystal Yield"] = "Interface\\Icons\\INV_Misc_Gem_Amethyst_01",
	--["Elemental Vulnerability"] = "Interface\\Icons\\Spell_Holy_Dizzy",

aDFArmorVals = {
	[90]   = "Sunder Armor x1", -- r1 x1
	[180]  = "Sunder Armor",    -- r2 x1, or r1 x2
	[270]  = "Sunder Armor",    -- r3 x1, or r1 x3
	[540]  = "Sunder Armor",    -- r3 x2, or r2 x3
	[810]  = "Sunder Armor x3", -- r3 x3
	[360]  = "Sunder Armor",    -- r4 x1, or r1 x4 or r2 x2
	[720]  = "Sunder Armor",    -- r4 x2, or r2 x4
	[1080] = "Sunder Armor",    -- r4 x3, or r3 x4
	[1440] = "Sunder Armor x4", -- r4 x4
	[450]  = "Sunder Armor",    -- r5 x1, or r1 x5
	[900]  = "Sunder Armor",    -- r5 x2, or r2 x5
	[1350] = "Sunder Armor",    -- r5 x3, or r3 x5
	[1800] = "Sunder Armor",    -- r5 x4, or r4 x5
	[2250] = "Sunder Armor x5", -- r5 x5
--[600]  = "Improved Expose Armor",   -- r1 -- conflicts with anni/rivenspike
--[400]  = "Untalented Expose Armor", -- r1 -- conflicts with anni/rivenspike
-- 	[] = "Improved Expose Armor",  -- 5pt IEA r2 r3 r4 values unknown
	[725]  = "Untalented Expose Armor",
-- 	[] = "Improved Expose Armor",
	[1050] = "Untalented Expose Armor",
-- 	[] = "Improved Expose Armor",
	[1375] = "Untalented Expose Armor",
	[510]  = "Fucked up IEA?",
	[1020] = "Fucked up IEA?",
	[1530] = "Fucked up IEA?",
	[2040] = "Fucked up IEA?",
	[2550] = "Improved Expose Armor",
	[1700] = "Untalented Expose Armor",
	[505]  = "Faerie Fire",
	[395]  = "Faerie Fire R3",
	[285]  = "Faerie Fire R2",
	[175]  = "Faerie Fire R1",
	[640]  = "Curse of Recklessness",
	[465]  = "Curse of Recklessness R3",
	[290]  = "Curse of Recklessness R2",
	[140]  = "Curse of Recklessness R1",
	[600]  = "Annihilator x3 ?", --
	[400]  = "Annihilator x2 ?", -- Armor Shatter spell=16928, or Puncture Armor r2 spell=17315
	[200]  = "Annihilator x1 ?", --
	[50]   = "Torch of Holy Flame", -- Can also be spell=13526, item=1434 but those conflict FF
	[100]  = "Weapon Proc Faerie Fire", -- non-stacking proc spell=13752, Puncture Armor r1 x1 spell=11791
	[300]  = "Weapon Proc Faerie Fire", -- Dark Iron Sunderer item=11607, Puncture Armor r1 x3
}

function aDF_Default()
    for k,v in pairs(aDFDebuffs) do
        if gui_Options[k] == nil then
            gui_Options[k] = 1
        end
    end
end

-- the main frame

function aDF:Init()
	aDF.Drag = { }
	function aDF.Drag:StartMoving()
		if ( IsShiftKeyDown() ) then
			this:StartMoving()
		end
	end
	
	function aDF.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
		local x, y = this:GetCenter()
		local ux, uy = UIParent:GetCenter()
		aDF_x, aDF_y = floor(x - ux + 0.5), floor(y - uy + 0.5)
	end
	
	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="8",
			edgeSize="8",
			insets={
				left="2",
				right="2",
				top="2",
				bottom="2"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth((24+gui_Optionsxy)*7) -- Set these to whatever height/width is needed 
	self:SetHeight(24+gui_Optionsxy) -- for your Texture
	self:SetPoint("CENTER",aDF_x,aDF_y)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1)
	self:SetScript("OnDragStart", aDF.Drag.StartMoving)
	self:SetScript("OnDragStop", aDF.Drag.StopMovingOrSizing)
	self:SetScript("OnMouseDown", function()
		if (arg1 == "RightButton") then
			if aDF_target ~= nil then
				if UnitAffectingCombat(aDF_target) and UnitCanAttack("player", aDF_target) then	
					aDF:SendChatMessage(UnitName(aDF_target).." has ".. UnitResistance(aDF_target,0).." armor", gui_chan)
				end
			end
		end
	end)
	
	-- Armor text
	self.armor = self:CreateFontString(nil, "OVERLAY")
    self.armor:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.armor:SetFont("Fonts\\FRIZQT__.TTF", 24+gui_Optionsxy)
	self.armor:SetShadowOffset(2,-2)
    self.armor:SetText("aDF")

	-- Resistance text
	self.res = self:CreateFontString(nil, "OVERLAY")
    self.res:SetPoint("CENTER", self, "CENTER", 0, 20+gui_Optionsxy)
    self.res:SetFont("Fonts\\FRIZQT__.TTF", 14+gui_Optionsxy)
	self.res:SetShadowOffset(2,-2)
    self.res:SetText("Resistance")
	
	-- for the debuff check function
	aDF_tooltip = CreateFrame("GAMETOOLTIP", "buffScan")
	aDF_tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	aDF_tooltipTextL = aDF_tooltip:CreateFontString()
	aDF_tooltipTextR = aDF_tooltip:CreateFontString()
	aDF_tooltip:AddFontStrings(aDF_tooltipTextL,aDF_tooltipTextR)
	--R = tip:CreateFontString()
	--
	
	f_ =  0
	for name,texture in pairs(aDFDebuffs) do
		aDFsize = 24+gui_Optionsxy
		aDF_frames[name] = aDF_frames[name] or aDF.Create_frame(name)
		local frame = aDF_frames[name]
		frame:SetWidth(aDFsize)
		frame:SetHeight(aDFsize)
		frame:SetPoint("BOTTOMLEFT",aDFsize*f_,-aDFsize)
		frame.icon:SetTexture(texture)
		frame:SetFrameLevel(2)
		frame:Show()
		frame:SetScript("OnEnter", function() 
			GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
			GameTooltip:SetText(this:GetName(), 255, 255, 0, 1, 1);
			GameTooltip:Show()
			end)
		frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		frame:SetScript("OnMouseDown", function()
			if (arg1 == "RightButton") then
				tdb=this:GetName()
				if aDF_target ~= nil then
					if UnitAffectingCombat(aDF_target) and UnitCanAttack("player", aDF_target) and gui_Options[tdb] ~= nil then
						if not aDF:GetDebuff(aDF_target,aDFSpells[tdb]) then
							aDF:SendChatMessage("["..tdb.."] is not active on "..UnitName(aDF_target), gui_chan)
						else
							if aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) == 1 then
								s_ = "stack"
							elseif aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) > 1 then
								s_ = "stacks"
							end
							if aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) >= 1 and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) < 5 and tdb ~= "Armor Shatter" then
								aDF:SendChatMessage(UnitName(aDF_target).." has "..aDF:GetDebuff(aDF_target,aDFSpells[tdb],1).." ["..tdb.."] "..s_, gui_chan)
							end
							if tdb == "Armor Shatter" and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) >= 1 and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) < 3 then
								aDF:SendChatMessage(UnitName(aDF_target).." has "..aDF:GetDebuff(aDF_target,aDFSpells[tdb],1).." ["..tdb.."] "..s_, gui_chan)
							end
						end
					end
				end
			end
		end)
		f_ = f_+1
	end
end

-- creates the debuff frames on load

function aDF.Create_frame(name)
	local frame = CreateFrame('Button', name, aDF)
	frame:SetBackdrop({ bgFile=[[Interface/Tooltips/UI-Tooltip-Background]] })
	frame:SetBackdropColor(0,0,0,1)
	frame.icon = frame:CreateTexture(nil, 'ARTWORK')
	frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	frame.icon:SetPoint('TOPLEFT', 1, -1)
	frame.icon:SetPoint('BOTTOMRIGHT', -1, 1)
	frame.dur = frame:CreateFontString(nil, "OVERLAY")
	frame.dur:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	frame.dur:SetFont("Fonts\\FRIZQT__.TTF", 10+gui_Optionsxy)
	frame.dur:SetTextColor(255, 255, 0, 1)
	frame.dur:SetShadowOffset(2,-2)
	frame.dur:SetText("0")
	frame.nr = frame:CreateFontString(nil, "OVERLAY")
	frame.nr:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	frame.nr:SetFont("Fonts\\FRIZQT__.TTF", 10+gui_Optionsxy)
	frame.nr:SetTextColor(255, 255, 0, 1)
	frame.nr:SetShadowOffset(2,-2)
	frame.nr:SetText("1")
	--DEFAULT_CHAT_FRAME:AddMessage("----- Adding new frame")
	return frame
end

-- creates gui checkboxes

function aDF.Create_guiframe(name)
    local frame = CreateFrame("CheckButton", name, aDF.Options, "UICheckButtonTemplate")
    frame:SetFrameStrata("LOW")
    frame:SetScript("OnClick", function ()
        if frame:GetChecked() then -- If checked
            gui_Options[name] = 1
        else -- If unchecked
            gui_Options[name] = 0 -- Use 0 instead of nil
        end
        aDF:Sort()
        aDF:Update()
        end)
    frame:SetScript("OnEnter", function()
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
        GameTooltip:SetText(name, 255, 255, 0, 1, 1);
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    -- Set initial checked state based on whether the value is exactly 1
    frame:SetChecked(gui_Options[name] == 1)
    frame.Icon = frame:CreateTexture(nil, 'ARTWORK')
    frame.Icon:SetTexture(aDFDebuffs[name])
    frame.Icon:SetWidth(25)
    frame.Icon:SetHeight(25)
    frame.Icon:SetPoint("CENTER",-30,0)
    --DEFAULT_CHAT_FRAME:AddMessage("----- Adding new gui checkbox")
    return frame
end

-- update function for the text/debuff frames

local sunderers = {}
local shattered_at = GetTime()
local sundered_at = GetTime()
local anni_stacks_maxed = false

function aDF:Update()
    if aDF_target ~= nil and UnitExists(aDF_target) and not UnitIsDead(aDF_target) then
        if UnitIsUnit(aDF_target,'targettarget') and GetTime() < (last_target_change_time + 1.3) then
            -- adfprint('target changed too soon, delaying update')
            return
        end
        local armorcurr = UnitResistance(aDF_target,0)
        aDF.armor:SetText(armorcurr)
        if armorcurr > aDF_armorprev then
            local armordiff = armorcurr - aDF_armorprev
            local diffreason = ""
            if aDF_armorprev ~= 0 and aDFArmorVals[armordiff] then
                diffreason = " (Dropped " .. aDFArmorVals[armordiff] .. ")"
            end
            local msg = UnitName(aDF_target).."'s armor: "..aDF_armorprev.." -> "..armorcurr..diffreason
            if UnitIsUnit(aDF_target,'target') then
                aDF:SendChatMessage(msg, gui_chan)
            end
        end
        aDF_armorprev = armorcurr
        if gui_Options.show_resistances then
            aDF.res:SetText("|cffFF0000FR "..UnitResistance(aDF_target,2).." |cff00FF00NR "..UnitResistance(aDF_target,3).." |cff4AE8F5FrR "..UnitResistance(aDF_target,4).." |cff800080SR "..UnitResistance(aDF_target,5))
        else
            aDF.res:SetText("")
        end
        for i, texture in pairs(aDFDebuffs) do
            if gui_Options[i] == 1 and aDF_frames[i] then
                local frame = aDF_frames[i]
                local stackCount = aDF:GetDebuff(aDF_target, aDFSpells[i], 1)
                if stackCount then -- Check if the debuff is present (stackCount will be a number >= 0, or false)
                    frame.icon:SetAlpha(1)
                    frame.nr:SetText(stackCount > 1 and stackCount or "")
                    if i == "Sunder Armor" then
                        local elapsed = 30 - (GetTime() - sundered_at)
                        frame.dur:SetText(format("%0.f", elapsed >= 0 and elapsed or 0))
                    elseif i == "Armor Shatter" then
                        local elapsed = 45 - (GetTime() - shattered_at)
                        if elapsed < 0 and anni_stacks_maxed == false then
                            shattered_at = shattered_at + 20
                        end
                        frame.dur:SetText(format("%0.f", elapsed >= 0 and elapsed or 0))
                    else
                         frame.dur:SetText("") -- Clear duration for others unless specific logic added
                    end
                else -- Debuff not present on target
                    frame.icon:SetAlpha(0.3)
                    frame.nr:SetText("")
                    frame.dur:SetText("")
                end
            end
        end
    else -- No valid target
        aDF.armor:SetText("")
        aDF.res:SetText("")
        -- Clear text/alpha on all potentially visible frames if no target
        for i, frame in pairs(aDF_frames) do
             if gui_Options[i] == 1 then -- Only clear frames that *should* be visible
                frame.icon:SetAlpha(0.3)
                frame.nr:SetText("")
                frame.dur:SetText("")
             end
        end
    end
end

function aDF:UpdateCheck()
	-- if utimer == nil or (GetTime() - utimer > 0.8) and UnitIsPlayer("target") then
	if utimer == nil or (GetTime() - utimer > 0.3) then
		utimer = GetTime()
		aDF:Update()
	end
end

-- Sort function to show/hide frames aswell as positioning them correctly

function aDF:Sort()
    -- Show/Hide frames based on options
    for name,_ in pairs(aDFDebuffs) do
        if aDF_frames[name] then -- Make sure frame exists
            if gui_Options[name] ~= 1 then -- Hide if option is not 1 (covers 0 and nil)
                aDF_frames[name]:Hide()
            else -- Show if option is 1
                aDF_frames[name]:Show()
            end
        end
    end

    -- Build table of enabled options for positioning
    local aDFTempTable = {}
    for dbf, state in pairs(gui_Options) do
        -- Only add to the sortable list if the option is enabled (1)
        -- And ensure it's a debuff that should have a frame
        if state == 1 and aDFDebuffs[dbf] then
            table.insert(aDFTempTable, dbf)
        end
    end
    table.sort(aDFTempTable, function(a,b) return a<b end) -- Sort alphabetically

    -- Position the enabled frames
    local aDFsize = 24 + gui_Optionsxy
    local items_per_row = 7 -- Assuming 7 frames fit per row based on original width calculation attempt

    for n, v in ipairs(aDFTempTable) do -- Iterate sorted list with numerical index
        if v and aDF_frames[v] then
            local frame = aDF_frames[v]
            -- Calculate row and column (0-indexed)
            local row = math.floor((n - 1) / items_per_row)
            -- Calculate column using floor division and subtraction (equivalent to modulo)
            local col = (n - 1) - (math.floor((n - 1) / items_per_row) * items_per_row) -- Replaced % calculation

            -- Calculate X and Y position based on row/column
            local y_ = -(aDFsize * (row + 1))
            local x_ = aDFsize * col

            frame:ClearAllPoints() -- Important to clear old points before setting new ones
            frame:SetPoint('BOTTOMLEFT', x_, y_)
        end
    end
end

-- Options frame

function aDF.Options:Gui()

	aDF.Options.Drag = { }
	function aDF.Options.Drag:StartMoving()
		this:StartMoving()
	end
	
	function aDF.Options.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
	end

	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="4",
			edgeSize="8",
			insets={
				left="2",
				right="2",
				top="2",
				bottom="2"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth(400) -- Set these to whatever height/width is needed 
	self:SetHeight(450) -- for your Texture
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", aDF.Options.Drag.StartMoving)
	self:SetScript("OnDragStop", aDF.Options.Drag.StopMovingOrSizing)
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1);
	
	-- Options text
	
	self.text = self:CreateFontString(nil, "OVERLAY")
    self.text:SetPoint("CENTER", self, "CENTER", 0, 180)
    self.text:SetFont("Fonts\\FRIZQT__.TTF", 25)
	self.text:SetTextColor(255, 255, 0, 1)
	self.text:SetShadowOffset(2,-2)
    self.text:SetText("Options")
	
	-- mid line
	
	self.left = self:CreateTexture(nil, "BORDER")
	self.left:SetWidth(125)
	self.left:SetHeight(2)
	self.left:SetPoint("CENTER", -62, 160)
	self.left:SetTexture(1, 1, 0, 1)
	self.left:SetGradientAlpha("Horizontal", 0, 0, 0, 0, 102, 102, 102, 0.6)

	self.right = self:CreateTexture(nil, "BORDER")
	self.right:SetWidth(125)
	self.right:SetHeight(2)
	self.right:SetPoint("CENTER", 63, 160)
	self.right:SetTexture(1, 1, 0, 1)
	self.right:SetGradientAlpha("Horizontal", 255, 255, 0, 0.6, 0, 0, 0, 0)
	
	-- slider

	self.Slider = CreateFrame("Slider", "aDF Slider", self, 'OptionsSliderTemplate')
	self.Slider:SetWidth(200)
	self.Slider:SetHeight(20)
	self.Slider:SetPoint("CENTER", self, "CENTER", 0, 140)
	self.Slider:SetMinMaxValues(1, 10)
	self.Slider:SetValue(gui_Optionsxy)
	self.Slider:SetValueStep(1)
	getglobal(self.Slider:GetName() .. 'Low'):SetText('1')
	getglobal(self.Slider:GetName() .. 'High'):SetText('10')
	--getglobal(self.Slider:GetName() .. 'Text'):SetText('Frame size')
	self.Slider:SetScript("OnValueChanged", function() 
		gui_Optionsxy = this:GetValue()
		for _, frame in pairs(aDF_frames) do
			frame:SetWidth(24+gui_Optionsxy)
			frame:SetHeight(24+gui_Optionsxy)
			frame.nr:SetFont("Fonts\\FRIZQT__.TTF", 16+gui_Optionsxy)
		end
		aDF:SetWidth((24+gui_Optionsxy)*7)
		aDF:SetHeight(24+gui_Optionsxy)
		aDF.armor:SetFont("Fonts\\FRIZQT__.TTF", 24+gui_Optionsxy)
		aDF.res:SetFont("Fonts\\FRIZQT__.TTF", 14+gui_Optionsxy)
		aDF.res:SetPoint("CENTER", aDF, "CENTER", 0, 20+gui_Optionsxy)
		aDF:Sort()
	end)
	self.Slider:Show()
	
	-- checkboxes

	local temptable = {}
	for tempn,_ in pairs(aDFDebuffs) do
		table.insert(temptable,tempn)
	end
	table.sort(temptable, function(a,b) return a<b end)
	-- table.insert(temptable,"Resistances")
	
	local x,y=130,-80
	for _,name in pairs(temptable) do
		y=y-40
		if y < -360 then y=-120; x=x+140 end
		--DEFAULT_CHAT_FRAME:AddMessage("Name of frame: "..name.." ypos: "..y)
		aDF_guiframes[name] = aDF_guiframes[name] or aDF.Create_guiframe(name)
		local frame = aDF_guiframes[name]
		frame:SetPoint("TOPLEFT",x,y)
	end	

	-- drop down menu

	self.dropdown = CreateFrame('Button', 'chandropdown', self, 'UIDropDownMenuTemplate')
	self.dropdown:SetPoint("BOTTOM",-60,20)
	InitializeDropdown = function() 
		local info = {}
		for k,v in pairs(gui_chantbl) do
			info = {}
			info.text = v
			info.value = v
			info.func = function()
			UIDropDownMenu_SetSelectedValue(chandropdown, this.value)
			gui_chan = UIDropDownMenu_GetText(chandropdown)
			end
			info.checked = nil
			UIDropDownMenu_AddButton(info, 1)
			if gui_chan == nil then
				UIDropDownMenu_SetSelectedValue(chandropdown, "None")
			else
				UIDropDownMenu_SetSelectedValue(chandropdown, gui_chan)
			end
		end
	end
	UIDropDownMenu_Initialize(chandropdown, InitializeDropdown)
	
	-- -- resistance check
	
	-- self.resistance = aDF.Create_guiframe("Resistances")
	-- self.resistance:SetPoint("BOTTOM",60,20)

	-- done button
	
	self.dbutton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.dbutton:SetPoint("BOTTOM",0,10)
	self.dbutton:SetFrameStrata("LOW")
	self.dbutton:SetWidth(79)
	self.dbutton:SetHeight(18)
	self.dbutton:SetText("Done")
	self.dbutton:SetScript("OnClick", function() PlaySound("igMainMenuOptionCheckBoxOn"); aDF:Sort(); aDF:Update(); aDF.Options:Hide() end)
	self:Hide()
end

-- function to check a unit for a certain debuff and/or number of stacks
function aDF:GetDebuff(name,buff,stacks)
	local a=1
	while UnitDebuff(name,a) do
		local _,s,_,id = UnitDebuff(name,a)
		local n = SpellInfo(id)
		-- local _, s = UnitDebuff(name,a)
		-- aDF_tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		-- aDF_tooltip:ClearLines()
		-- aDF_tooltip:SetUnitDebuff(name,a)
		-- local aDFtext = aDF_tooltipTextL:GetText()
		-- if string.find(aDFtext,buff) then 
		if buff == n then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end

	-- if not found, check buffs in case over the debuff limit
	a=1
	while UnitBuff(name,a) do
		local _,s,id = UnitBuff(name,a)
		local n = SpellInfo(id)
		-- aDF_tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		-- aDF_tooltip:ClearLines()
		-- aDF_tooltip:SetUnitBuff(name,a)
		-- local aDFtext = aDF_tooltipTextL:GetText()
		-- if string.find(aDFtext,buff) then 
		if buff == n then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end
	return false
end

-- event function, will load the frames we need
function aDF:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "aDF" then
        aDF_x = aDF_x or 0
        aDF_y = aDF_y or 0
        gui_Options = gui_Options or {}
        gui_chan = gui_chan or "None"
        gui_Optionsxy = gui_Optionsxy or 1
		aDF_Default()

		if gui_Options.show_resistances == nil then 
			gui_Options.show_resistances = true -- Default to ON
		end

		aDF_target = nil
		aDF_armorprev = 30000
		-- if gui_chan == nil then gui_chan = Say end
		aDF:Init() -- loads frame, see the function
		aDF.Options:Gui() -- loads options frame
		aDF:Sort() -- sorts the debuff frames and places them to eachother
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r Loaded",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf show|r to show frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf hide|r to hide frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf options|r for options frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf resist on|r or |cFFFFFF00 /adf resist off|r to toggle resistance display",1,1,1)
  elseif event == "UNIT_AURA" and arg1 == aDF_target then
		-- print("adf update")
		local anni_prev = tonumber(aDF_frames["Armor Shatter"]["nr"]:GetText()) or 0
		aDF:Update()
		local anni = tonumber(aDF_frames["Armor Shatter"]["nr"]:GetText()) or 0
		if anni_prev ~= anni then shattered_at = GetTime() end
		if anni_stacks_maxed and anni < 3 then anni_stacks_maxed = false end
		if not anni_stacks_maxed and anni >= 3 then
			UIErrorsFrame:AddMessage("Annihilator Stacks Maxxed",1,0.1,0.1,1)
			PlaySoundFile("Sound\\Spells\\YarrrrImpact.wav")
			anni_stacks_maxed = true
		end
	elseif event == "UNIT_CASTEVENT" and arg2 == aDF_target then
	-- elseif event == "UNIT_CASTEVENT" then
		-- print(SpellInfo(arg4) .. " " .. arg4)
		local name = SpellInfo(arg4)
		if name == "Sunder Armor" then
			sunderers[UnitName(arg1)] = sundered_at
			local now = GetTime()
			-- print("since sunder: "..now - sundered_at)
			sundered_at = now
		end

	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then -- self
		local sunder_miss = string.find(arg1,"^Your Sunder Armor") -- (was parried/dodges) or (missed)
		if not sunder_miss then return end
		local n = UnitName("player")
		if sunderers[n] then
			sundered_at = sunderers[n]
			sunderers[n] = nil
		end

	elseif event == "CHAT_MSG_SPELL_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE" then
		local _,_,n = string.find(arg1,"^(%S+)%s?'s Sunder Armor") -- (was parried) or (missed)
		if not n then return end
		if sunderers[n] then
			sundered_at = sunderers[n]
			sunderers[n] = nil
		end

	elseif event == "PLAYER_TARGET_CHANGED" then
		local aDF_target_old = aDF_target
		aDF_target = nil
		last_target_change_time = GetTime()
		if UnitIsPlayer("target") then
			aDF_target = "targettarget"
		end
		if UnitCanAttack("player", "target") then
			aDF_target = "target"
		end
		aDF_armorprev = 30000
		if has_superwow then
			_,aDF_target = UnitExists(aDF_target)
		end
		if aDF_target ~= aDF_target_old then
			anni_stacks_maxed = false
		end

		-- adfprint('PLAYER_TARGET_CHANGED ' .. tostring(aDF_target))
		aDF:Update()
	end
end

-- update and onevent who will trigger the update and event functions

aDF:SetScript("OnEvent", aDF.OnEvent)
aDF:SetScript("OnUpdate", aDF.UpdateCheck)

-- slash commands

function aDF.slash(input)
    -- Ensure input is a string and trim whitespace
    local s = input or ""
    s = string.gsub(s, "^%s*(.-)%s*$", "%1")

    local cmd, value = string.match(s, "^(%S+)%s*(.*)$")

    -- If input was empty, string.match returns nil. Default them to empty strings.
    cmd = cmd or ""
    value = value or ""

    local lower_cmd = string.lower(cmd)
    local lower_value = string.lower(value)

    if lower_cmd == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf show|r to show frame",1,1,1)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf hide|r to hide frame",1,1,1)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf options|r for options frame",1,1,1)
        DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf resist on|r or |cFFFFFF00 /adf resist off|r to toggle resistance display",1,1,1)
    elseif lower_cmd == "show" then
        aDF:Show()
    elseif lower_cmd == "hide" then
        aDF:Hide()
    elseif lower_cmd == "options" then
        aDF.Options:Show()
    elseif lower_cmd == "resist" then
        if lower_value == "on" then
            gui_Options.show_resistances = true
            DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r Resistances |cFF00FF00ON",1,1,1)
            aDF:Update()
        elseif lower_value == "off" then
            gui_Options.show_resistances = false
            DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r Resistances |cFFFF0000OFF",1,1,1)
            aDF:Update()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r Usage: /adf resist [on|off]",1,0.3,0.3);
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r unknown command: " .. cmd,1,0.3,0.3);
    end
end

SlashCmdList['ADF_SLASH'] = aDF.slash
SLASH_ADF_SLASH1 = '/adf'
SLASH_ADF_SLASH2 = '/ADF'

-- debug

function adfprint(arg1)
	DEFAULT_CHAT_FRAME:AddMessage("|cffCC121D adf debug|r "..arg1)
end
