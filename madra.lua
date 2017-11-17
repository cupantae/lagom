----[[   madra library   ]]--
--
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
            stringlist:insert (word)
    end
    return stringlist
end

 --[[ Gather all elements of a table, in order, into a string ]]--
function gathertostring (object)
    typeo = type(object)
    rstring = ""
       -- space out terms:
    if rstring ~= "" then rstring = rstring .. " " end
    typev = type(v)
    if typeo == "string" then
        rstring = rstring .. object
    elseif typeo == "number" then
        rstring = rstring .. tostring(object)
    elseif typeo == "table" then
        for k,v in pairs(object) do
            rstring = rstring .. gathertostring(v)
        end
    else io.write(object .. " is a " .. typeo .. "\n")
    end

    return rstring
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
        namehome = "/home/" .. USER
        UID = getuid()
        diratts = lfs.attributes (namehome)
        if diratts == UID then
            return namehome
        end
    end
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

