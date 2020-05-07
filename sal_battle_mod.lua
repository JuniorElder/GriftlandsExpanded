local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CONFIG = require "JuniorElderExpandedMod:config"

local attacks =
{	
	proper_technique =
    {
        name = "Proper Technique",
        anim = "taunt",
        desc = "Insert {float_butterfly} or {sting_bee} into your hand.",
	icon = "negotiation/sals_instincts.tex",

        rarity = CARD_RARITY.RARE,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        target_type = TARGET_TYPE.SELF,

        cost = 2,
        max_xp = 4,

        sound = "event:/sfx/battle/status/special/sals_daggers",

        OnPostResolve = function( self, battle, attack)
            local cards = {
                Battle.Card( "float_butterfly", self.owner ),
                Battle.Card( "sting_bee", self.owner ),
            }
            battle:ImproviseCards( cards )
        end,
    },
 
    float_butterfly = 
    {
        name = "Float Like a Butterfly",
        desc = "Gain 1 {EVASION}.",
        anim = "taunt",
	icon = "battle/slippery.tex",

        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        target_type = TARGET_TYPE.SELF,

	cost = 0,

        OnPostResolve = function( self, battle, attack )
            self.owner:AddCondition("EVASION", 1)
        end,
	
	features = 
        {
            DEFEND = 6,
        }
    },

    sting_bee = 
    {
        name = "Sting Like a Bee!",
        anim = "stab",
	icon = "battle/echo_strike.tex",

        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.MELEE | CARD_FLAGS.EXPEND,
        cost = 0,

        min_damage = 4,
        max_damage = 4,

        features =
        {
            STUN = 1,
        }
    },

    proper_technique_plus =
    {
        name = "Conservative Technique",
	flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.STICKY,
    },
    proper_technique_plus2 =
    {
        name = "Innovative Technique",
        desc = "Insert {float_butterfly} or {sting_bee} into your hand.\nDraw two cards.",

        OnPostResolve = function( self, battle, attack )
            battle:DrawCards(2)
            local cards = {
                Battle.Card( "float_butterfly", self.owner ),
                Battle.Card( "sting_bee", self.owner ),
            }
            battle:ImproviseCards( cards )
        end,
    },
    
    quick_reflexes =
    {
        name = "Quick Reflexes",
        desc = "Discard this card:\nDraw a card.",
        anim = "taunt",
        icon = "battle/churn.tex",
        rarity = CARD_RARITY.UNCOMMON,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.UNPLAYABLE | CARD_FLAGS.REPLENISH,
        target_type = TARGET_TYPE.SELF,

        cost = 0,
        max_xp = 5,

        event_handlers =
        {
            [ BATTLE_EVENT.CARD_DISCARDED ] = function( self, card, battle )
                if card == self then
                    battle:DrawCards(self.num_cards)
                    self:AddXP(1)
                end
            end,
        },
    },
    quick_reflexes_plus =
    {
        name = "Reflexive Parry",	
        target_type = TARGET_TYPE.SELF,
	desc = "Discard this card:\nDraw a card. Gain {1} {RIPOSTE}.",
	desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self:CalculateDefendText( self.riposte_amount))
        end,
        icon = "battle/rebound.tex",

        riposte_amount = 2,

	event_handlers =
        {
            [ BATTLE_EVENT.CARD_DISCARDED ] = function( self, card, battle )
                if card == self then
                    battle:DrawCards(self.num_cards)
                    self:AddXP(1)
                    self.owner:AddCondition("RIPOSTE", self.riposte_amount, self)		    
                end
            end,
        },

    },
    quick_reflexes_plus2 = 
    {
        name = "Reflexive Dodge",
        target_type = TARGET_TYPE.SELF,
	desc = "Discard this card:\nDraw a card. Gain {1} {DEFEND}.",
	desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self:CalculateDefendText( self.defend_amount ))
        end,
        icon = "battle/scatter.tex",

	defend_amount = 3,

	event_handlers =
        {
            [ BATTLE_EVENT.CARD_DISCARDED ] = function( self, card, battle )
                if card == self then
                    battle:DrawCards(self.num_cards)
                    self:AddXP(1)
		    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                end
            end,
        },
    },
    energy_field =
    {
        name = "Energy Field",
        icon = "battle/arc_deflection.tex",

        flavour = "'The best way to take a hit is to be in another place when it comes.'",
        
        anim = "taunt",
        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNCOMMON,
        cost = 2,
        max_xp = 8,
        flags = CARD_FLAGS.SKILL,

	features = 
        {
	    DEFEND = 8,
            RIPOSTE = 2,
        },
    },
    energy_field_plus =
    {
        name = "Portable Energy Field",	
        desc = "Apply {DEFEND 8}.\nApply 2 {RIPOSTE}.",        
        manual_desc = true,
        target_type = TARGET_TYPE.FRIENDLY_OR_SELF,
    },
    energy_field_plus2 =
    {
        name = "Charged Energy Field",
        features = 
        {
	    DEFEND = 12,
            RIPOSTE = 2,
        },
    },
}

for i, id, data in sorted_pairs(attacks) do
    if not data.series then
        data.series = "SAL"
    end
    local basic_id = data.base_id or id:match( "(.*)_plus.*$" ) or id:match( "(.*)_upgraded[%w]*$") or id:match( "(.*)_supplemental.*$" )
    if CONFIG.enabled_cards[id] or CONFIG.enabled_cards[basic_id] then
        Content.AddBattleCard( id, data )
    end
end

