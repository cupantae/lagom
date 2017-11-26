 -------------------------------------------------------------------------
---[["""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""]]---
--[[         lagom: "the chilled-out shell", written in lua            ]]--
--[[  Copyright © 2017 cupantae - Mark O'Neill - cupantae@uineill.net  ]]--
---[[_________________________________________________________________]]---
 -------------------------------------------------------------------------


                      -------------------------------
                   --[[  DEFINITIONS AND LIBRARIES  ]]--
                      -------------------------------

dofile("madra.lua")
local lfs = require ( "lfs" )
local posix = require ("posix")

                   --------------------------------------
                --[[  GLOBAL VARIABLES (TO THIS SHELL)  ]]--
                   --------------------------------------
 -- The initial values are unlikely choices, so that they'll show up in debugging.
HOME       = "/"
HOSTNAME   = "unlikelyhostname"
UID        = "9999"
USER       = "whocares"
WORKINGDIR = "/"

                                ----------
                             --[[  MAIN  ]]--
                                ----------

function main()
    while str ~= "quit" do 
            str = promptloop()
    end
    io.write("Thanks for using my shell. Goodbye!")
    return EXIT_SUCCESS
end

function promptloop ()
    actfunc = nil            --> The function run in this cycle

 --[[ Getting details to display the prompt ]]--
    USER = os.getenv("USER")
    HOSTNAME = gethostname()
    WORKINGDIR = lfs.currentdir()            --> or os.getenv("PWD") -- ? Probably better to take
    TIME = os.date(datefmt)           -- \->  lua's word for it than some external process.
    infostr = "\n" .. BGreen .. USER
                   .. White  .. "@"
                   .. Green .. HOSTNAME
                   .. Blue .. " [" .. WORKINGDIR .. "] "
                   .. BWhite .. TIME  .. "\n"
    prompt_whole = infostr .. Colour_Off .. lagompromptfmt
    io.write(prompt_whole)

    cmdstring = io.read()

    actfunc, args = cmdparser ( cmdstring )

    if type(actfunc) == "function" then
        actfunc(args)
    end
end

 --[[ Turning the input into a table of strings, running the result. ]]--
function cmdparser ( cmdstring )
    cmdlist = strsplit (cmdstring)
    if #cmdlist == 0 then
        return nil
    else
        initial = cmdlist[1]:sub(1,1)               -- If the first letter...
        if token[initial] ~= nil then               --  ..is a "token" like !,?,$,#
            cmdlist[1] = cmdlist[1]:sub(2)          --   ..then remove the token..
            args = cmdlist
            return token[initial], args             --    ..and execute its action.
        elseif action[cmdlist[1]] ~= nil then
            actstr = table.remove (cmdlist, 1)
            actfunc = action[actstr]
            args = cmdlist
            return actfunc, args                    -- args is a table (!!)
        end
    end

end


   ---------------------------
--[[  CALLING THE WHOLE LOT  ]]--
   ---------------------------

main()
