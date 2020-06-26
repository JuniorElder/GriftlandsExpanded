local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS

local JAKES_NEGOTIATION =
{
	OnInit = function( self, difficulty )
		self.crafty = self:AddArgument( "CRAFTY" )
		self.snare = self:AddArgument( "SNARE" )
		self.ploy = self:AddArgument( "ploy" )

		if difficulty <= 2 then
			self:SetPattern( self.BasicCycle )
		else
			self:SetPattern( self.Cycle )
		end

		self.negotiator:AddModifier("DOUBLE_EDGE")
	end,

	BasicCycle = function( self, turns )
		-- CRAFTY every once in awhile if it does't exist.
		if (turns - 1) % 4 == 0 and not self.negotiator:FindModifier( "CRAFTY" ) then
			self:ChooseCard( self.crafty )
		end

		if turns % 3 == 0 then
			if math.random() < 0.5 then
				self:ChooseGrowingNumbers( 1, 1 )
			else
				self:ChooseCard( self.ploy )
			end
		end

		self:ChooseGrowingNumbers( 1, 0, 0.75 )
	end,

	Cycle = function( self, turns )
		-- CRAFTY every once in awhile if it does't exist.
		if (turns - 1) % 4 == 0 and not self.negotiator:FindModifier( "CRAFTY" ) then
			self:ChooseCard(self.crafty )

		elseif math.random() < 0.5 then
			if math.random() < 0.5 then
				self:ChooseCard( self.snare )
			else
				self:ChooseCard( self.ploy )
			end
		end

		self:ChooseGrowingNumbers( 1, 0 )
	end,
}

Content.AddCharacterDef
(
	CharacterDef("JAKES_GHOST",
	{
		base_def = "NPC_BASE",
		faction_id = "JAKES",
		desc = "Ghost",
		name = "Ghost",
        shorttitle = "Jakes Ghost",
		combat_strength = 4,
		renown = 1,
		species = SPECIES.HUMAN,
        gender = GENDER.FEMALE,
		boss = true,
        battle_preview_offset = { x = 80, y = -10 },
        battle_preview_glow = { colour = 0xF2FE79FF, bloom = 0.12, threshold = 0.02 },
        battle_preview_audio = "event:/ui/prebattle_overlay/prebattle_overlay_whooshin_boss_assassin_zyn",

		unique = true,

		voice_actors = {
		    [GENDER.MALE] = { "jakeLowClassMale01" },
    		[GENDER.FEMALE] = { "jakeLowClassFemale01" },
		},

    	death_money = DEATH_MONEY_HIGH,
    	death_item = "bleachbug_tincture",

    	loved_graft = "sharpened_blades",
    	hated_graft = "hemophiliac",

		aspects = {
			social_connections = true,
		},

		social_boons =
		{
			[ RELATIONSHIP.LIKED ] = { ASSASSINATE = 1, NOTHING = 3 },
			[ RELATIONSHIP.LOVED ] = { ASSASSINATE = 1 },
		},

        head = "head_female_grifter",
        build = "male_phicket",
		anims = {"anim/weapon_sword_phicket_assassin.zip"},
		combat_anims = { "anim/med_combat_sword_phicket_assassin.zip" },

		skin_colour = 0xFFFFFFFF,
		hair_colour = 0xFFFFFFFF,


		fight_data = 
		{
			MAX_MORALE = MAX_MORALE_LOOKUP.HIGH,
			MAX_HEALTH = 115,

	        status_widget_head_dx = 0.0,
	        status_widget_head_dy = 4.5,

			anim_mapping =
 			{
 				riposte = "debilitate",
			},

			cards = { "graceful_swing", "lightning_strikes", "slash_open", "regain_composure" },
			
			conditions = 
			{
	
				combo_factor = 
				{
					name = "Combo Potential",
					desc = "Gains bonuses with higher {COMBO}.\n{COMBO} => 5: at the end of turn gain 6 base {DEFEND}\n{COMBO} => 10: all attacks apply 1 {WOUND}\n{COMBO} => 15: all attacks apply 1 {CRIPPLE}",
					icon = "battle/conditions/inside_fighting.tex",
				},

				hidden_wound = 
				{
					hidden = true,
                    event_handlers = 
                    {
                        [ BATTLE_EVENT.ON_HIT] = function( self, battle, attack, hit )
                            if attack.attacker == self.owner and attack.card and attack.card:IsAttackCard() and self.owner:GetConditionStacks( "COMBO" ) >= 10 then
                                hit.target:AddCondition("WOUND", self.stacks, self)
                            end
                        end,
                    },
				},

				hidden_combo = 
				{
					hidden = true,
                    event_handlers = 
                    {
                        [ BATTLE_EVENT.ON_HIT] = function( self, battle, attack, hit )
                            if attack.attacker == self.owner and attack.card and attack.card:IsAttackCard() then
                                self.owner:AddCondition("COMBO", self.stacks, self)
                            end
                        end,
                    },
				},

				hidden_cripple = 
				{
					hidden = true,
                    event_handlers = 
                    {
                        [ BATTLE_EVENT.ON_HIT] = function( self, battle, attack, hit )
                            if attack.attacker == self.owner and attack.card and attack.card:IsAttackCard() and self.owner:GetConditionStacks( "COMBO" ) >= 15 and not hit.defended and not hit.evaded then
                                hit.target:AddCondition("CRIPPLE", self.stacks, self)
                            end
                        end,
                    },
				},
			},

			attacks = 
			{
			    graceful_swing = table.extend(NPC_ATTACK)
			    {
			        name = "Graceful Swing",
			        anim = "bloodbind",
			        flags = CARD_FLAGS.MELEE,

			        base_damage = { 7, 8, 9 },

					hit_count = 2,
				
					defend = 4,
					combo_defend = 6,
					combo = 4,
					
					OnPostResolve = function( self, battle, attack )
						if self.owner:GetConditionStacks( "COMBO" ) >= 5 then
			            self.owner:AddCondition("DEFEND", self.combo_defend )
						end
						self.owner:AddCondition("DEFEND", self.defend )
						self.owner:AddCondition("COMBO", self.combo )
					end
			    },

			    lightning_strikes = table.extend(NPC_ATTACK)
			    {
			        name = "Lightning Strikes",
			        anim = "attack3",
			        flags = CARD_FLAGS.MELEE ,

			        base_damage = { 4, 4, 5 },

					hit_count = 3,
					
					defend = 6,
					combo = 6,
					
					OnPostResolve = function( self, battle, attack )
						if self.owner:GetConditionStacks( "COMBO" ) >= 5 then
			            self.owner:AddCondition("DEFEND", self.defend )
						end
						self.owner:AddCondition("COMBO", self.combo )
					end
			    },

			    slash_open = table.extend(NPC_ATTACK)
			    {
			        name = "Slash Open",
			        anim = "slash",
			        flags = CARD_FLAGS.MELEE,
			        
					base_damage = { 12, 14, 16 },
					
					defend = 6,
					wound = 3,
					combo = 2,
					
                    event_handlers = 
                    {
                        [ BATTLE_EVENT.ON_HIT] = function( self, battle, attack, hit )
                            if attack.attacker == self.owner and attack.card and attack.card:IsAttackCard() and self == attack.card then
                                hit.target:AddCondition("WOUND", self.wound )
                            end
                        end,
                    },

					OnPostResolve = function( self, battle, attack )
						if self.owner:GetConditionStacks( "COMBO" ) >= 5 then
			            self.owner:AddCondition("DEFEND", self.defend )
						end
						self.owner:AddCondition("COMBO", self.combo )
					end
			    },

			    regain_composure = table.extend(NPC_BUFF)
			    {
			        name = "Regain Composure",
			        anim = "taunt",
			        flags = CARD_FLAGS.SKILL | CARD_FLAGS.BUFF,
			        target_type = TARGET_TYPE.SELF,

					
			        sure_footing = {2,3,3},
					defend = 8,
					combo_defend = 6,

					OnPostResolve = function( self, battle, attack )
						if self.owner:GetConditionStacks( "COMBO" ) >= 5 then
						self.owner:AddCondition("DEFEND", self.combo_defend )
						end
						self.owner:AddCondition("COMBO", self.combo )
			            self.owner:AddCondition("DEFEND", self.defend )
			            self.owner:AddCondition("SURE_FOOTING", self.sure_footing[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1])
			        end
			    },
			},

			behaviour =
			{
				OnActivate = function( self, fighter )
					self.attacks = self:MakePicker()
						:AddID( "graceful_swing", 1 )
						:AddID( "lightning_strikes", 1 )
						:AddID( "slash_open", 1 )
					self.buff = self:MakePicker()
						:AddID( "regain_composure", 1 )
					self:SetPattern( self.Cycle )
					self.fighter:AddCondition("hidden_wound")
					self.fighter:AddCondition("hidden_cripple")
					self.fighter:AddCondition("combo_factor")

					self:Present( function( screen, ent )
						screen:DelayForFighter( fighter )
						ent.cmp.AnimFighter:PlayAnim( "taunt" )
					end )
				end,

				Cycle = function( self )
					if self.battle:GetTurns() % 3 == 0 and self.battle:GetTurns() > 0 then
					self.buff:ChooseCard( 1 )
					self.fighter:AddCondition("PERFECT_PARRY")
					else
					self.attacks:ChooseCard( 1 )
					self.fighter:AddCondition("PERFECT_PARRY")
					end
				end,

			},
		},

		negotiation_data =
		{
			behaviour = table.extend( JAKES_NEGOTIATION )
			{
			}
		},

	})
)
