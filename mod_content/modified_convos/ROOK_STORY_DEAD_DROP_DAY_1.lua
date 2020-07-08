

return function(convo)
    convo:GetState("CONFRONT")
    :Loc{
        DIALOG_INTRO = [[
            * You arrive at the dead drop. It's much like all the others around Havaria: empty, but full of anticipation. 
            player:
                !left
                !neutral_notepad
            * You jot down a few notes about the Rise and the Spark Barons, and shove the wax envelope into the sealed canister.
            * If you were any less experienced, you wouldn't notice the sudden silence as someone approaches behind you.
        ]],
        DIALOG_CONFRONTATION = [[
            {RENTORIAN_BOSS? 
                player:
                    Strange place for a walk, isn't it?
                agent:
                    !right
                    $happyCocky
                    Why, it's a well-worn trail. If you know how to find it. 
                    !cruel
                    Should've watched your back more carefully, "Rook". 
                    You made too many enemies to just quietly fade away.
                player:
                    Ah. 
                    !dubious
                    And that includes you, I suppose? You seemed happy enough when I was paying you for Rentorian secrets.
                agent:
                    Well, that's the problem, isn't it? You have too good a memory. Someone needs to wipe it clean.
                    $angryCruel
                    Besides, look at you. A bum leg. No pension, no friends. 
                    !throatcut
                    Maybe you should <i>let</i> me put you down. 
            }
            {HESH_BOSS?
                player: 
                    You're well out of the shallows, Heshian.
                    !dubious
                    If you're looking for the Cult's secrets, I'm retired. I don't trade in those anymore.
                agent:
                    !right
                    No? Secrets are the only things the heretics here accept as currency. 
                player:
                    Is that why you've followed me here? It has nothing to do with you, {agent}. 
                    $miscPersuasive
                    !overthere
                    Remember the old times, hm? Our memories are all our masters let us keep for ourselves.
                * You say the words, but you know {agent} too well to hold any real hope that {agent.heshe}'d neglect {agent.hisher} duty.
            }

            {ADMIRALTY_OPERATIVE?
                player: 
                    Grout Bog isn't a place for Admiralty agents.
                agent:
                    !right
                    $miscMocking
                    Rook, I am surprised you don't remember me.
                    I had assumed you would remember people you betrayed. 
                player:
                    !dubious
                    It is all coming back to me.
                    You oversaw the infiltration of the Hesh radicals, right?
                agent:
                    $angryCruel
                    Do you also remember that when you switched sides you caused the death of four of my agents?
                    Or is that so insignificant to even remember?
                    The only thing that saved you back then was the importance of your success in the eyes of the Admiralty.
                    !throatcut
                    * Well, that certainly won't save you now.
            }
        ]],
        DIALOG_DEFEND = [[
            {RENTORIAN_BOSS? 
                player:
                    $neutralResigned
                    Let's just begin, shall we?
            }

            {HESH_BOSS?
                player:
                    $neutralResigned
                    Let's just begin, shall we?
            }

            {ADMIRALTY_OPERATIVE?
            player:
                $neutralResigned
                Let's just begin, shall we?
        }
        ]],
        OPT_DEMORALIZE = "Intimidate {agent}",
        DIALOG_DEMORALIZE = [[
            {RENTORIAN_BOSS? 
                player:
                    That's just wishful thinking on your part, you know.
            }
            {HESH_BOSS? 
                player:
                    There was a time when we could find common ground, even in the darkest days.
            }

            {ADMIRALTY_OPERATIVE? 
            player:
                They knew what they were getting into.
        }
        ]],
        NEGOTIATION_REASON = "Gain advantage in battle and apply 1 {battle.DEFECT} to {1} for each {negotiation.FEAR} you destroy! ({2} so far)",
        DIALOG_DEMORALIZED = [[
            {RENTORIAN_BOSS? 
                player:
                    You might recall that time in Palketti, when you swore you'd never look at flayed oshnu the same again.
                    I can do that to your insides. You know I can.
                agent:
                    Y-you... you're bluffing! 
                    It's just me and your trigger finger, and I know which one of us is faster. 
            }
            {HESH_BOSS?
                player:
                    I seem to remember the time you let a heretic slip through your fingers with a holy relic.
                    Who helped you then, old friend? Your god? Or me?
                agent:
                    You're only dragging out the inevitable. I wish you wouldn't.
            }
            
            {ADMIRALTY_OPERATIVE?
            player:
                $miscPersuasive
                Imagine how many people would die later had we not succeeded.
                However tragic it may be, we prevented a bigger tragedy.
                agent:
                $angryCruel
                Stop trying to sound like the good guy, it won't change the past.
        }
        ]],
        DIALOG_NOT_DEMORALIZED = [[
            {RENTORIAN_BOSS? 
                player:
                    Why, the bushes hide a dozen men, each of them trained to fire on my command.
                agent:
                    I think that's the senility talking. 
                    Pathetic. This is a long time coming, I'm afraid.   
            }
            {HESH_BOSS?
                player:
                    Would you really do me in now, {agent}? Just because I happen to be in Spark Baron territory?
                agent:
                    As if anything you do is just by chance. 
                    You're here for a reason, I'm sure of it. And I can't let it happen. 
            }

            {ADMIRALTY_OPERATIVE?
            player:
                $miscMocking
                Their sacrifice was necessary for the operation.
            agent:
                I will not let you write their deaths off as an unavoidable consequence.
        }
        ]],
        --change player:
        OPT_ATTACK_DEMORALIZED = "Attack {agent} in their moment of doubt",

        DIALOG_ATTACK_DEMORALIZED = [[
            {RENTORIAN_BOSS? 
                player:
                    !fight
                    $neutralWhatever
                    As you like. 
            }
            
            {HESH_BOSS?
                player:
                    !fight
                    $neutralWhatever
                    As you like. 
            }

            {ADMIRALTY_OPERATIVE?
            player:
                !fight
                $neutralWhatever
                As you like. 
        }
        ]],

        OPT_DEFEND_SELF = "Defend yourself",
        DIALOG_ATTACK_NOT_DEMORALIZED = [[
            player:
                !fight
        ]]
    }
        :ClearFn()
        :Fn(function(cxt) 
            
            local boss_def_alternative = TheGame:GetGameProfile():GetNoStreakRandom("ROOK_DAY_1_BOSS_PICK", {"HESH_BOSS", "RENTORIAN_BOSS", "ADMIRALTY_OPERATIVE"}, 2)
            cxt.quest.param[boss_def_alternative] = true
            
            if cxt.quest.param.HESH_BOSS == true then cxt.quest.param.HESH_BOSS_alternative = true end
            if cxt.quest.param.RENTORIAN_BOSS == true then cxt.quest.param.RENTORIAN_BOSS_alternative = true end
            if cxt.quest.param.ADMIRALTY_OPERATIVE == true then cxt.quest.param.ADMIRALTY_OPERATIVE_alternative = true end

            if not cxt.quest.param.HESH_BOSS_alternative and not cxt.quest.param.RENTORIAN_BOSS_alternative and not cxt.quest.param.ADMIRALTY_OPERATIVE_alternative then
                cxt.quest.param.RENTORIAN_BOSS_alternative = true
            end

            cxt:Dialog("DIALOG_INTRO")
            local boss_def_alternative
            if cxt.quest.param.HESH_BOSS_alternative then
                boss_def_alternative = "HESH_BOSS"
            end
            if cxt.quest.param.RENTORIAN_BOSS_alternative then
                boss_def_alternative = "RENTORIAN_BOSS"
            end
            if cxt.quest.param.ADMIRALTY_OPERATIVE_alternative then
                boss_def_alternative = "ADMIRALTY_OPERATIVE"
            end

            
            local rentorian = cxt.quest:CreateSkinnedAgent( boss_def_alternative )
            TheGame:GetGameState():AddAgent( rentorian )
            cxt.enc:SetPrimaryCast(rentorian)
            cxt:Dialog("DIALOG_CONFRONTATION")

            local won_bonuses = {}

            cxt:Opt("OPT_DEMORALIZE")
                :Dialog("DIALOG_DEMORALIZE")
                :Negotiation{
                    on_start_negotiation = function(minigame)
                        local mod = minigame.opponent_negotiator:CreateModifier("FEAR")
                        mod.result_table = won_bonuses
                    end,

                    reason_fn = function(minigame)
                        local total_amt = table.sum( won_bonuses )
                        return loc.format(cxt:GetLocString("NEGOTIATION_REASON"), minigame:GetOpponent():GetName(), total_amt )
                    end,

    
                    on_success = function(cxt) 
                        cxt:Dialog("DIALOG_DEMORALIZED")
                        cxt:Opt("OPT_ATTACK_DEMORALIZED")
                            :Dialog("DIALOG_ATTACK_DEMORALIZED")
                            :Battle{
                                flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.ISOLATED,
                                advantage = TEAM.BLUE,
                                on_start_battle = function(battle) 
                                    local total = table.sum( won_bonuses )
                                    if total > 0 then
                                        battle:GetTeam( TEAM.RED ):Primary():AddCondition( "DEFECT", total )
                                    end

                                end,
                                on_win = function(cxt) 
                                    cxt:GoTo("STATE_POST_FIGHT")
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
                                    cxt:GoTo("STATE_POST_FIGHT")
                                end,
                            }

                    end,
                }

            cxt:Opt("OPT_DEFEND_SELF")
                :Dialog("DIALOG_DEFEND")
                :Battle{
                    flags = BATTLE_FLAGS.SELF_DEFENCE | BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.ISOLATED,
                    on_win = function(cxt) 
                        cxt:GoTo("STATE_POST_FIGHT")
                    end,
                }

        end)

end