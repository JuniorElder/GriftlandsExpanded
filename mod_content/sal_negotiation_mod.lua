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
        rarity = CARD_RARITY.COMMON,
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

    humiliation = 
    {
        name = "Humiliation",
        icon = "negotiation/reckless_insults.tex",
        desc = "If this card destroys an argument, incept {DOUBT 1}.",

        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.COMMON,

        cost = 1,
        min_persuasion = 2,
        max_persuasion = 4,

        event_handlers =
        {
            [ EVENT.MODIFIER_REMOVED ] = function( self, modifier, card )
                if card == self then
                    self.anti_negotiator:InceptModifier( "DOUBT", 1, self )
                end
            end,
        },
    },
    
    humiliation_plus =
    {
        name = "Twisted Humiliation",
        desc = "If this card destroys an argument, incept {DOUBT 2}.",
        min_persuasion = 1,
        max_persuasion = 3,

        event_handlers =
        {
            [ EVENT.MODIFIER_REMOVED ] = function( self, modifier, card )
                if card == self then
                    self.anti_negotiator:InceptModifier( "DOUBT", 2, self )
                end
            end,
        },
    },

    humiliation_plus2 =
    {
        name = "Tall Humiliation",
        desc = "If this card destroys an argument, incept {DOUBT 1}.\nCannot target core arguments.",
        min_persuasion = 2,
        max_persuasion = 8,

        CanTarget = function ( self, target )
            if is_instance( target, Negotiation.Modifier ) and target.modifier_type == MODIFIER_TYPE.CORE then
                return false, CARD_PLAY_REASONS.INVALID_TARGET
            end
            return true
        end,
    },

    set_expectations =
    {
        name = "Set Expectations",
        icon = "negotiation/pressure.tex",
        desc = "Deals 1 more max damage per {DOUBT} stack of your opponent.",

        max_xp = 6,
        cost = 1,

        min_persuasion = 1,
        max_persuasion = 3,

        flags = CARD_FLAGS.DIPLOMACY,
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
                    bonus = self.anti_negotiator:GetModifierStacks("DOUBT")
                    persuasion:AddPersuasion( 0, bonus, self )
                end
            end,
        },
    },
    set_expectations_plus =
    {
        name = "Boosted Set Expectations",
        min_persuasion = 2,
        max_persuasion = 4,
    },

    set_expectations_plus2 =
    {
        name = "Mirrored Set Expectations",
        desc = "Attack twice. Deals 1 more max damage per {DOUBT} stack of your opponent.",

        min_persuasion = 0,
        max_persuasion = 1,

        OnPostResolve = function( self, minigame )
            minigame:ApplyPersuasion( self )
        end,
    },

    paranoia =
    {
        name = "Paranoia",
        icon = "negotiation/go_between.tex",
        desc = "Remove all {DOUBT} of your opponent. Gain 1 action and draw 1 card for every 2 stacks removed.",

        flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.RARE,
        cost = 1,

        mod_xp = -3,

        doubt_cost = 2,

        PreReq = function( self, minigame )
            return self.anti_negotiator:GetModifierStacks("DOUBT") >= self.doubt_cost
        end,

        OnPostResolve = function( self, minigame )
            local gain = 0
            gain = math.floor( self.anti_negotiator:GetModifierStacks("DOUBT") / self.doubt_cost )
            minigame:DrawCards(gain)
            minigame:ModifyActionCount( gain, self )
            self.anti_negotiator:RemoveModifier("DOUBT", self.anti_negotiator:GetModifierStacks("DOUBT"), self )
        end,
    },
    paranoia_plus =
    {
        name = "Pale Paranoia",
        cost = 0,
    },

    paranoia_plus2 =
    {
        name = "Boosted Paranoia",
        desc = "Remove all {DOUBT} of your opponent. Gain 2 action and draw 2 card for every 3 stacks removed.",
        cost = 2,
        doubt_cost = 3,

        OnPostResolve = function( self, minigame )
            local gain = 0
            gain = math.floor( self.anti_negotiator:GetModifierStacks("DOUBT") / self.doubt_cost )
            minigame:DrawCards(gain*2)
            minigame:ModifyActionCount( gain*2, self )
            self.anti_negotiator:RemoveModifier("DOUBT", self.anti_negotiator:GetModifierStacks("DOUBT"), self )
        end,
    },

    protection_money =
    {
        name = "Protection Money",
        icon = "negotiation/rant.tex",
        desc = "Remove all {DOUBT} of your opponent. Gain 5 Shils for every stack removed.",

        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.UNCOMMON,
        cost = 1,

        max_xp = 5,

        min_persuasion = 2,
        max_persuasion = 4,

        OnPostResolve = function( self, minigame )
            local gain = 0
            gain = self.anti_negotiator:GetModifierStacks("DOUBT")
            minigame:ModifyMoney( 5 * gain )
            self.anti_negotiator:RemoveModifier("DOUBT", self.anti_negotiator:GetModifierStacks("DOUBT"), self )
        end,
    },
    protection_money_plus =
    {
        name = "Pale Protection Money",
        flags = CARD_FLAGS.HOSTILE | CARD_FLAGS.EXPEND,
        cost = 0,
    },

    protection_money_plus2 =
    {
        name = "Tall Protection Money",
        min_persuasion = 2,
        max_persuasion = 6,
    },
    
    puppy_eyes =
    {
        name = "Puppy Eyes",
        icon =  "negotiation/fall_guy.tex",
        desc = "{INCEPT} {GUILT {1}}. Gain {2} {COMPOSURE}.",
        desc_fn = function( self, fmt_str )
            return loc.format( fmt_str, self.stacks, self.composure )
        end,

        cost = 1,

        flags = CARD_FLAGS.MANIPULATE,
        rarity = CARD_RARITY.UNCOMMON,
        stacks = 1,
        composure = 2,

        OnPostResolve = function( self, minigame, targets )
            self.anti_negotiator:InceptModifier("GUILT", self.stacks, self )
            self.negotiator:DeltaComposure( self.composure, self )
        end,

    },
    puppy_eyes_plus = 
    {
        name = "Boosted Puppy Eyes",
        stacks = 2,
    },

    puppy_eyes_plus2 = 
    {
        name = "Stone Puppy Eyes",
        composure = 4,
    },
    
    pull_the_strings =
    {
        name = "Pull the Strings",
        icon =  "negotiation/networked.tex",
        desc = "Insert {improvise_boast} or {improvise_conviction} into your hand.",
        cost = 1,

        flags = CARD_FLAGS.MANIPULATE,
        rarity = CARD_RARITY.UNCOMMON,

        pool_size = 2,

        pool_cards = {"improvise_boast", "improvise_conviction"},

        OnPostResolve = function( self, minigame, targets)
            local cards = ObtainWorkTable()

            cards = table.multipick( self.pool_cards, self.pool_size )
            for k,id in pairs(cards) do
                cards[k] = Negotiation.Card( id, self.owner  )
            end
            minigame:ImproviseCards( cards, 1 )
            ReleaseWorkTable(cards)
        end,
    },

    pull_the_strings_plus =
    {
        name = "Hurtful Strings",
        desc = "Insert {improvise_boast}, {improvise_conviction} or {improvise_contempt} into your hand.",
        pool_cards = {"improvise_boast", "improvise_conviction", "improvise_contempt"},

        pool_size = 3,
    },

    pull_the_strings_plus2 = 
    {
        name = "Empathic Strings",
        desc = "Insert {improvise_boast}, {improvise_conviction} or {improvise_sympathy} into your hand.",
        pool_cards = {"improvise_boast", "improvise_conviction", "improvise_sympathy"},

        pool_size = 3,
    },


    improvise_conviction = 
    {
        name = "Conviction",
        icon =  "negotiation/overdrive.tex",
        desc = "{INCEPT} 1 {DOUBT}.",

        cost = 0,

        flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,

        OnPostResolve = function( self, minigame, targets )
            self.anti_negotiator:InceptModifier("DOUBT", 1 , self )
        end
    },

    improvise_sympathy = 
    {
        name = "Sympathy",
        icon =  "negotiation/cachet.tex",
        desc = "{INCEPT} 1 {GUILT}.",

        cost = 0,

        flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,

        OnPostResolve = function( self, minigame, targets )
            self.anti_negotiator:InceptModifier("GUILT", 1 , self )
        end
    },

    improvise_boast =
    {
        name = "Oblivious",
        icon =  "negotiation/disregard.tex",
        desc = "{INCEPT} 1 {FLUSTERED}.",

        cost = 0,

        flags = CARD_FLAGS.HOSTILE | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,

        OnPostResolve = function( self, minigame, targets )
            self.anti_negotiator:InceptModifier("FLUSTERED", 1 , self )
        end
    },

    improvise_contempt =
    {
        name = "Contempt",
        icon =  "negotiation/degrade.tex",
        desc = "{INCEPT} 1 {VULNERABILITY}.",

        cost = 0,

        flags = CARD_FLAGS.HOSTILE | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNIQUE,

        OnPostResolve = function( self, minigame, targets )
            self.anti_negotiator:InceptModifier("VULNERABILITY", 1 , self )
        end
    },
}

for i, id, carddef in sorted_pairs( CARDS ) do
    if not carddef.series then
        carddef.series = "SAL"
    end
    local basic_id = carddef.base_id or id:match( "(.*)_plus.*$" ) or id:match( "(.*)_upgraded[%w]*$") or id:match( "(.*)_supplemental.*$" )
        Content.AddNegotiationCard( id, carddef )
end
