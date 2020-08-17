
return function(convo)
    convo:GetState("STATE_ASSASSINATION_ATTEMPT")

        :ClearFn()
        :Fn(function(cxt) 
            if cxt:FirstLoop() then
                TheGame:SubmitLog("DAY 2 BOSS")
                cxt.encounter:DoLocationTransition( TheGame:GetGameState():GetLocation("GROG_N_DOG.inn_room") )
                TheGame:GetGameState():GetPlayerAgent():MoveToLocation( TheGame:GetGameState():GetLocation("GROG_N_DOG.inn_room") )
                cxt.enc:GetScreen():ClearHistory()
                cxt.enc:GetScreen():SetBlur(false)
                cxt:Dialog("DIALOG_INTRO")
                
                local boss_def = TheGame:GetGameProfile():GetNoStreakRandom("SAL_DAY_2_BOSS_PICK", {"JAKES_ASSASSIN", "JAKES_ASSASSIN2", "JAKES_GHOST"}, 2)
                local assassin = cxt.quest:CreateSkinnedAgent( boss_def )

                TheGame:GetGameState():AddAgent( assassin )
                assassin:MoveToLocation(cxt.location)
                cxt.enc:SetPrimaryCast(assassin)
                cxt:Dialog("DIALOG_INTRO_2")
            end

            local won_bonuses = {}

            cxt:Opt("OPT_DEMORALIZE")
                :Dialog("DIALOG_DEMORALIZE")
                :Negotiation{
                    on_start_negotiation = function(minigame)
                        local mod = minigame.opponent_negotiator:CreateModifier( "IMPENDING_DOOM", 2 )
                        mod.result_table = won_bonuses

                        local mod = minigame.opponent_negotiator:CreateModifier( "IMPENDING_DOOM", 3 )
                        mod.result_table = won_bonuses

                        local mod = minigame.opponent_negotiator:CreateModifier( "IMPENDING_DOOM", 5 )
                        mod.result_table = won_bonuses
                    end,

                    reason_fn = function(minigame)
                        local total_amt = 0
                        for k,v in pairs(won_bonuses) do
                            total_amt = total_amt + v
                        end
                        return loc.format(cxt:GetLocString("NEGOTIATION_REASON"), total_amt )
                    end,

    
                    on_success = function(cxt) 

                        cxt:Dialog("DIALOG_DEMORALIZED")
                        cxt:Opt("OPT_ATTACK_DEMORALIZED")
                            :Dialog("DIALOG_ATTACK_DEMORALIZED")
                            :Battle{
                                flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.ISOLATED,
                                on_start_battle = function(battle) 
                                    
                                    local total = 0
                                    for k,v in pairs(won_bonuses) do
                                        total = total + v
                                    end

                                    if total > 0 then
                                        for k,v in pairs (battle:GetTeam(TEAM.RED):GetFighters()) do
                                            v:AddCondition("EXISTENTIAL_CRISIS", total)
                                        end
                                    end

                                end,
                                on_win = function(cxt) 
                                    cxt:GoTo(cxt:GetAgent():IsDead() and "STATE_POST_FIGHT_DEAD" or "STATE_POST_FIGHT_ALIVE")
                                end,
                            }
                    end,
                    on_fail = function(cxt)
                        cxt:Dialog("DIALOG_NOT_DEMORALIZED")
                        cxt:Opt("OPT_DEFEND_SELF")
                            :Dialog("DIALOG_ATTACK_NOT_DEMORALIZED")
                            :Battle{
                                flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.ISOLATED,
                                advantage = TEAM.RED,
                                on_win = function(cxt) 
                                    cxt:GoTo(cxt:GetAgent():IsDead() and "STATE_POST_FIGHT_DEAD" or "STATE_POST_FIGHT_ALIVE")
                                end,
                            }

                    end,
                }

            cxt:Opt("OPT_DEFEND_SELF")
                :Battle{
                    flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.ISOLATED,
                    advantage = TEAM.BLUE,
                    -- noncombatants = cxt.quest.param.party_members,
                    on_win = function(cxt) 
                        if cxt:GetAgent():IsDead() then
                            cxt:GoTo("STATE_POST_FIGHT_DEAD")
                        else
                            cxt:GoTo("STATE_POST_FIGHT_ALIVE")
                        end
                    end,
                }
        end)    
end 