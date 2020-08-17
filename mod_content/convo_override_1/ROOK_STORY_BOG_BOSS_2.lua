local PRE_FIGHT_ALTERNATIVE = function(cxt)
    local party
    
    if cxt.quest.param.handler_faction == "RISE" then
        party = {"RISE_PAMPHLETEER", "RISE_RADICAL", "RISE_REBEL", "RISE_AUTODOG", "RISE_AUTOMECH"}
    else
        party = {"SPARK_BARON_TASKMASTER", "SPARK_BARON_PROFESSIONAL", "SPARK_BARON_GOON", "AUTODOG", "SPARK_BARON_AUTOMECH"}
    end

    --spawn some rise
    cxt.quest.param.helpers = CreateCombatParty( party, cxt.quest:GetRank(), cxt.location )
    cxt:TalkTo(cxt.quest.param.helpers[1])
    cxt:Dialog("DIALOG_INTRO")

    local fight_allies = {}
    for k,v in ipairs(cxt.quest.param.helpers) do
        if k > 1 then
            table.insert(fight_allies, v)
        end
    end

    cxt:RunLoop(function()
        if cxt.quest.param.FLEAD_QUEEN == true then
            cxt:AskAbout(cxt.quest.param.handler_faction == "RISE" and "RISE_QUESTIONS_FLEAD" or "BARON_QUESTIONS_FLEAD")
            else
            cxt:AskAbout(cxt.quest.param.handler_faction == "RISE" and "RISE_QUESTIONS_EGG" or "BARON_QUESTIONS_EGG")
            end

        cxt:Opt("OPT_CONVINCE_HELP")
            :Dialog("DIALOG_CONVINCE_HELP")
            :Negotiation{
                flags = NEGOTIATION_FLAGS.ALLY_GRAB | NEGOTIATION_FLAGS.NO_CORE_RESOLVE,
                fight_allies = fight_allies,
                reason_txt = cxt:GetLocString("NEGOTIATION_REASON")
            }
                :OnFailure()
                    :Dialog("DIALOG_FAIL_NEGOTIATION")
                :OnSuccess()
                    :Dialog("DIALOG_SUCCESS_NEGOTIATION")
                    :Fn(function(cxt, minigame) 
                        
                        cxt.quest.param.fight_allies = {}
                        for i, modifier in minigame:GetPlayerNegotiator():Modifiers() do
                            if modifier.id == "FIGHT_ALLY_WON" and modifier.ally_agent then
                                table.insert( cxt.quest.param.fight_allies, modifier.ally_agent )
                            end
                        end
                        cxt:Opt("OPT_ATTACK_THE_QUEEN")
                            :Dialog("DIALOG_ATTACK_QUEEN_TEAM")
                            :GoTo("STATE_ATTACK_FLEAD_QUEEN")
                    end)

        cxt:Opt("OPT_ATTACK_THE_QUEEN")
            :Dialog("DIALOG_ATTACK_QUEEN_ALONE")
            :GoTo("STATE_ATTACK_FLEAD_QUEEN")
    end)
end

return function(convo)
    convo:GetState("STATE_ATTACK_FLEAD_QUEEN")
    :Loc{
            
        DIALOG_INTRO = [[
            {FLEAD_QUEEN? 
            player:
                !exit
            right:
                !exit

            * You follow the low, guttural sounds deep into the cave.
            player:
                !left
            * Turning a corner, you find yourself in the queen's brood chamber.
                
            agent:
                !right                    
            player:
                !fight
            * Hundreds of hungry eyes snap to attention as the queen rises on impossibly small wings to meet you.
            }

            {BOG_EGG? 
            player:
                !exit
            right:
                !exit

            * You follow the low, guttural sounds deep into the cave.
            player:
                !left
            * Turning a corner, you find yourself in a chamber covered in fluorescent eggs.
                
            agent:
                !right                    
            player:
                !fight
            * The ground begins to shift under your legs and as you leap back an abnormally large burr emerges from below.
            }
        ]],
        DIALOG_BEAT_FLEAD_QUEEN = [[
            {FLEAD_QUEEN? 
                right:
                    !exit
                * The flead queen collapses in a pile of chitin and ichor.
                player:
                    !exit
                * The stench of it all chases you out of the cave.
            }
            {BOG_EGG? 
                right:
                    !exit
                * The gigantic burr explodes, covering you and the cave in yellow slime.
                player:
                    !exit
                * The stench of it all chases you out of the cave.
            }
        ]],
        
        OPT_ATTACK_THE_QUEEN = "Attack the Boss",

        DIALOG_TALK_TO_HELPER_SOLO_RISE = [[
            {FLEAD_QUEEN? 
            player:
                !left
            agent:
                !right
                You survived that?!
            * {agent} hands a fistful of shills to one of {agent.hisher} underlings.
            agent:
                I lost money on that bet, grifter.
            player:
                Sorry to disappoint you with my competence!
            }

            {BOG_EGG? 
            player:
                !left
            agent:
                !right
                You survived that?!
            * {agent} hands a fistful of shills to one of {agent.hisher} underlings.
            agent:
                I lost money on that bet, grifter.
            player:
                Sorry to disappoint you with my competence!
            }
        ]],
        DIALOG_TALK_TO_HELPER_SOLO_BARONS = [[
            {FLEAD_QUEEN? 
            player:
                !left
            agent:
                !right
                You survived that?!
            * {agent} looks you up and down appraisingly as you wipe the flead ichor off of your metal leg. 
            agent:
                Seems like I underestimated you. 
            player:
                That's alright, I'm used to it.
            }

            {BOG_EGG? 
            player:
                !left
            agent:
                !right
                You survived that?!
            * {agent} looks you up and down appraisingly as you wipe the yellow slime off of your metal leg. 
            agent:
                Seems like I underestimated you. 
            player:
                That's alright, I'm used to it.
            }
        ]],
        DIALOG_TALK_TO_HELPER_SURVIVED_RISE = [[
            {FLEAD_QUEEN? 
            player:
                !left
            agent:
                !right
            * {agent} does a quick headcount as your party emerges from the cave.
            * Satisfied with the result, {agent.heshe} nods to you.
            agent:
                So it's dead, then.
            player:
                It is. And all of your people have been returned to you in one piece.
            agent:
                Good work, grifter. I was right to bet on you.
            }

            {BOG_EGG? 
            player:
                !left
            agent:
                !right
            * {agent} does a quick headcount as your party emerges from the cave.
            * Satisfied with the result, {agent.heshe} nods to you.
            agent:
                So it's destroyed, then.
            player:
                It is. And all of your people have been returned to you in one piece.
            agent:
                Good work, grifter. I was right to bet on you.
            }
        ]],
        DIALOG_TALK_TO_HELPER_SURVIVED_BARONS = [[
            {FLEAD_QUEEN? 
            player:
                !left
            agent:
                !right
            * Back topside, {agent}'s minions reassemble.
            * {agent.HeShe} does a quick roll call, and finding no-one missing, extends their hand to you.
            agent:
                Excellent work, grifter. I couldn't have done it better myself.
            player:
                Truer words you've never spoken.
            }

            {BOG_EGG? 
            player:
                !left
            agent:
                !right
            * Back topside, {agent}'s minions reassemble.
            * {agent.HeShe} does a quick roll call, and finding no-one missing, extends their hand to you.
            agent:
                Excellent work, grifter. I couldn't have done it better myself.
            player:
                Truer words you've never spoken.
            }
        ]],
        DIALOG_TALK_TO_HELPER_DIED_RISE = [[
            {FLEAD_QUEEN? 
            player:
                !left
            agent:
                !right
            * You limp back out of the cave, leaving the bodies of the fallen behind.
            agent:
                What happened down there?
            player:
                The beast is dead.
            agent:
                !angry
                Yeah, but that's not all that's dead. You wasted what I gave you. I won't forget this.
                !exit
            * {agent} storms off in anger.
            }

            {BOG_EGG? 
            player:
                !left
            agent:
                !right
            * You limp back out of the cave, leaving the bodies of the fallen behind.
            agent:
                What happened down there?
            player:
                The source is destroyed.
            agent:
                !angry
                Yeah, but that's not all that's dead. You wasted what I gave you. I won't forget this.
                !exit
            * {agent} storms off in anger.
            }
        ]],
        DIALOG_TALK_TO_HELPER_DIED_BARONS = [[
            {FLEAD_QUEEN? 
            player:
                !left
            agent:
                !right
            * You limp back out of the cave, leaving the bodies of the fallen behind.
            agent:
                Where are my people?
            player:
                There were casualties. 
            agent:
                !angry
                Hesh damn it. Now I have paperwork to fill out. I told you that I hate paperwork!
                !exit
            * {agent} storms off in anger.
            }

            {BOG_EGG? 
            player:
                !left
            agent:
                !right
            * You limp back out of the cave, leaving the bodies of the fallen behind.
            agent:
                Where are my people?
            player:
                There were casualties. 
            agent:
                !angry
                Hesh damn it. Now I have paperwork to fill out. I told you that I hate paperwork!
                !exit
            * {agent} storms off in anger.
            }
        ]],

        DIALOG_HANDLER_TALK_BARONS = [[
            {FLEAD_QUEEN? 
            * {handler_second} arrives on the scene.
            handler_second:
                !right
                You got the job done, grifter.
                I am thankful. 
                But I will be watching. If the rumors of your dalliance with the Rise turn out to be more than rumors, I will be forced to execute you.
            player:
                !dubious
                You're welcome?
            handler_second:
                !give
                But I am getting ahead of myself. Here, take this as a token of our working relationship.
            }

            {BOG_EGG? 
            * {handler_second} arrives on the scene.
            handler_second:
                !right
                You got the job done, grifter.
                I am thankful. 
                But I will be watching. If the rumors of your dalliance with the Rise turn out to be more than rumors, I will be forced to execute you.
            player:
                !dubious
                You're welcome?
            handler_second:
                !give
                But I am getting ahead of myself. Here, take this as a token of our working relationship.
            }
        ]],
        DIALOG_HANDLER_TALK_BARONS_2 = [[
            {FLEAD_QUEEN? 
            player:
                Much appreciated.
            handler_second:
                Don't let it go to waste.
                !exit
            * {handler_second} leaves, leaving the rest of the Barons to clean up the mess.
            }

            {BOG_EGG? 
            player:
                Much appreciated.
            handler_second:
                Don't let it go to waste.
                !exit
            * {handler_second} leaves, leaving the rest of the Barons to clean up the mess.
            }
        ]],
        DIALOG_HANDLER_TALK_RISE = [[
            {FLEAD_QUEEN? 
            * {handler_second} arrives on the scene.
            handler_second:
                !right
                It's dead?
            player:
                It is.
            handler_second:
                And you are not.
                That is good, I guess.
                But if I find out that you <i>are</> working with the Barons, I will gut you myself.
            player:
                That's... Charming.
            handler_second:
                !give
                I forget my manners. You helped me help the Rise, so I owe you something. Here, take this.
                }

                {BOG_EGG? 
                * {handler_second} arrives on the scene.
                handler_second:
                    !right
                    It's destroyed?
                player:
                    It is.
                handler_second:
                    And you are not.
                    That is good, I guess.
                    But if I find out that you <i>are</> working with the Barons, I will gut you myself.
                player:
                    That's... Charming.
                handler_second:
                    !give
                    I forget my manners. You helped me help the Rise, so I owe you something. Here, take this.
                    }
        ]],
        DIALOG_HANDLER_TALK_RISE_2 = [[
            {FLEAD_QUEEN? 
            player:
                !happy
                That's surprisingly generous of you, {handler_second}. Are you warming up to me?
            handler_second:
                Don't make me tear it out of you again.
                !exit
            * {handler_second} leaves, leaving the rest of the Rise to clean up the mess.
            }

            {BOG_EGG? 
            player:
                !happy
                That's surprisingly generous of you, {handler_second}. Are you warming up to me?
            handler_second:
                Don't make me tear it out of you again.
                !exit
            * {handler_second} leaves, leaving the rest of the Rise to clean up the mess.
            }
        ]],

    }
        :ClearFn()
        :Fn(function(cxt)

            cxt.encounter:DoLocationTransition( cxt.quest:GetCastMember("flead_queen_lair") )

            local boss

            if cxt.quest.param.BOG_EGG == true then boss = TheGame:GetGameState():AddAgent(Agent("BOG_EGG"))
            else boss = TheGame:GetGameState():AddAgent(Agent("FLEAD_QUEEN"))
            end

            cxt:TalkTo(boss)

            cxt:Dialog("DIALOG_INTRO")
                
            cxt:Opt("OPT_ATTACK_THE_QUEEN")
                :Battle{ 
                    allies = cxt.quest.param.fight_allies,
                    flags = BATTLE_FLAGS.BOSS_FIGHT | BATTLE_FLAGS.NO_BURRS,
                }    
                :OnWin()
                    :Fn(function() 
                        local had_allies = cxt.quest.param.fight_allies and #cxt.quest.param.fight_allies > 0
                        local all_allies_survived = true
                        if had_allies then
                            for k,v in ipairs(cxt.quest.param.fight_allies) do
                                if v:IsDead() and v:IsSentient() then
                                    all_allies_survived = false
                                    break
                                end
                            end
                        end
                        cxt:Dialog("DIALOG_BEAT_FLEAD_QUEEN")
                        cxt.encounter:DoLocationTransition( cxt.quest:GetCastMember("flead_queen_staging") )
                        cxt:TalkTo(cxt.quest.param.helpers[1])
                        if not had_allies then
                            cxt:Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_TALK_TO_HELPER_SOLO_RISE" or "DIALOG_TALK_TO_HELPER_SOLO_BARONS")
                        elseif all_allies_survived then
                            cxt:Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_TALK_TO_HELPER_SURVIVED_RISE" or "DIALOG_TALK_TO_HELPER_SURVIVED_BARONS")
                        else
                            cxt:Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_TALK_TO_HELPER_DIED_RISE" or "DIALOG_TALK_TO_HELPER_DIED_BARONS")
                            cxt:GetAgent():OpinionEvent(cxt.quest:GetQuestDef():GetOpinionEvent("got_their_people_killed"))
                        end
                        
                        cxt:GetCastMember("handler_second"):MoveToLocation(cxt.location) 
                        cxt:Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_HANDLER_TALK_RISE" or "DIALOG_HANDLER_TALK_BARONS")
                        cxt:GetAgent():OpinionEvent(cxt.quest:GetQuestDef():GetOpinionEvent("dealt_with_a_monster"))
                    end)
                    
                    :Fn(function()  ConvoUtil.GiveGraftChoice(cxt, RewardUtil.GetGrafts(2, 3)) end)
                    :Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_HANDLER_TALK_RISE_2" or "DIALOG_HANDLER_TALK_BARONS_2")

                    :CompleteQuest()
                    :Travel()
        end)
    end