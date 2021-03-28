--[[ =========== Start:: Recoloured Dome Bonus Icons ========== --]]

local mod_name = "Recoloured_Dome_Bonus_Icons"
local steamID = "1582890631"
-- local author = "RustyDios"
-- local version ="10"

--[[ =========== Start:: Add Entities ========== --]]

-- list of entities we're going to be adding
local entity_list = {
	"SignDomeBonusResearch",
	"SignDomeBonusVista",
}
-- getting called a bunch, so make them local
local path_loc_str = string.format("%sEntities/%s.ent",CurrentModPath,"%s")
local mod = Mods.mod_name
local EntityData = EntityData
local EntityLoadEntities = EntityLoadEntities
local SetEntityFadeDistances = SetEntityFadeDistances

-- no sense in making a new one for each entity
local EntityDataTableTemplate = {
	category_Building = true,
	entity = {
		fade_category = "Never",
		material_type = "Metal",
	},
}

-- pretty much using what happens when you use ModItemEntity
local function AddEntity(name)
	EntityData[name] = EntityDataTableTemplate
	EntityLoadEntities[#EntityLoadEntities + 1] = {
		mod,
		name,
		path_loc_str:format(name)
	}
	SetEntityFadeDistances(name, -1, -1)
end

for i = 1, #entity_list do
	AddEntity(entity_list[i])
end
--[[ =========== End:: Add Entities ========== --]]

--[[ =========== Start:: Replace Entities ========== --]]

-- newly revealed deposits get this entity
function ResearchEffectDeposit:GameInit()
	self:ChangeSkin("SignDomeBonusResearch")
end

function BeautyEffectDeposit:GameInit()
	self:ChangeSkin("SignDomeBonusVista")
end

-- replace existing ones (that haven't been replaced yet)
local function ChangeEntityLabel(label,cls,new)
	for i = 1, #(label or "") do
		if label[i].entity ~= new and label[i]:IsKindOf(cls) then
			label[i]:ChangeSkin(new)
		end
	end
end

local function InitialModSwap()
	-- this way it'll only fire once per savegame instead of every load
	if not UICity.DomeBonusExchange then
		local l = UICity.labels
		ChangeEntityLabel(l.EffectDeposit,"ResearchEffectDeposit","SignDomeBonusResearch")
		ChangeEntityLabel(l.EffectDeposit,"BeautyEffectDeposit","SignDomeBonusVista")
		UICity.DomeBonusExchange = true
	end
end

--replace on a new map
function OnMsg.CityStart()
	InitialModSwap()
end

--replace on a loaded save that hasn't been modded yet
function OnMsg.LoadGame()
	InitialModSwap()
end

--[[ =========== End:: Replace Entities ========== --]]

--[[ =========== Start:: Add Skin Systems ========== --]]

-- No sense in creating a table each time we select one
local ResearchSkins = {"SignResearchDeposit","SignDomeBonusResearch"}
local VistaSkins = {"SignBeautyDeposit","SignDomeBonusVista"}

-- make the paintbrush show up and cycle skins
function ResearchEffectDeposit:GetSkins()
	return ResearchSkins
end

function BeautyEffectDeposit:GetSkins()
	return VistaSkins
end

-- they normally can't change skins so we need to make them able to
function OnMsg.ClassesPreprocess()
	BeautyEffectDeposit.__parents[#BeautyEffectDeposit.__parents+1] = "SkinChangeable"
	ResearchEffectDeposit.__parents[#ResearchEffectDeposit.__parents+1] = "SkinChangeable"
end

-- Deep Water/Metals Extraction tech replace the entities by classdef using UpdateEntity
-- this adds an overide to that function to ignore our newly skinned icons
function OnMsg.ClassesBuilt()
    function ResearchEffectDeposit:UpdateEntity()
	end
	
	function BeautyEffectDeposit:UpdateEntity()
	end
end

--[[
--function in original code, tied to SubsurfaceDeposit, which all others have as a parent class, except concrete
-- A deep deposit before research is complete is shown as a disabled_entity
function SubsurfaceDeposit:UpdateEntity() 
	local classdef = g_Classes[self.class]
	local ent = (self:GetDepth() < 2 or IsDeepExploitable(self.resource)) and classdef.entity or classdef.disabled_entity	
	self:ChangeEntity(ent) --change to self:ChangeSkin(ent)?
end
--]]

--[[ =========== End:: Add Skin Systems ========== --]]

--[[ =========== End ::Recoloured Dome Bonus Icons ========== --]]
