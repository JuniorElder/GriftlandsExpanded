local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT
local CARD_FLAGS = negotiation_defs.CARD_FLAGS


local NEGOTIATION_GRAFTS =
{
    wager = 
    {
        name = "Wager",
        desc = "{GAMBLE} whenever an opponent's argument is destroyed or removed by a card.",
        icon_override = "slider",
        card_defs = negotiation_defs,

        rarity = CARD_RARITY.UNCOMMON,
        gamble_twice = false,

        negotiation_modifier =
        {
            hidden = true,

            event_handlers =
            {
                [ EVENT.MODIFIER_REMOVED ] = function ( self, modifier, source )
                    if modifier.owner == self.anti_negotiator.agent and
                        (modifier.modifier_type == MODIFIER_TYPE.ARGUMENT or modifier.modifier_type == MODIFIER_TYPE.BOUNTY) and
                        is_instance( source, Negotiation.Card ) then
                        
                        local coin = self.negotiator:FindModifier("LUCKY_COIN")
                        coin:Gamble(self)
                        if self.graft:GetDef().gamble_twice == true then
                            coin:Gamble(self)
                        end
                    end
                end
            },
        },
    },

    wager_plus =
    {
        name = "Boosted Wager",
        desc = "{GAMBLE} twice whenever an opponent's argument is destroyed or removed by a card.",
        icon_override = "slider_plus",

        gamble_twice = true,
    },

    blunt_companion = 
    {
        name = "Blunt Companion",
        desc = "Whenever you discard a manipulation card, gain 2 {COMPOSURE}.",
        icon_override = "bloody_mess",
        card_defs = negotiation_defs,

        rarity = CARD_RARITY.UNCOMMON,
        target_self = true,

        negotiation_modifier = 
        {
            event_handlers = 
            {
                hidden = true,

                [ EVENT.CARD_DISCARDED ] = function( self, card, minigame )
                    if card.owner == self.owner and self.graft:GetDef().target_self == true and CheckBits(card.flags, CARD_FLAGS.MANIPULATE ) then
                        self.negotiator:DeltaComposure(2, self)
                        self.engine:BroadcastEvent( EVENT.GRAFT_TRIGGERED, self.graft )
                    end
                    if card.owner == self.owner and self.graft:GetDef().target_self == false and CheckBits(card.flags, CARD_FLAGS.MANIPULATE ) then
                        minigame:BroadcastEvent( EVENT.GRAFT_TRIGGERED, self.graft )
                        local targets = minigame:CollectAlliedTargets(self.negotiator)
                        for i=1, #targets do
                            if (targets[i]:GetResolve() or 0) > 0 then
                                targets[i]:DeltaComposure(1, self)
                            end
                        end
                    end
                end,
            },
        },
    },

    blunt_companion_plus =
    {
        name = "Boosted Blunt Companion",
        desc = "Whenever you discard a manipulation card, apply 1 {COMPOSURE} to all arguments.",
        icon_override = "bloody_mess_plus",

        target_self = false,
    },
}

---------------------------------------------------------------------------------------------

for i, id, graft in sorted_pairs( NEGOTIATION_GRAFTS ) do
    graft.card_defs = negotiation_defs
    graft.series = "ROOK"
    
    if graft.negotiation_modifier and graft.negotiation_modifier.modifier_type == nil then
        graft.negotiation_modifier.modifier_type = MODIFIER_TYPE.HIDDEN
    end
    graft.type = GRAFT_TYPE.NEGOTIATION
    Content.AddGraft( id, graft )
end
