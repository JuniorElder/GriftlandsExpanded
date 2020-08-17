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
    convo:GetState("STATE_PRE_FIGHT_BARONS")
        :Loc{
            DIALOG_INTRO = [[
                {FLEAD_QUEEN? 
                * You find the cave entrance. A small detachment of Spark Barons has established a perimeter around it.
                * Unsettling noises occasionally rise up from the depths. The barons respond with blaster fire, and the occasional grenade.
                player:
                    !left
                agent:
                    !right
                    The grifter is here!
                player:
                    !left
                agent:
                    {handler_second} said to expect you. 
                    !overthere
                    The queen is down there. Good luck.
                }

                {BOG_EGG? 
                * You find the cave entrance. A small detachment of Spark Barons has established a perimeter around it.
                * Unsettling noises occasionally rise up from the depths. The barons respond with blaster fire, and the occasional grenade.
                player:
                    !left
                agent:
                    !right
                    The grifter is here!
                player:
                    !left
                agent:
                    {handler_second} said to expect you. 
                    !overthere
                    The infestation source is down there. Good luck.
                }
            ]],
            OPT_ATTACK_THE_QUEEN = "Attack the Boss",
            NEGOTIATION_REASON = "Collect allies and then play the ending card to start the fight!",
            OPT_CONVINCE_HELP = "Convince {agent} to provide backup",
            
            DIALOG_CONVINCE_HELP = [[
                {FLEAD_QUEEN? 
                player:
                    If it's taking all of you to keep the queen pinned down, surely it will take more than just me to destroy it.
                    I need some volunteers to go down with me.
                agent:
                    I don't get paid enough for that. 
                    I might send some of my underlings, if you make a strong enough case.
                }

                {BOG_EGG? 
                player:
                    If it's taking all of you to keep it contained, surely it will take more than just me to destroy it.
                    I need some volunteers to go down with me.
                agent:
                    I don't get paid enough for that. 
                    I might send some of my underlings, if you make a strong enough case.
                }
            ]],
            DIALOG_SUCCESS_NEGOTIATION = [[
                agent:
                    Take the help, and get the job done.
                    I'll be up here covering the exit.
            ]],
            DIALOG_FAIL_NEGOTIATION = [[
                agent:
                    I think I'll keep my forces above ground. There's too much paperwork to fill out if I lose anyone.
            ]],

            DIALOG_ATTACK_QUEEN_ALONE = [[
                * You stride into the cave without the help of the Barons.
                player:
                    !exit
            ]],

            DIALOG_ATTACK_QUEEN_TEAM = [[
                * You rally the volunteers, and head into the cave.
                player:
                    !exit
                agent:
                    Don't get my people killed! 
                    I hate paperwork!
            ]],

        }
        :ClearFn()
        :Fn(PRE_FIGHT_ALTERNATIVE)

    :AskAboutHub("BARON_QUESTIONS_EGG", 
    {
        "Ask {agent} about cave",
        [[
            player:
                What are we up against here?
            agent:
                <i>We</> are up against a hole in the ground.
                <b>You</> are up against a burr infestation.
                And probably the strange source of this mess.
                But you'll do fine, I'm sure.
        ]],
        "Ask for help",
        [[
            player:
                I'm going to need some help clearing the cave.
            agent:
                I think you're misunderstanding the situation here.
                You <b>are</> the help.
                So go and contain this before it can spread, will you?
        ]],

    })    

    :AskAboutHub("BARON_QUESTIONS_FLEAD", 
    {
        "Ask {agent} about cave",
        [[
            player:
                What are we up against here?
            agent:
                <i>We</> are up against a hole in the ground.
                <b>You</> are up against a flead queen.
                And probably a not insubstantial quantity of flead and flead larvae.
                But you'll do fine, I'm sure.
        ]],
        "Ask for help",
        [[
            player:
                I'm going to need some help killing this beast.
            agent:
                I think you're misunderstanding the situation here.
                You <b>are</> the help.
                So go kill the beast, will you?
        ]],

    })  
    end