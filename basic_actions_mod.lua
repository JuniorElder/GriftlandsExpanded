local battle_defs = require "battle/battle_defs"
local CARD_FLAGS = battle_defs.CARD_FLAGS
local BATTLE_EVENT = battle_defs.BATTLE_EVENT

local attacks =
{

    corrosive_goo =
    {
        name = "Corrosive Goo",
        desc = "At the end of your turn take 3 damage.",
	    icon = "battle/status_lumin_burn.tex",
        cost = 1,

        played_sound = SoundEvents.battle_status_bleed,

        target_type = TARGET_TYPE.SELF,
        bleed_damage = 3,

        flags =  CARD_FLAGS.STATUS | CARD_FLAGS.EXPEND,

        event_handlers =
        {

        [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
            self:NotifyTriggered()
            self.engine:BroadcastEvent( BATTLE_EVENT.DELAY, 0.25 )
            self.owner:ApplyDamage( self.bleed_damage, nil, nil, nil, {"bleed"} )
        end,
        },
    },
   
    enfeebling_goo =
    {
    	name = "Enfeebling Goo",
    	desc = "Gain 1 {ENFEEBLEMENT} while this is in your hand.",
    	cost = 1,
	    icon = "battle/numbness.tex",
        target_type = TARGET_TYPE.SELF,
    	rarity = CARD_RARITY.UNIQUE,
    	flags = CARD_FLAGS.EXPEND | CARD_FLAGS.STATUS,

        deck_handlers = { DECK_TYPE.DISCARDS, DECK_TYPE.IN_HAND, DECK_TYPE.DRAW},

    	event_handlers =
        {
            [ BATTLE_EVENT.CARD_MOVED ] = function( self, card, source_deck, source_idx, target_deck, target_idx )
                if card == self then
                    if target_deck and target_deck:GetDeckType() == DECK_TYPE.IN_HAND then
                        self.owner:AddCondition( "ENFEEBLEMENT", 1 )

                    elseif source_deck and source_deck:GetDeckType() == DECK_TYPE.IN_HAND then
                        self.owner:RemoveCondition( "ENFEEBLEMENT", 1 )
                    end
                end
            end,
        },
    },

    adherent_goo =
    {
    	name = "Adherent Goo",
    	desc = "Gain 1 {UNBALACED} while this is in your hand.",
    	cost = 1,
	    icon = "battle/robo_kick.tex",
        target_type = TARGET_TYPE.SELF,
    	rarity = CARD_RARITY.UNIQUE,
    	flags = CARD_FLAGS.EXPEND | CARD_FLAGS.STATUS,

        deck_handlers = { DECK_TYPE.DISCARDS, DECK_TYPE.IN_HAND, DECK_TYPE.DRAW},

    	event_handlers =
        {
            [ BATTLE_EVENT.CARD_MOVED ] = function( self, card, source_deck, source_idx, target_deck, target_idx )
                if card == self then
                    if target_deck and target_deck:GetDeckType() == DECK_TYPE.IN_HAND then
                        self.owner:AddCondition( "UNBALACED", 1 )

                    elseif source_deck and source_deck:GetDeckType() == DECK_TYPE.IN_HAND then
                        self.owner:RemoveCondition( "UNBALACED", 1 )
                    end
                end
            end,
        },
    },

    replicating_goo = 
    {
        name = "Replicating Goo",
        desc = "If this card is in your hand at the end of the turn, divide it into 2.",
    	cost = 1,
	    icon = "negotiation/horrible_rash.tex",
        target_type = TARGET_TYPE.SELF,
        flags =  CARD_FLAGS.STATUS | CARD_FLAGS.EXPEND,

        event_handlers =
        {
            [ BATTLE_EVENT.END_PLAYER_TURN ] = function( self, battle )
                self:NotifyTriggered()
                self.engine:BroadcastEvent( BATTLE_EVENT.DELAY, 0.25 )
                battle:ExpendCard(self)
                    local cards = {}
                    for k = 1, 2 do
                        local incepted_card = Battle.Card( "replicating_goo", self.owner) 
                        incepted_card.incepted = true
                        table.insert(cards, incepted_card )                                  
                    end
                    battle:DealCards( cards, battle:GetDiscardDeck() )

                
            end
        }

    },

    
}


for id, data in pairs(attacks) do
    data.cost = data.cost or 0
    data.rarity = data.rarity or CARD_RARITY.UNIQUE
    data.series = CARD_SERIES.GENERAL

    Content.AddBattleCard(id, data)
end

