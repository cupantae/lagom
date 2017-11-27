 -------------------------------------------------------------------------
---[["""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""]]---
--[[         lagom: "the chilled-out shell", written in lua            ]]--
--[[  Copyright © 2017 cupantae - Mark O'Neill - cupantae@uineill.net  ]]--
---[[_________________________________________________________________]]---
 -------------------------------------------------------------------------


                      -------------------------------
                   --[[  DEFINITIONS AND LIBRARIES  ]]--
                      -------------------------------

local madra = require ("madra")
local lfs   = require ("lfs")
local posix = require ("posix")

                       -----------------------------
                    --[[  ENVIRONMENTAL VARIABLES  ]]--
                       -----------------------------
env = {}
 -- The initial values are unlikely choices, so that they'll show up in debugging.
env.HOME       = "/"
env.HOSTNAME   = "unlikelyhostname"
env.UID        = "9999"
env.USER       = "whocares"
env.WORKINGDIR = "/"

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
    env.USER = os.getenv("USER")
    env.HOSTNAME = madra.gethostname()
    env.WORKINGDIR = lfs.currentdir()            --> or os.getenv("PWD") -- ? Probably better to take
    env.TIME = os.date(datefmt)           -- \->  lua's word for it than some external process.
    infostr = "\n" .. BGreen .. env.USER
                   .. White  .. "@"
                   .. Green .. env.HOSTNAME
                   .. Blue .. " [" .. env.WORKINGDIR .. "] "
                   .. BWhite .. env.TIME  .. "\n"
    prompt_whole = infostr .. Colour_Off .. lagompromptfmt
    io.write(prompt_whole)

    cmdstring = io.read()

    actfunc, args = cmdparser ( cmdstring )

    if type(actfunc) == "function" then
        actfunc(args)
    elseif type(actfunc) == "number" then
        io.write("I don't know what you mean.\n")
    end
end

 --[[ Turning the input into a table of strings, running the result. ]]--
function cmdparser ( cmdstring )
 --returns:
    actfunc = nil
    args = {}

    cmdlist = madra.strsplit (cmdstring)
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
        else return EXIT_DONTKNOW
        end
    end

end

 --[[ This function should understand the command even if a synonym (within
     reason and without ambiguity) OR if a substring of it is given.
  These two things might be a bit in opposition of each other, and for the
    substring, I might have to store the actions differently.
        For now, only the full action name given in the table will do. ]]--
function understandaction ( actstring ) 
end

   ---------------------------
--[[  CALLING THE WHOLE LOT  ]]--
   ---------------------------

main()
