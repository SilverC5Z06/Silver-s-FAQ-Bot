--// Variables \\--

local Module = {}

local Stdout = _G.process.stdout.handle ---@diagnostic disable-line: undefined-field

local Colors = { Black = 30, Red = 31, Green = 32, Yellow = 33, Blue = 34, Magenta = 35, Cyan = 36, White = 37, Pink = 95, Orange = 91}
local Config = {
    {'[ERROR]  ', Colors.Red}, 
    {'[WARNING]', Colors.Yellow}, 
    {'[INFO]   ', Colors.Green}, 
    {'[DEBUG]  ', Colors.Cyan}
} 

for _, v in ipairs(Config) do
    v[3] = string.format('\27[%i;%im%s\27[0m', 1, v[2], v[1])
end

--// Functions \\--

local function CustomType(Text, Color)
    local SpacedText = "[" .. Text .. "]" .. string.rep(" ", (9-(#Text+2)))

    return string.format('\27[%i;%im%s\27[0m', 1, Color, SpacedText)
end 

local function GetDate()
    return os.date("%Y-%m-%d %H:%M:%S")
end 

--// Module \\--

function Module:GetLogMessage(Level, Message, CustomParams)
    local TextTag = (CustomParams and CustomType(CustomParams.Text, CustomParams.Color)) or Config[Level][3]
    local Date = GetDate()
    local LogText = string.format('%s | %s | %s\n', Date, TextTag, Message)

    return LogText 
end 


function Module:Log(Level, Message, CustomParams)
    local LogText = Module:GetLogMessage(Level, Message, CustomParams)

    Stdout:write(LogText)
    
    local File, err = io.open("./BotLogs.log", "a")
    if File then
        File:write(LogText)
        File:close()
    else
        Stdout:write(string.format("Error opening log file: %s\n", err))
    end
end 


Stdout:write(string.format('\27[%i;%im%s\27[0m', 1, 95, -- 91 is color 
    [[



@@@@@@@@   @@@  @@@       @@@  @@@  @@@@@@@@  @@@@@@@    @@@@@@@  @@@@@@@  @@@@@@@@   @@@@@@@@     @@@@@@                   <
@@@@@@@    @@@  @@@       @@@  @@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@  @@@@@@@@  @@@@@@@@@@   @@@@@@@                   <
!@@        @@!  @@!       @@!  @@@  @@!       @@!  @@@  !@@       !@@           @@!  @@!   @@@@  !@@                        <
!@!        !@!  !@!       !@!  @!@  !@!       !@!  @!@  !@!       !@!          !@!   !@!  @!@!@  !@!                        <
!!@@!!     !!@  @!!       @!@  !@!  @!!!:!    @!@!!@!   !@!       !!@@!!      @!!    @!@ @! !@!  !!@@!@!                    <
 !!@!!!    !!!  !!!       !@!  !!!  !!!!!:    !!@!@!    !!!       @!!@!!!    !!!     !@!!!  !!!  @!!@!!!!                   <
     !:!   !!:  !!:       :!:  !!:  !!:       !!: :!!   :!!           !:!   !!:      !!:!   !!!  !:!  !:!                   <
    !:!    :!:   :!:       ::!!:!   :!:       :!:  !:!  :!:           !:!  :!:       :!:    !:!  :!:  !:!                   <
:::: ::     ::   :: ::::    ::::     :: ::::  ::   :::   ::: :::  :::: ::   :: ::::  ::::::: ::  :::: :::                   <
:: : :     :    : :: : :     :      : :: ::    :   : :   :: :: :  :: : :   : :: : :   : : :  :    :: : :                    <
                                                                                                                            <
 @@@@@@    @@@@@@@   @@@@@@             Name        :       Silver's FAQ BOT                                                <
@@@@@@@@  @@@@@@@@  @@@@@@@             Version     :       3.0.8                                                           <
@@!  @@@  !@@       !@@                 Created     :       10/31/24                                                        <
!@!  @!@  !@!       !@!                 Modified    :       10/31/24                                                        <
@!@!@!@!  !@!       !!@@!!              Language    :       Lua 5.4                                                         <
!!!@!!!!  !!!        !!@!!!                                                                                                 <
!!:  !!!  :!!            !:!            Contacts    :       silverc5z06@gmail.com, @silverc5z06                             <
:!:  !:!  :!:           !:!                                                                                                 <
::   :::   ::: :::  :::: ::                                                                                                 <
 :   : :   :: :: :  :: : :              !! TO AVOID LOSING DATA, MODIFICATIONS MUST BE APPROVED BEFORE COMMITTED OR RAN !!  <
                                                                                                                            <
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


]]))


Module:Log(0, "Silver's FAQ Bot: Begin Log      < " .. GetDate() .. " >\n", {Text = "START", Color = Colors.White})

return Module
