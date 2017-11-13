-------------------------------------------------
---[["""""""""""""""""""""""""""""""""""""""]]---
--[[      LAGOM: THE CHILLED-OUT SHELL       ]]--
---[[_______________________________________]]---
-------------------------------------------------

local lfs = require ( "lfs" )

dofile("madra.lua")

pwd = lfs.currentdir()
-- or os.getenv("PWD")


  ---	PROMPT   ---
datestring = "%X, %a %d %b"

-- ### Colours and prompts ###
--#  No colour
--\u{1b}
Colour_Off='\u{1b}[0m'
--# Normal coloured text
Black='\u{1b}[0;30m'
Red='\u{1b}[0;31m'
Green='\u{1b}[0;32m'
Yellow='\u{1b}[0;33m'
Blue='\u{1b}[0;34m'
Purple='\u{1b}[0;35m'
Cyan='\u{1b}[0;36m'
White='\u{1b}[0;37m'
--# Bold coloured text
BBlack='\u{1b}[1;30m'
BRed='\u{1b}[1;31m'
BGreen='\u{1b}[1;32m'
BYellow='\u{1b}[1;33m'
BBlue='\u{1b}[1;34m'
BPurple='\u{1b}[1;35m'
BCyan='\u{1b}[1;36m'
BWhite='\u{1b}[1;37m'
--# Prompts
--PS1="\n\[$BGreen\]\u\[$White\]@\[$Green\]\h \[$Blue\][\w] \[$BWhite\]\t\n\[$Yellow\]\!  \[$Colour_Off\]\$ "
--PS2="> "

prompt = ""
promptstr = Cyan .. "-+" .. Colour_Off .. "> "

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

        actfunc(args)
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
