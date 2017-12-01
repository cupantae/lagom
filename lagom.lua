 -------------------------------------------------------------------------
---[["""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""]]---
--[[         lagom: "the chilled-out shell", written in lua            ]]--
--[[  Copyright © 2017 cupantae - Mark O'Neill - cupantae@uineill.net  ]]--
---[[_________________________________________________________________]]---
 -------------------------------------------------------------------------

                            ------------------
                         --[[  MODULE TABLE  ]]--
                            ------------------

local lagom = {}


                      -------------------------------
                   --[[  DEFINITIONS AND LIBRARIES  ]]--
                      -------------------------------

INTROTEXT = "   Welcome to lagom, the chilled-out shell.\nCopyright © 2017 cupantae - Mark O'Neill - cupantae@uineill.net\n\n"
local madra = require ("madra")
local lfs   = require ("lfs")
local posix = require ("posix")

                       -----------------------------
                    --[[  ENVIRONMENTAL VARIABLES  ]]--
                       -----------------------------
env = {}
 -- The initial values are unlikely choices, so that they'll show up in debugging.
env.HOME        = "/"
env.HOSTNAME    = "unlikelyhostname"
env.MODE        = ""
env.SHELL       = "/exe/macos"
env.UID         = "9999"
env.USER        = "whocares"
env.WORKINGDIR  = "/"

Laction         = {}            --> additional actions for lagom
--[[action = Maction --[[
for cmd,func in pairs(Maction) do
    action[cmd] = Maction[func]    -- copy the madra actions in
end ]]--

                                ----------
                             --[[  MAIN  ]]--
                                ----------

function main()
    lagom.init()
    while str ~= "quit" do 
            str = lagom.promptloop()
    end
    io.write("Thanks for using my shell. Goodbye!\n")
    return EXIT_SUCCESS
end

function lagom.init ()
    io.write(INTROTEXT)
    env.HOME        = madra.gethome()
    env.HOSTNAME    = madra.gethostname()
    env.MODE        = ""
    env.SHELL       = madra.getshell()
    env.UID         = madra.getuid()
    env.USER        = madra.getuser()
    env.WORKINGDIR  = lfs.currentdir()
end

function lagom.promptloop ()
    actfunc = nil            --> The function run in this cycle

 --[[ Getting details to display the prompt ]]--
    env.USER = os.getenv("USER")
    env.HOSTNAME = madra.gethostname()
    env.WORKINGDIR = lfs.currentdir()     --> or os.getenv("PWD") -- ? Probably better to take
    env.TIME = os.date(datefmt)           -- \->  lua's word for it than some external process.
    infostr = "\n" .. BGreen .. env.USER
                   .. White  .. "@"
                   .. Green .. env.HOSTNAME
                   .. Blue .. " [" .. env.WORKINGDIR .. "] "
                   .. BWhite .. env.TIME  .. "\n"
    prompt_whole = infostr .. Colour_Off .. env.MODE .. lagompromptfmt
    io.write(prompt_whole)

    cmdstring = io.read()

    actfunc, args = lagom.newparser ( cmdstring )

    aftype = type(actfunc)
    if aftype  == "function" then
        status = actfunc(args)
    elseif aftype == "number" then      --> error code
        io.write("I don't know what you mean.\n")
    end

    if status == "quit" then
        return "quit"
    end
end

function lagom.newparser ( cmdstring )
 --returns:
    actfunc = nil
  --rest = "string"
  
    if cmdstring == nil then            --> only happens on Ctrl-D
        return lagom.quit("eof")
    elseif ( type(cmdstring) == "string" ) then
        if env.MODE == "" then
            leader, rest = madra.firstoff ( cmdstring )
            if leader == nil then           --> no command given
                return nil
            else           --> have been given something.
                initial = leader:sub(1,1)               --> If the first letter...
                if token[initial] ~= nil then           -- ..is a "token" like !,?,$,#
                    rest = leader:sub(2) .. " " .. rest --  ..add the first word to the rest
                    actfunc = token[initial]
                elseif Laction[leader] ~= nil then      --> if the leader is a lagom action
                    actfunc = Laction[leader]
                    if actfunc == Laction.quit then
                        rest = "quit"
                    end
                elseif action[leader] ~= nil then       --> if the leader is an action
                    actfunc = action[leader]
                else
                    ltype, lprops = madra.understand( leader )
                    if  lprops.exists == true then
                        return action.view, rest
                    end
                end
                if actfunc ~= nil and (rest == nil or rest == "") and mode[leader] == true then
                   env.MODE = leader
                   actfunc = nil
                end
            end
        else
            rest = madra.gathertostring( madra.strsplit(cmdstring) )
            if cmdstring ~= "" then
                actfunc = action[env.MODE]
            end
        end
    end
  --  io.write( tostring(actfunc) .. tostring(rest) )    -->   debug
    return actfunc, rest             --    ..and execute token's action.
end

 --[[ Turning the input into a table of strings, running the result. ]]--
 --[[
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
        elseif action[cmdlist[1]]--[[ ~= nil then
            actstr = table.remove (cmdlist, 1)
            actfunc = action[actstr]
            args = cmdlist
            return actfunc, args                    -- args is a table (!!)
        else --return EXIT_DONTKNOW

        end
    end

end
 ]]--

 --[[ This function should understand the command even if a synonym (within
     reason and without ambiguity) OR if a substring of it is given.
  These two things might be a bit in opposition of each other, and for the
    substring, I might have to store the actions differently.
        For now, only the full action name given in the table will do.
function lagom.understandaction ( actstring ) 
end ]]--

function lagom.quit( exitstring )
    if env.MODE == "" then              --> actually quit
        if exitstring == "quit" then
            io.write("\n   ===========================\n   === Quit by user action ===\n   ===========================\n\n")
        elseif exitstring == "eof" then
            io.write("\n   =====================================\n   === End-of-File or Ctrl-D reached ===\n   =====================================\n\n")
        end
        return "quit"
    else
        env.MODE = ""                   --> exit that mode
        return nil                 -- and take no further action
    end
end
Laction.quit = lagom.quit


   ---------------------------
--[[  CALLING THE WHOLE LOT  ]]--
   ---------------------------

main()
