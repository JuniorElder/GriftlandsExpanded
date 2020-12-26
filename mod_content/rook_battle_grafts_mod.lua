local battle_defs = require "battle/battle_defs"

local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

--------------------------------------------------------------------

local BATTLE_GRAFTS =
{
    ammobank = 
    {
        name = "Ammobank",
        desc = "After you play a Basic card expend it.",
        rarity = CARD_RARITY.UNCOMMON,
        icon_override = "tumbler",
        card_defs = battle_defs,

        cost_reduction = false,

        battle_condition =
        {
            hidden = true,

            event_handlers =
            {
                [ BATTLE_EVENT.POST_RESOLVE ] = function( self, battle, attack )
                    if attack.attacker == self.owner then
                        if attack.card.rarity == CARD_RARITY.BASIC then
                            battle:ExpendCard( attack.card )
                        end
                    end
                end,

                [ BATTLE_EVENT.CALC_ACTION_COST ] = function( self, acc, card, target )
                    if card.rarity == CARD_RARITY.BASIC and self.graft:GetDef().cost_reduction == true then
                        acc:ModifyValue(0)
                    end
                end,
            },
        },
        
    },

    ammobank_plus =
    {
        name = "Boosted Ammobank",
        desc = "Basic cards cost 0. After you play a Basic card expend it.",
        icon_override = "tumbler_plus",

        cost_reduction = true,
    },

    refiner = 
    {
        name = "Refiner",
        desc = "The first time you {EXPEND} a card each turn, gain 4 {DEFEND}.",
        icon_override = "distributed_processing",
        
        rarity = CARD_RARITY.COMMON,
        card_defs = battle_defs,

        defend_amt = 4,
        battle_condition =
        {
            event_handlers =
            {
                [ BATTLE_EVENT.BEGIN_PLAYER_TURN ] = function( self, battle, card )
                    self.has_triggered = false
                end,

                [ BATTLE_EVENT.CARD_EXPENDED ] = function( self, battle, card )
                    if card.owner == self.owner and not self.has_triggered then
                        self.owner:AddCondition("DEFEND", self.graft:GetDef().defend_amt, self)
                        battle:BroadcastEvent( BATTLE_EVENT.GRAFT_TRIGGERED, self.graft )
                        self.has_triggered = true
                    end
                end,
            }
        },
    },

    refiner_plus =
    {
        name = "Boosted Refiner",
        desc = "The first time you {EXPEND} a card each turn, gain 6 {DEFEND}.",
        icon_override = "distributed_processing_plus",

        defend_amt = 6,
    },
}

---------------------------------------------------------------------------------------------

for i, id, graft in sorted_pairs( BATTLE_GRAFTS ) do
    graft.card_defs = battle_defs
    graft.series = "ROOK"
    graft.type = GRAFT_TYPE.COMBAT
    if graft.battle_condition and graft.battle_condition.hidden == nil then
        graft.battle_condition.hidden = true
    end

    Content.AddGraft( id, graft )
end
