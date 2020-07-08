local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

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
        rarity = CARD_RARITY.COMMON,
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
        anim = "taunt",
        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.COMMON,
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
    recollection = 
    {
        name = "Recollection",
        desc = "Draw 2 cards and discard them immediately. They cost 0 until played.",
        anim = "taunt2",
        icon = "negotiation/recall.tex", 
        flavour = "'Usually a little difficult to do, the more focused the combatant the better the results.'",
        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNCOMMON,
        cost = 1,
        max_xp = 5,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

        OnPostResolve = function( self, battle, attack)
            local cards = battle:DrawCards( 2 )
            if cards[1] then
                cards[1]:SetFlags( CARD_FLAGS.FREEBIE )
                self.engine:DiscardCard(cards[1])
            end
            if cards[2] then
                cards[2]:SetFlags( CARD_FLAGS.FREEBIE )
                self.engine:DiscardCard(cards[2])
            end
        end,
    },
    recollection_plus =
    {
        name = "Enduring Recollection",
        flags = CARD_FLAGS.SKILL,
    },

    recollection_plus2 =
    {
        name = "Visionary Recollection",
        desc = "Draw <#UPGRADE>3</> cards and discard them immediately. They cost 0 until played.",

        OnPostResolve = function( self, battle, attack)
            local cards = battle:DrawCards( 3 )
            if cards[1] then
                cards[1]:SetFlags( CARD_FLAGS.FREEBIE )
                self.engine:DiscardCard(cards[1])
            end
            if cards[2] then
                cards[2]:SetFlags( CARD_FLAGS.FREEBIE )
                self.engine:DiscardCard(cards[2])
            end
            if cards[3] then
                cards[3]:SetFlags( CARD_FLAGS.FREEBIE )
                self.engine:DiscardCard(cards[3])
            end
        end,
    },

    bloodshed =
    {
        name = "Bloodshed",
        icon = "battle/ripper.tex", 
		desc = "If the target has {1} or more {BLEED} {HEAL} {1}.",
        desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self.heal_amount)
        end,
        anim = "hemorrhage",

        flags = CARD_FLAGS.MELEE | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.RARE,
        max_xp = 5,

        cost = 1,
        min_damage = 1,
        max_damage = 5,
        heal_amount = 5,

        OnPostResolve = function( self, battle, attack)
            for i, hit in attack:Hits() do
                if not attack:CheckHitResult( hit.target, "evaded" ) and hit.target:GetConditionStacks("BLEED") > 4 then
                    self.owner:HealHealth(self.heal_amount, self)
                end
            end
        end,
    },
    bloodshed_plus =
    {
        name = "Ravenous Bloodshed",
        heal_amount = 8,

        OnPostResolve = function( self, battle, attack)
            for i, hit in attack:Hits() do
                if not attack:CheckHitResult( hit.target, "evaded" ) and hit.target:GetConditionStacks("BLEED") > 7 then
                    self.owner:HealHealth(self.heal_amount, self)
                end
            end
        end,
    },
    bloodshed_plus2 =
    {
        name = "Savage Bloodshed",
        min_damage = 3,
        max_damage = 9,
    },

parry =
{
    name = "Parry",
    icon = "battle/rebound.tex", 
    desc = "Gain {1} {PERFECT_PARRY}.",
    desc_fn = function(self, fmt_str)
        return loc.format(fmt_str, self.parry_amount)
    end,
    anim = "taunt",
    target_type = TARGET_TYPE.SELF,
    rarity = CARD_RARITY.COMMON,
    cost = 1,
    max_xp = 7,
    flags = CARD_FLAGS.SKILL,

    parry_amount = 1,

    features = 
        {
            DEFEND = 4,
        },

        OnPostResolve = function( self, battle, attack)
            self.owner:AddCondition("PERFECT_PARRY", self.parry_amount, self)
        end,
    },  
parry_plus =
{
    name = "Stone Parry",

    features = 
    {
        DEFEND = 6,
    },
},
parry_plus2 =
{
    name = "Rival's Parry",

    parry_amount = 2,

},

adrenaline_rush = 
{
    name = "Adrenaline Rush",
    icon = "battle/jolt.tex", 
    desc = "{FINISHER}: Draw a card per {COMBO}.",
    anim = "wildlunge",
    flags = CARD_FLAGS.MELEE | CARD_FLAGS.COMBO_FINISHER,
    rarity = CARD_RARITY.UNCOMMON, 

    cost = 1,
    min_damage = 2,
    max_damage = 4,
    cards_drawn = 1,

    OnPreResolve = function( self, battle, attack )
        if self.owner:HasCondition("COMBO") then
            battle:DrawCards( self.cards_drawn * self.owner:GetConditionStacks("COMBO") )
            self.owner:RemoveCondition("COMBO")
        end
    end,
},

adrenaline_rush_plus =
{
    name = "Pale Adrenaline Rush",

    cost = 0,
    min_damage = 1,
    max_damage = 2,
},

adrenaline_rush_plus2 = 
{
    name = "Boosted Adrenaline Rush",

    min_damage = 4,
    max_damage = 6,
},

resource_management =
{
    name = "Resource Management",
    desc = "{IMPROVISE} 1 card from your draw pile and 1 card from your discard pile.",
    icon = "battle/fully_loaded.tex", 

    cost = 1,

    flags = CARD_FLAGS.SKILL,
    rarity = CARD_RARITY.UNCOMMON,

    target_type = TARGET_TYPE.SELF,

    OnPostResolve = function( self, battle, attack )
        if battle:GetDrawDeck():CountCards() == 0 then
            battle:ShuffleDiscardToDraw()
        end
        local cards = battle:ImproviseCards(table.multipick(battle:GetDrawDeck().cards, 3), 1)
        local cards = battle:ImproviseCards(table.multipick(battle:GetDiscardDeck().cards, 3), 1)
    end
},

resource_management_plus =
{
    name = "Wide Management",
    desc = "{IMPROVISE_PLUS} 1 card from your draw pile and 1 card from your discard pile.",

    OnPostResolve = function( self, battle, attack )
        if battle:GetDrawDeck():CountCards() == 0 then
            battle:ShuffleDiscardToDraw()
        end
        local cards = battle:ImproviseCards(table.multipick(battle:GetDrawDeck().cards,  5), 1)
        local cards = battle:ImproviseCards(table.multipick(battle:GetDiscardDeck().cards, 5), 1)
    end
},

resource_management_plus2 =
{
    name = "Reliable Management",
    desc = "{IMPROVISE} 1 card from your draw pile and 1 card from your discard pile.",
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.STICKY,
},

}

for i, id, data in sorted_pairs(attacks) do
    if not data.series then
        data.series = "SAL"
    end
    local basic_id = data.base_id or id:match( "(.*)_plus.*$" ) or id:match( "(.*)_upgraded[%w]*$") or id:match( "(.*)_supplemental.*$" )
        Content.AddBattleCard( id, data )
end

