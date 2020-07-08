require "content/characters/base_types"

local negotiation_defs = require "negotiation/negotiation_defs"
local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS
local EVENT = negotiation_defs.EVENT

Content.AddNegotiationCard("secret_codes", 
{
	name = "Secret Codes",
	icon = "negotiation/planning.tex",
	desc = "Dismiss a random enemy intent.",
	quip = "bribery",
	cost = 0,

    flags = negotiation_defs.CARD_FLAGS.MANIPULATE | negotiation_defs.CARD_FLAGS.EXPEND,

	OnPostResolve = function( self, minigame, targets )
		local intents = minigame:GetOpponentNegotiator():GetIntents()
		if #intents > 0 then
			minigame:GetOpponentNegotiator():DismissIntent(intents[math.random(#intents)])
		end
	end,

    rarity = CARD_RARITY.UNIQUE,
    series = CARD_SERIES.GENERAL,

})

Content.AddCharacterDef
(
	CharacterDef("ADMIRALTY_OPERATIVE",
	{
		base_def = "NPC_BASE",
		faction_id = "ADMIRALTY",
		gender = GENDER.FEMALE,

		name = "Theia",
		title = "Operative",
		renown = 1,
		combat_strength = 3,
		species = "HUMAN",

		death_money = DEATH_MONEY_HIGH,
		death_item = "secret_codes",

		anims = {"anim/weapon_spear_guard_lumin.zip"},
		combat_anims = { "anim/med_combat_spear_admiralty_patrol_leader.zip"},

		base_builds = {
			[ GENDER.FEMALE ] = "guard_corporal_female"
		},

		voice_actor = "prindokalandra",

		head = "head_female_bogger_clobber",
		hair_colour = 2810538751,
		skin_colour = 3314969087,

		boss = true,
		unique = true,
    	loved_graft = "admiralty_medals",
		hated_graft = "wrong_papers",

		idle_anims = 
		{
			guarding = "idle_neutral_guarding"
		},

        support_negotiation = "formality",

        negotiation_data = 
        {
            modifiers =
            {
    
            },
            behaviour = 
            {
                OnInit = function( self, difficulty )
                    self.moment_of_weakness = self:AddCard( "moment_of_weakness" )
                    self.negotiator:AddModifier( "UNCERTAINTY" )
                    self:SetPattern( self.BasicCycle )
                end,
    
                BasicCycle = function( self, turns )
                    if not self.player_negotiator:HasModifier("moment_of_weakness") then
                        self:ChooseCard( self.moment_of_weakness )
                        self:ChooseGrowingNumbers( 2 )
                    else
                        self:ChooseGrowingNumbers( 2, 2 )
                        if math.random() < .5 then
                            self:ChooseComposure( 1, 2, 2 )
                        end
                    end
                end,
            }
        },

		fight_data =
		{
			MAX_MORALE = MAX_MORALE_LOOKUP.HIGH,
			MAX_HEALTH = 72,
			battle_scale = 0.95,

			attacks =
			{
				Whirlwind = table.extend(NPC_ATTACK)
				{
					name = "Whirlwind",
					anim = "hamstring",

					target_mod = TARGET_MOD.TEAM,
					hit_tags = { "lumin" },

					flags = battle_defs.CARD_FLAGS.MELEE | battle_defs.CARD_FLAGS.SPECIAL,
					base_damage = { 6, 9, 12 },
				},

				Jab = table.extend(NPC_ATTACK)
				{
					name = "Jab",
					anim = "mightythrust",

					hit_tags = { "lumin" },

					flags = battle_defs.CARD_FLAGS.MELEE,

					base_damage = { 8, 11, 14 },
				},

				Distraction =
				{
					name = "Distraction",
					flags = battle_defs.CARD_FLAGS.BUFF | battle_defs.CARD_FLAGS.SKILL,
					target_type = TARGET_TYPE.SELF,
					anim = "taunt",

					evasion_amount = { 1, 1, 2 },
					riposte_amount = { 3, 4, 5 },

					OnPostResolve = function( self, battle, attack )
						local evasion_amount = self.evasion_amount[ GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1 ]
						local riposte_amount = self.riposte_amount[ GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1 ]

						self.owner:AddCondition("RIPOSTE", math.floor(riposte_amount))
                        self.owner:AddCondition("EVASION", math.floor(evasion_amount))
					end,

				}
			},

			conditions =
			{
				NPC_OVERCHARGE = 
				{
					name = "Overcharge",
					desc = "Attack damage is increased by {1}.\nReduced by half at the end of the turn.",
					desc_fn = function( self, fmt_str, battle )
						return loc.format(fmt_str, self.stacks )
					end,
					icon = "battle/conditions/pruned.tex",
			
					apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack_Combo",

					event_handlers =
					{
						[ BATTLE_EVENT.END_TURN ] = function( self, fighter )
							if fighter == self.owner then
							self.owner:RemoveCondition("NPC_OVERCHARGE", math.ceil(self.stacks * 0.5), self)
							end
						end,
			
						[ BATTLE_EVENT.CALC_DAMAGE ] = function( self, card, target, dmgt )
							if card.owner == self.owner and card:IsAttackCard() then
								dmgt:ModifyDamage( dmgt.min_damage + self.stacks, dmgt.max_damage + self.stacks, self )
							end
						end
					},
				},

				RECHARGING_SHIELDS =
				{
					name = "Recharging Shields",
					desc = "Gain {1} {DEFEND} at the end of every turn.\nRemove 1 stack when you take damage from an attack.",
					desc_fn = function( self, fmt_str )
						return loc.format(fmt_str, self.stacks or 1)
					end,

					icon = "battle/conditions/tank.tex",
					hide_gained = true,
					
					OnApply = function( self, battle )
						self.owner:AddCondition("DEFEND", self.stacks or 1, self)
					end,
			
					event_handlers =
					{
						[ BATTLE_EVENT.DAMAGE_APPLIED ] = function( self, fighter, damage, delta, source )
							if fighter == self.owner then
								local shield_loss = 1
								shield_loss = self.battle:CalculateComboLoss( shield_loss, source )
								self.owner:RemoveCondition( self.id, shield_loss )
							end
						end,

						[ BATTLE_EVENT.END_TURN ] = function( self, fighter )
							if self.owner == fighter and self.owner:IsActive() then
								self.owner:AddCondition( "DEFEND", self.stacks or 1, self )
							end
						end,
					}
				},

				LEACHING_EDGE = 
				{
					name = "Leaching Edge",
					desc = "Unblocked attacks apply 1 {IMPAIR}.",
					icon = "battle/conditions/sharpened_blade.tex",

			        apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack",

                    event_handlers = 
                    {
                        [ BATTLE_EVENT.ON_HIT] = function( self, battle, attack, hit )
                            if attack.attacker == self.owner and attack.card and attack.card:IsAttackCard() and not hit.defended and not hit.evaded then
                                hit.target:AddCondition("IMPAIR", self.stacks, self)
                            end
                        end,
                    },
				},

				WARY = 
				{
					name = "Wary",
					desc = "When reduced to half health, start losing morale.",
					icon = "battle/conditions/gear_head.tex",
					
					event_handlers =
					{
						[ BATTLE_EVENT.END_TURN ] = function( self, fighter )
							if fighter == self.owner and fighter:GetHealthPercent() < 0.5 then
								fighter:RemoveCondition( "WARY", 1 )
								fighter:AddCondition( "WAVERING", 1 )
							end
						end,
					},
				},

				WAVERING = 
				{
					name = "Wavering",
					desc = "At the end of each turn, increase this fighter's {SURRENDER} meter by 5.",
					icon = "battle/conditions/existential_crisis.tex",
					ctype = CTYPE.DEBUFF,

			        apply_sound = "event:/sfx/battle/status/system/Status_Buff_Attack",

					event_handlers =
					{
						[ BATTLE_EVENT.END_TURN ] = function( self, fighter )
							if fighter == self.owner then
								fighter:ApplyMoraleDamage( 5, self)
								fighter:CheckForSurrender()
							end
						end,
					},
				},
			},

			behaviour =
			{
				OnActivate = function( self )
					self.overcharge_amount = { 8, 10, 12 }
					self.shields_amount = { 6, 8, 10 }

					local overcharge_amount = self.overcharge_amount[ GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1 ]
					local shields_amount = self.shields_amount[ GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1 ]

					self.charge_0 = self:MakePicker()
						:AddID( "Whirlwind", 1 )
						:AddID( "Jab", 2 )
						:AddID( "Distraction", 1 )

						self.Jab = self:AddCard("Jab")

						self.Whirlwind = self:AddCard("Whirlwind")

						self.Distraction = self:AddCard("Distraction")

						self.fighter:AddCondition( "WARY", 1 )
						self.fighter:AddCondition( "LEACHING_EDGE", 1 )
						self.fighter:AddCondition( "NPC_OVERCHARGE", math.floor(overcharge_amount) )
						self.fighter:AddCondition( "RECHARGING_SHIELDS", math.floor(shields_amount) )
					self:SetPattern( self.Turn1 )
				end,

				Turn1 = function( self )
						self:ChooseCard(self.Jab)

						self:SetPattern( self.Turn2 )
				end,
				Turn2 = function( self )
						self:ChooseCard(self.Whirlwind)

						self:SetPattern( self.Turn3 )
				end,
				Turn3 = function( self )
						self:ChooseCard(self.Jab)

						self:SetPattern( self.Turn4 )
				end,
				Turn4 = function( self )
						self:ChooseCard(self.Distraction)

						self:SetPattern( self.Cycle )
				end,
				Cycle = function( self )
						self.charge_0:ChooseCard( 1 )
				end
			}

		},

	})
)
