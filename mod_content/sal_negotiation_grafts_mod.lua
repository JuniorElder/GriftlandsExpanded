local negotiation_defs = require "negotiation/negotiation_defs"
local EVENT = negotiation_defs.EVENT
local CARD_FLAGS = negotiation_defs.CARD_FLAGS


local NEGOTIATION_GRAFTS =
{
    sacoactive_orbslug = 
    {
        name = "Coactive Orbslug",
        desc = "Whenever you gain {INFLUENCE}, deal 2 damage to a random enemy argument.",

        rarity = CARD_RARITY.BOSS,

        damage = 2,

        negotiation_modifier =
        {
            hidden = true,
            
            target_enemy = TARGET_ANY_RESOLVE,
            min_persuasion = 2,
            max_persuasion = 2,

            event_handlers =
            {
                [ EVENT.MODIFIER_CHANGED ] = function( self, modifier, delta, clone )
                    if delta and delta < 0 and modifier.negotiator == self.negotiator and modifier.id == "INFLUENCE" then
                        self.min_persuasion = self.graft:GetDef().damage
                        self.max_persuasion = self.graft:GetDef().damage
                        self:ApplyPersuasion()
                    end
                end,            
            },
        },
    },

    sacoactive_orbslug_plus =
    {
        name = "Boosted Coactive Orbslug",
        desc = "Whenever you gain {INFLUENCE}, deal <#UPGRADE>3</> damage to a random enemy argument.",
        damage = 3,
    },
}

---------------------------------------------------------------------------------------------

for i, id, graft in sorted_pairs( NEGOTIATION_GRAFTS ) do
    graft.card_defs = negotiation_defs
    graft.series = "SAL"
    
    if graft.negotiation_modifier and graft.negotiation_modifier.modifier_type == nil then
        graft.negotiation_modifier.modifier_type = MODIFIER_TYPE.HIDDEN
    end
    graft.type = GRAFT_TYPE.NEGOTIATION
    Content.AddGraft( id, graft )
end
