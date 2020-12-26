local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT
local CARD_FLAGS = negotiation_defs.CARD_FLAGS


local NEGOTIATION_GRAFTS =
{
    surveyor = 
    {
        name = "Surveyor",
        desc = "If you play a Diplomacy, Hostility and Manipulation card in the same turn gain 1 action.",
        rarity = CARD_RARITY.COMMON,
        icon_override = "clan_ring",
        card_defs = negotiation_defs,

        diplomacy = false,
        manipulation = false,
        hostility = false,
        charge = true,
        draw = 0,

        negotiation_modifier =
        {
            hidden = true,

            event_handlers =
            {
                [ EVENT.POST_RESOLVE ] = function(self, minigame, card)
                    if card.owner == self.owner then
                        if CheckBits( card.flags, CARD_FLAGS.DIPLOMACY ) then
                            self.graft:GetDef().diplomacy = true
                        end
                        if CheckBits( card.flags, CARD_FLAGS.HOSTILE ) then
                            self.graft:GetDef().manipulation = true
                        end
                        if CheckBits( card.flags, CARD_FLAGS.MANIPULATE ) then
                            self.graft:GetDef().hostility = true
                        end
                        if self.graft:GetDef().diplomacy == true and self.graft:GetDef().manipulation == true and self.graft:GetDef().hostility == true and self.graft:GetDef().charge == true then
                            self.graft:GetDef().charge = false
                            minigame:ModifyActionCount(1)
                            minigame:DrawCards( self.graft:GetDef().draw )
                        end
                    end
                end,

                [ EVENT.END_PLAYER_TURN ] = function( self, battle )
                    self.graft:GetDef().diplomacy = false
                    self.graft:GetDef().manipulation = false
                    self.graft:GetDef().hostility = false
                    self.graft:GetDef().charge = true
                end
            },
        },

    },

    surveyor_plus =
    {
        name = "Boosted Surveyor",
        desc = "If you play a Diplomacy, Hostility and Manipulation card in the same turn gain 1 action and draw 2 cards.",
        icon_override = "clan_ring_plus",

        draw = 2,
    },

    rectifier = 
    {
        name = "Rectifier",
        desc = "After you play a Basic card expend it.",
        rarity = CARD_RARITY.UNCOMMON,
        icon_override = "cerebral_tackle",
        card_defs = negotiation_defs,

        cost_reduction = false,

        negotiation_modifier =
        {
            hidden = true,

            event_handlers =
            {
                [ EVENT.POST_RESOLVE ] = function(self, minigame, card)
                    if card.owner == self.owner then
                        if card.rarity == CARD_RARITY.BASIC then
                            minigame:ExpendCard( card )
                        end
                    end
                end,

                [ EVENT.CALC_ACTION_COST ] = function( self, acc, card, target )
                    if card.rarity == CARD_RARITY.BASIC and self.graft:GetDef().cost_reduction == true then
                        acc:ModifyValue(0)
                    end
                end,
            },
        },
        
    },

    rectifier_plus =
    {
        name = "Boosted Rectifier",
        desc = "Basic cards cost 0. After you play a Basic card expend it.",
        icon_override = "cerebral_tackle_plus",

        cost_reduction = true,
    },
}

---------------------------------------------------------------------------------------------

for i, id, graft in sorted_pairs( NEGOTIATION_GRAFTS ) do
    graft.card_defs = negotiation_defs
    graft.series = "SAL"
    
    if graft.negotiation_modifier and graft.negotiation_modifier.modifier_type == nil then
        graft.negotiation_modifier.modifier_type = MODIFIER_TYPE.HIDDEN
    end
    graft.type = GRAFT_TYPE.NEGOTIATION
    Content.AddGraft( id, graft )
end
