 --------------------------------------------------------------------------
---[[""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""]]---
--[[       madra: a library of desktop actions, written in lua          ]]--
--[[  Copyright © 2017 cupantae - Mark O'Neill - cupantae@uineill.net   ]]--
---[[__________________________________________________________________]]---
 --------------------------------------------------------------------------

                            ------------------
                         --[[  MODULE TABLE  ]]--
                            ------------------

local madra = {}

                      -------------------------------
                   --[[  DEFINITIONS AND LIBRARIES  ]]--
                      -------------------------------

dofile("madra.def")
local lfs   = require  ("lfs")
local posix = require ("posix")


                          ----------------------
                       --[[  GLOBAL VARIABLES  ]]--
                          ----------------------

global = {}
      -- Madra is to be run by the user, for now. Having a UID of 0 (root)
      --   should invoke very different behaviour.
      --        It should also work like a daemon, being aware of other
      --     instances and taking appropriate action (notification?), and
      --    being aware of available information (and only update as needed)

      -- Data relevant to a given shell is to be stored within
      -- that shell's environment, not here (directory, effective uid...).

 -- The initial values are unlikely choices, so that they'll show up in debugging.
global.HOME  = "/"
global.SHELL = "/exe/macos"
global.OS    = "unknown"
global.UID   = "9999"
global.USER  = "whocares"


                        ----------------------------
                     --[[  TABLES OF USABLE STUFF  ]]--
                        ----------------------------
 
action    = {}
token     = {}
protocol  = {}

 
                          ------------------------
                       --[[  ACTION DEFINITIONS  ]]--
                          ------------------------
 
   --[[  FILE MANAGEMENT  ]]--
 --[[ Change directory ]]--
function madra.cd ( location )

    global.HOME = madra.gethome()
    locstring = madra.gathertostring ( location )
    locstring = locstring:gsub("~", global.HOME)

    if locstring == "" then
        locstring = global.HOME
    --else locstring = WORKINGDIR .. lo
    end
    dirstring = tostring( locstring )
    changed = lfs.chdir( dirstring )
    if changed == true then
        return EXIT_SUCCESS
    else return EXIT_FAILURE
    end
end
action.cd = madra.cd


 --[[ List directory contents ]]--
function madra.ls ( location )
    locstring = madra.gathertostring ( location )
    if locstring == "" then locstring = "." end
    
    global.HOME = madra.gethome()
    locstring = locstring:gsub("~", global.HOME)

    iter, dir_obj = lfs.dir( locstring )

    io.write("Showing contents of " .. locstring )

    name = ""
    while name ~= nil do
        name = dir_obj:next()
        if type(name) == "string" then
            io.write(name .. "\n")
        end
    end
    io.write("  === DONE ===\n\n")
    return EXIT_SUCCESS
end
action.ls = madra.ls


 --[[ Run commands directly, not read by any shell ]]--
function madra.run (binary, ...)
    binstring = tostring(binary)
    args = {...}

    io.write("  ***  Executing this file:  ***\n".. binstring .."\n\n")

    if args ~= nil then
        io.write("  with these " .. #args .. " arguments:\n")
        for k,v in pairs(args) do
            print(k,v)
        end
    end
    posix.exec (binstring, args)
end
action.run = madra.run
token["!"] = action.run

 --[[ Run commands through the shell ]]--
function madra.shellexec (command)
    cmdstring = madra.gathertostring(command)
    io.write("  ***  Executing this command in ".. global.SHELL ..":  ***\n" .. cmdstring ..  "\n\n")
    os.execute(cmdstring)
end
action.shell = madra.shellexec
token["$"] = action.shell


 --[[ Search using any search term -based "engine" ]]--
function madra.search (enginestring, ...)
    efunc = engine[enginestring]
    if efunc ~= nil then
        return efunc()
    else
        io.write("I don't know that search engine.\n")
        return EXIT_FAILURE
    end
end
action.search = madra.search
token["?"] = action.search

 --[[ Find files and objects among your data ]]--
function madra.find (path, ...)
    terms = {...}
    cmdstring = madra.gathertostring (BINfind .. " " .. path .. " " .. terms)
    os.execute(cmdstring)
end
action.find = madra.find
token["/"] = action.find

                               ----------------------
                            --[[  HELPER FUNCTIONS  ]]--
                               ----------------------

   --[[  STRING/TABLE CONVERSION  ]]--
 --[[ Split a string into a table of its words ]]--
function madra.strsplit (string)
    stringlist = {}
    for word in string:gmatch ( "%S+" ) do  -- = length-1-or-more strings of non-space
            table.insert(stringlist, word)
    end
    return stringlist
end

 --[[ Gather all elements of a table, in order, into a string ]]--
function madra.gathertostring (object)
    typeo = type(object)                -- what type is the object
    if typeo == "string" then           -- string? then we're done
        return object
    elseif typeo == "table" then        -- table? then...
        if #object > 1 then
            firstobject = table.remove(object, 1)       -- break into first and rest.
            return madra.gathertostring(firstobject) .. ' ' .. madra.gathertostring(object)
        elseif #object == 1 then
            return madra.gathertostring(object[1])
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


   --[[  OBJECT INSPECTION  ]]--
 --[[ Identify the type of a given string ]]--
function madra.understand ( object )
 --returns:
    obtype = ""
    props = {}

    obstring = madra.gathertostring ( object )
    obsplit  = madra.strsplit ( obstring )
    if #obsplit > 1 then
        io.write("The object contains spaces.")
    end
    if obsplit[1]:sub(1,1) == "/" then
        obtype = "localpath"
        props = madra.getfileprops(obstring)
    else
        protocol = obstring:match( "%w+://" )    -- alphanumerics and ://
        if protocol ~= nil then
            protocol = protocol:gsub("://", "")    -- remove :
            if protocol == "file" then
                obstring = obstring:gsub('file://', '', 1) --remove first
                obtype = "localpath"
                props = madra.getfileprops (obstring)
              -- ..more protocols.. --
            end
        else

        end
    end

    return obtype, props

end


function madra.getfileprops ( obstring )
  -- is it a symlink?
    properties = {}
    properties.attributes = lfs.symlinkattributes ( obstring )
    if properties.attributes == nil then
        properties.exists = false
    else
        properties.exists = true
        if properties.attributes.mode == "link" then
            properties.symlink    = true
            properties.attributes = lfs.attributes ( obstring )
        else
            properties.symlink    = false
        end

      -- find attributes:
        if properties.attributes.mode == "directory" then
            properties.filetype = "dir"
        elseif properties.attributes.mode == "block device" then
            properties.filetype = "blockdev"
        elseif properties.attributes.mode == "char device" then
            properties.filetype = "chardev"
           -- ...more filetypes... --
        else
            madra.run(BINfile, obstring)
        end
    end

    return properties
end


   --[[  SYSTEM DETAILS  ]]--
 --[[ Find out the hostname of the computer ]]--
function madra.gethostname()
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
function madra.gethome()
    envhome = os.getenv("HOME")
    if envhome ~= nil then
        return envhome
    else
        namehome = "/home/" .. USER
        UID = madra.getuid()
        diratts = lfs.attributes (namehome)
        if diratts == UID then
            return namehome
        end
    end
    io.write("Never returned a home")
    return EXIT_FAILURE
end

 --[[ Find out the user's UID ]]--
function madra.getuid()
    return posix.getuid()
end
    

   --[[  MADRA ACTIONS  ]]--
 --[[ Reload madra / this file ]]--
function madra.reload ()
    package.loaded.madra = nil
    madra = require "madra"
end

--[[    for when needed:
function madra.makeaction ( keyword, callback )
    a = {}
    a.str = keyword
    a.cb  = callback
end
  ]]--

               ----------
            --[[  MAIN  ]]--
               ----------

  --[[  DEFINITIONS, FILES, CHOICES  ]]--
HOSTNAME = madra.gethostname()

return madra
