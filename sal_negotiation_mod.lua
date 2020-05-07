local negotiation_defs = require "negotiation/negotiation_defs"
local CARD_FLAGS = negotiation_defs.CARD_FLAGS
local EVENT = ExtendEnum( negotiation_defs.EVENT,
{
    "PRE_GAMBLE",
    "GAMBLE",
})
local CONFIG = require "JuniorElderExpandedMod:config"

local CARDS =
{
    prepare_arguments = 
    {
        name = "Prepare Arguments",
        desc = "Gain {COOL_HEAD}.",
        icon = "negotiation/intrigue.tex",

        flags = CARD_FLAGS.DIPLOMACY | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.RARE,

        max_xp = 4,
        cost = 2,

	features =
        {
            COMPOSURE = 5,
	    INFLUENCE = 2,
        },

        OnPostResolve = function( self, minigame )
            self.negotiator:AddModifier("COOL_HEAD")
        end,

	target_self = TARGET_ANY_RESOLVE,

    },
    prepare_arguments_plus = 
    {
        name = "Quick Preparation",
        flags = CARD_FLAGS.DIPLOMACY | CARD_FLAGS.EXPEND | CARD_FLAGS.AMBUSH,
    },
    prepare_arguments_plus2 =
    {
        name = "Thorough Preparation",
        features =
        {
            COMPOSURE = 5,
	    INFLUENCE = 4,
        },
    },
    exhausting_argument = 
    {
        name = "Exhausting Argument",
        desc = "Attack a random argument, repeat twice.\nShuffle 3 {frustration} into your draw pile.",
        icon = "negotiation/domineer.tex",

        cost = 1,
        max_xp = 6,
        target_mod = TARGET_MOD.RANDOM1,
        auto_target = true,
        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.UNCOMMON,

        min_persuasion = 2,
        max_persuasion = 3,
        num_copies = 3,
        bonus = 2,

        OnPostResolve = function( self, minigame, attack )
            
            
                    for i = 1, self.bonus do
                        minigame:ApplyPersuasion( self )
	    end
	    local cards = {}
            for i = 1, self.num_copies do
                local incepted_card = Negotiation.Card( "frustration", self.owner )
                incepted_card.incepted = true
                table.insert(cards, incepted_card )
            end
	    minigame:DealCards( cards )
        end,
    },
    exhausting_argument_plus = 
    {
        name = "Vicious Argument",
        desc = "Attack a random argument, repeat twice.\nShuffle 3 {anger} into your draw pile.",

	OnPostResolve = function( self, minigame, attack )
            

                    for i = 1, self.bonus do
                        minigame:ApplyPersuasion( self )
	    end
	    local cards = {}
            for i = 1, self.num_copies do
                local incepted_card = Negotiation.Card( "anger", self.owner )
                incepted_card.incepted = true
                table.insert(cards, incepted_card )
            end
            minigame:DealCards( cards )
        end,
    },
    exhausting_argument_plus2 =
    {
        name = "Dragging Argument",
        desc = "Attack a random argument, repeat four times.\nShuffle 3 {frustration} into your draw pile.",
        min_persuasion = 1,
        max_persuasion = 2,
        bonus = 4,
    },
}

for i, id, carddef in sorted_pairs( CARDS ) do
    if not carddef.series then
        carddef.series = "SAL"
    end
    local basic_id = carddef.base_id or id:match( "(.*)_plus.*$" ) or id:match( "(.*)_upgraded[%w]*$") or id:match( "(.*)_supplemental.*$" )
    if CONFIG.enabled_cards[id] or CONFIG.enabled_cards[basic_id] then
        Content.AddNegotiationCard( id, carddef )
    end
end
