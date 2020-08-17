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
        max_persuasion = 6,

        features =
        {
            FREE_ACTION = 2,
        },
    },

}

for i, id, carddef in sorted_pairs( CARDS ) do
    carddef.series = "ROOK"

    Content.AddNegotiationCard( id, carddef )
end

local MODIFIERS = 
{
    THICK_SKINNED =
    {
        name = "Thick-skinned",
        icon = "negotiation/modifiers/sympathizer.tex",
        desc = "Apply {1} {COMPOSURE} to all friendly arguments at the beginning of your turn.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.stacks)
        end,

        max_resolve = 4,

        event_handlers =
        {
            [ EVENT.BEGIN_TURN ] = function( self, minigame, negotiator )
                if negotiator == self.negotiator then
                local targets = minigame:CollectAlliedTargets(self.negotiator)
                for i=1, #targets do
                    if (targets[i]:GetResolve() or 0) > 0 then
                        targets[i]:DeltaComposure(self.stacks, self)
                    end
                end
                end
            end,
        },
    },
}

for id, def in pairs( MODIFIERS ) do
    Content.AddNegotiationModifier( id, def )
end