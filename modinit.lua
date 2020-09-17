MountModData( "GriftlandsExpanded" )

local function OnLoad()
    local self_dir = "GriftlandsExpanded:mod_content/"
    local LOAD_FILE_ORDER =
    {
        -- COMPLEMENTARY CARDS AND DEFINITIONS
        "basic_negotiation_mod",
        "basic_actions_mod",
        "battle_conditions_mod",
        "items_mod",
        -- SAl CARDS
        "sal_negotiation_mod",
        "sal_battle_mod",
        -- ROOK CARDS
        "rook_negotiation_mod",
        "rook_battle_mod",
        --"sal_battle_grafts_mod",
        --"sal_negotiation_grafts_mod",
        -- CUSTOM BOSSES
        "sal_boss_1_mod",
        "sal_boss_2_mod",
        "sal_boss_3_mod",

        "rook_boss_1_mod",
        "rook_boss_2_bog_mod",
        -- QUESTS, CONVOS
        "convo_override_1",
        "convo_override_2",
        "convo_override_3",
    }
    for k, filepath in ipairs(LOAD_FILE_ORDER) do
        require(self_dir .. filepath)
    end
end

return {
    version = "0.4.1",
    alias = "GriftlandsExpanded",  --path for files
    OnLoad = OnLoad,
    title = "Griftlands Expanded",
    previewImagePath = "placeholder.png",
    description_file = "GriftlandsExpanded:steam_description.txt",
}