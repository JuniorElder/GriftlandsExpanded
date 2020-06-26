require "content/characters/base_types"

local negotiation_defs = require "negotiation/negotiation_defs"
local battle_defs = require "battle/battle_defs"
local BATTLE_EVENT = battle_defs.BATTLE_EVENT
local CARD_FLAGS = battle_defs.CARD_FLAGS


local SPARK_NEGOTIATION =
{
	OnInit = function( self, difficulty )
		self.all_business = self:AddArgument( "ALL_BUSINESS" )

		self.attacks = self:MakePicker()
		self.attacks:AddID( "straw_man", 1 )

		self.bounty = self:AddArgument( "SCRUPLE" )

		self.negotiator:AddModifier("APPROPRIATOR")
		self:SetPattern( self.Cycle )
	end,

	Cycle = function( self, turns )
		if (turns - 1) % 6 == 0 and not self.negotiator:HasModifier( "ALL_BUSINESS" ) then
			self:ChooseCard( self.all_business )
			self:ChooseGrowingNumbers( 1, 0 )
		else
			if turns % 2 == 0 then
				self.attacks:ChooseCard( 1 )
				self:ChooseGrowingNumbers( 1, 0 )

				if math.random() < 0.3 and not self.negotiator:HasModifier( "SCRUPLE" ) and self.negotiator:GetResolve() ~= nil then
					self:ChooseCard( self.bounty )
				end
			else
				self:ChooseGrowingNumbers( 3, 0, 0.75 )
			end
		end
	end,
}

Content.AddCharacterDef
(
	CharacterDef("GUARDIAN_AUTOMECH",
	{
		base_def = "NPC_BASE",
		tags = {"clust"},
		faction_id = "SPARK_BARONS",
		gender = GENDER.UNDISCLOSED,

		negotiation_data = 
		{
			behaviour = SPARK_NEGOTIATION
		},

		name = "Guardian Automech",
		renown = 1,
		combat_strength = 3,
		species = SPECIES.MECH,

		death_item = "damaged_charging_module",

		base_builds = {
			[ GENDER.UNDISCLOSED ] = "automech_spark_baron_01",
		},
		voice_actor = "robot1",

		anims = {"anim/weapon_blaster_automech_spark_baron.zip"},
		combat_anims = { "anim/med_combat_automech_sparkbaron.zip" },
		head = "head_automech_spark_baron_01",

		fight_data =
		{
            MAX_MORALE = MAX_MORALE_LOOKUP.IMMUNE,
			MAX_HEALTH = 68,
			battle_scale = 1.15,
			shadow_symbol = "hips",

			fx =
			{
				flead_dust = { auto = true },
            },

			attacks =
			{
				Probing_blast = table.extend(NPC_ATTACK)
				{
					name = "Probing Blast",
					anim = "blast",
			        pre_anim = "blast_pre",
			        post_anim = "idle_ground_pre",
					hit_tags = { "spark" },

					flags = battle_defs.CARD_FLAGS.RANGED,
					base_damage = { 6, 7, 8 },
					charge_amount = 1,
					
					OnPostResolve = function( self, battle, attack )
						self.owner:AddCondition("CHARGES", self.charge_amount, self)
					end

				},

				Precision_shot = table.extend(NPC_ATTACK)
				{
					name = "Precision Shot",
					anim = "shoot",
					pre_anim = "shoot_pre",
					post_anim = "shoot_pst",
					hit_tags = { "spark" },

					flags = battle_defs.CARD_FLAGS.RANGED | battle_defs.CARD_FLAGS.SPECIAL,
					base_damage = { 14, 18, 22 },
					hit_count = 1,
					charge_amount = 2,

					OnPostResolve = function( self, battle, attack )
						self.owner:RemoveCondition("CHARGES", self.charge_amount, self)
					end
				},
				Quick_discharge = table.extend(NPC_ATTACK)
				{
					name = "Quick Discharge",
					hit_tags = { "spark" },
					anim = "blast",
			        pre_anim = "blast_pre",
			        post_anim = "idle_ground_pre",

					flags = battle_defs.CARD_FLAGS.RANGED,

					base_damage = { 5, 7, 9 },
					hit_count = 2,
					charge_amount = 1,

					OnPostResolve = function( self, battle, attack )
						self.owner:RemoveCondition("CHARGES", self.charge_amount, self)
					end
				},

				Revitalization =
				{
					name = "Revitalization",
					flags = battle_defs.CARD_FLAGS.BUFF | battle_defs.CARD_FLAGS.SKILL,
					target_type = TARGET_TYPE.SELF,
					anim = "taunt",
			        pre_anim = "idle_ground_post",
			        post_anim = "idle_ground_pre",

					defend_amount = {6,8,10},
					charge_amount = 2,

					OnPostResolve = function( self, battle, attack )
                        local defend_amount = self.defend_amount[ GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1 ]

						self.owner:AddCondition("CHARGES", self.charge_amount, self)
                        self.owner:AddCondition("DEFEND", math.floor(defend_amount))
					end,

				}
			},

			conditions =
			{
				SAHOVER_PACK = -- This is just plain stupid
				{
					hidden = true,
					name = "Animation Fix",
					hud_fx = { "automech_thrust" },

					pre_anim = "stunned_ground_pre",
					post_anim = "stunned_ground_pst",

					max_stacks = 1,
                    anim_mapping =
                    {
                        idle = "idle",
                    },

                    OnUnapply = function( self, battle )
                        self.owner:BroadcastEvent( battle_defs.BATTLE_EVENT.FIGHTER_REMAP_ANIMS )
      --                   if battle:GetCurrentTeam() ~= self.owner:GetTeam() then
						-- 	self.owner:AddCondition( "EVASION", self.stacks )
						-- end
                    end,

                    OnApply = function( self, battle )
                    	self.owner:BroadcastEvent( battle_defs.BATTLE_EVENT.FIGHTER_REMAP_ANIMS, self.ground_anims )
                    end,

		            ground_anims =
		            {
						defend = "defend",
		                defend_pre = "idle_ground_pst",
						defend_pst = "idle_ground_pre",
						
		                hit_mid = "hit_mid_ground",
		                hit_mid_pst_idle = "hit_mid_ground_pst_idle",
		                hit_mid_pst_stunned = "hit_mid_ground_pst_stunned",

		                idle = "idle_ground",
		                step_back = "step_back_ground",
		                step_forward = "step_forward_ground",

		                stunned = "stunned_ground",
		                stunned_pre = "stunned_ground_pre",
		                stunned_pst = "stunned_ground_pst",
		            },

				},

				CHARGES =
				{
					name = "Weapon Charge",
					desc = "Uses stronger attacks when charged.",
					max_stacks = 2,
					icon = "battle/conditions/npc_rook_charges.tex",		
				},

			},

			behaviour =
			{
				OnActivate = function( self )
					self.charge_0 = self:MakePicker()
						:AddID( "Revitalization", 2 )
						:AddID( "Probing_blast", 1 )

						self.charge_1 = self:MakePicker()
						:AddID( "Quick_discharge", 1 )
						:AddID( "Probing_blast", 1 )

						self.charge_2 = self:MakePicker()
						:AddID( "Quick_discharge", 1 )
						:AddID( "Precision_shot", 2 )

					self:SetPattern( self.Cycle )
					self.fighter:AddCondition( "METALLIC", 1 )
					self.fighter:AddCondition( "SAHOVER_PACK", 1 )
				end,

				Cycle = function( self )
					local charges = self.fighter:GetConditionStacks("CHARGES")
						if charges == 0 then
						self.charge_0:ChooseCard( 1 )
						elseif charges == 1 then
						self.charge_1:ChooseCard( 1 )
						elseif charges == 2 then
						self.charge_2:ChooseCard( 1 )
						end
				end
			}

		},
		
		idle_anims = 
		{
			guarding = "idle_neutral_guarding_ranged"
		},

	})
)
