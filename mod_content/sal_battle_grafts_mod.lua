local battle_defs = require "battle/battle_defs"

local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

--------------------------------------------------------------------

local BATTLE_GRAFTS =
{
    prickle = 
    {
        name = "Prickle",
        desc = "If you end your turn with no {DEFEND} gain 4 {RIPOSTE}.",
        rarity = CARD_RARITY.COMMON,
        icon_override = "razorglass",
        card_defs = battle_defs,

        riposte_amt = 4,

        battle_condition =
        {
            hidden = true,

            event_handlers =
            {
                [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                    if not self.owner:HasCondition("DEFEND") then
                        self.owner:AddCondition( "RIPOSTE", self.graft:GetDef().riposte_amt or 4)
                    end
                end
            },
        },
    },

    prickle_plus =
    {
        name = "Boosted Prickle",
        desc = "If you end your turn with no {DEFEND} gain 6 {RIPOSTE}.",
        icon_override = "razorglass_plus",

        riposte_amt = 6,
    },

    cogitator = 
    {
        name = "Cogitator",
        desc = "After you play 6 cards in a single turn gain 1 {EVASION}.",
        rarity = CARD_RARITY.UNCOMMON,
        icon_override = "reflector",
        card_defs = battle_defs,

        counter = 0,

        battle_condition =
        {
            hidden = true,

            event_handlers =
            {
                [ BATTLE_EVENT.POST_RESOLVE ] = function (self, battle, attack)
                    if attack.owner == self.owner then
                    self.graft:GetDef().counter = self.graft:GetDef().counter + 1
                    if self.graft:GetDef().counter == 6 then
                    self.owner:AddCondition( "EVASION", 1)
                        if self.graft:GetDef().repeating == true then
                        self.graft:GetDef().counter = 0
                        end
                    end
                end
                end,

                [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                    self.graft:GetDef().counter = 0
                end
            },
        },
    },

    cogitator_plus =
    {
        name = "Boosted Cogitator",
        desc = "For every 6 cards you play in a single turn gain 1 {EVASION}.",
        icon_override = "reflector_plus",

        repeating = true,
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
