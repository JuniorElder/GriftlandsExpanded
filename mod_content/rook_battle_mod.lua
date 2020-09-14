local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS

local BATTLE_EVENT = ExtendEnum( battle_defs.EVENT,
{
    "PRIMED_GAINED",
    "PRIMED_LOST",
    "LUMIN_CHARGED",
    "LUMIN_SPENT",
})

-- Shared PreReq function
local function NoCharges( self, battle )
    local tracker = self.owner:GetCondition("lumin_tracker") 
    return tracker and tracker:GetCharges() == 0
end

---------------------------------------------------------------------------------

local attacks =
{	
    
    mayhem =
    {
        name = "Mayhem",
        icon = "battle/wildfire.tex",
        anim = "burner",
        desc = "Hits all enemies. Remove all {CONCENTRATION} stacks. Gain {1} {EXPOSED}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.exposion_amount)
        end,

        cost = 1,
        max_xp = 5,

        rarity = CARD_RARITY.UNCOMMON,
        flags = CARD_FLAGS.RANGED,

        min_damage = 1,
        max_damage = 10,
        target_mod = TARGET_MOD.TEAM,

        exposion_amount = 2,

        OnPostResolve = function( self, battle, attack )
            self.owner:AddCondition("CONCENTRATION", -self.owner:GetConditionStacks("CONCENTRATION"), self)
            self.owner:AddCondition("EXPOSED", self.exposion_amount, self)
        end
    },
    mayhem_plus =
    {
        name = "Professional Mayhem",
        
        exposion_amount = 1,
    },
    mayhem_plus2 = 
    {
        name = "Boosted Mayhem",

        min_damage = 4,
        max_damage = 10,
    },
    crack_the_circuit =
    {
        name = "Crack the Circuit",
        icon = "battle/gut_shot.tex",
        anim = "whip",
        desc = "{THRESHOLD} {1}: Refill all charges.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.threshold)
        end,

        cost = 1,
        max_xp = 7,

        rarity = CARD_RARITY.UNCOMMON,
        flags = CARD_FLAGS.MELEE,

        min_damage = 2,
        max_damage = 6,

        threshold = 6,

        ThresholdEffect = function( self, battle, attack )
            local tracker = self.owner:GetCondition("lumin_tracker")
                tracker:AddLuminCharges(tracker:GetEmptyCharges(), self)
        end
    },
    crack_the_circuit_plus =
    {
        name = "Boosted Crack",	

        desc = "{THRESHOLD} {1}: Refill all charges. Gain {2} {SURGE}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.threshold, self.overcharge_amount)
        end,

        cost = 1,
        max_xp = 7,

        rarity = CARD_RARITY.UNCOMMON,
        flags = CARD_FLAGS.MELEE,

        min_damage = 2,
        max_damage = 6,

        threshold = 8,
        overcharge_amount = 2,

        ThresholdEffect = function( self, battle, attack )
            local tracker = self.owner:GetCondition("lumin_tracker")
            tracker:AddLuminCharges(tracker:GetEmptyCharges(), self)
            self.owner:AddCondition("SURGE", self.overcharge_amount, self)
        end
    },
    crack_the_circuit_plus2 =
    {
        name = "Tall Crack",

        max_damage = 8,
    },
    spot_weakness = 
    {
        name = "Spot Weakness",
        desc = "{ABILITY}: Whenever you apply a debuff to an enemy, gain 1 {CONCENTRATION}.",
        icon = "battle/inside_fighting.tex",
        anim = "psionic",

        max_xp = 4,
        cost = 2,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.RARE,
        target_type = TARGET_TYPE.SELF,

        OnPostResolve = function( self, battle, attack )
            self.owner:AddCondition("spot_weakness", 1, self)
        end,

        condition = 
        {
            icon = "battle/conditions/mark.tex",
            desc = "Whenever you apply a debuff to an enemy, gain {1} {CONCENTRATION}.",
            desc_fn = function( self, fmt_str )
                return loc.format(fmt_str, self.stacks)
            end,
            event_handlers =
            {
                [ BATTLE_EVENT.CONDITION_ADDED ] = function( self, fighter, condition, stacks, source )
                    if fighter:GetTeam() ~= self.owner:GetTeam() and source and source.owner == self.owner and condition.ctype == CTYPE.DEBUFF then
                        self.owner:AddCondition("CONCENTRATION", self.stacks, self)
                    end
                end
            },
        },
    },
    spot_weakness_plus =
    {
        name = "Pale Spot Weakness",
        
        cost = 1,
    },

    spot_weakness_plus2 =
    {
        name = "Initial Spot Weakness",

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.AMBUSH,
    },

    incendiary_ammunition =
    {
        name = "Incendiary Ammunition",
        icon = "battle/improvise_spare_ammo.tex", 
        desc = "{EXPEND} 1 chosen card in your hand.\nYour attacks apply {BURN 2} for the rest of the turn.",
        anim = "reload_01",

        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNCOMMON,

        cost = 0,
        max_xp = 5,
        min_choose = 1,
        max_choose = 1,

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

        condition =
        {
            icon = "battle/conditions/kashio_pistol.tex", 
            desc = "Your attacks apply {BURN 2} for the rest of the turn.",

            event_handlers =
            {
                [ BATTLE_EVENT.ON_HIT ] = function( self, battle, attack, hit )
                    if attack.attacker == self.owner and attack.card:IsAttackCard() and not hit.evaded then
                        hit.target:AddCondition( "BURN", 2 )
                    end
                end,

                [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                    self.owner:RemoveCondition( "incendiary_ammunition" )
                end,
            }
        },

        OnPostResolve = function( self, battle, attack)
            local cards = battle:ExpendCards( self.min_choose, self.max_choose )

            self.owner:AddCondition( "incendiary_ammunition", 1, self)
        end,
    },
    incendiary_ammunition_plus =
    {
        name = "Enduring Incendiary Ammunition",

        flags = CARD_FLAGS.SKILL,
    },
    incendiary_ammunition_plus2 =
    {
        name = "Spare Incendiary Ammunition",
        desc = "{EXPEND} 2 chosen card in your hand.\nYour attacks apply {BURN 3} for the rest of the turn.",

        min_choose = 2,
        max_choose = 2,

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

        condition =
        {
            icon = "battle/conditions/kashio_pistol.tex", 
            desc = "Your attacks apply {BURN 3} for the rest of the turn.",

            event_handlers =
            {
                [ BATTLE_EVENT.ON_HIT ] = function( self, battle, attack, hit )
                    if attack.attacker == self.owner and attack.card:IsAttackCard() and not hit.evaded then
                        hit.target:AddCondition( "BURN", 3 )
                    end
                end,

                [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                    self.owner:RemoveCondition( "incendiary_ammunition_plus2" )
                end,
            }
        },

        OnPostResolve = function( self, battle, attack)
            local cards = battle:ExpendCards( self.min_choose, self.max_choose )

            self.owner:AddCondition( "incendiary_ammunition_plus2", 1, self)
        end,
    },

    psychic_overload = 
    {
        name = "Psychic Overload",
        icon = "battle/psionic_feedback.tex", 
        anim = "psionic",
        desc = "If the enemy has at least {1} unique debuffs {STUN} them.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.debuff_count)
        end,

        cost = 1,
        max_xp = 6,

        min_damage = 1,
        max_damage = 5,

        debuff_count = 4,

        rarity = CARD_RARITY.RARE,
        flags = CARD_FLAGS.RANGED | CARD_FLAGS.EXPEND,

        OnPostResolve = function( self, battle, attack )
            local count = 0
            for i, hit in attack:Hits() do --this is just plain stupid, if something breaks it is this
            for i,condition in pairs(hit.target:GetConditions()) do
                if condition.ctype == CTYPE.DEBUFF then
                    count = count + 1
                end
            end
        end
            for i, hit in attack:Hits() do
                if count >= self.debuff_count then
                hit.target:AddCondition("STUN", 1, self)
            end
        end
    end
    },

    psychic_overload_plus =
    {
        name = "Boosted Psychic Overload",

        debuff_count = 3,
    },

    psychic_overload_plus2 = 
    {
        name = "Opportunistic Psychic Overload",

        flags = CARD_FLAGS.RANGED | CARD_FLAGS.EXPEND | CARD_FLAGS.STICKY,
    },

    advanced_targeting =
    {
        name = "Advanced Targeting",
        desc = "Spend all {CHARGE}, apply 1 {RICOCHET}, than 1 {MARK} per {CHARGE} spent to a random enemy.",
        icon = "battle/riptide.tex", 
        anim = "mark",

        cost = 1,
        max_xp = 4,

        flags = CARD_FLAGS.SKILL,
        rarity = CARD_RARITY.UNCOMMON,

        target_type = TARGET_TYPE.SELF,

        OnPostResolve = function( self, battle, attack )
            local tracker = self.owner:GetCondition("lumin_tracker")
            local target_fighters = {}
            if tracker and tracker:GetCharges() > 0 then
                for i = 1, tracker:GetCharges() do
                    battle:CollectRandomTargets( target_fighters, self.owner:GetEnemyTeam().fighters, 1 )
                    if target_fighters[ math.random( #target_fighters ) ] then --UGH
                        target_fighters[ math.random( #target_fighters ) ]:AddCondition("RICOCHET", 1, self)
                        target_fighters[ math.random( #target_fighters ) ]:AddCondition("MARK", 1, self)
                    end
                end
                tracker:RemoveCharges(tracker:GetCharges(), self)
            end
        end
    },

    advanced_targeting_plus =
    {
        name = "Boosted Targeting",
        desc = "Spend all {CHARGE}, apply 2 {RICOCHET}, than 1 {MARK} per {CHARGE} spent to a random enemy.",

        OnPostResolve = function( self, battle, attack )
            local tracker = self.owner:GetCondition("lumin_tracker")
            local target_fighters = {}
            if tracker and tracker:GetCharges() > 0 then
                for i = 1, tracker:GetCharges() do
                    battle:CollectRandomTargets( target_fighters, self.owner:GetEnemyTeam().fighters, 1 )
                    if target_fighters[ math.random( #target_fighters ) ] then --UGH
                        target_fighters[ math.random( #target_fighters ) ]:AddCondition("RICOCHET", 2, self)
                        target_fighters[ math.random( #target_fighters ) ]:AddCondition("MARK", 1, self)
                    end
                end
                tracker:RemoveCharges(tracker:GetCharges(), self)
            end
        end
    },

    advanced_targeting_plus2 =
    {
        name = "Pointed Targeting",
        desc = "Spend all {CHARGE}, apply 1 {RICOCHET}, than 2 {MARK} per {CHARGE} spent to a random enemy.",

        OnPostResolve = function( self, battle, attack )
            local tracker = self.owner:GetCondition("lumin_tracker")
            local target_fighters = {}
            if tracker and tracker:GetCharges() > 0 then
                for i = 1, tracker:GetCharges() do
                    battle:CollectRandomTargets( target_fighters, self.owner:GetEnemyTeam().fighters, 1 )
                    if target_fighters[ math.random( #target_fighters ) ] then --UGH
                        target_fighters[ math.random( #target_fighters ) ]:AddCondition("RICOCHET", 1, self)
                        target_fighters[ math.random( #target_fighters ) ]:AddCondition("MARK", 2, self)
                    end
                end
                tracker:RemoveCharges(tracker:GetCharges(), self)
            end
        end
    },
    marked_shot =
    {
        name = "Marked Shot",
        icon = "battle/target_practice.tex", 
        pre_anim = "double_pre",
        anim = "double",
        post_anim = "double_pst",
        desc = "Attack twice.\nDeals +{1} damage for every {MARK} on the target.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.bonus_damage)
        end,

        cost = 1,

        flags = CARD_FLAGS.RANGED,
        rarity = CARD_RARITY.COMMON,

        min_damage = 1,
        max_damage = 3,

        bonus_damage = 1,
        hit_count = 2,

        max_xp = 6,

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if card == self and target then
                    local count = 0
                    count = target:GetConditionStacks("MARK")
                    dmgt:AddDamage(count * self.bonus_damage, count * self.bonus_damage, self)
                end
            end
        },
    },

    marked_shot_plus =
    {
        name = "Opportunistic Marked Shot",

        flags = CARD_FLAGS.RANGED | CARD_FLAGS.EXPEND | CARD_FLAGS.STICKY,
    },

    marked_shot_plus2 =
    {
        name = "Boosted Marked Shot",

        bonus_damage = 2,
    },
    
    short_circuit =
    {
        name = "Short Circuit",
        icon = "battle/reflector_shield.tex",
        anim = "taunt",
        desc = "Gain {1} {CHARGE}.\nGain {2} {malfunctioning_charge_cells}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.charge_amount, self.malfunction_amount)
        end,

        cost = 0,
        max_xp = 5,

        rarity = CARD_RARITY.UNCOMMON,
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        target_type = TARGET_TYPE.SELF,

        charge_amount = 5,
        malfunction_amount = 2,

        OnPostResolve = function( self, battle, attack )
            local tracker = self.owner:GetCondition("lumin_tracker")
                tracker:AddLuminCharges(self.charge_amount, self)
                local con = self.owner:AddCondition("PLAYER_MALFUNCTIONING_CHARGE_CELLS", self.malfunction_amount, self)
                if con then 
                    con.applier = self.owner
                end
        end,        
    },
    short_circuit_plus =
    {
        name = "Enduring Circuit",	

        flags = CARD_FLAGS.SKILL,
    },
    short_circuit_plus2 =
    {
        name = "Safe Circuit",

        malfunction_amount = 1,
    },

    feed_the_fire =
    {
        name = "Feed the Fire",
        icon = "battle/bottle_hurl.tex",
        anim = "crackle",
        desc = "If the target has {SCORCHED}, draw {1} card. If the target has {BURN}, apply {2} {SCORCHED}. Apply {3} {BURN}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.cards_drawn, self.scorched_applied, self.burn_applied)
        end,

        cost = 1,

        flags = CARD_FLAGS.MELEE,
        rarity = CARD_RARITY.UNCOMMON,

        min_damage = 2,
        max_damage = 2,
        burn_applied = 2,
        scorched_applied = 1,
        cards_drawn = 1,

        event_handlers =
        {
            [ BATTLE_EVENT.PRE_RESOLVE ] = function( self, battle, attack )
                if attack.card and attack.card == self then
                    for i, hit in attack:Hits() do
                        if hit.target:HasCondition("SCORCHED") then
                            battle:DrawCards(self.cards_drawn)
                        end
                        if hit.target:HasCondition("BURN") then
                            hit.target:AddCondition("SCORCHED", self.scorched_applied, self)
                        end
                        hit.target:AddCondition("BURN", self.burn_applied, self)
                    end
                end
            end,
        },
    },

    feed_the_fire_plus =
    {
        name = "Visionary Feed the Fire",
        desc = "If the target has {SCORCHED}, draw {1} card. If the target has {BURN}, apply {2} {SCORCHED}. Apply {3} {BURN}.",

        cards_drawn = 2,
    },

    feed_the_fire_plus2 =
    {
        name = "Boosted Feed the Fire",

        burn_applied = 3,
        scorched_applied = 2,
    },

    plant_explosives =
    {
        name = "Plant Explosives",
        desc = "Add 2 {explosive_trap} cards to your discards.",
        icon = "negotiation/dangerous.tex", 
        anim = "taunt",

        cost = 1,
        max_xp = 5,

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNCOMMON,

        target_type = TARGET_TYPE.SELF,

        num_copies = 2,

        OnPostResolve = function( self, battle, attack )
        local cards = {}
            for i = 1, self.num_copies do
                local incepted_card = Battle.Card( "explosive_trap", self.owner )
                incepted_card.incepted = true
                incepted_card:TransferCard( battle:GetDiscardDeck() )
            end
        battle:DealCards( cards )
        end,
    },

    plant_explosives_plus =
    {
        name = "Boosted Explosives",
        desc = "Add 3 {explosive_trap} cards to your discards.",

        num_copies = 3,
    },

    plant_explosives_plus2 =
    {
        name = "Visionary Explosives",
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.REPLENISH,
    },

    explosive_trap =
    {
        name = "Explosive Trap",
        desc = "Draw a card.\nAfter the end of your turn if any enamy has {BURN} deal 5 damage to all enemies and Expend.",
	    icon = "battle/fuel_canister.tex",
        cost = 0,

        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNIQUE,
        flags =  CARD_FLAGS.STATUS,

        OnPostResolve = function( self, battle, attack )
            battle:DrawCards(1)
        end,

        event_priorities =
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = 1000, -- First! (before METALLIC)
        },

        event_handlers =
        {
        [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
            local burn = 0
                for i,fighter in ipairs(self.owner:GetEnemyTeam().fighters) do
                    burn = burn + fighter:GetConditionStacks("BURN")
                end
                if burn > 0 then
                self:NotifyTriggered()
                for i,fighter in ipairs(self.owner:GetEnemyTeam().fighters) do
                    fighter:ApplyDamage( 5 )
                end
                burn = 0
                battle:ExpendCard(self)
            end
        end,
        },
    },
        
    improvisation =
    {
        name = "Improvisation",
        desc = "Add 2 {improvised_plan} cards to your discards.",
        icon = "battle/thieves_instinct.tex", 
        anim = "taunt",

        cost = 1,
        max_xp = 5,

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNCOMMON,

        target_type = TARGET_TYPE.SELF,

        num_copies = 2,

        OnPostResolve = function( self, battle, attack )
        local cards = {}
            for i = 1, self.num_copies do
                local incepted_card = Battle.Card( "improvised_plan", self.owner )
                incepted_card.incepted = true
                incepted_card:TransferCard( battle:GetDiscardDeck() )
            end
        battle:DealCards( cards )
        end,
    },

    improvisation_plus =
    {
        name = "Boosted Improvisation",
        desc = "Add 3 {improvised_plan} cards to your discards.",

        num_copies = 3,
    },

    improvisation_plus2 =
    {
        name = "Visionary Improvisation",
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.REPLENISH,

    },

    improvised_plan =
    {
        name = "Improvised Plan",
        desc = "Draw a card.\nAfter the end of your turn if you have 4 or more Concentration draw 2 more cards next turn and Expend.",
	    icon = "battle/battle_plan.tex",
        cost = 0,

        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNIQUE,
        flags =  CARD_FLAGS.STATUS,

        OnPostResolve = function( self, battle, attack )
            battle:DrawCards(1)
        end,

        event_priorities =
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = 1000, -- First! (before METALLIC)
        },

        event_handlers =
        {
        [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                local concentration = self.owner:GetConditionStacks("CONCENTRATION")
                if concentration > 3 then
                self:NotifyTriggered()
                self.owner:AddCondition( "NEXT_TURN_DRAW", 2 )
                concentration = 0
                battle:ExpendCard(self)
            end
        end,
        },
    },
            
    smoke_bomb =
    {
        name = "Smoke Bomb",
        desc = "Add 2 {smokescreen} cards to your discards.",
        icon = "battle/vapor_vial.tex", 
        anim = "taunt",

        cost = 1,
        max_xp = 5,

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNCOMMON,

        target_type = TARGET_TYPE.SELF,

        num_copies = 2,

        OnPostResolve = function( self, battle, attack )
        local cards = {}
            for i = 1, self.num_copies do
                local incepted_card = Battle.Card( "smokescreen", self.owner )
                incepted_card.incepted = true
                incepted_card:TransferCard( battle:GetDiscardDeck() )
            end
        battle:DealCards( cards )
        end,
    },

    smoke_bomb_plus =
    {
        name = "Boosted Smoke Bomb",
        desc = "Add 3 {smokescreen} cards to your discards.",

        num_copies = 3,
    },

    smoke_bomb_plus2 =
    {
        name = "Visionary Smoke Bomb",
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.REPLENISH,

    },

    smokescreen =
    {
        name = "Smokescreen",
        desc = "Draw a card.\nAfter the end of your turn if you have 10 or more {DEFEND} gain 5 {RIPOSTE} and Expend.",
	    icon = "battle/bombard_muddler.tex",
        cost = 0,

        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNIQUE,
        flags =  CARD_FLAGS.STATUS,

        OnPostResolve = function( self, battle, attack )
            battle:DrawCards(1)
        end,

        event_priorities =
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = 1000, -- First! (before METALLIC)
        },

        event_handlers =
        {
        [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                local defense = self.owner:GetConditionStacks("DEFEND")
                if defense > 9 then
                self:NotifyTriggered()
                self.owner:AddCondition( "RIPOSTE", 5 )
                defense = 0
                battle:ExpendCard(self)
            end
        end,
        },
    },
               
    lumin_polarization =
    {
        name = "Lumin Polarization",
        desc = "Add 2 {harmonic_charge} cards to your discards.",
        icon = "battle/exertion.tex", 
        anim = "taunt",

        cost = 1,
        max_xp = 5,

        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,
        rarity = CARD_RARITY.UNCOMMON,

        target_type = TARGET_TYPE.SELF,

        num_copies = 2,

        OnPostResolve = function( self, battle, attack )
        local cards = {}
            for i = 1, self.num_copies do
                local incepted_card = Battle.Card( "harmonic_charge", self.owner )
                incepted_card.incepted = true
                incepted_card:TransferCard( battle:GetDiscardDeck() )
            end
        battle:DealCards( cards )
        end,
    },

    lumin_polarization_plus =
    {
        name = "Boosted Polarization",
        desc = "Add 3 {harmonic_charge} cards to your discards.",

        num_copies = 3,
    },

    lumin_polarization_plus2 =
    {
        name = "Visionary Polarization",
        flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.REPLENISH,

    },

    harmonic_charge =
    {
        name = "Harmonic Charge",
        desc = "Draw a card.\nAfter the end of your turn if you are fully charged gain 4 {SURGE} and Expend.",
	    icon = "battle/barnacle.tex",
        cost = 0,

        target_type = TARGET_TYPE.SELF,
        rarity = CARD_RARITY.UNIQUE,
        flags =  CARD_FLAGS.STATUS,

        OnPostResolve = function( self, battle, attack )
            battle:DrawCards(1)
        end,

        event_priorities =
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = 1000, -- First! (before METALLIC)
        },

        event_handlers =
        {
        [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
            local tracker = self.owner:GetCondition("lumin_tracker")
                if tracker:GetEmptyCharges() == 0 then
                self:NotifyTriggered()
                self.owner:AddCondition( "SURGE", 4 )
                battle:ExpendCard(self)
            end
        end,
        },
    }, 

}

for i, id, data in sorted_pairs(attacks) do
    data.series = "ROOK"

    Content.AddBattleCard( id, data )
end

