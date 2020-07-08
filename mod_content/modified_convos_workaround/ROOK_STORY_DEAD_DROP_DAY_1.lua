

return function(convo)
    convo:GetState("STATE_POST_FIGHT")
    :Loc{
        DIALOG_WON_FIGHT = [[
            {RENTORIAN_BOSS?
                agent:
                    !injured
                player:
                    $miscMocking
                    Well, there you have it. Seems very little has changed.
                    But what am I to do with you now?
                agent:
                    $scaredFearful
                    N-nothing. I'll leave the way I came. The bog will cover my tracks behind me.
                    Nobody has to know I was here, and I won't mention you to anyone. 
            }
            {HESH_BOSS?
                agent:
                    !injured
                player:
                    !shrug
                    Come now, old friend. Surely this has gone on long enough.
                agent:
                    If I walk away now, it's to Hesh's judgment.
                    Surely you know that's worse than whatever fate you could deal me.
            }
            {ADMIRALTY_OPERATIVE?
                agent:
                    !injured
                player:
                    !shrug
                    Well, you failed to get your vengeance.
                    Maybe it is time to accept the past and move on?
                agent:
                    $scaredFearful
                    If I can't make you pay someone else will.
                    I will disappear and wait patiently for your death.
            }
        ]],
        OPT_LET_GO = "Let {agent} go",
        OPT_FINISH_OFF = "Finish {agent} off",
        DIALOG_FINISH_OFF = [[
            {RENTORIAN_BOSS?
                player:
                    $neutralResigned
                    Alas, I wish I could believe you, old friend.
                    But your memory is also too good. And I'd just rather be forgotten. 
                agent:
                    !exit
                * It's a quick pull of the trigger to finish {agent.himher} off, and easy work to drag the body into the brush. The scavengers will do the rest.
            }
            {HESH_BOSS?
                player:
                    $neutralResigned
                    Yes, I suppose that's true. 
                    Consider this a small mercy, then. 
                agent:
                    !exit
                * It's a quick pull of the trigger to finish {agent.himher} off, and easy work to drag the body into the brush. The scavengers will do the rest.
            }
            {ADMIRALTY_OPERATIVE?
            player:
                $neutralResigned
                Since forgetting isn't an option, you give me no choice. 
                Let's get this over with. 
            agent:
                !exit
            * It's a quick pull of the trigger to finish {agent.himher} off, and easy work to drag the body into the brush. The scavengers will do the rest.
        }

        ]],
        DIALOG_LET_GO = [[
            {RENTORIAN_BOSS? 
                player:
                    $angrySeething
                    Next time you come wondering what I'm up to, remember the usual rewards that await a curious cat. 
                agent:
                    $scaredFearful
                    J-just talk normal, you damn old coot. 
                    But fine, I get the picture. See you never—you can be sure of that. 
                    !exit
            }
            {HESH_BOSS ?
                player:
                    I suppose so. But that will at least be of your own making.
                    May you keep to the shallows, as much as you're able.
                agent:
                    !exit
                * {agent} disappears into the trees, dragged along by the will of {agent.hisher} god.
            }
            {ADMIRALTY_OPERATIVE ?
                player:
                    !shrug
                    You wouldn't be the first one to do so.
                    Get out of sight, before you pass out.
                agent:
                !exit
                * {agent} disappears hastily, leaving a trail of blood behind her. 
            }   
        ]],
        DIALOG_KILLED_BOSS = [[
            {RENTORIAN_BOSS?
                * That problem's dealt with. But if one shadow tracked you down, there may well be others.  
            }
            {HESH_BOSS?
                * That problem's dealt with. But if one shadow tracked you down, there may well be others.  
            }
            {ADMIRALTY_OPERATIVE?
            * That problem's dealt with. But if one shadow tracked you down, there may well be others.  
        }
        ]],
    }
    :ClearFn()
    :Fn(function(cxt) 
        if cxt:FirstLoop() then
            if cxt:GetAgent():IsDead() then
                cxt:Dialog("DIALOG_KILLED_BOSS")
                cxt.quest:Complete()
                StateGraphUtil.AddLeaveLocation(cxt)
            else
                cxt:Dialog("DIALOG_WON_FIGHT")
            end
        end

        if not cxt:GetAgent():IsDead() then
            
            if cxt.quest.param.HESH_BOSS_alternative then
                cxt:AskAbout("STATE_QUESTIONS_HESH")    
            end
                
            if cxt.quest.param.RENTORIAN_BOSS_alternative then
                cxt:AskAbout("STATE_QUESTIONS_RENTORIAN")    
            end

            if cxt.quest.param.ADMIRALTY_OPERATIVE_alternative then
                cxt:AskAbout("STATE_QUESTIONS_OPERATIVE")    
            end
                
            cxt:Opt("OPT_FINISH_OFF")
                :Dialog("DIALOG_FINISH_OFF")
                :Fn(function() 
                    local death_item = cxt:GetAgent():GetDeathItem()
                    cxt:GainCards{death_item}
                    cxt:GetAgent():Kill()
                    cxt.quest:Complete()
                end)
                :Travel()
            
            cxt:Opt("OPT_LET_GO")
                :Dialog("DIALOG_LET_GO")
                :Fn(function() 
                    cxt:GetAgent():Retire()
                    cxt.quest:Complete()
                end)
                :Travel()
        end
    end)

:AskAboutHub("STATE_QUESTIONS_OPERATIVE", 
{

    "Ask how {agent.title} found you",
    [[
        player:
            $neutralDubious
            Tell me, how <i>did</i> you know I was here?
        agent:
            !dubious
            $neutralDubious
            You were only a shadow on the Rentorian side of the border. Once you came back, you were followed by paperwork.
            Took a while to figure out who you were working for <i>now</i>, but once I did...
            Well, they sure like to get their reports, don't they?
        player:
            ...
    ]],
})

end