require "eventsystem"
local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT


local CONDITIONS = 
{

    DISORIENTATION = 
    {
        name = "Disorientation",
        desc = "Damage dealt and defense applied is halved, remove 1 stack after you play a card.",
        icon = "battle/conditions/stagger.tex",

        ctype = CTYPE.DEBUFF,

        apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Cripple",
        apply_fx = {"cripple"},
        fx_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Cripple_FX",
        fx_sound_delay = 0.85,
        target_type = TARGET_TYPE.ENEMY,

        damage_mult = 0.5,

        event_priorities =
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = EVENT_PRIORITY_MULTIPLIER,
        },

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if card.owner == self.owner then
                    dmgt:ModifyDamage( math.round( dmgt.min_damage * self.damage_mult ),
                                       math.round( dmgt.max_damage * self.damage_mult ),
                                       self )
                end
            end,

            [ BATTLE_EVENT.CALC_MODIFY_STACKS ] = function( self, acc, condition_id, fighter, card )
                if condition_id == "DEFEND" and fighter == self.owner then
                    if acc.value > 0 then
                        acc:AddValue( -math.floor( acc.value / 2 ), self )
                    end
                end
            end,

            [ BATTLE_EVENT.START_RESOLVE ] = function( self, battle, card )
                if card.owner == self.owner then
                    self.owner:RemoveCondition( self.id, 1 )
                end
            end,
        }
    },
    
    ENFEEBLEMENT =
    {
        name = "Enfeeblement",
        feature_desc = "Gain {1} {ENFEEBLEMENT}.",
        desc = "Attack damage is decreased by {1}.",
        desc_fn = function( self, fmt_str, battle )
            return loc.format(fmt_str, self.stacks )
        end,
	    icon = "battle/conditions/power.tex",		
		apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Power",
        ctype = CTYPE.DEBUFF,
        fx_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Power_FX",
        fx_sound_delay = .4,
        apply_fx = {"power"},

        target_type = TARGET_TYPE.SELF,
        max_stacks = 99,
        min_stacks = -99,

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
                if card.owner == self.owner then
                if card.owner == self.owner and card:IsAttackCard() and not card.ignore_power then
                    dmgt:ModifyDamage( dmgt.min_damage - self.stacks, dmgt.max_damage - self.stacks, self )
                end
                end
            end,
        }
    },

    UNBALACED =
    {
        name = "Unbalanced ",
        feature_desc = "Gain {1} {POWER}.",
		desc = "Amount of defense applied is decreased by {1}.",
        desc_fn = function( self, fmt_str, battle )
            return loc.format(fmt_str, self.stacks )
        end,
	    icon = "battle/conditions/shield_of_hesh.tex",
        ctype = CTYPE.DEBUFF,
		apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Power",

        fx_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Power_FX",
        fx_sound_delay = .4,
        apply_fx = { "wound"},

        target_type = TARGET_TYPE.SELF,
        max_stacks = 99,
        min_stacks = -99,

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_MODIFY_STACKS ] = function( self, acc, condition_id, fighter, card )
                if fighter == self.owner then
                if condition_id == "DEFEND"  then
                    if acc.value > 0 then
                        acc:AddValue( -math.floor( self.stacks ), self )
                    end
                    end
                end
            end,
	}
    },

    SURE_FOOTING =
    {
        name = "Sure Footing",
        feature_desc = "Gain {1} {POWER}.",
		desc = "Amount of defense applied is increased by {1}.",
        desc_fn = function( self, fmt_str, battle )
            return loc.format(fmt_str, self.stacks )
        end,
	    icon = "battle/conditions/shield_of_hesh.tex",
		
		apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Power",

        fx_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Power_FX",
        fx_sound_delay = .4,
        apply_fx = { "wound"},

        target_type = TARGET_TYPE.SELF,
        max_stacks = 99,
        min_stacks = -99,

        event_handlers =
        {
            [ BATTLE_EVENT.CALC_MODIFY_STACKS ] = function( self, acc, condition_id, fighter, card )
                if fighter == self.owner then
                if condition_id == "DEFEND"  then
                    if acc.value > 0 then
                        acc:AddValue( -math.floor( - self.stacks ), self )
                    end
                end
                end
            end,
	}
    },

    PERFECT_PARRY = 
    {
        name = "Perfect Parry",
        desc = "Gain {1} {COMBO} when attack is fully defended. Remove all stacks at the start of the turn.",
        desc_fn = function( self, fmt_str, battle )
            return loc.format(fmt_str, self.stacks )
        end,
        icon = "battle/conditions/cautious.tex",

        max_stacks = 99,
        min_stacks = -99,

        event_handlers = 
        {

            [ BATTLE_EVENT.ON_HIT] = function( self, battle, attack, hit )
                if hit.target == self.owner and attack.card and attack.card:IsAttackCard() and hit.defended then
                    self.owner:AddCondition("COMBO", self.stacks, self)
                end
            end,

            [ BATTLE_EVENT.BEGIN_TURN ] = function( self, fighter )
                if self.owner == fighter then
                    self.owner:RemoveCondition( self.id )
                end
            end,
        },
    },

}

for id, def in pairs( CONDITIONS ) do
    Content.AddBattleCondition( id, def )
end

