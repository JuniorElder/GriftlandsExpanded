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
}

for i, id, data in sorted_pairs(attacks) do
    data.series = "ROOK"

    Content.AddBattleCard( id, data )
end

