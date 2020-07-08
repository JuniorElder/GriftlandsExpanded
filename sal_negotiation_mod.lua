local negotiation_defs = require "negotiation/negotiation_defs"
local CARD_FLAGS = negotiation_defs.CARD_FLAGS
local EVENT = ExtendEnum( negotiation_defs.EVENT,
{
    "PRE_GAMBLE",
    "GAMBLE",
})

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
        desc = "Attack a random argument, repeat once.\nShuffle 2 {frustration} into your draw pile.",
        icon = "negotiation/unyielding.tex",

        cost = 1,
        max_xp = 6,
        target_mod = TARGET_MOD.RANDOM1,
        auto_target = true,
        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.UNCOMMON,

        min_persuasion = 2,
        max_persuasion = 4,
        num_copies = 2,
        bonus = 1,

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
        desc = "Attack a random argument, repeat once.\nShuffle 2 {anger} into your draw pile.",

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
        desc = "Attack a random argument, repeat three times.\nShuffle 2 {frustration} into your draw pile.",
        min_persuasion = 1,
        max_persuasion = 2,
        bonus = 3,
    },

    last_laugh =
    {
        name = "Last Laugh",
        icon = "negotiation/quip.tex",
        desc = "Deal 1 bonus damage for every card played this turn.",

        max_xp = 7,
        cost = 1,

        min_persuasion = 2,
        max_persuasion = 2,

        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.UNCOMMON,

        event_priorities =
        {
            [ EVENT.CALC_PERSUASION ] = EVENT_PRIORITY_ADDITIVE,
        },

        event_handlers = 
        {
            [ EVENT.CALC_PERSUASION ] = function( self, source, persuasion )
                if source == self then
                    local bonus = 0
                    local count = self.engine:CountCardsPlayed()
                            bonus = bonus + count * 1
                    persuasion:AddPersuasion( bonus, bonus, self )
                end
            end,
        },
    },
    last_laugh_plus =
    {
        name = "Boosted Last Laugh",
        min_persuasion = 4,
        max_persuasion = 4,
    },

    last_laugh_plus2 =
    {
        name = "Tall Last Laugh",
        desc = "Deal 2 bonus damage for every card played this turn.",

        cost = 2,

        event_priorities =
        {
            [ EVENT.CALC_PERSUASION ] = EVENT_PRIORITY_ADDITIVE,
        },

        event_handlers = 
        {
            [ EVENT.CALC_PERSUASION ] = function( self, source, persuasion )
                if source == self then
                    local bonus = 0
                    local count = self.engine:CountCardsPlayed()
                            bonus = bonus + count * 2
                    persuasion:AddPersuasion( bonus, bonus, self )
                end
            end,
        },
    },

    backhanded_compliment = 
    {
        name = "Backhanded Compliment",
        icon = "negotiation/bluff.tex",
        desc = "{INCEPT} 1 {DOUBT}.\n{EVOKE}: Play 4 Diplomacy cards in a single turn. {1}",
        desc_fn = function( self, fmt_str )
            if self.engine and self.evoke_count then
                local str = loc.format( LOC"CARD_ENGINE.CARDS_PLAYED", self.evoke_count )
                return loc.format( fmt_str, str )
            else
                return loc.format( fmt_str, "" )
            end
        end,
        flags = CARD_FLAGS.DIPLOMACY | CARD_FLAGS.UNPLAYABLE,
        rarity = CARD_RARITY.UNCOMMON,
        auto_target = true,
        target_mod = TARGET_MOD.RANDOM1,

        cost = 0,

        evoke_max = 4,
        stacks = 1,

        deck_handlers = { DECK_TYPE.DRAW, DECK_TYPE.DISCARDS },

        event_handlers = 
        {
            [ EVENT.POST_RESOLVE ] = function( self, minigame, card )
                if card.owner == self.owner then
                    if CheckBits( card.flags, CARD_FLAGS.DIPLOMACY ) then
                        self:Evoke( self.evoke_max )
                    end
                end
            end,

            [ EVENT.END_TURN ] = function( self, minigame, negotiator )
                if negotiator == self.negotiator then
                    self:ResetEvoke()
                end
            end,
        },

        OnPostResolve = function( self, minigame, targets )
            self.anti_negotiator:InceptModifier("DOUBT", self.stacks, self )
        end,
    },

    backhanded_compliment_plus = 
    {
        name = "Pale Backhanded Compliment",
        desc = "{INCEPT} 2 {DOUBT}.\n{EVOKE}: Play 4 Diplomacy cards in a single turn. {1}",
        stacks = 2,
    },

    backhanded_compliment_plus2 = 
    {
        name = "Boosted Backhanded Compliment",
        desc = "{INCEPT} 1 {DOUBT}.\n{EVOKE}: Play 3 Diplomacy cards in a single turn. {1}",
        evoke_max = 3,
    },

}

for i, id, carddef in sorted_pairs( CARDS ) do
    if not carddef.series then
        carddef.series = "SAL"
    end
    local basic_id = carddef.base_id or id:match( "(.*)_plus.*$" ) or id:match( "(.*)_upgraded[%w]*$") or id:match( "(.*)_supplemental.*$" )
        Content.AddNegotiationCard( id, carddef )
end
