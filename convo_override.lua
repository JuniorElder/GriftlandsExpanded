-- MIT License

-- Copyright (c) 2020 RageLeague

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local filepath = require "util/filepath"

-- The location of the folder which contains the modified convo options
-- Each file under there must have the same name as the id of the convo that will be modified
-- Each file returns a function that has 1 parameter: the convo object associated with the id.
-- Example: See SAL_STORY_FSSHCAKES.lua
local CONVO_DIR = "JuniorElderExpandedMod:mod_content/modified_convos"

----------------------------------------------------------------------------------------
-- Additional methods for the convo class. This is useful for modifying existing states.
----------------------------------------------------------------------------------------

-- Get an existing state of the convo
function Convo:GetState(id)
    self.default_state = self.states[id]
    return self
end

-- Clear all functions under this convo
function Convo:ClearFn()
    assert(self.default_state, "NO STATE PUSHED")
    self.default_state.fns = {}
    return self
end

for k, filepath in ipairs( filepath.list_files( CONVO_DIR, "*.lua", true )) do -- ConvoId isnt same as file name, check through debug screen in campaign. Second convo should have _2 after file name, 1 is skiped. Probably.
    local name = filepath:match( "(.+)[.]lua$" )
    print(name)
    if name then
        local id = filepath:match("([^/]+)[.]lua$")
        print(id)
        local convos = Content.GetConvoStateGraph(id)
        local fn = require(name)
        fn(convos)
    end
end
-- for id, fn in pairs(CONVO_OVERRIDE) do
--     local convos = Content.GetConvoStateGraph(id)
--     fn(convos)
-- end 