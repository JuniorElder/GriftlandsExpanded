local battle_defs = require "battle/battle_defs"

local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

--------------------------------------------------------------------

local BATTLE_GRAFTS =
{
    sa_cowl =
    {
        name = "SA Cowl",
        desc = "Start battle with 10 {DEFENSE}.",
        rarity = CARD_RARITY.COMMON,
	    icon = "icons/items/graft_digger.tex",
        defense_amt = 10,
        OnActivateFighter = function(self, fighter)
            fighter:AddCondition( "DEFENSE", self:GetDef().combo_amt )
        end,
        flavour = "It's a dark cowl!",
    },



}

---------------------------------------------------------------------------------------------

for i, id, graft in sorted_pairs( BATTLE_GRAFTS ) do
    graft.card_defs = battle_defs
    graft.series = "SAL"
    graft.type = GRAFT_TYPE.COMBAT
    if graft.battle_condition and graft.battle_condition.hidden == nil then
        graft.battle_condition.hidden = true
    end

    Content.AddGraft( id, graft )
end
