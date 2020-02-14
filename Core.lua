local addonName = ...
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName)
local addon = _G[addonName]

addon.corruptions = {};
local corruptions = addon.corruptions;

local BONUS_TOKEN_OFFSET = 13

local function TokenizeItemLink(link)
	local itemString = string.match(link, "item:([%-?%d:]+)")
	local itemTokens = {}
  
	-- Split data into a table
	for _, v in ipairs({strsplit(":", itemString)}) do
	  if v == "" then
		itemTokens[#itemTokens + 1] = 0
	  else
		itemTokens[#itemTokens + 1] = tonumber(v)
	  end
	end
  
	return itemTokens
end

local function UpdateTooltip(corruptionName, ...)
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if region and region:GetObjectType() == "FontString" then
			local text = region:GetText()
			if(text and string.match(text,ITEM_MOD_CORRUPTION)) then
			 region:SetText(text.." ("..corruptionName..")")
			end
        end
    end
end

local function OnTooltipSetItem(tooltip, ...)
	local name, link = tooltip:GetItem();

	if(IsCorruptedItem(link)) then
		local tokens = TokenizeItemLink(link);

		for index=1, tokens[BONUS_TOKEN_OFFSET] do
			local bonus = tokens[BONUS_TOKEN_OFFSET + index];

			if(corruptions[bonus]) then
				--cache the spellName
				if(not corruptions[bonus].spellName) then
					corruptions[bonus].spellName = GetSpellInfo(corruptions[bonus].spellId)
				end

				local corruptionName = corruptions[bonus].spellName
				if(corruptions[bonus].level ~= "") then
					corruptionName = corruptionName.." "..corruptions[bonus].level;
				end
				
				UpdateTooltip(corruptionName, tooltip:GetRegions());

				--tooltip:AddLine(corruptions[bonus].spellName.." "..corruptions[bonus].level,CORRUPTION_COLOR.r, CORRUPTION_COLOR.g, CORRUPTION_COLOR.b);
			end
		end
	end
end


function addon:OnEnable()
  GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
  ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
end