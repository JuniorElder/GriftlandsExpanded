local negotiation_defs = require "negotiation/negotiation_defs"
local CARD_FLAGS = negotiation_defs.CARD_FLAGS
local EVENT = negotiation_defs.EVENT

local CARDS =
{
    frustration = 
    {
        name = "Frustration",
        icon = "negotiation/agitation.tex",
        flags = CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.STATUS | CARD_FLAGS.AUTOPLAY | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,
        desc = "Automatically played at the end of your turn.",

    },

    anger = 
    {
        name = "Anger",
        icon = "negotiation/bulldoze.tex",
        flags = CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.STATUS | CARD_FLAGS.AUTOPLAY | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,
        desc = "Gain 2 {VULNERABILITY} and 2 {DOMINANCE} when drawn.\nAutomatically played at the end of your turn.",
        
        vulnerability_stacks = 2,
        dominance_stacks = 2,

        event_handlers =
        {
           [ EVENT.DRAW_CARD ] = function( self, minigame, card, start_of_turn )
            if card == self then
            self.negotiator:AddModifier("DOMINANCE", self.dominance_stacks, self)
            self.negotiator:AddModifier("VULNERABILITY", self.vulnerability_stacks, self)
            end
            end,
        }
    },
}

for i, id, carddef in sorted_pairs( CARDS ) do
    carddef.rarity = carddef.rarity or CARD_RARITY.BASIC
    carddef.series = CARD_SERIES.GENERAL

    Content.AddNegotiationCard( id, carddef )
end

