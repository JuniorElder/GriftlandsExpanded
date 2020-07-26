local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT

local def = CharacterDef("DRUSK_ANCIENT",
{
    unique = true,
    renown = 3,
    combat_strength = 3, 
    name = "Drusk Ancient",
    base_def = "NPC_BASE",
    species = SPECIES.BEAST,
    gender = GENDER.MALE,
        boss = true,
        battle_preview_offset = { x = 80, y = -10 },
        battle_preview_glow = { colour = 0xF2FE79FF, bloom = 0.12, threshold = 0.02 },
        battle_preview_anim = "anim/boss_drusk_slide.zip",
        battle_preview_audio = "event:/ui/prebattle_overlay/prebattle_overlay_whooshin_boss_drusk1",
        death_item = "core_fluid",

        faction_id = MONSTER_FACTION,
        tags = { "beast", "no_rob", "enforcer" },

        combat_anims = { "anim/med_combat_drusk_01.zip" },
        build = "drusk_01",

    
    fight_data = 
    {
            MAX_MORALE = MAX_MORALE_LOOKUP.IMMUNE,
            MAX_HEALTH = {200, 220, 240},
            battle_scale = 1.25,
            status_widget_dx = 0.5,
            status_widget_dy = -0.95,
        
	conditions = 
        { 
            phase1 =
            {
                name = "Phase I",
                feature_desc = "Changes moveset after losing a significant portion of health.",
                desc = "Changes moveset after losing a significant portion of health.",
                icon = "JuniorElderExpandedMod:mod_content/icons/phase1.png",

            },
            phase2 =
            {
                name = "Phase II",
                feature_desc = "Changes moveset after losing a significant portion of health.",
                desc = "Changes moveset after losing a significant portion of health.",
                icon = "JuniorElderExpandedMod:mod_content/icons/phase2.png",
                ctype = CTYPE.DEBUFF,

                apply_fx = {"power"},

            },

            leaking_core = 
            {
                name = "Leaking Core",
                desc = "When attacked and damaged shuffle a random goo into the attacker's deck.",
                icon = "battle/conditions/acidic_slime.tex",
                target_type = TARGET_TYPE.SELF,
                options = {"corrosive_goo", "enfeebling_goo", "adherent_goo", "replicating_goo"},
                
                event_handlers =
               {
                [ BATTLE_EVENT.DAMAGE_APPLIED] = function( self, fighter, damage, delta, attack )
                
                    if delta > 0 then
                    if attack ~= nil then
                    if fighter == self.owner then
                    if attack.attacker == self.battle:GetPlayerFighter() then --if this stops working again try attack.owner first
                    local cards = {}
                    local incepted_card = Battle.Card(self.options[math.random(#self.options)], self.battle:GetPlayerFighter() )
                    incepted_card.incepted = true
                    incepted_card.show_dealt = true
                    self.battle:DealCards( {incepted_card}, self.battle:GetDrawDeck() )
                end   
                end
                end       
                end
                end,
                },
            },

        },
        
        
        attacks = 
        {
            -- Max Health attacks
            balanced_lunge = table.extend(NPC_MELEE)
            {
                name = "Balanced Lunge",
                anim = "stab",
                flags = CARD_FLAGS.MELEE,

                base_damage = {8,10,12},
                defensiveness_amount = 2	,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("SURE_FOOTING", self.defensiveness_amount, self)
                end

            },

            claw_extension = table.extend(NPC_BUFF)
            {
                name = "Claw Extension",
                anim = "taunt_defend",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.SKILL,
                target_type = TARGET_TYPE.SELF,
                defend_amount = {6,8,10},
                power_amount = 2,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1], self)
                    self.owner:AddCondition("POWER", self.power_amount, self)
                end
            },

            cautious_jab = table.extend(NPC_MELEE)
            {
                name = "Cautious Jab",
                anim = "stab",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.MELEE,

                base_damage = {8,10,12},
                defend_amount = {6,8,10},

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1], self)
                end
            },

            -- Enraged Attacks
            wild_flailing = table.extend(NPC_MELEE)
            {
                name = "Wild Flailing",
                anim = "stab",
                flags = CARD_FLAGS.MELEE,

                base_damage = {6,8,10},
   		        hit_count = 2,

            },

            disorienting_spores = table.extend(NPC_RANGED)
            {
                name = "Disorienting Spores",
                anim = "splort",

                flags = CARD_FLAGS.RANGED,
                target_mod = TARGET_MOD.TEAM,
                base_damage = {8,10,12},

                features =
                {
                    DISORIENTATION = 4,
                },
            },

            last_reserves = table.extend(NPC_MELEE)
            {
                name = "Last Reserves",
                pre_anim = "taunt",
                anim = "stab",
                flags = CARD_FLAGS.BUFF | CARD_FLAGS.MELEE,

                base_damage = {6,8,10},
                defend_amount = {6,8,10},
                power_amount = 1,
                defensiveness_amount = 1,

                OnPostResolve = function( self, battle, attack )
                    self.owner:AddCondition("DEFEND", self.defend_amount[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1], self)
                    self.owner:AddCondition("POWER", self.power_amount, self)
                    self.owner:AddCondition("SURE_FOOTING", self.defensiveness_amount, self)
                end
            },
        },
        behaviour =
        {
            OnActivate = function( self, fighter )
                self.high_health_attacks = self:MakePicker()
                    :AddID("balanced_lunge", 2)
                    :AddID("claw_extension", 2)
                    :AddID("cautious_jab", 1)


                self.low_health_attacks = self:MakePicker()
                    :AddID("wild_flailing", 2)
                    :AddID("disorienting_spores", 1)
                    :AddID("last_reserves", 1)

                    self.fighter:AddCondition("phase1", 1, self)
                    self.fighter:AddCondition("leaking_core", 1, self)
                self:SetPattern(self.HighHealth)
            end,

            HighHealth = function( self )
            	if self.fighter:GetHealthPercent() > 0.5 then
                    self.high_health_attacks:ChooseCards(1)
                else
                    self.fighter:RemoveCondition("phase1", 1, self)
                    self.fighter:AddCondition("phase2", 1, self)
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
    