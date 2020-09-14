local negotiation_defs = require "negotiation/negotiation_defs"
local CARD_FLAGS = negotiation_defs.CARD_FLAGS
local EVENT = ExtendEnum( negotiation_defs.EVENT,
{
    "PRE_GAMBLE",
    "GAMBLE",
})

local CARDS =
{
    following_orders = 
    {
        name = "Following Orders",
        icon = "negotiation/exploit_weakness.tex",
        desc = "{INCEPT} {1} {FLUSTERED}. {GAMBLE}.\n{HEADS}: Gain {2} {INFLUENCE}.\n{SNAILS}: Gain {3} {DOMINANCE}.",
        desc_fn = function( self, fmt_str )
            return loc.format( fmt_str, self.flustered_stacks, self.influence_stacks, self.dominance_stacks )
        end,

        flags = CARD_FLAGS.MANIPULATE,
        rarity = CARD_RARITY.UNCOMMON,

        cost = 1,
        max_xp = 5,
        flustered_stacks = 2,
        influence_stacks = 1,
        dominance_stacks = 1,

        OnPostResolve = function( self, minigame, card )
            self.anti_negotiator:InceptModifier("FLUSTERED", self.flustered_stacks, self )
        end,

        event_handlers =
        {
            [ EVENT.PRE_RESOLVE ] = function( self, minigame, card, targets )
                if card == self then
                    local coin = self.negotiator:FindModifier("LUCKY_COIN")
                    local result = coin and coin:Gamble(self)
                        if result == "HEADS" then
                        self.negotiator:AddModifier( "INFLUENCE", self.influence_stacks, self ) 
                        else 
                        self.negotiator:AddModifier( "DOMINANCE", self.dominance_stacks, self )
                    end
                end
            end
        }
    },
    following_orders_plus = 
    {
        name = "Convincing Following Orders",

        influence_stacks = 2,
    },
    following_orders_plus2 =
    {
        name = "Forceful Following Orders",

        dominance_stacks = 2,
    },

    questioning =
    {
        name = "Questioning",
        icon = "negotiation/browbeat.tex",
        desc = "Deal 2 bonus damage for every {IMPATIENCE} enemy has.",

        max_xp = 7,
        cost = 1,

        min_persuasion = 2,
        max_persuasion = 4,

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
                    local count = self.anti_negotiator:GetModifierStacks("IMPATIENCE")
                            bonus = bonus + count * 2
                    persuasion:AddPersuasion( bonus, bonus, self )
                end
            end,
        },
    },
    questioning_plus =
    {
        name = "Tall Questioning",

        min_persuasion = 2,
        max_persuasion = 6,
    },

    questioning_plus2 =
    {
        name = "Boosted Questioning",
        desc = "Deal 3 bonus damage for every {IMPATIENCE} enemy has.",

        min_persuasion = 1,
        max_persuasion = 2,

        event_handlers = 
        {
            [ EVENT.CALC_PERSUASION ] = function( self, source, persuasion )
                if source == self then
                    local bonus = 0
                    local count = self.anti_negotiator:GetModifierStacks("IMPATIENCE")
                            bonus = bonus + count * 3
                    persuasion:AddPersuasion( bonus, bonus, self )
                end
            end,
        },
    },

    rhetorical_question = 
    {
        name = "Rhetorical Question",
        icon = "negotiation/setup.tex",
        desc = "Cannot target core arguments.",

        flags = CARD_FLAGS.DIPLOMACY,
        rarity = CARD_RARITY.UNCOMMON,

        cost = 1,
        min_persuasion = 1,
        max_persuasion = 4,

        CanTarget = function ( self, target )
            if is_instance( target, Negotiation.Modifier ) and target.modifier_type == MODIFIER_TYPE.CORE then
                return false, CARD_PLAY_REASONS.INVALID_TARGET
            end
            return true
        end,

        features =
        {
            FREE_ACTION = 1,
        },
    },

    rhetorical_question_plus = 
    {
        name = "Tall Rhetorical Question",

        min_persuasion = 2,
        max_persuasion = 6,
    },

    rhetorical_question_plus2 = 
    {
        name = "Boosted Rhetorical Question",

    
        cost = 2,

        min_persuasion = 1,
        max_persuasion = 8,

        features =
        {
            FREE_ACTION = 2,
        },
    },

    all_in =
    {
        name = "All In",
        icon = "negotiation/kickback.tex",
        desc = "Draw a card for every time you gambled this turn.\nDraw {1}",
        desc_fn = function( self, fmt_str )
            return loc.format( fmt_str, self.gamble )
        end,

        cost = 1,

        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.UNCOMMON,

        min_persuasion = 0,
        max_persuasion = 5,
        gamble = 0,

        deck_handlers = { DECK_TYPE.DISCARDS, DECK_TYPE.IN_HAND, DECK_TYPE.DRAW},

        OnPostResolve = function( self, minigame, card )
            minigame:DrawCards(self.gamble)
        end,

        event_handlers =
        {
            [ EVENT.GAMBLE ] = function( self, result, source )
                self.gamble = self.gamble + 1
            end,

            [ EVENT.END_PLAYER_TURN ] = function( self, minigame )
                self.gamble = 0
            end,
        },
    },

    all_in_plus = 
    {
        name = "Dicey All In",
        cost = 0,
        flags = CARD_FLAGS.HOSTILE | CARD_FLAGS.EXPEND,
    },

    all_in_plus2 =
    {
        name = "Boosted All In",
        min_persuasion = 2,
        max_persuasion = 5,
    },

    forced_compliance =
    {
        name = "Forced Compliance",
        icon = "negotiation/bully.tex",
        desc = "If you have discarded a card this turn, {IMPROVISE} a manipulation card from your deck.",

        cost = 1,

        flags = CARD_FLAGS.HOSTILE,
        rarity = CARD_RARITY.COMMON,

        min_persuasion = 2,
        max_persuasion = 3,

        cards_discarded = 0,
        improvise_size = 3,
        
    	event_handlers =
        {
            [ EVENT.CARD_DISCARDED ] = function( self, card, minigame )
                if card.owner == self.owner then
                    self.cards_discarded = self.cards_discarded + 1
                end
            end,

            [ EVENT.END_TURN ] = function( self, minigame, negotiator )
                if negotiator == self.negotiator then
                    self.cards_discarded = 0
                end
            end,
        },

        OnPostResolve = function( self, minigame, card )
            if self.cards_discarded > 0 then
                local cards = {}
                for i, card in minigame:GetDrawDeck():Cards() do
                    if CheckBits(card.flags, CARD_FLAGS.MANIPULATE) then
                        table.insert(cards, card)
                    end
                end
                if #cards == 0 then
                    minigame:ShuffleDiscardToDraw()
                    for i, card in minigame:GetDrawDeck():Cards() do
                        if CheckBits(card.flags, CARD_FLAGS.MANIPULATE) then
                            table.insert(cards, card)
                        end
                    end
                end
    
                minigame:ImproviseCards( table.multipick(cards, self.improvise_size), self.count )
            end
        end,
    },

    forced_compliance_plus = 
    {
        name = "Targeted Compliance",
        desc = "If you have discarded a card this turn, {IMPROVISE} a manipulation card from your discards.",

    	event_handlers =
        {
            [ EVENT.CARD_DISCARDED ] = function( self, card, minigame )
                if card.owner == self.owner then
                    self.cards_discarded = self.cards_discarded + 1
                end
            end,

            [ EVENT.END_TURN ] = function( self, minigame, negotiator )
                if negotiator == self.negotiator then
                    self.cards_discarded = 0
                end
            end,
        },

        OnPostResolve = function( self, minigame, card )
            if self.cards_discarded > 0 then
                local cards = {}
                for i, card in minigame:GetDiscardDeck():Cards() do
                    if CheckBits(card.flags, CARD_FLAGS.MANIPULATE) then
                        table.insert(cards, card)
                    end
                end

                minigame:ImproviseCards( table.multipick(cards, self.improvise_size), self.count )
            end
        end,
    },

    forced_compliance_plus2 =
    {
        name = "Tall Compliance",
        min_persuasion = 2,
        max_persuasion = 5,
    },

    stall = 
    {
        name = "Stall",
        icon = "negotiation/improvise_withdrawn.tex",
        desc = "Apply {1} {COMPOSURE}, decrease composure applied by this card by 2.",
        desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self.composure_gained)
        end,

        cost = 0,
        max_xp = 8,

        composure_gained = 4,

        flags = CARD_FLAGS.MANIPULATE,
        rarity = CARD_RARITY.COMMON,

        target_self = TARGET_ANY_RESOLVE,

        OnPostResolve = function( self, minigame, targets )
            for i,target in ipairs(targets) do
                target:DeltaComposure(self.composure_gained, self)
            end
            if self.composure_gained > 1 then
                self.composure_gained = self.composure_gained - 2
            else self.composure_gained = 0 
            end
        end,
    },

    stall_plus =
    {
        name = "Enduring Stall",
        desc = "Apply {1} {COMPOSURE}, decrease composure applied by this card by 1.",

        OnPostResolve = function( self, minigame, targets )
            for i,target in ipairs(targets) do
                target:DeltaComposure(self.composure_gained, self)
            end
            if self.composure_gained > 0 then
                self.composure_gained = self.composure_gained - 1
            else self.composure_gained = 0 
            end
        end,
    },

    stall_plus2 =
    {
        name = "Boosted Stall",
        desc = "Apply {1} {COMPOSURE}, decrease composure applied by this card by 3.",

        composure_gained = 6,

        OnPostResolve = function( self, minigame, targets )
            for i,target in ipairs(targets) do
                target:DeltaComposure(self.composure_gained, self)
            end
            if self.composure_gained > 2 then
                self.composure_gained = self.composure_gained - 3
            else self.composure_gained = 0 
            end
        end,
    },
    
    swindle_modded = 
    {
        name = "Swindle",
        icon = "negotiation/associates.tex",
        desc = "Set the coin.\n{EVOKE}: {RIG} {HEADS} or {SNAILS}.",
        desc_fn = function( self, fmt_str )
            return loc.format( fmt_str, self.composure )
        end,

        flags = CARD_FLAGS.MANIPULATE | CARD_FLAGS.UNPLAYABLE,
        rarity = CARD_RARITY.UNCOMMON,

        deck_handlers = { DECK_TYPE.DRAW, DECK_TYPE.DISCARDS },

        cost = 1,

        OnPostResolve = function( self, minigame, targets )
            local coin = self.negotiator:FindModifier("LUCKY_COIN")
            if coin then coin:SetCoin(nil, self) end
        end,

        event_handlers = 
        {
            [ EVENT.MODIFIER_ADDED ] = function( self, modifier, source )
                if modifier.id == "RIG_HEADS" or modifier.id == "RIG_SNAILS" then
                    self:Evoke( 1 )
                end
            end,

            [ EVENT.MODIFIER_CHANGED ] = function( self, modifier, delta, clone, source )
                if modifier.id == "RIG_HEADS" or modifier.id == "RIG_SNAILS" and delta > 0 then
                    self:Evoke( 1 )
                end
            end,

            [ EVENT.END_TURN ] = function( self, minigame, negotiator )
                if negotiator == self.negotiator then
                    self:ResetEvoke()
                end
            end,
        },
    },

    swindle_modded_plus =
    {
        name = "Repeated Swindle",
        desc = "Set the coin twice.\n{EVOKE}: {RIG} {HEADS} or {SNAILS}.",
        OnPostResolve = function( self, minigame, targets )
            local coin = self.negotiator:FindModifier("LUCKY_COIN")
            if coin then coin:SetCoin(nil, self) end
            if coin then coin:SetCoin(nil, self) end
        end,
    },

    swindle_modded_plus2 =
    {
        name = "Boosted Swindle",
        desc = "Set the coin. {RIG} 1 more {HEADS} or {SNAILS}.\n{EVOKE}: {RIG} {HEADS} or {SNAILS}.",

        OnPostResolve = function( self, minigame, targets )
            local coin = self.negotiator:FindModifier("LUCKY_COIN")
            if coin then coin:SetCoin(nil, self) end
            if self.negotiator:HasModifier("RIG_HEADS") then self.negotiator:AddModifier("RIG_HEADS", 1) end
            if self.negotiator:HasModifier("RIG_SNAILS") then self.negotiator:AddModifier("RIG_SNAILS", 1) end
        end,
    },
    
    blissful_ignorance = 
    {
        name = "Blissful Ignorance",
        icon = "negotiation/networker.tex",
        desc = "Apply {1} {COMPOSURE}.\n{PREPARED}: Increase composure applied by this card by 2 for the rest of this negotiation.",
        desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self.composure_gained)
        end,

        cost = 1,
        max_xp = 8,

        composure_gained = 2,
        composure_increase = 2,

        flags = CARD_FLAGS.DIPLOMACY,
        rarity = CARD_RARITY.COMMON,

        target_self = TARGET_ANY_RESOLVE,

        PreReq = function( self, minigame )
            self.prepared = self:IsPrepared()
            return self.prepared
        end,

        OnPostResolve = function( self, minigame, targets )
            for i,target in ipairs(targets) do
                target:DeltaComposure(self.composure_gained, self)
            end
            if self.prepared then
                self.composure_gained = self.composure_gained + self.composure_increase
            end
        end,
    },

    blissful_ignorance_plus =
    {
        name = "Wide Ignorance",
        desc = "Apply {1} {COMPOSURE} all your arguments.\n{PREPARED}: Increase composure applied by this card by 1 for the rest of this negotiation.",

        target_mod = TARGET_MOD.TEAM,
        auto_target = true,

        composure_gained = 1,
        composure_increase = 1,
    },

    blissful_ignorance_plus2 =
    {
        name = "Boosted Ignorance",

        composure_gained = 4,
    },
    
}

for i, id, carddef in sorted_pairs( CARDS ) do
    carddef.series = "ROOK"

    Content.AddNegotiationCard( id, carddef )
end

local MODIFIERS = 
{

}

for id, def in pairs( MODIFIERS ) do
    Content.AddNegotiationModifier( id, def )
end