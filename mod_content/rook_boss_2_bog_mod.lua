local fun = require "util/fun"
local battle_defs = require "battle/battle_defs"
local FLAGS = battle_defs.CARD_FLAGS
local EVENT = battle_defs.BATTLE_EVENT
---------------------------------------------------

local function GroutJoin( fighter, anim_fighter )
    local x, z = anim_fighter:GetHomePosition()
    anim_fighter.entity.cmp.AnimController:SetXFlip(fighter:GetTeamID() == TEAM.RED)
    anim_fighter.entity:SetLocalPosition( x, 0, z )
    anim_fighter:PlayAnim( "emerge" )
    anim_fighter:WaitAnim()
end

local function GroutMoving( anim_fighter, x, z, move_type, fx_tags, force_run )
    -- To satisfy AnimFighter:IsMoving()
    anim_fighter.destx = x
    anim_fighter.destz = z

    anim_fighter:PlayAnim( "surrender" )
    anim_fighter:WaitAnim()
    anim_fighter.entity.cmp.Transform:SetPosRot(x,anim_fighter.height,z)
    anim_fighter:PlayAnim( "emerge" )
    anim_fighter:WaitAnim()

    anim_fighter:StopMoving()
end

local function GroutUpdateMoving( anim_fighter, dt )
end

Content.AddBattleCard("alluring_visions",
{
    name = "Alluring Visions",
    anim = "shake_it_off",
    icon = "negotiation/baffled.tex",

    flags = FLAGS.EXPEND | FLAGS.STATUS,
    series = CARD_SERIES.NPC,
    rarity = CARD_RARITY.UNIQUE,
    target_type = TARGET_TYPE.SELF,

    cost = 1,
})

Content.AddBattleCard("osmotic_tissue",
{
    name = "Osmotic Tissue",
    anim = "melee_item",
    hit_tags = { "bleed" },
    icon = "negotiation/grisly_trophy.tex",
    desc = "Steal 5 health from an enemy.",

    flags = FLAGS.EXPEND | FLAGS.MELEE | FLAGS.ITEM,
    series = CARD_SERIES.NPC,
    rarity = CARD_RARITY.UNIQUE,

    cost = 1,

    OnPostResolve = function( self, battle, attack )
        for i, hit in attack:Hits() do
            local health = 0
            if hit.target:GetHealth() > 4 then
            health = 5
            else
            health = hit.target:GetHealth()
            end
            hit.target:DeltaHealth(-5)
            self.owner:HealHealth( health, self )
        end
    end,
})

local QUEEN_FORMATION =
{
    { 11.2, 1.0, FIGHTER_FORMATION.FRONT_X },  -- centre: always queen

    { 3.0, -4, nil }, -- top foreward
    { 8.2, 6.6, nil }, -- bottom back
    { 3.8, 4.6, nil }, -- bottom foreward
    { 6.5, -4.2, nil }, -- top back
    { 0.2, 1, nil }, -- centre foreward
}

Content.AddCharacterDef
(
    CharacterDef("BOG_EGG",
    {
		base_def = "NPC_BASE",
        faction_id = MONSTER_FACTION,
        renown = 1,
		combat_strength = 3,
        species = SPECIES.BEAST,
        tags = { "beast", "no_rob", "enforcer" },

        title = "Monstrosity",
        name = "Mutated Burr",
        build = "grout_egg_batch",
        boss = true,
		gender = GENDER.UNDISCLOSED,
        battle_preview_offset = { x = 0, y = 0 },
        death_item = "ethereal_pheromones",


        fight_data =
        {
            battle_scale = 1.45,
            MAX_HEALTH = 40,
            formation = FIGHTER_FORMATION.FRONT_X,

            status_widget_head_dx = 1.0,
            status_widget_head_dy = 2.5,

            shadow_scale = 0.0, -- Doesn't add a shadow prefab if 0

            OnJoinBattle = GroutJoin,

            StartMoving = GroutMoving,

            UpdateMoving = GroutUpdateMoving,

            anim_mapping =
            {
                stunned = "idle",
            },

			conditions = 
			{
				hidden_spawn_knuckle = 
				{
					hidden = true,
                    event_handlers = 
                    {
                        [ EVENT.FIGHTER_KILLED ] = function( self, fighter )

                            if fighter:GetTeam() and fighter:GetTeam() == self.owner:GetTeam() and fighter.agent:GetContentID() == "KNUCKLE_EGG" then
                                self.owner:AddCondition("hidden_spawn_knuckle", 1, self)
                            end
                         end,

                         [ EVENT.BEGIN_TURN ] = function( self, fighter, battle )
                            if self.stacks == 3 then
                                local to_summon = 2
                                for k =1 , to_summon do
                                    local agent = Agent( "KNUCKLE_EGG" )
                                    local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                                    new_fighter.parent = self.owner
                                    new_fighter:AddCondition("run_away_grouts_egg")   
                                    new_fighter:AddCondition("STUN")                                     
                                    self.owner:GetTeam():AddFighter( new_fighter )
                                end

                                self.owner:AddCondition("hidden_spawn_knuckle", -2, self)
                            end
                            if self.stacks == 2 then
                                local to_summon = 1
                                for k =1 , to_summon do
                                    local agent = Agent( "KNUCKLE_EGG" )
                                    local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                                    new_fighter.parent = self.owner
                                    new_fighter:AddCondition("run_away_grouts_egg")      
                                    new_fighter:AddCondition("STUN")                                  
                                    self.owner:GetTeam():AddFighter( new_fighter )
                                end

                                self.owner:AddCondition("hidden_spawn_knuckle", -1, self)
                            end
                        end
                    },
				},

				hidden_spawn_mine = 
				{
					hidden = true,
                    event_handlers = 
                    {
                        [ EVENT.FIGHTER_KILLED ] = function( self, fighter )

                            if fighter:GetTeam() and fighter:GetTeam() == self.owner:GetTeam() and fighter.agent:GetContentID() == "SPARK_MINE_EGG" then
                                self.owner:AddCondition("hidden_spawn_mine", 1, self)
                            end
                         end,

                         [ EVENT.BEGIN_TURN ] = function( self, fighter )
                            if self.stacks == 3 then
                                local to_summon = 2
                                for k =1 , to_summon do
                                    local agent = Agent( "SPARK_MINE_EGG" )
                                    local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                                    new_fighter.parent = self.owner
                                    new_fighter:AddCondition("run_away_grouts_egg")    
                                    new_fighter:AddCondition("STUN")                                    
                                    self.owner:GetTeam():AddFighter( new_fighter )
                                end

                                self.owner:AddCondition("hidden_spawn_mine", -2, self)
                            end
                            if self.stacks == 2 then
                                local to_summon = 1
                                for k =1 , to_summon do
                                    local agent = Agent( "SPARK_MINE_EGG" )
                                    local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                                    new_fighter.parent = self.owner
                                    new_fighter:AddCondition("run_away_grouts_egg") 
                                    new_fighter:AddCondition("STUN")                                       
                                    self.owner:GetTeam():AddFighter( new_fighter )
                                end

                                self.owner:AddCondition("hidden_spawn_mine", -1, self)
                            end
                        end
                    },
				},

				hidden_spawn_loot = 
				{
					hidden = true,
                    event_handlers = 
                    {
                        [ EVENT.FIGHTER_KILLED ] = function( self, fighter )

                            if fighter:GetTeam() and fighter:GetTeam() == self.owner:GetTeam() and fighter.agent:GetContentID() == "LOOT_CLUSTER_EGG" then
                                self.owner:AddCondition("hidden_spawn_loot", 1, self)
                            end
                         end,

                         [ EVENT.BEGIN_TURN ] = function( self, fighter )
                            if self.stacks == 2 then
                                local to_summon = 1
                                for k =1 , to_summon do
                                    local agent = Agent( "LOOT_CLUSTER_EGG" )
                                    local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                                    new_fighter.parent = self.owner
                                    new_fighter:AddCondition("run_away_grouts_egg")   
                                    new_fighter:AddCondition("STUN")                         
                                    self.owner:GetTeam():AddFighter( new_fighter )
                                end

                                self.owner:AddCondition("hidden_spawn_loot", -1, self)
                            end
                        end,
                    },
                },
                
                protected =
			    {
                    name = "Protected",
                    icon = "battle/conditions/formation.tex",
			        desc = "Gain 5 {DEFEND} for every other active friendly fighter at the end of the turn.",

        			apply_sound = "event:/sfx/battle/status/system/Status_Buff_Defend",
			        ctype = CTYPE.INNATE,
                    ally_count = 1,

			        event_handlers = 
			        {
                        [ EVENT.BEGIN_TURN ] = function ( self, fighter )
                            if fighter == self.owner then
                            self.ally_count = #self.owner:GetTeam():GetFighters()
                            end
                        end,
                        
                        [ EVENT.END_TURN ] = function ( self, fighter )
                            if fighter == self.owner then
                            if self.ally_count > 1 then
                            self.owner:AddCondition("DEFEND", 5*(self.ally_count-1), self)
                            end
                            end
			            end,
			        },
			    },
			},

            attacks =
            {
                emerge =
                {
                    name = "Emerge",
                    anim = "taunt",
                    flags = FLAGS.SKILL | FLAGS.BUFF,

                    target_type = TARGET_TYPE.SELF,

                    CanPlayCard = function( self, battle, target )
                        return self.owner:GetTeam():NumActiveFighters() < self.owner:GetTeam():GetMaxFighters(), CARD_PLAY_REASONS.TEAM_FULL
                    end,

                    OnPostResolve = function( self, battle, attack )
                        local to_summon = math.min( 2, self.owner:GetTeam():GetMaxFighters() - self.owner:GetTeam():NumActiveFighters() )
                        for k =1 , to_summon do
                            local agent = Agent( "KNUCKLE_EGG" )
                            local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                            new_fighter.parent = self.owner
                            new_fighter:AddCondition("run_away_grouts_egg")                            
                            self.owner:GetTeam():AddFighter( new_fighter )
                        end
                        local to_summon2 = math.min( 2, self.owner:GetTeam():GetMaxFighters() - self.owner:GetTeam():NumActiveFighters() )
                        for k =1 , to_summon2 do
                            local agent = Agent( "SPARK_MINE_EGG" )
                            local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                            new_fighter.parent = self.owner
                            new_fighter:AddCondition("run_away_grouts_egg")                            
                            self.owner:GetTeam():AddFighter( new_fighter )
                        end
                        local to_summon3 = math.min( 1, self.owner:GetTeam():GetMaxFighters() - self.owner:GetTeam():NumActiveFighters() )
                        for k =1 , to_summon3 do
                            local agent = Agent( "LOOT_CLUSTER_EGG" )
                            local new_fighter = Fighter.CreateFromAgent( agent, self.owner:GetScale() )
                            new_fighter.parent = self.owner
                            new_fighter:AddCondition("run_away_grouts_egg")                            
                            self.owner:GetTeam():AddFighter( new_fighter )
                        end
                        self.owner:GetTeam():ActivateNewFighters( battle )
                    end,
                },

                potent_nourishment =
                {
                    name = "Potent Nourishment",
                    anim = "taunt",

			        target_type = TARGET_TYPE.FRIENDLY_OR_SELF,
			        target_mod = TARGET_MOD.TEAM,
			        flags = FLAGS.SKILL | FLAGS.BUFF,

			        OnPostResolve = function(self, battle, attack)
			        	local ally_count = #self.owner:GetTeam():GetFighters()
			        	local power = {1,1,2}
			        	for i, fighter in ipairs(self.owner:GetTeam():GetFighters()) do
				        		fighter:AddCondition("POWER", power[ GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1 ])
			        	end
			    	end,
                },

                acid_spray = table.extend(NPC_MELEE)
                {
                    name = "Acid Spray",
                    anim = "hit_mid",
                    flags = FLAGS.MELEE,
                    target_type = TARGET_TYPE.ENEMY,
                    hit_tags = { "acid" },

                    base_damage = { 4, 7, 10 },
                    
                    features =
                    {
                        WOUND = 3,
                    },
                },
            },

            behaviour =
            {
                CUSTOM_FIGHT_FORMATIONS =
                {
                    [1] = QUEEN_FORMATION,
                    [2] = QUEEN_FORMATION,
                    [3] = QUEEN_FORMATION,
                    [4] = QUEEN_FORMATION,
                    [5] = QUEEN_FORMATION,
                    [6] = QUEEN_FORMATION,
                },

                OnActivate = function( self )
                    self.fighter:GetTeam():SetMaxFighters( 6 )
                    self.fighter:GetTeam():SetCustomFormation( self.CUSTOM_FIGHT_FORMATIONS )

                    self.opener = self:AddCard("emerge")
                    self.fighter.battle:PlayCard(self.opener)

                    self.attack = self:MakePicker()
                        :AddID( "potent_nourishment", 2 )
                        :AddID( "acid_spray", 1 )

                    self.fighter:AddCondition( "protected", 1 )
                    self.fighter:AddCondition( "DEFEND", 25 )
                    self.fighter:AddCondition( "hidden_spawn_knuckle", 1 )
                    self.fighter:AddCondition( "hidden_spawn_mine", 1 )
                    self.fighter:AddCondition( "hidden_spawn_loot", 1 )
                    self:SetPattern( self.Cycle )
                end,

                Cycle = function( self )
                    self.attack:ChooseCard()
                end,
            },

        },
    })
)

--this one is a turret
Content.AddCharacterDef
(
    CharacterDef("KNUCKLE_EGG",
    {
		base_def = "NPC_BASE",
        faction_id = MONSTER_FACTION,
        species = SPECIES.BEAST,
        tags = { "beast", "no_rob", "enforcer" },
        gender = GENDER.UNDISCLOSED,

        title = "Knuckle",
        build = "grout_knuckles",
        combat_strength = 1,
        renown = 1,

        fight_data =
        {
            MAX_HEALTH = 12,
            battle_scale = 0.85,

            status_widget_head_dx = 1.0,
            status_widget_head_dy = 2.5,

            shadow_scale = 0.0, -- Doesn't add a shadow prefab if 0

            OnJoinBattle = GroutJoin,

            StartMoving = GroutMoving,

            UpdateMoving = GroutUpdateMoving,

            ally_killed_quip = "battle_grout_killed",

            ranged_riposte = true,
            anim_mapping =
            {
                riposte = "attack1",
            },

            attacks =
            {
                egg_puncture = table.extend(NPC_RANGED)
                {
                    name = "Puncture",
                    anim = "attack1",
                    flags = FLAGS.RANGED,
                    target_type = TARGET_TYPE.ENEMY,

					base_damage = { 6, 8, 10 },
                },

            },

            behaviour =
            {
                OnActivate = function( self )
                    self.attack = self:MakePicker()
                        :AddID( "egg_puncture", 1 )

                    self:SetPattern( self.Cycle )
                end,

                Cycle = function( self )
                    self.attack:ChooseCard()
                end,

            },
        },
    })
)

--this one is a mine
Content.AddCharacterDef
(
    CharacterDef("SPARK_MINE_EGG",
    {
		base_def = "NPC_BASE",
        faction_id = MONSTER_FACTION,
        species = SPECIES.BEAST,
        tags = { "beast", "no_rob", "enforcer" },
        gender = GENDER.UNDISCLOSED,

        title = "Grout Spark Mine",
        build = "grout_spark_mine",
        combat_strength = 1,
        renown = 1,

        fight_data =
        {
            MAX_HEALTH = 10,
            battle_scale = 0.85,

            death_fade_delay = 0.8,

            status_widget_head_dx = 1.0,
            status_widget_head_dy = 2.5,

            ally_killed_quip = "battle_grout_killed",
            shadow_scale = 0.0, -- Doesn't add a shadow prefab if 0

            OnJoinBattle = GroutJoin,

            StartMoving = GroutMoving,

            UpdateMoving = GroutUpdateMoving,
            ranged_riposte = true,
            attacks = 
            {
                dynamo = table.extend(NPC_BUFF)
                {
                    name = "Dynamo",
                    anim = "taunt",
                    defend_amount = {4,6,8},


			        flags = FLAGS.SKILL | FLAGS.BUFF,
			        target_type = TARGET_TYPE.FRIENDLY,

			        OnPostResolve = function( self, battle, attack )
                        attack:AddCondition( "POWER", 2)
                        attack:AddCondition( "DEFEND", self.defend_amount[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1])
			        end,
                },
                barbed_cover = table.extend(NPC_BUFF)
                {
                    name = "Barbed Cover",
                    anim = "taunt",

                    flags = FLAGS.SKILL,
                    target_type = TARGET_TYPE.SELF,

                    defense_applied = {4,6,6},
                    counter_applied = 4,
                    protect_applied = {1,1,2},

                    OnPostResolve = function( self, battle, attack )
                                self.owner:AddCondition("DEFEND", self.defense_applied[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1], self)
                                self.owner:AddCondition("PROTECT", self.protect_applied[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1], self)
                                self.owner:AddCondition("RIPOSTE", self.counter_applied + self.owner:GetConditionStacks("POWER"), self)
                    end
                },
            },

            behaviour =
            {
                OnActivate = function( self )
                    self.attack = self:MakePicker()
                        :AddID( "barbed_cover", 1 )
                        :AddID( "dynamo", 1 )
                    self:SetPattern( self.Cycle )
                end,

                Cycle = function( self )
                    self.attack:ChooseCard()
                end,

            },
        },
    })
)

--this one gives loot if you kill it
Content.AddCharacterDef
(
    CharacterDef("LOOT_CLUSTER_EGG",
    {
		base_def = "NPC_BASE",
        faction_id = MONSTER_FACTION,
        species = SPECIES.BEAST,
        tags = { "beast", "no_rob", "enforcer" },
        gender = GENDER.UNDISCLOSED,

        title = "Loot Cluster",
        build = "grout_loot",
        combat_strength = 1,
        renown = 1,

        fight_data =
        {
            MAX_HEALTH = 20,
            battle_scale = 0.85,
            
            death_fade_delay = 0.8,
            ally_killed_quip = "battle_grout_killed",

            status_widget_head_dx = 1.0,
            status_widget_head_dy = 2.5,

            shadow_scale = 0.0, -- Doesn't add a shadow prefab if 0
            
            anim_mapping =
            {
                stunned = "idle",
            },

            OnJoinBattle = GroutJoin,

            StartMoving = GroutMoving,

            UpdateMoving = GroutUpdateMoving,

            conditions = 
            {
                run_away_grouts_egg = {
                    name = "Quitter",
                    desc = "Will run away if the Mutated Burr is killed.",
                    icon = "battle/conditions/quitter.tex",
                    event_handlers = 
                    {
                        [ EVENT.FIGHTER_KILLED ] = function( self, fighter )
                            if fighter:GetTeam() and fighter:GetTeam() == self.owner:GetTeam() and fighter.agent:GetContentID() == "BOG_EGG" then
                                self.owner:Flee()
                            end
                        end,
                    },
                },

                osmotic_tissue_condition =
                {
                    name = "Osmotic Tissue",
                    desc = "When this grout dies, insert {osmotic_tissue} into your hand.",
                    hide_gained = true,
                    icon = "battle/conditions/mending.tex",

                    event_handlers =
                    {
                        [ EVENT.STATUS_CHANGED ] = function( self, fighter, status )
                            if status == FIGHT_STATUS.DEAD and fighter == self.owner then
                                self.battle:InsertCard( "osmotic_tissue" )
                            end
                        end,
                    }
                }
            },

            attacks = 
            {
                alluring_visions_egg =
                {
                    name = "Alluring Visions",
                    anim = "taunt",

                    flags = FLAGS.SKILL,
                    target_type = TARGET_TYPE.SELF,
                    num_to_insert = {1,1,2},

                    OnPostResolve = function(self, battle, attack)
                        local cards = {}
                        
                        local num = self.num_to_insert[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1]
                        for i=1, num do
                            local incepted_card = Battle.Card( "alluring_visions", battle:GetPlayerTeam():Primary())
                            incepted_card.source = self.owner
                            --incepted_card.bonus_damage = self.bonus_damage[GetAdvancementModifier( ADVANCEMENT_OPTION.NPC_BOSS_DIFFICULTY ) or 1]
                            table.insert(cards, incepted_card )                                  
                        end
                        
                        battle:Delay( 0.5 )
                        battle:DealCards( cards, battle:GetDiscardDeck() )
                    end,
                },

                osmosis = 
                {
                    name = "Osmosis",
                    anim = "taunt",

                    flags = FLAGS.SKILL,
                    target_type = TARGET_TYPE.SELF,

                    OnPostResolve = function(self, battle, attack)
                        local heath_gained
                        local max_health_gained

                        max_health_gained = 2 + self.owner:GetConditionStacks("POWER")

                        if self.owner:GetHealth() > max_health_gained then
                        heath_gained = max_health_gained
                        else
                        heath_gained = self.owner:GetHealth()
                        end

                        self.owner:DeltaHealth(-heath_gained)

                        for i, fighter in ipairs(self.owner:GetTeam():GetFighters()) do
                            if fighter.agent:GetContentID() == "SPARK_MINE_EGG" then
                                fighter:HealHealth(heath_gained)
                            end
                        end
                        for i, fighter in ipairs(self.owner:GetTeam():GetFighters()) do
                            if fighter.agent:GetContentID() == "KNUCKLE_EGG" then
                                fighter:HealHealth(heath_gained)
                            end
			    	    end    
                    end,
                },
            },

            behaviour =
            {
                OnActivate = function( self )
                    self.attack = self:MakePicker()
                        :AddID( "osmosis", 1 )
                        :AddID( "alluring_visions_egg", 1 )

                    self:SetPattern( self.Cycle )
                    self.fighter:AddCondition( "osmotic_tissue_condition", 1 )
                end,

                Cycle = function( self )
                    self.attack:ChooseCard()
                end,

            },
        },
    })
)