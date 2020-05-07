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
        desc = "Automaticly played at the end of your turn.",

    },

    anger = 
    {
        name = "Anger",
        icon = "negotiation/bulldoze.tex",
        flags = CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.STATUS | CARD_FLAGS.AUTOPLAY | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,
        desc = "Automaticly played at the end of your turn.\nGain 2 {VULNERABILITY}",
        
	vulnerability_stacks = 2,

	features =
        {
            DOMINANCE = 2,
	    
        },

        OnPostResolve = function( self, minigame, targets )
            local stacks = self.negotiator:GetModifierStacks("INFLUENCE")
            self.negotiator:AddModifier("INFLUENCE", stacks)
            self.negotiator:AddModifier("VULNERABILITY", self.vulnerability_stacks, self)
        end,

    },
}

for i, id, carddef in sorted_pairs( CARDS ) do
    carddef.rarity = carddef.rarity or CARD_RARITY.BASIC
    carddef.series = CARD_SERIES.GENERAL

    Content.AddNegotiationCard( id, carddef )
end

