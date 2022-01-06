local cdefs = include( "client_defs" )
local rig_util = include( "gameplay/rig_util" )
local talkinghead_ingame = include( "client/fe/talkinghead_ingame" )

--by Cyberboy2000

local oldShowLine = talkinghead_ingame.ShowLine

function talkinghead_ingame:ShowLine(idx)
    -- The placeholder is here because it's a lazy way to make the delay apply to the last line in a script (the Halt function is called from multiple places so we don't want to alter it)
    if not self.script[#self.script].placeHolder then
        table.insert( self.script, { placeHolder = true } )
    end
    
    if self.ismainframefn() then
        -- You can add additional delay or wait conditions here
        while self.ismainframefn() do
            coroutine.yield()
        end

        rig_util.wait( (self.script[idx].timing or 5) * cdefs.SECONDS)
    end
    
    if self.script[idx].placeHolder then
        -- This runs after the final line has been played
        table.remove(self.script)
        
        self:Halt()
        return
    end
    
    oldShowLine(self, idx)
end
