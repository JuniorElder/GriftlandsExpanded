require "eventsystem"
local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT


local CONDITIONS = 
{

    DEFICIENCY =
    {
        name = "Enfeeblement",
        feature_desc = "Gain {1} {DEFICIENCY}.",
		desc = "Attack damage is decreased by {1}.",
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
		desc = "Amount of defense applied is increased by {1}.",
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

    leaking_core = 
    {
        name = "Leaking Core",
        desc = "When attacked and damaged shuffle a random goo into attacker´s deck.",
        desc_fn = function( self, fmt_str )
            return loc.format( fmt_str, loc.cap( self:GetOwnerName() ))
        end,

        icon = "battle/conditions/spark_aura.tex",
        target_type = TARGET_TYPE.SELF,
        options = {"corrosive_goo", "anesthetic_goo", "adherent_goo", "replicating_goo"},
        event_handlers =
       {
        [ BATTLE_EVENT.DAMAGE_APPLIED] = function( self, fighter, damage, delta, attack )
        
            if delta > 0 then
            if attack ~= nil then
            if fighter == self.owner then
            local cards = {}
            local incepted_card = Battle.Card(self.options[math.random(#self.options)], self.battle:GetPlayerFighter() )
            incepted_card.incepted = true
               incepted_card.show_dealt = true
            self.battle:DealCards( {incepted_card}, self.battle:GetDrawDeck() )
            end   
        end       
        end
       end,
        },
    },

}

for id, def in pairs( CONDITIONS ) do
    Content.AddBattleCondition( id, def )
end

