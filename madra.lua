 --------------------------------------------------------------------------
---[[""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""]]---
--[[       madra: a library of desktop actions, written in lua          ]]--
--[[  Copyright © 2017 cupantae - Mark O'Neill - cupantae@uineill.net   ]]--
---[[__________________________________________________________________]]---
 --------------------------------------------------------------------------


           --[[  GLOBALS  ]]--
UID = "9999"
HOME = "/"

---> definitions and libraries
dofile("madra.def")
local lfs   = require  ("lfs")
local posix = require ("posix")

--[[ something about tables & packages..? ]]--

      --[[  ACTIONS AND TOKENS  ]]--
action = {}
token = {}

 --[[ Change directory ]]--
function MAcd ( location )
    if location == nil then
        location = gethome()
    end
    dirstring = tostring( location )
    changed = lfs.chdir( dirstring )
    if changed == true then
        return EXIT_SUCCESS
    else return EXIT_FAILURE
    end
end
action.cd = MAcd


 --[[ Run commands through the shell ]]--
function MAshell (command)
   -- necessary? :
    cmdstring = gathertostring(command)
    io.write("  ***  Executing this command:  ***\n" .. cmdstring ..  "\n\n")
    os.execute(cmdstring)
end
action.shell = MAshell
token["$"] = action.shell


 --[[ Search using any search term -based "engine" ]]--
function MAsearch (enginestring, ...)
    efunc = engine[enginestring]
    if efunc ~= nil then
        return efunc()
    else
        io.write("I don't know that search engine.\n")
        return EXIT_FAILURE
    end
end
action.search = MAsearch
token["?"] = action.search

 --[[ Find files and objects among your data ]]--
function MAfind (path, ...)
    terms = {...}
    cmdstring = gathertostring (BINfind .. " " .. path .. " " .. terms)
    os.execute(cmdstring)
end
action.find = MAfind
token["/"] = action.find


        --[[  HELPER FUNCTIONS  ]]--

 --[[ Split a string into a table of its words ]]--
function strsplit (string)
    stringlist = {}
    for word in string:gmatch ( "%S+" ) do  -- = length-1-or-more strings of non-space
            table.insert(stringlist, word)
    end
    return stringlist
end

 --[[ Gather all elements of a table, in order, into a string ]]--
function gathertostring (object)
    typeo = type(object)                -- what type is the object
    if typeo == "string" then           -- string? then we're done
        return object
    elseif typeo == "table" then        -- table? then...
        if #object > 1 then
            firstobject = table.remove(object, 1)       -- break into first and rest.
            return gathertostring(firstobject) .. ' ' .. gathertostring(object)
        elseif #object == 1 then
            return gathertostring(object[1])
        elseif #object == 0 then
            return ""
        else
            io.write("\n\nThe object has " .. tostring(#object) .. "entries!\n\tBarmy!!\n\n")
            return EXIT_FAILURE
        end
    else                                -- PLEASE LET ME KNOW if there's any
        return tostring(object)         -- other data type I should worry about!!
    end
end

function makeaction ( keyword, callback )
    a = {}
    a.str = keyword
    a.cb  = callback
end

 --[[ Find out the hostname of the computer ]]--
function gethostname()
    hnfile = io.open("/etc/hostname", "r")
    if hnfile ~= nil then
        hostname = tostring ( hnfile:read() )
        if hostname ~= nil and hostname ~= "" then
            return hostname
        end
  --[[  else
            tmpstring = os.tmpfile()
            tmpf = io.open(tmpf, "w")
            io.output =  tmpf
            os.execute("hostname")
            hostname = tostring ( tmpf:read() )
            if hostname ~= nil and hostname ~= "" then
                return hostname
            end
        end ]]
    end
end

 --[[ Find out where the home folder is ]]--
function gethome()
    envhome = os.getenv("HOME")
    if envhome ~= nil then
        return envhome
    else
        namehome = "/home/" .. USER
        UID = getuid()
        diratts = lfs.attributes (namehome)
        if diratts == UID then
            return namehome
        end
    end
    io.write("Never returned a home")
    return EXIT_FAILURE
end

 --[[ Find out the user's UID ]]--
function getuid()
    return posix.getuid()
end
    

  --[[  MISCELLANEOUS TEST FUNCTIONS  ]]--
function halp (object)
    typeo = type(object)
    if typeo == "table" then
        print("  k", "type(k)", "  v", "type(v)")
        for k,v in pairs(object) do
            typev = type(v)
            print( k, type(k), v, typev)
            if typev == table then
                print("\n\nContents of \"" .. v .. "\"..\n")
                halp(v)
            --elseif function ..?
            end
        end
    else print(object)
    end
end

               ----------
            --[[  MAIN  ]]--
               ----------

  --[[  DEFINITIONS, FILES, CHOICES  ]]--
HOSTNAME = gethostname()

