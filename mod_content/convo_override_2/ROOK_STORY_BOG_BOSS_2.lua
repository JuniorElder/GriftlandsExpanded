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
    convo:GetState("STATE_PRE_FIGHT_RISE")
    :Loc{
            
        DIALOG_INTRO = [[
            {FLEAD_QUEEN? 
            * You find some Rise members guarding the entrance to a small cave.
            * Unsettling noises occasionally rise up from its mouth, to which the Rise responds by blindly firing shots into the darkness.
            player:
                !left
            agent:
                !right
                Are you the relief?
                Oh Hesh am I glad to see you. We're running low on ammo, and the thing down there's getting angrier.
            }

            {BOG_EGG? 
            * You find some Rise members guarding the entrance to a small cave.
            * Unsettling noises occasionally rise up from its mouth, to which the Rise responds by blindly firing shots into the darkness.
            player:
                !left
            agent:
                !right
                Are you the relief?
                Oh Hesh am I glad to see you. We're running low on ammo, and the things down there are getting restless.
            }
        ]],
        OPT_ATTACK_THE_QUEEN = "Attack the Boss",
        NEGOTIATION_REASON = "Collect allies and then play the ending card to start the fight!",
        OPT_CONVINCE_HELP = "Convince {agent} to spare some fighters",
        DIALOG_CONVINCE_HELP = [[
            {FLEAD_QUEEN? 
            player:
                I'm going to take down that queen, but I need backup.
            agent:
                Whoa, now - we didn't sign up for that.
            }

            {BOG_EGG? 
            player:
                I'm going to get rid of the source, but I need backup.
            agent:
                Whoa, now - we didn't sign up for that.
            }
        ]],
        DIALOG_SUCCESS_NEGOTIATION = [[
            agent:
                Fine, I can spare some fighters.
                But <b>I'm</> not going down there.
        ]],
        DIALOG_FAIL_NEGOTIATION = [[
            agent:
                No way. Our job is up here. You go do yours.
        ]],

        DIALOG_ATTACK_QUEEN_ALONE = [[
            * You head into the cave without the help of the Rise.
            player:
                !exit
            agent:
                !cruel
                Good luck in there!
        ]],

        DIALOG_ATTACK_QUEEN_TEAM = [[
            * You signal to the 'volunteers', and head into the cave.
            player:
                !exit
            agent:
                Good luck in there!
        ]],
        }
        :ClearFn()
        :Fn(PRE_FIGHT_ALTERNATIVE)


:AskAboutHub("RISE_QUESTIONS_EGG", 
{

    "Ask {agent} about cave",
    [[
        player:
            What's down there?
        agent:
            The cave's completely infested with burrs.
            !shrug
            Whatever's drawing them here is hiding inside, preparing to kill anyone who steps in.
            It's good that you are going down there for us.
    ]],
    "Ask for help",
    [[
        player:
            Are you going to provide backup?
        agent:
            Of course.
            !laugh
            I'm going to be "back up" here!
            !neutral                
            Seriously, though. I am <b>not</> going in that cave.
    ]],

})

:AskAboutHub("RISE_QUESTIONS_FLEAD", 
{

    "Ask {agent} about cave",
    [[
        player:
            What's down there?
        agent:
            We were told it's a Flead queen.
            !shrug
            Whatever it is, it's big. And mean.
            You're going to take care of it for us, right?
    ]],
    "Ask for help",
    [[
        player:
            Are you going to provide backup?
        agent:
            Of course.
            !laugh
            I'm going to be "back up" here!
            !neutral                
            Seriously, though. I am <b>not</> going in that cave.
    ]],

})
    end