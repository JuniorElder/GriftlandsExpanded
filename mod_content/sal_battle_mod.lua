local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

local attacks =
{	
	proper_technique =
    {
        name = "Escape Artist",
        desc = "Insert {hamstring} or {graceful_retreat} into your hand.",
	    icon = "battle/get_down.tex",

        rarity = CARD_RARITY.RARE,
	    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.STICKY,
        target_type = TARGET_TYPE.SELF,

        cost = 2,
        max_xp = 4,

        OnPostResolve = function( self, battle, attack)
            local cards = {
                Battle.Card( "hamstring", self.owner ),
                Battle.Card( "graceful_retreat", self.owner ),
            }
            battle:ImproviseCards( cards )
        end,
    },
 
    proper_technique_plus =
    {
        name = "Radical Escape Artist",
        desc = "Insert {hamstring}, {graceful_retreat} or {anaesthesia} into your hand.",

        OnPostResolve = function( self, battle, attack)
            local cards = {
                Battle.Card( "hamstring", self.owner ),
                Battle.Card( "graceful_retreat", self.owner ),
                Battle.Card( "anaesthesia", self.owner ),
            }
            battle:ImproviseCards( cards )
        end,
    },

    proper_technique_plus2 =
    {
        name = "Geared Escape Artist",
        desc = "Insert {hamstring}, {graceful_retreat} or {flashbang} into your hand.",

        OnPostResolve = function( self, battle, attack )
            local cards = {
                Battle.Card( "hamstring", self.owner ),
                Battle.Card( "graceful_retreat", self.owner ),
                Battle.Card( "flashbang", self.owner ),
            }
            battle:ImproviseCards( cards )
        end,
    },

    flashbang = 
    {
        name = "Flashbang",
        desc = "{STUN} everyone except yourself.",
        anim = "throw",
        hit_tags = { "spark" },
        icon = "battle/gunsmoke.tex",
        
        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        cost = 0,

        target_type = TARGET_TYPE.ANY,
        target_mod = TARGET_MOD.CUSTOM,
        auto_target = true,

        target_fn = function( self, battle, primary_target, target_fighters )
            for i, fighter in battle:ActiveFighters() do
                if fighter:GetStatus() ~= FIGHT_STATUS.SURRENDER then
                    table.insert( target_fighters, fighter )
                end
            end
        end,

        OnPostResolve = function( self, battle, attack )
            for i, hit in attack:Hits() do
                hit.target:AddCondition("STUN", 1, self)
            end
        end    
    },

    anaesthesia = 
    {
        name = "Anaesthesia",
        desc = "Remove all debuffs and gain 8 {DEFEND}.",
        anim = "drink",
	    icon = "battle/power_through.tex",

        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        cost = 0,

        target_type = TARGET_TYPE.SELF,

        defend_amt = 8,

        OnPostResolve = function( self, battle, attack)
            self.owner:RemoveAllDebuffs()
            attack:AddCondition("DEFEND", self.defend_amt, self)
        end,
    },

    graceful_retreat = 
    {
        name = "Graceful Retreat",
        desc = "Gain 2 {EVASION} and 2 {RIPOSTE}.",
        anim = "step_back",
	    icon = "battle/misdirection.tex",

        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        cost = 0,

        target_type = TARGET_TYPE.SELF,

        evasion_amt = 2,
        riposte_amt = 2,

        OnPostResolve = function( self, battle, attack)
            attack:AddCondition("RIPOSTE", self.riposte_amt, self)
            attack:AddCondition("EVASION", self.evasion_amt, self)
        end,
    },
    
    hamstring = 
    {
        name = "Hamstring",
        desc = "Apply 2 {IMPAIR} to all enemies and draw 2 cards. They cost 0 until played.",
        anim = "taunt2",
	    icon = "battle/certainty.tex",

        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        cost = 0,

        target_mod = TARGET_MOD.TEAM,

        OnPostResolve = function( self, battle, attack )
            local cards = battle:DrawCards( 2 )
            for i = 1, math.min( #cards, 2 ) do
                cards[i]:SetFlags( CARD_FLAGS.FREEBIE )
            end
            for i, hit in attack:Hits() do
                hit.target:AddCondition("IMPAIR", 2, self)
            end
        end   
    },

    energy_field =
    {
        name = "Energy Field",
        desc = "Gain {DEFEND {1}}.\nGain {2} {RIPOSTE}.",
        desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self.defend_amt, self.riposte_amt )
        end,
        icon = "battle/arc_deflection.tex",    
        anim = "taunt",

        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.COMMON,
        cost = 2,
        max_xp = 8,
        flags = CARD_FLAGS.SKILL,

        defend_amt = 8,
        riposte_amt = 2,
        
        OnPostResolve = function( self, battle, attack)
            attack:AddCondition("DEFEND", self.defend_amt, self)
            attack:AddCondition("RIPOSTE", self.riposte_amt, self)
        end,
    },
    energy_field_plus =
    {
        name = "Portable Energy Field",	
        target_type = TARGET_TYPE.FRIENDLY_OR_SELF,
        desc = "Apply {DEFEND {1}}.\nApply {2} {RIPOSTE}.",

        defend_amt = 6,
        riposte_amt = 4,
    },
    energy_field_plus2 =
    {
        name = "Charged Energy Field",

        defend_amt = 12,
        riposte_amt = 2,
    },
    recollection = 
    {
        name = "Recollection",
        desc = "Draw 3 cards and discard them immediately. They cost 0 until played.",
        anim = "taunt2",
        icon = "negotiation/recall.tex", 
        
        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNCOMMON,
        cost = 1,
        max_xp = 5,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

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
    recollection_plus =
    {
        name = "Enduring Recollection",
        desc = "Draw 2 cards and discard them immediately. They cost 0 until played.",
        flags = CARD_FLAGS.SKILL,

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

    recollection_plus2 =
    {
        name = "Visionary Recollection",
        desc = "Draw <#UPGRADE>4</> cards and discard them immediately. They cost 0 until played.",

        OnPostResolve = function( self, battle, attack)
            local cards = battle:DrawCards( 4 )
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
            if cards[4] then
                cards[4]:SetFlags( CARD_FLAGS.FREEBIE )
                self.engine:DiscardCard(cards[4])
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
    name = "Outmaneuver",
    icon = "battle/weakness_slow.tex", 
    desc = "Gain {1} {DEFEND}.\nSpend {2} {COMBO} to increase {DEFEND} applied by {3} for the rest of this combat.",
    desc_fn = function(self, fmt_str)
        return loc.format(fmt_str, self.defense_amt, self.combo_needed, self.defense_increase)
    end,
    anim = "taunt",
    target_type = TARGET_TYPE.SELF,
    rarity = CARD_RARITY.UNCOMMON,
    cost = 1,
    max_xp = 7,
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.COMBO_FINISHER,

    defense_amt = 4,
    combo_needed = 3,
    defense_increase = 2,

    OnPostResolve = function( self, battle, attack )
        self.owner:AddCondition("DEFEND", self.defense_amt)
        if self.owner:GetConditionStacks("COMBO") > (self.combo_needed - 1) then
            self.defense_amt = self.defense_amt + self.defense_increase
            self.owner:RemoveCondition("COMBO", self.defense_increase)
        end
    end,
    },  

    parry_plus =
    {
    name = "Stone Outmaneuver",

    defense_amt = 6,
    },

    parry_plus2 =
    {
    name = "Pale Outmaneuver",

    combo_needed = 2,
    },

adrenaline_rush = 
{
    name = "Adrenaline Rush",
    icon = "battle/jolt.tex", 
    desc = "Spend all your {COMBO}: Draw a card per {COMBO}.",
    anim = "wildlunge",
    flags = CARD_FLAGS.MELEE | CARD_FLAGS.COMBO_FINISHER,
    rarity = CARD_RARITY.UNCOMMON, 

    cost = 1,
    min_damage = 2,
    max_damage = 4,
    cards_drawn = 1,

    OnPostResolve = function( self, battle, attack )
        if self.owner:HasCondition("COMBO") then
            battle:DrawCards( self.cards_drawn * self.owner:GetConditionStacks("COMBO") )
            self.owner:RemoveCondition("COMBO")
        end
    end,
},

adrenaline_rush_plus =
{
    name = "Ambitious Adrenaline Rush",
    desc = "Discard your hand.\nSpend all your {COMBO}: Draw a card per {COMBO}.",

    OnPostResolve = function( self, battle, attack)

        local tbl = ObtainWorkTable()
        for i, card in battle:GetHandDeck():Cards() do
            table.insert(tbl, card)
        end

        for i, card in ipairs(tbl) do
            battle:DiscardCard(card)
        end

        ReleaseWorkTable(tbl)

        if self.owner:HasCondition("COMBO") then
            battle:DrawCards( self.cards_drawn * self.owner:GetConditionStacks("COMBO") )
            self.owner:RemoveCondition("COMBO")
        end
    end,
},

adrenaline_rush_plus2 = 
{
    name = "Boosted Adrenaline Rush",

    min_damage = 3,
    max_damage = 6,
},

resource_management =
{
    name = "Resource Management",
    desc = "{IMPROVISE} 1 card from your draw pile and 1 card from your discard pile.",
    icon = "battle/fully_loaded.tex", 

    cost = 1,
    max_xp = 6,

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

pounce =
{
    name = "Pounce",
    icon = "battle/rib_cracker.tex", 
    anim = "stomp",
    desc = "At the end of your turn increase cost by 1.",

    cost = 0,
    min_damage = 4,
    max_damage = 8,

    increase = 0,

    flags = CARD_FLAGS.MELEE,
    rarity = CARD_RARITY.COMMON,

    deck_handlers = { DECK_TYPE.DRAW, DECK_TYPE.IN_HAND, DECK_TYPE.DISCARDS },

    event_handlers = 
    {
        [ BATTLE_EVENT.CALC_ACTION_COST ] = function( self, cost_acc, card, target )
            if card == self then
                cost_acc:AddValue(self.increase)
            end
        end,

        [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                self.increase = self.increase + 1
                return self.increase
        end
    },
},

pounce_plus =
{
    name = "Boosted Pounce",

    min_damage = 6,
    max_damage = 8,
},

pounce_plus2 =
{
    name = "Nailed Pounce",

    flags = CARD_FLAGS.PIERCING | CARD_FLAGS.MELEE,
},

bait =
{
    name = "Bait",
    icon = "battle/take_cover.tex", 
    anim = "call_in",
    desc = "Discard a card. Gain {DEFEND} equal to twice its cost.",

    rarity = CARD_RARITY.UNCOMMON,
    flags = CARD_FLAGS.SKILL,
    target_type = TARGET_TYPE.SELF,

    cost = 0,
    defend_base = 0,
    defend_increment = 1,

    card_number = 1,

    OnPostResolve = function( self, battle, attack)
        local cards = battle:DiscardCards(1)
        if #cards > 0 then
            local discard_cost = battle:CalculateActionCost(cards[1])
            self.owner:AddCondition( "DEFEND", discard_cost * 2, self )
        end
    end,
},

bait_plus =
{
    name = "Reliable Bait",
    desc = "Gain {DEFEND} equal to twice the cost of the most expensive card in your hand.",

    cost = 0,
    defend_base = 0,
    defend_increment = 1,

    card_number = 1,

    OnPostResolve = function( self, battle, attack)
        local options = {}
        for i,hand_card in self.engine:GetHandDeck():Cards() do
            if hand_card ~= self then
                table.insert(options, hand_card)
            end
        end
        table.sort(options, function(a,b) return self.engine:CalculateActionCost(a) < self.engine:CalculateActionCost(b) end)
        local cost_added = 0
        if #options > 0 then
            for i=1, math.min(self.card_number, #options) do
                cost_added = cost_added + self.engine:CalculateActionCost(options[#options - i + 1])
            end
        end
        local defend_amt = self.defend_base + cost_added * self.defend_increment
        self.owner:AddCondition( "DEFEND", defend_amt * 2, self )
    end,
    
},
bait_plus2 =
{
    name = "Enhanced Bait",
    desc = "Discard two cards. Gain {DEFEND} equal to their combined cost.",

    OnPostResolve = function( self, battle, attack)
        local cards = battle:DiscardCards(2)
        if #cards > 0 then
            local discard_cost1 = battle:CalculateActionCost(cards[1])
            if #cards > 1 then
            local discard_cost2 = battle:CalculateActionCost(cards[2])
            self.owner:AddCondition( "DEFEND", discard_cost1 + discard_cost2, self )
            else
            self.owner:AddCondition( "DEFEND", discard_cost1, self )
            end
        end
    end,
},

trickery =
{
    name = "Trickery",
    icon = "battle/snellecks_finest.tex", 
    desc = "{IMPROVISE} a random common, uncommon and rare card.",
    anim = "taunt",
    target_type = TARGET_TYPE.SELF,
    rarity = CARD_RARITY.UNCOMMON,
    cost = 1,
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
    upgraded = false,

    pool_size = 3,

    OnPostResolve = function( self, battle, attack)
        
        local card_defs1 = BattleCardCollection():IsUnlocked():Filter(function(card_def) 
                                                            return self.id ~= card_def.id and 
                                                                    (card_def.rarity == CARD_RARITY.COMMON) and
                                                                    AgentUtil.CanUseCard(self:GetOwner().agent, card_def) and 
                                                                    not CheckBits( card_def.flags, CARD_FLAGS.ITEM ) and 
                                                                    CheckBits( card_def.flags, CARD_FLAGS.UPGRADED ) == self.upgraded 
                                                        end):Pick(self.pool_size)

        local cards1 = table.map(card_defs1, 
                function(card_def) 
                    local card = Battle.Card(card_def.id, self:GetOwner()) 
                    card:ClearXP()
                    return card
                end)

        local card_defs2 = BattleCardCollection():IsUnlocked():Filter(function(card_def) 
            return self.id ~= card_def.id and 
                    (card_def.rarity == CARD_RARITY.UNCOMMON) and
                    AgentUtil.CanUseCard(self:GetOwner().agent, card_def) and 
                    not CheckBits( card_def.flags, CARD_FLAGS.ITEM ) and 
                    CheckBits( card_def.flags, CARD_FLAGS.UPGRADED ) == self.upgraded 
        end):Pick(self.pool_size)

        local cards2 = table.map(card_defs2, 
        function(card_def) 
        local card = Battle.Card(card_def.id, self:GetOwner()) 
        card:ClearXP()
        return card
        end)

        local card_defs3 = BattleCardCollection():IsUnlocked():Filter(function(card_def) 
            return self.id ~= card_def.id and 
                    (card_def.rarity == CARD_RARITY.RARE) and
                    AgentUtil.CanUseCard(self:GetOwner().agent, card_def) and 
                    not CheckBits( card_def.flags, CARD_FLAGS.ITEM ) and 
                    CheckBits( card_def.flags, CARD_FLAGS.UPGRADED ) == self.upgraded 
        end):Pick(self.pool_size)

        local cards3 = table.map(card_defs3, 
        function(card_def) 
        local card = Battle.Card(card_def.id, self:GetOwner()) 
        card:ClearXP()
        return card
        end)

        battle:ImproviseCards(cards1)
        battle:ImproviseCards(cards2)
        battle:ImproviseCards(cards3)
    end,
},

trickery_plus =
{
    name = "Wide Trickery",
    desc = "{IMPROVISE_PLUS} a random common, uncommon and rare card.",

    pool_size = 5,
},

trickery_plus2 =
{
    name = "Enduring Trickery",

    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.STICKY,
},

reserves = 
{
    name = "Hidden Reserves",
    icon = "battle/ammo_pouch.tex",
    anim = "hero_taunt2",
    desc = "Gain 2 {DEFEND} and 1 {RIPOSTE} for every 3 cards in your discards.",
    loc_strings =
    {
        ALT_DESC = "Gain 2 {DEFEND} and 1 {RIPOSTE} for every 3 cards in your discards.\n({1} {DEFEND} {2} {RIPOSTE})",
    },
    desc_fn = function( self, fmt_str )
        if self.engine then
            return loc.format( self.def:GetLocalizedString( "ALT_DESC" ), self:CalculateActions() * 2, self:CalculateActions() )
        else
            return fmt_str
        end
    end,

    target_type = TARGET_TYPE.SELF,
    flags = CARD_FLAGS.SKILL,
    rarity = CARD_RARITY.UNCOMMON,

    cost = 1,

    CalculateActions = function( self )
        return math.floor( self.engine:GetDeck( DECK_TYPE.DISCARDS ):CountCards() / 3 )
    end,

    Defense = function(self, battle)
        self.owner:AddCondition( "DEFEND", self:CalculateActions() * 2, self )
    end,

    Counter = function(self, battle)
        self.owner:AddCondition( "RIPOSTE", self:CalculateActions() * 1, self )
    end,

    OnPostResolve = function( self, battle )
        self:Defense(battle)
        self:Counter(battle)
    end,
},
reserves_plus = 
{
    name = "Boosted Reserves",
    desc = "Gain 3 {DEFEND} and 1 {RIPOSTE} for every 3 cards in your discards.",
    loc_strings =
    {
        ALT_DESC = "Gain 3 {DEFEND} and 1 {RIPOSTE} for every 3 cards in your discards.\n({1} {DEFEND} {2} {RIPOSTE})",
    },
    desc_fn = function( self, fmt_str )
        if self.engine then
            return loc.format( self.def:GetLocalizedString( "ALT_DESC" ), self:CalculateActions() * 3, self:CalculateActions() )
        else
            return fmt_str
        end
    end,

    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND ,
    
    Defense = function(self, battle)
        self.owner:AddCondition( "DEFEND", self:CalculateActions() * 3, self )
    end,

    Counter = function(self, battle)
        self.owner:AddCondition( "RIPOSTE", self:CalculateActions() * 1, self )
    end,
},

reserves_plus2 = 
{
    name = "Targeted Reserves",
    desc = "Apply 2 {DEFEND} and 1 {RIPOSTE} for every 3 cards in your discards.",

    loc_strings =
    {
        ALT_DESC = "Apply 2 {DEFEND} and 1 {RIPOSTE} for every 3 cards in your discards.\n ({1} {DEFEND} {2} {RIPOSTE})",
    },

    target_type = TARGET_TYPE.FRIENDLY_OR_SELF,
},

frenzy_mod = 
{
    name = "Frenzy",
    icon = "battle/affliction.tex",
    anim = "lacerate",
    desc = "Apply {1} {BLEED}, then gain 1 {COMBO} for every 2 {BLEED} on the target.",
        desc_fn = function(self, fmt_str)
            return loc.format(fmt_str, self.bleed_amt)
        end,

        flags = CARD_FLAGS.MELEE,
        rarity = CARD_RARITY.COMMON,
        min_damage = 2,
        max_damage = 3,

        cost = 1,
        bleed_amt = 2,

        OnPostResolve = function( self, battle, attack)
            for i, hit in attack:Hits() do
                if not attack:CheckHitResult( hit.target, "evaded" ) then
                    hit.target:AddCondition("BLEED", self.bleed_amt, self)
                end
                self.owner:AddCondition("COMBO", math.floor(hit.target:GetConditionStacks("BLEED")/2), self)
            end
        end,
},
frenzy_mod_plus = 
{
    name = "Boosted Frenzy",

    min_damage = 1,
    max_damage = 2,
    bleed_amt = 4,
},

frenzy_mod_plus2 = 
{
    name = "Tall Frenzy",
    desc = "Apply {1} {BLEED}, then gain 2 {COMBO} for every 3 {BLEED} on the target.",

        OnPostResolve = function( self, battle, attack)
            for i, hit in attack:Hits() do
                if not attack:CheckHitResult( hit.target, "evaded" ) then
                    hit.target:AddCondition("BLEED", self.bleed_amt, self)
                end
                self.owner:AddCondition("COMBO", math.floor(hit.target:GetConditionStacks("BLEED")/3)*2, self)
            end
        end,
},

close_up = 
{
    name = "Close up",
    icon = "battle/tank.tex",
    anim = "hero_taunt",
    desc = "Spend up to {1} {COMBO}: Gain {DEFEND 2} and {PROTECT 1} per {COMBO} spent.",
    desc_fn = function(self, fmt_str)
        return loc.format(fmt_str, self.combo_limit)
    end,

    flags = CARD_FLAGS.SKILL,
    rarity = CARD_RARITY.UNCOMMON,
    target_type = TARGET_TYPE.SELF,

    combo_limit = 2,

    cost = 0,

    PreReq = function( self, minigame )
        return self.owner:GetConditionStacks("COMBO") > 0
    end,

    OnPreResolve = function( self, battle, attack )
        if self.owner:HasCondition("COMBO") then
            local count = math.min(self.owner:GetConditionStacks("COMBO"), self.combo_limit)
            self.owner:RemoveCondition("COMBO", count)
            self.combo_consumed = count    
        end
    end,
    
    OnPostResolve = function( self, battle, attack )
        if self.combo_consumed then
                self.owner:AddCondition("DEFEND", self.combo_consumed*2, self)
                self.owner:AddCondition("PROTECT", self.combo_consumed, self)
            self.combo_consumed = nil
        end
    end
},

close_up_plus =
{
    name = "Tall Close up",
    desc = "Spend up to <#UPGRADE>{1} {COMBO}</>: Gain {DEFEND 2} and {PROTECT 1} per {COMBO} spent.",

    combo_limit = 3,
},

close_up_plus2 =
{
    name = "Spined Close up",
    desc = "Spend up to {1} {COMBO}: Gain {DEFEND 1}, {RIPOSTE 1}, and {PROTECT 1} per {COMBO} spent.",
    desc_fn = function(self, fmt_str)
        return loc.format(fmt_str, self.combo_limit)
    end,

    PreReq = function( self, minigame )
        return self.owner:GetConditionStacks("COMBO") > 0
    end,

    OnPreResolve = function( self, battle, attack )
        if self.owner:HasCondition("COMBO") then
            local count = math.min(self.owner:GetConditionStacks("COMBO"), self.combo_limit)
            self.owner:RemoveCondition("COMBO", count)
            self.combo_consumed = count    
        end
    end,
    
    OnPostResolve = function( self, battle, attack )
        if self.combo_consumed then
                self.owner:AddCondition("DEFEND", self.combo_consumed, self)
                self.owner:AddCondition("PROTECT", self.combo_consumed, self)
                self.owner:AddCondition("RIPOSTE", self.combo_consumed, self)
            self.combo_consumed = nil
        end
    end
},

mindfulness =
{
    name = "Mindfulness",
    icon = "battle/baron_expedition.tex",
    anim = "hero_taunt",
    desc = "{ABILITY}: Whenever you {HEAL}, draw a card, then discard a card.",

    cost = 1,
    rarity = CARD_RARITY.UNCOMMON,
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

    target_type = TARGET_TYPE.SELF,

    OnPostResolve = function( self, battle, attack)
        self.owner:AddCondition("mindfulness", 1, self)
    end,

    condition =
    {
        icon = "battle/conditions/gear_head.tex",
        name = "Targeted Mindfulness",
        desc = "Whenever you {HEAL}, draw a card, then discard a card.",

        event_handlers =
        {
            [ BATTLE_EVENT.DELTA_STAT ] = function( self, fighter, stat, delta, value, mitigated  )
                if fighter == self.owner and stat == COMBAT_STAT.HEALTH then
                    if delta > 0 then
                        self.battle:DrawCards(1)
                        self.battle:DiscardCards(1)
                    end
                end
            end,
        },
    },

},

mindfulness_plus =
{
    name = "Initial Mindfulness",
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.AMBUSH,
},

mindfulness_plus2 =
{
    name = "Targeted Mindfulness",
    desc = "{ABILITY}: Whenever you {HEAL}, {IMPROVISE} a card from your draw pile, then discard a card.",

        OnPostResolve = function( self, battle, attack)
            self.owner:AddCondition("mindfulness_plus2", 1, self)
        end,
    
        condition =
        {
            icon = "battle/conditions/gear_head.tex",
            name = "Mindfulness",
            desc = "Whenever you {HEAL}, {IMPROVISE} a card from your draw pile, then discard a card.",
    
            event_handlers =
            {
                [ BATTLE_EVENT.DELTA_STAT ] = function( self, fighter, stat, delta, value, mitigated  )
                    if fighter == self.owner and stat == COMBAT_STAT.HEALTH then
                        if delta > 0 then
                            if self.battle:GetDrawDeck():CountCards() == 0 then
                                self.battle:ShuffleDiscardToDraw()
                            end
                            local cards = self.battle:ImproviseCards(table.multipick(self.battle:GetDrawDeck().cards, 3), 1)
                            self.battle:DiscardCards(1)
                        end
                    end
                end,
            },
        },
},

dancing_blade =
{
    name = "Dancing Blade",
    icon = "battle/zero.tex",
    anim = "silentshiv",
    desc = "Spend {1} {COMBO}: {IMPROVISE} an attack card from your draw pile and play it with a random target.",
    desc_fn = function( self, fmt_str )
        return loc.format( fmt_str, self.combo_cost)
    end,

    cost = 1,
    max_xp = 6,

    rarity = CARD_RARITY.RARE,
    flags = CARD_FLAGS.MELEE ,

    min_damage = 2,
    max_damage = 5,
    combo_cost = 4,

        OnPreResolve = function( self, battle, attack )
            if self.owner:GetConditionStacks("COMBO") >= self.combo_cost then
                self.combo_used = true
            else
                self.combo_used = false
            end
        end,

    OnPostResolve = function( self, battle, attack )
        local options = {}
        if self.owner:GetConditionStacks("COMBO") >= self.combo_cost then
            if battle:GetDrawDeck():CountCards() == 0 then
                battle:ShuffleDiscardToDraw()
            end
        for i,card in battle:GetDrawDeck():Cards() do
            if card:IsAttackCard() then
                table.insert(options, card)
            end
        end
        if #options > 0 then
            local card = battle:ChooseCardsFromTable( table.multipick(options, 3), 1, 1)[1]
            if card then
                card:TransferCard(battle:GetHandDeck())
                battle:PlayCard(card)
            end
        end
        self.owner:RemoveCondition("COMBO", self.combo_cost)
        self.combo_used = nil
    end
end
},      
dancing_blade_plus =
{
    name = "Targeted Dancing Blade",
    desc = "Spend {1} {COMBO}: {IMPROVISE} an attack card from your <#UPGRADE>discards</> and play it with a random target.",
    desc_fn = function( self, fmt_str )
        return loc.format( fmt_str, self.combo_cost)
    end,

    min_damage = 2,
    max_damage = 6,

    OnPostResolve = function( self, battle, attack )
        local options = {}
        if self.owner:GetConditionStacks("COMBO") >= self.combo_cost then
        for i,card in battle:GetDiscardDeck():Cards() do
            if card:IsAttackCard() then
                table.insert(options, card)
            end
        end
        if #options > 0 then
            local card = battle:ChooseCardsFromTable( table.multipick(options, 3), 1, 1)[1]
            if card then
                card:TransferCard(battle:GetHandDeck())
                battle:PlayCard(card)
            end
        end
        self.owner:RemoveCondition("COMBO", self.combo_cost)
        self.combo_used = nil
    end
end
},

dancing_blade_plus2 =
{
    name = "Boosted Dancing Blade",

    min_damage = 4,
    max_damage = 6,
},

resourceful_modded =
{
    name = "Resourceful",
    icon = "battle/scrounge.tex",
    anim = "defend",
    desc = "Until the end of the turn, whenever you gain or spend combo, {IMPROVISE} a card from your deck.",

    cost = 1,
    max_xp = 4,
    
    rarity = CARD_RARITY.UNCOMMON,
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

    target_type = TARGET_TYPE.SELF,

    OnPostResolve = function( self, battle, attack)
        self.owner:AddCondition("resourceful_modded", 1, self)
    end,

    condition =
    {
        icon = "battle/conditions/arint_beam_charge.tex",
        name = "Resourceful",
        desc = "Until the end of the turn, whenever you gain or spend combo, {IMPROVISE} a card from your deck.",

        apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack",
        pool_size = 3,

        event_handlers =
        {

            [ BATTLE_EVENT.CONDITION_ADDED ] = function( self, fighter, condition, stacks, source )
                if condition.owner == self.owner and condition.id == "COMBO" then
                    local cards = {}
                    if self.battle:GetDrawDeck():CountCards() == 0 then
                        self.battle:ShuffleDiscardToDraw()
                    end
                    for i, card in self.battle:GetDrawDeck():Cards() do
                            table.insert(cards, card)
                    end
                    self.battle:ImproviseCards(table.multipick(cards, self.pool_size), 1)
                end
            end,

            [ BATTLE_EVENT.CONDITION_REMOVED ] = function( self, fighter, condition, stacks, source )
                if condition.owner == self.owner and condition.id == "COMBO" then
                    local cards = {}
                    if self.battle:GetDrawDeck():CountCards() == 0 then
                        self.battle:ShuffleDiscardToDraw()
                    end
                    for i, card in self.battle:GetDrawDeck():Cards() do
                            table.insert(cards, card)
                    end
                    self.battle:ImproviseCards(table.multipick(cards, self.pool_size), 1)
                end
            end,

            [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                self.owner:RemoveCondition("resourceful_modded", self.stacks, self)
            end,
        },
    },

},

resourceful_modded_plus =
{
    name = "Targeted Resourceful",
    desc = "Until the end of the turn, whenever you gain or spend combo, {IMPROVISE_PLUS} a card from your deck.",

    OnPostResolve = function( self, battle, attack)
        self.owner:AddCondition("resourceful_modded_plus", 1, self)
    end,

    condition =
    {
        icon = "battle/conditions/arint_beam_charge.tex",
        name = "Targeted Resourceful",
        desc = "Until the end of the turn, whenever you gain or spend combo, {IMPROVISE_PLUS} a card from your deck.",

        apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack",
        pool_size = 5,

        event_handlers =
        {

            [ BATTLE_EVENT.CONDITION_ADDED ] = function( self, fighter, condition, stacks, source )
                if condition.owner == self.owner and condition.id == "COMBO" then
                    local cards = {}
                    if self.battle:GetDrawDeck():CountCards() == 0 then
                        self.battle:ShuffleDiscardToDraw()
                    end
                    for i, card in self.battle:GetDrawDeck():Cards() do
                            table.insert(cards, card)
                    end
                    self.battle:ImproviseCards(table.multipick(cards, self.pool_size), 1)
                end
            end,

            [ BATTLE_EVENT.CONDITION_REMOVED ] = function( self, fighter, condition, stacks, source )
                if condition.owner == self.owner and condition.id == "COMBO" then
                    local cards = {}
                    if self.battle:GetDrawDeck():CountCards() == 0 then
                        self.battle:ShuffleDiscardToDraw()
                    end
                    for i, card in self.battle:GetDrawDeck():Cards() do
                            table.insert(cards, card)
                    end
                    self.battle:ImproviseCards(table.multipick(cards, self.pool_size), 1)
                end
            end,

            [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                self.owner:RemoveCondition("resourceful_modded_plus", self.stacks, self)
            end,
        },
    },
},

resourceful_modded_plus2 =
{
    name = "Pale Resourceful",
    cost = 0,
},

eye_for_an_eye = 
{
    name = "Eye for an Eye",
    icon = "battle/headbutt.tex",
    anim = "fightdirty",
    desc = "Add an {status_injury} card to your discard pile. Apply 2 {BLEED} per Status card in your discard pile.",
    desc_fn = function( self, fmt_str )
        return loc.format( fmt_str, self.combo_cost)
    end,

    rarity = CARD_RARITY.UNCOMMON,
    flags = CARD_FLAGS.MELEE,

    cost = 1,

    min_damage = 3,
    max_damage = 6,

    bleed_applied = 2,

    OnPostResolve = function( self, battle, attack )
        local card = Battle.Card( "status_injury", self.owner )
        card:TransferCard( battle:GetDiscardDeck() )
        for i,card in battle:GetDiscardDeck():Cards() do
            if card:IsFlagged( CARD_FLAGS.STATUS ) then
                attack:AddCondition("BLEED", self.bleed_applied )
            end
        end
    end,
},

eye_for_an_eye_plus = 
{
    name = "Enhanced Eye for an Eye",
    desc = "Add an {status_injury} card to your discard pile. Apply 3 {BLEED} per Status card in your discard pile.",

    min_damage = 2,
    max_damage = 4,

    bleed_applied = 3,
},

eye_for_an_eye_plus2 = 
{
    name = "Boosted Eye for an Eye",
    desc = "Add 2 {status_injury} cards to your discard pile. Apply 2 {BLEED} per Status card in your discard pile.",

    min_damage = 3,
    max_damage = 6,

    OnPostResolve = function( self, battle, attack )
        local card1 = Battle.Card( "status_injury", self.owner )
        local card2 = Battle.Card( "status_injury", self.owner )
        card1:TransferCard( battle:GetDiscardDeck() )
        card2:TransferCard( battle:GetDiscardDeck() )
        for i,card in battle:GetDiscardDeck():Cards() do
            if card:IsFlagged( CARD_FLAGS.STATUS ) then
                attack:AddCondition("BLEED", self.bleed_applied )
            end
        end
    end,
},

balanced_stance = 
{
    name = "Balanced Stance",
    icon = "battle/cyclone.tex",
    anim = "taunt2",
    desc = "{ABILITY}: All your attacks deal 2 bonus damage if you have {RIPOSTE}.",
    cost = 1,

    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
    rarity = CARD_RARITY.UNCOMMON,
    target_type = TARGET_TYPE.SELF,

    OnPostResolve = function( self, battle, attack )
        self.owner:AddCondition("balanced_stance", 2, self)
    end,

    condition = 
    {
        name = "Balanced Stance",
        icon = "battle/conditions/hologram_projection_belt.tex",
        desc = "All your attacks deal {1} bonus damage if you have {RIPOSTE}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.stacks )
        end,

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if card.owner == self.owner and target then
                    if self.owner:GetConditionStacks("RIPOSTE") > 0 then
                    dmgt:AddDamage(self.stacks, self.stacks, self)
                    end
                end
            end
        },
    },
},

balanced_stance_plus =
{
    name = "Boosted Balanced Stance",
    desc = "{ABILITY}: All your attacks deal 3 bonus damage if you have {RIPOSTE}.",
    
    OnPostResolve = function( self, battle, attack )
        self.owner:AddCondition("balanced_stance", 3, self)
    end,
},

balanced_stance_plus2 = 
{
    name = "Initial Balanced Stance",

    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.AMBUSH,
},

whirlwind = 
{
    name = "Whirlwind",
    desc = "If you have nothing but attacks in your hand gain {1} {COMBO}.",
    desc_fn = function( self, fmt_str )
        return loc.format( fmt_str, self.combo_gained)
    end,
    icon = "battle/hurricane.tex",
    anim = "attack2",
    rarity = CARD_RARITY.UNCOMMON,
    flags = CARD_FLAGS.MELEE,

    cost = 1,
    max_xp = 7,

    min_damage = 2,
    max_damage = 4,
    combo_gained = 4,

    OnPostResolve = function( self, battle, attack )
        local combo = true
        for i, hand_card in battle:GetHandDeck():Cards() do
            if not hand_card:IsFlagged( CARD_FLAGS.MELEE ) and not hand_card:IsFlagged( CARD_FLAGS.RANGED ) or hand_card:IsFlagged( CARD_FLAGS.ITEM ) then
                combo = false
            end
        end
        if combo == true then
        self.owner:AddCondition("COMBO", self.combo_gained, self)
        end
    end,
},

whirlwind_plus = 
{
    name = "Boosted Whirlwind",
    min_damage = 4,
    max_damage = 6,
},

whirlwind_plus2 = 
{
    name = "Enhanced Whirlwind",
    combo_gained = 6,
},

disguise =
{
    name = "Disguise",
    desc = "Gain {1} {DEFEND}.\nIf you have at least 8 cards in hand, this card costs 0.",
    desc_fn = function( self, fmt_str )
        return loc.format( fmt_str, self.defend_amount)
    end,
    icon = "battle/gumption.tex",
    anim = "taunt",

    cost = 2,
    
    rarity = CARD_RARITY.UNCOMMON,
    flags = CARD_FLAGS.SKILL,
    target_type = TARGET_TYPE.SELF,

    deck_handlers = { DECK_TYPE.DRAW, DECK_TYPE.DISCARDS },

    defend_amount = 6,

    OnPostResolve = function( self, battle, attack )
        attack:AddCondition( "DEFEND", self.defend_amount, self )
    end,

    event_handlers =
    {
        [ BATTLE_EVENT.CALC_ACTION_COST ] = function( self, cost_acc, card, target )
            if card == self and self.engine:GetHandDeck():CountCards() > 7 then
                cost_acc:ModifyValue(0)
            end
        end
    },

},
disguise_plus =
{
    name = "Boosted Disguise",

    defend_amount = 8,

    OnPostResolve = function( self, battle, attack )
        attack:AddCondition( "DEFEND", self.defend_amount, self )
    end,
},

disguise_plus2 =
{
    name = "Spined Disguise",
    desc = "Gain {1} {DEFEND} and {2} {RIPOSTE}.\nIf you have at least 8 cards in hand, this card costs 0.",
    desc_fn = function( self, fmt_str )
        return loc.format( fmt_str, self.defend_amount, self.riposte_amount)
    end,

    defend_amount = 6,
    riposte_amount = 2,

    OnPostResolve = function( self, battle, attack )
        attack:AddCondition( "DEFEND", self.defend_amount, self )
        attack:AddCondition( "RIPOSTE", self.riposte_amount, self )
    end,
},

if_it_bleeds = 
{
    name = "If it Bleeds",
    desc = "{ABILITY}: All your attacks deal max damage if the target has {BLEED}.",
    cost = 2,
    icon = "battle/sacrifice.tex",
    anim = "taunt2",

    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
    rarity = CARD_RARITY.UNCOMMON,
    target_type = TARGET_TYPE.SELF,

    OnPostResolve = function( self, battle, attack )
        self.owner:AddCondition("if_it_bleeds", 1, self)
    end,

    condition = 
    {
        desc = "All your attacks deal max damage if the target has {BLEED}.",
        icon = "battle/conditions/cleaved.tex",

        event_priorities = 
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = EVENT_PRIORITY_MULTIPLIER,
        },

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if card.owner == self.owner and target then
                    if target:HasCondition("BLEED") then
                        dmgt:AddDamage((dmgt.max_damage-dmgt.min_damage), 0, self)
                    end
                end
            end
        },
    },
},

if_it_bleeds_plus =
{
    name = "Pale If it Bleeds",
    cost = 1,
},

if_it_bleeds_plus2 = 
{
    name = "Initial If it Bleeds",
    flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.AMBUSH,
},
}

for i, id, data in sorted_pairs(attacks) do
    if not data.series then
        data.series = "SAL"
    end
    local basic_id = data.base_id or id:match( "(.*)_plus.*$" ) or id:match( "(.*)_upgraded[%w]*$") or id:match( "(.*)_supplemental.*$" )
        Content.AddBattleCard( id, data )
end

