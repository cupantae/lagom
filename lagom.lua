-------------------------------------------------
---[["""""""""""""""""""""""""""""""""""""""]]---
--[[      LAGOM: THE CHILLED-OUT SHELL       ]]--
---[[_______________________________________]]---
-------------------------------------------------

local lfs = require ( "lfs" )

dofile("madra.lua")

PWD = lfs.currentdir()
-- or os.getenv("PWD")

USER = os.getenv("USER")


  ---	PROMPT   ---
datestring = "%X, %a %d %b"

--# Prompts
--PS1="\n\[$BGreen\]\u\[$White\]@\[$Green\]\h \[$Blue\][\w] \[$BWhite\]\t\n\[$Yellow\]\!  \[$Colour_Off\]\$ "
--PS2="> "

infostr = "\n" .. BGreen .. USER
               .. White  .. "@"
               .. Green .. HOSTNAME
               .. Blue .. " [" .. PWD .. "] "
               .. BWhite .. os.date(datestring) .. "\n"
promptstr = infostr .. Colour_Off .. "» "

function makeaction ( keyword, callback )
    a = {}
    a.str = keyword
    a.cb  = callback
end

function prompt ()
    io.write(promptstr)

    cmdstring = io.read()
--[[	commandstring = tostring (command)	]]-- I don't think this will ever be needed.

--	bagowords = strsplit ( commandstring )
--[[	io.write ( "bagowords is a ".. tostring (type(bagowords)) .. "\n...OK?")
	io.read()	]]-- debug

    actfunc, args = cmdparser ( cmdstring )

    if type(actfunc) == "function" then
        actfunc(args)
    end
end

function cmdparser ( cmdstring )

    i = 1
  --  Tokens let us make directed commands like shell commands and web searches
    initial = cmdstring:sub (1,1)      --> first letter
    if token[initial] ~= nil then
        args = cmdstring:sub(2)
        return token[initial], args
    else
        cmdlist = strsplit (cmdstring)
        if action[cmdlist[1]] ~= nil then
            actfunc = table.remove (cmdlist, 1)
            args = cmdlist
            return actfunc, args
        end
    end
        --if action [ cmdlist[1] ] ~= nil then
          --  args = cmdlist

end



actions = {}


   --------------
--[[	MAIN	]]--
   --------------

while str ~= "quit" do 
	str = prompt()
end
