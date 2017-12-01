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
global.HOME     = "/"
global.HOSTNAME = "nohost"
global.OS       = "unknown"
global.UID      = "9999"
global.USER     = "whocares"


                        ----------------------------
                     --[[  TABLES OF USABLE STUFF  ]]--
                        ----------------------------
 
action    = {}  --> actions the user can run
token     = {}  --> single character abbreviations of the above
mode      = {}  --> string name of mode for a given action

protocol  = {}  --> the protocols madra recognises
filetype  = {}  --> the filetypes madra recognises
 
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
mode.cd = false
action.cd  = madra.cd

madra.go  = madra.cd
mode.go = true
action.go  = madra.go
token["="] = action.go

 --[[ Find files and objects among your data ]]--
function madra.find (path, ...)
    terms = {...}
    cmdstring = madra.gathertostring (BINfind .. " " .. path .. " " .. terms)
    os.execute(cmdstring)
end
mode.find = true
action.find = madra.find
token["/"] = action.find

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
mode.ls = false
action.ls = madra.ls

-- aliases:
action.list = madra.ls
mode.list = mode.ls

 --[[ Make new directory/-ies ]]--
function madra.mkdir ( path )
 --TODO: Make this work; make madra.parentdir
    success, errstr, errcode = lfs.mkdir ( path )
    if success == true then
        return EXIT_SUCCESS
    elseif errcode == 2 then
        madra.mkdir ( madra.parentdir ( path ) )
    end
end
mode.mkdir = true
action.mkdir = madra.mkdir

 --[[ Run commands directly, not read by any shell ]]--
--function madra.run (binary, ...)
function madra.run ( obstring )
    binstring, rest = madra.firstoff( obstring )

    --binstring = tostring(binary)
    --args = {...}

    io.write("  ***  Executing this file:  ***\n".. binstring .."\n\n")

    if args ~= nil then
        args = strsplit( obstring )
        io.write("  with these " .. #args .. " arguments:\n")
        for k,v in pairs(args) do
            print(k,v)
        end
    end
    posix.exec (binstring, args)
end
mode.run = true
action.run = madra.run
token["!"] = action.run

 --[[ Find out what's going on right now ]]--
--function madra.status ( path )

  --  io.write(" == MADRA STATUS ==\n")

 --[[ Run commands through the shell ]]--
function madra.shellexec (command)
    SHELL = madra.getshell()
    cmdstring = madra.gathertostring(command)
    io.write("  ***  Executing this command in ".. SHELL ..":  ***\n" .. cmdstring ..  "\n\n")
    os.execute(cmdstring)
end
mode.shell = true
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
mode.search = true
action.search = madra.search
token["?"] = action.search

 --[[ View object(s) and actions about it/them ]]--
function madra.view ( obstring )
    obtype, obprops = madra.understand(obstring)
    if obprops.exists == true then
        io.write(obstring)
    end
end
mode.view = false
action.view = madra.view
token["@"] = action.view


                               ----------------------
                            --[[  HELPER FUNCTIONS  ]]--
                               ----------------------
  
   --[[  BASIC MADRA FUNCTIONS  ]]--
 --[[ Initialize the system (for this user and program) ]]--
function madra.init ( system )
    if type(system) ~= string or system == "" or system == "madra" then
         io.write("madra")
    end
end

    

   --[[  STRING MANIPULATION  ]]--
 --[[ Pop off the first word; return it and the rest ]]--
function madra.firstoff ( obstring )
    firstword = obstring:match ( "%S+" )                     --> first collection of non-spaces.
    if firstword == nil then
        return nil
    else
        rest = obstring:gsub( "%s*" .. firstword .. "%s*" , "" , 1 ) --> minus firstword and spaces.
        return firstword, rest
    end
end


   --[[  STRING/TABLE CONVERSION  ]]--
 --[[ Split a string into a table of its words ]]--
function madra.strsplit ( string )
    stringlist = {}
    for word in string:gmatch ( "%S+" ) do  -- = length-1-or-more strings of non-space
            table.insert(stringlist, word)
    end
    return stringlist
end

 --[[ Gather all elements of a list in order into a string, separating with spaces ]]--
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
function madra.understand ( obstring )
 --returns:
    obtype = ""
    props = {}

    --obstring = madra.gathertostring ( object )
--[[    obsplit  = madra.strsplit ( obstring )
    if #obsplit > 1 then
        io.write("The object contains spaces.")
    end
    if obsplit[1]:sub(1,1) == "/" then ]]
    if obstring:sub(1,1) == "/" then
        props.protocol = "file"
        obtype = "localpath"
        props = madra.getfileprops (obstring)
    else
        props.protocol = obstring:match ( "%w+://" )    -- alphanumerics and ://
        if props.protocol ~= nil then
            props.protocol = props.protocol:gsub ( "://", "" )    -- remove :
            rest = obstring:gsub (props.protocol .. "://", "", 1) --remove protocol
            if props.protocol == "file" then
                obtype = "localpath"
                props = madra.getfileprops (obstring)
            elseif props.protocol == "http" then
                obtype = "netpath"
            elseif props.protocol == "https" then
                obtype = "netpath"
            elseif props.protocol == "ftp" then
                obtype = "netpath"
              -- ..more protocols.. --
            end
            --props = madra.getnetprops( obstring, props )
            --debug:
            io.write("File: " .. obstring .. "\n\\_> Protocol: " .. protocol .. "\n\n")
        else -- protocol == nil
            props = madra.getfileprops (obstring)
            if props.domain == "localhost" then
                obtype = "localfile"
                if props.exists == true then
                    dfsjk = true
                    -- madra.view( obstring )
                else
                    io.write( "The file \"" .. obstring .. "\" does not exist\n" )
                end
            else
                linkmatch = obstring:match( "[%w+.]*%w+/.*" )
            end
        end
    end

    return obtype, props

end

 --[[ Get the properties of a file ]]--
function madra.getfileprops ( obstring )
 --returns:
    properties = {}

  -- is it a symlink?
    properties.attributes = lfs.symlinkattributes ( obstring )
    if properties.attributes == nil then
        properties.exists = false
    else
        properties.domain = "localhost"
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
    else return global.HOSTNAME
    end

end

 --[[ Find out where the home folder is ]]--
function madra.gethome( USER )
    envhome = os.getenv("HOME")
    if envhome ~= nil then
        return envhome
    elseif USER ~= nil then
        namehome = "/home/" .. USER
        UID = madra.getuid()
        diratts = lfs.attributes (namehome)
        if diratts == UID then
            return namehome
        end
    else return global.HOME
    end
    return EXIT_FAILURE
end

 --[[ Find out the current shell ]]--
function madra.getshell()
    return os.getenv("SHELL")
end

 --[[ Find out the user's UID ]]--
function madra.getuid()
    return posix.getuid()
end

 --[[ Find out the current username ]]--
function madra.getuser()
    return os.getenv("USER")
end
    

   --[[  MADRA ACTIONS  ]]--
 --[[ Reload madra / this file ]]--
function madra.reload ()
    package.loaded.madra = nil
    madra = require "madra"
end

--[[    for when needed:
local function makeaction ( keyword, callback )
    a = {}
    a.str = keyword
    a.cb  = callback
end
  ]]--

               ----------
            --[[  MAIN  ]]--
               ----------

  --[[  DEFINITIONS, FILES, CHOICES  ]]--

return madra
