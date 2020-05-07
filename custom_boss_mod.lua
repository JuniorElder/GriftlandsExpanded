local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT

local def = CharacterDef("SABOSS",
{
    unique = true,

    name = "SABOSS",
    base_def = "NPC_BASE",
    species = SPECIES.HUMAN,
    gender = GENDER.MALE,
    renown = 3,
    combat_strength = 2,
		boss = true,
        battle_preview_anim = "anim/boss_drusk_slide.zip",
        battle_preview_offset = { x = 135, y = 0 },
        battle_preview_glow = { colour = 0xC3DE2EFF, bloom = 0.15, threshold = 0.02 },
        battle_preview_audio = "event:/ui/prebattle_overlay/prebattle_overlay_whooshin_boss_drusk1",
    death_item = "war_story",

    faction_id = "RENTORIAN",

    voice_actor = "rentorian_boss",

        combat_anims = { "anim/med_combat_drusk_01.zip" },
        build = "drusk_01",

    
    fight_data = 
    {
            MAX_MORALE = MAX_MORALE_LOOKUP.IMMUNE,
        MAX_HEALTH = 200,
        battle_scale = 1.25,
            status_widget_dx = 0.5,
            status_widget_dy = -0.95,
        
	conditions = 
        { 
            enraged =
            {
                name = "Enraged",
                feature_desc = "You have angered the boss, his attacks are now more agressive.",
                icon = "battle/conditions/power.tex",		
                ctype = CTYPE.DEBUFF,

                apply_fx = {"power"},

            },
        },
        
        
        attacks = 
        {
            -- Max Health attacks
            Sdual_blade_flurry = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.MELEE,

                base_damage = 4,
                defensiveness_amount = 2	,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("SURE_FOOTING", self.defensiveness_amount, self)
                end

            },

            Sdual_blade_slice = table.extend(NPC_BUFF)
            {
                anim = "taunt_defend",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.SKILL,
                target_type = TARGET_TYPE.SELF,
                defend_amount = 4,
                power_amount = 2,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                    self.owner:AddCondition("POWER", self.power_amount, self)
                end
            },

            Sdual_blade_buff = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.MELEE,

                base_damage = 6,
                defend_amount = 6,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                end
            },

            -- Enraged Attacks
            Shalberd_swipe = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.MELEE,

                base_damage = 2,
   		        hit_count = 2,

            },

            Shalberd_stab = table.extend(NPC_BUFF)
            {
                anim = "splort",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.SKILL,
                target_type = TARGET_TYPE.SELF,
                defend_amount = 6,
                options = {"corrosive_goo", "anesthetic_goo", "adherent_goo", "replicating_goo"},
                num_copies = 2,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)

                    local cards = {}
                    for i = 1, self.num_copies do
                    local incepted_card = Battle.Card(self.options[math.random(#self.options)], self.battle:GetPlayerFighter() )
                    incepted_card.incepted = true
                    incepted_card.show_dealt = true
                    self.battle:DealCards( {incepted_card}, self.battle:GetDrawDeck() )
                    end
                end,

            },

            Shalberd_buff = table.extend(NPC_MELEE)
            {
                anim = "stab",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.MELEE,

                base_damage = 6,
                defend_amount = 6,
                power_amount = 1,
                defensiveness_amount = 1,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount, self)
                    self.owner:AddCondition("POWER", self.power_amount, self)
                    self.owner:AddCondition("SURE_FOOTING", self.defensiveness_amount, self)
                end
            },
        },

        behaviour =
        {
            OnActivate = function( self, fighter )
                self.high_health_attacks = self:MakePicker()
                    :AddID("Sdual_blade_flurry", 2)
                    :AddID("Sdual_blade_slice", 2)
                    :AddID("Sdual_blade_buff", 1)


                self.low_health_attacks = self:MakePicker()
                    :AddID("Shalberd_swipe", 3)
                    :AddID("Shalberd_stab", 1)
                    :AddID("Shalberd_buff", 1)

                    self.fighter:AddCondition("leaking_core", 1, self)
                self:SetPattern(self.HighHealth)
            end,

            HighHealth = function( self )
            	if self.fighter:GetHealthPercent() > 0.5 then
                    self.high_health_attacks:ChooseCards(1)
                else
                    self.fighter:AddCondition("enraged", 1, self)
                    self.low_health_attacks:ChooseCards(1)
                    self:SetPattern(self.LowHealth)
                end
            end,

            LowHealth = function( self )
                self.low_health_attacks:ChooseCards(1)
            end,

        },


    },
})

Content.AddCharacterDef( def )
    