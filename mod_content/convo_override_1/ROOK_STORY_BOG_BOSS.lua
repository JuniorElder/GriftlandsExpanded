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
    convo:GetState("CONFRONT")
    :Loc{
            
        DIALOG_INTRO_RISE = [[
            * {agent} emerges from the back of the bar.
            agent:
                !right
                Grifter, over here. I have a task for you.
            player:
                !left
                Last I checked, my employer is {rise_contact}, not you.
            agent:
                Last <i>I</> checked, folks say you've been working with the Barons between jobs for {rise_contact}.
                Now {rise_contact} is very busy, so I doubt {rise_contact.heshe}'s heard the same rumors that I have.
                !cruel
                Yet.
            *** {agent} is on to your double-act, and is shaking you down.
        ]],

        DIALOG_RISE_FLEAD = [[
            {FLEAD_QUEEN? 
            player:
                So what is it you want?
            agent:
                I need a mess cleaned up.
                We bought some flead eggs from the Spree in Murder Bay. The plan was to slow down the Baron dig sites with the bugs. 
                Treat the workers right, the bugs don't show up, and the quotas get filled.
            player:
                !dubious
                You <i>willingly</> introduced fleads to the Bog?
            agent:
                Turns out one of those eggs was a queen.
                !shrug
                Honest mistake.
                But now I need it dead before the Barons find it.
                They'll call in the big guns if they need to deal with it, and I don't want to face those big guns afterwards.
            }

            {BOG_EGG? 
            player:
                So what is it you want?
            agent:
                I need a mess cleaned up.
                We bought some flead eggs from the Spree in Murder Bay. The plan was to slow down the Baron dig sites with the bugs. 
                Treat the workers right, the bugs don't show up, and the quotas get filled.
            player:
                !dubious
                You <i>willingly</> introduced fleads to the Bog?
            agent:
                Turns out one of those wasn't a flead.
                !shrug
                We decided that the Barons would have to deal with whatever's inside instead of us.
                But it started to attract burrs and I need it taken care of before it attracts too much attention.
                They'll call in the big guns if they need to deal with it, and I don't want to face those big guns afterward.
            }

        ]],

        DIALOG_INTRO_SPARK = [[
            * {agent} emerges from the back of the bar.
            agent:
                !right
                Grifter. We have reason to speak.
            player:
                !left
                We do?
            agent:
                I have heard disquieting rumors that you have been less than forthright in your dealings with {baron_contact}.
            player:
                !happy
                Rumors are like birds, always flying about. I wouldn't pay them any-
            agent:
                Drop the act, grifter. I am immune to your folksy charms. I put out inquiries about you and I know all about your past.
                I know who you are, and what you've done.
            *** {agent} is on to your double-act, and is shaking you down.
        ]],

        DIALOG_SPARK_FLEAD = [[
            {FLEAD_QUEEN? 
            player:
                !cruel
                You might know what I've done. But you have no idea what I can do.
                !happy
                I do respect an honest shakedown, though. 
                !neutral
                What is it you need done?
            agent:
                One of our dig sites has been experiencing disruptions. Fleads have been attacking the workers.
                We thought we had it under control, but the last attack revealed the source - a queen.
                I want you to go eradicate the problem. Quietly. I don't want to panic the workers and give them any more of an excuse to shirk their duty.
            }

            {BOG_EGG? 
            player:
                !cruel
                You might know what I've done. But you have no idea what I can do.
                !happy
                I do respect an honest shakedown, though. 
                !neutral
                What is it you need done?
            agent:
                One of our dig sites has been experiencing disruptions. Burrs have started appearing inside and attacking workers.
                We started an investigation, since the site is mostly isolated from the Bog and found the presumed source.
                There is a strong power source emitting from a cave, completely infested with burrs.
                I want you to go eradicate the problem. Quietly. I don't want to panic the workers and give them any more of an excuse to shirk their duty.
            }
        ]],
        
        DIALOG_SETOUT_RISE = [[
            {FLEAD_QUEEN? 
            player:
                I suppose I don't have much choice in the matter, do I?
            agent:
                Ha! You know the score!
                There's some of our brothers and sisters keeping the flead at bay at the site.
                Maybe they'll help you. But probably not.
                I'll find you when it's over.
            }

            {BOG_EGG? 
            player:
                I suppose I don't have much choice in the matter, do I?
            agent:
                Ha! You know the score!
                There are some of our brothers and sisters trying to contain it at the site.
                Maybe they'll help you. But probably not.
                I'll find you when it's over.
            }
        ]],
        
        DIALOG_SETOUT_SPARK = [[
            {FLEAD_QUEEN? 
            player:
                I'll do it, but only because I have to.
            agent:
                We have a containment team at the location. Meet with them, and they will show you how to access the queen.
                I will find you when the task is completed.
            }

            {BOG_EGG? 
            player:
                I'll do it, but only because I have to.
            agent:
                We have a containment team at the location. Meet with them, and they will show you how to access the cave.
                I will find you when the task is completed.
            }
        ]],

        OPT_SET_OUT = "Set out for the bog",
    }
    :ClearFn()
    :Fn(function(cxt)
            
        local boss_def = TheGame:GetGameProfile():GetNoStreakRandom("ROOK_DAY_1_BOSS_PICK", {"FLEAD_QUEEN", "BOG_EGG"}, 2)

        if boss_def == "FLEAD_QUEEN" then cxt.quest.param.FLEAD_QUEEN = true end
        if boss_def == "BOG_EGG" then cxt.quest.param.BOG_EGG = true end

        cxt:GetCastMember("handler_second"):MoveToLocation(cxt.location)
        cxt:TalkTo("handler_second")
        cxt:Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_INTRO_RISE" or "DIALOG_INTRO_SPARK")
        
        
        cxt:Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_RISE_FLEAD" or "DIALOG_SPARK_FLEAD")

        
        cxt:RunLoop(function()
            
            if cxt.quest.param.FLEAD_QUEEN == true then
            cxt:AskAbout(cxt.quest.param.handler_faction == "RISE" and "RISE_QUESTIONS_FLEAD" or "BARON_QUESTIONS_FLEAD")
            else
            cxt:AskAbout(cxt.quest.param.handler_faction == "RISE" and "RISE_QUESTIONS_EGG" or "BARON_QUESTIONS_EGG")
            end

            cxt:Opt("OPT_SET_OUT")
                :Dialog(cxt.quest.param.handler_faction == "RISE" and "DIALOG_SETOUT_RISE" or "DIALOG_SETOUT_SPARK")  
                :Fn(function() cxt:GetAgent():MoveToLimbo() end)
                :CompleteQuest("introduction")
                :End()
        end)

    end)

    :AskAboutHub("RISE_QUESTIONS_EGG", 
    {

        "Ask {agent} about the egg",
        [[
            player:
                Do you know what did the egg look like?
            agent:
                !shrug
                No idea. Like an egg? 
                !shrug
                That doesn't mater, it'll probably stop causing trouble if you shoot it enough.
            player:
                Very enlightening, thanks.
        ]],
        "Ask about the flead plan",
        [[
            player:
                Flead are nasty. Why would you endanger your own people with those eggs?
            agent:
                We gave the workers warning. The only folks in real danger were the Baron extermination squads.
                And now you, I guess.
        ]],

    })

    :AskAboutHub("BARON_QUESTIONS_EGG", 
    {

        "Ask {agent} about the infestation",
        [[
            player:
                What are we dealing with, exactly?
            agent:
                There is a cave filled with burrs and there's something that lures them here.
                I would expect that the source is significantly more dangerous than the burrs.
                We don't know what it looks like. Nobody at the worksite has been able to tell us.
        ]],
        "Ask why are grouts coming here",
        [[
            player:
                Burrs don't show up this far from the bog. Why would they suddenly do this?
            agent:
                The Rise are nothing if not resourceful. 
                They lure all kinds of wildlife here to disrupt our mining operations.
        ]],

    })

    end

    