-------------------------------------------------
---[["""""""""""""""""""""""""""""""""""""""]]---
--[[      LAGOM: THE CHILLED-OUT SHELL       ]]--
---[[_______________________________________]]---
-------------------------------------------------

local lfs = require ( "lfs" )

dofile("madra.lua")


function promptloop ()
    actfunc = nil            --> The function run in this cycle

 --[[ Getting details to display the prompt ]]--
    USER = os.getenv("USER")
    HOSTNAME = gethostname()
    PWD = lfs.currentdir()            --> or os.getenv("PWD") -- ? Probably better to take
    TIME = os.date(datefmt)           -- \->  lua's word for it than some external process.
    infostr = "\n" .. BGreen .. USER
                   .. White  .. "@"
                   .. Green .. HOSTNAME
                   .. Blue .. " [" .. PWD .. "] "
                   .. BWhite .. TIME  .. "\n"
    prompt_whole = infostr .. Colour_Off .. lagompromptfmt
    io.write(prompt_whole)

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
--[[    initial = cmdstring:sub (1,1)      --> first letter is a token (?)
    if token[initial] ~= nil then
        cmdstring = cmdstring:sub(2)
        args = strsplit (cmdstring)
        return token[initial], cmdstring
    else
        args = strsplit (cmdstring)
        if action[args[1]]             --[[               ~= nil then
            actfunc = table.remove (args, 1)    --> first word is command
            --args = cmdlist
            return actfunc, args
        end
    end
]]
    initial = cmdstring:sub (1,1)      --> first letter
    if token[initial] ~= nil then
        args = cmdstring:sub(2)
        return token[initial], args             -- args is string (!!)
    else
        args = strsplit (cmdstring)
        if action[args[1]] ~= nil then
            actfunc = table.remove (args, 1)
            return actfunc, args                -- args is table
        end
    end
        --if action [ cmdlist[1] ] ~= nil then
          --  args = cmdlist

end


   --------------
--[[	MAIN	]]--
   --------------

while str ~= "quit" do 
	str = promptloop()
end

io.write("Thanks for using my shell. Goodbye!")
