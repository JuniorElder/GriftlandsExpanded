local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.EVENT

local attacks =
{
    -- Spark Baron Guardian - day 1 Sal
    damaged_charging_module = 
    {
        name = "Damaged Charging Module",
        icon = "battle/rusty_power_core.tex",
        desc = "Take {1} damage, gain {2} {POWER}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.damage_amt, self.power_amt)
        end,
        anim = "taunt",
    	cost = 1,

    	rarity = CARD_RARITY.UNIQUE,
    	flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND | CARD_FLAGS.HATCH,

        max_xp = 5,
        hatch = true,

        target_type = TARGET_TYPE.SELF,

        damage_amt = 6,
        power_amt = 2,

        hatch_fn = function( self, battle )
            self:TransferCard( battle.trash_deck )
            self:Consume()
            local card = TheGame:GetGameState():GetPlayerAgent().battler:LearnCard("charging_module")
            local battle_card = card:Clone()
            battle_card.owner = self.owner
            battle:DealCard( battle_card, battle.trash_deck )
        end,

        CanPlayCard = function( self, battle )
            return self.owner:GetHealth() + self.owner:GetConditionStacks("DEFEND") > self.damage_amt
        end,

        OnPostResolve= function( self, battle, attack )
            self.owner:ApplyDamage(self.damage_amt, self.owner, self)
            self.owner:AddCondition("POWER", self.power_amt, self)
        end
    },

        -- Spark Baron Guardian Hatched - day 1 Sal
    charging_module = 
    {
        name = "Charging Module",
        icon = "battle/shock_core.tex",
        desc = "Gain {1} {POWER}.",
        desc_fn = function( self, fmt_str )
            return loc.format(fmt_str, self.power_amt)
        end,
        anim = "taunt",
    	cost = 1,

    	rarity = CARD_RARITY.UNIQUE,
    	flags = CARD_FLAGS.SKILL | CARD_FLAGS.EXPEND,

        target_type = TARGET_TYPE.SELF,

        power_amt = 2,

        OnPostResolve= function( self, battle, attack )
            self.owner:AddCondition("POWER", self.power_amt, self)
        end    
    },

    -- Ghost - day 2 Sal
    bleachbug_tincture =
    {
        name = "Bleachbug Tincture",
        icon = "negotiation/liquid_courage.tex",
        desc = "Gain 4 {EVASION} but lose 8 health.",
        anim = "taunt",
    	cost = 1,

    	rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.EXPEND | CARD_FLAGS.SKILL,

        target_type = TARGET_TYPE.SELF,

        evasion_amt = 4,
        lost_health_amount = 8,

        CanPlayCard = function( self, battle )
            return self.owner:GetHealth() > self.lost_health_amount
        end,

        OnPostResolve= function( self, battle, attack )
            self.owner:AddCondition("EVASION", self.evasion_amt, self)
            self.owner:DeltaHealth(-self.lost_health_amount)
        end    
    },

    -- Drusk Ancient - day 3 Sal
    core_fluid = 
    {
        name = "Core Fluid",
        icon = "battle/warp_vial.tex",
        anim = "throw",
        manual_desc = true,
        desc = "Hits all enemies. Apply 2 {DISORIENTATION}.\n{EXPEND}",
        anims = { "anim/weapon_blaster_druskcore.zip"},
        hit_tags = { "acid" },

        cost = 1,

        rarity = CARD_RARITY.UNIQUE,
        flags = CARD_FLAGS.RANGED | CARD_FLAGS.EXPEND,

        min_damage = 3,
        max_damage = 5,
        target_mod = TARGET_MOD.TEAM,

        features =
        {
            DISORIENTATION = 2,
        },

    },

}


for i, id, data in sorted_pairs(attacks) do
    data.series = "GENERAL"
    data.item_tags = (data.item_tags or 0) | ITEM_TAGS.COMBAT
    data.flags = (data.flags or 0) | CARD_FLAGS.ITEM 
    Content.AddBattleCard( id, data )
end