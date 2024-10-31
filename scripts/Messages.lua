--// Variables \\--

local Module        = {}

local Discordia     = _G.Discordia
local Json          = _G.Json 
local Http          = _G.Http 

local Logger        = _G.Logger
local Table         = _G.Table
local DataStore     = _G.DataStore
local Commands      = _G.Commands

local Client        = _G.Client

local Questions     = _G.Questions
local Config        = _G.Config


local Cooldowns     = {}
local DMCooldowns   = {}

--// Functions \\--

function IsExcempted(Message) 
    local LoadedData = DataStore.LoadData()
    LoadedData.Excemptions = LoadedData.Excemptions or {Users = {}, Roles = {}, Channels = {}}

    for Role in Message.guild:getMember(Message.author.id).roles:iter() do 
        if Table.find(Config.Overrides.Roles, Role.id) or Table.find(LoadedData.Excemptions.Roles, Role.id) then 
            return true  
        end 
    end 

    if Table.find(Config.Overrides.Users, Message.author.id) or Table.find(LoadedData.Excemptions.Users, Message.author.id) then return true end 
    if Table.find(Config.Overrides.Channels, Message.channel.id) or Table.find(LoadedData.Excemptions.Channels, Message.channel.id) then return true end 
end 


Client:on("messageCreate", function(Message)
    local Answered = false
    if (Message.author.id==Client.user.id) or (Message.guild and IsExcempted(Message)) then return end

    local Command, CanRun, IsAdmin = Commands:GetCommandFromMessage(Message)

    if Command then 
	    if Message.guild then if Table.find(Cooldowns, Message.author.id) then Message.author:send("You are on cooldown. Please wait.") return  end
        else if Table.find(DMCooldowns, Message.author.id) then Message.author:send("You are on cooldown. Please wait.") return end
        end
        

        if not CanRun then Message:reply({content = "Sorry, you can't run this command!", reference = {message = Message, mention = true}}) Answered = true return end 
        
        Commands[Command](Message)
        Answered = true
    end  
    

    for _, Question in pairs(Questions) do 
        if string.match(Message.content:lower(), Question[1]) then 
			local CustomCommand 	= Question[2] 
			local CustomReference	= Question[3]
			
			if CustomReference then Message:reply({content = Config.Messages[CustomReference], reference = {message = Message, mention = true}}) return end
			
            Answered = true
            Commands[(CustomCommand or "AskedFAQ")](Message)
            return 
        end 
    end 

    if (not Answered) and (not Message.guild) then Message:reply({content = Config.Messages.UnableToAnswer, reference = {message = Message, mention = true}}) return end

    if Message.guild then Table.insert(Cooldowns, Message.author.id); Timer.sleep(1 * 1000) ; table.remove(Cooldowns, Table.find(Cooldowns, Message.author.id)) 
    else Table.insert(DMCooldowns, Message.author.id); Timer.sleep(1 * 1000) ; table.remove(DMCooldowns, Table.find(Cooldowns, Message.author.id)) 
    end 
end) 





Logger:Log(0, "Recieved scripts/Messages.lua        : OK", {Text = "MODULES", Color = Logger.Colors.BrightBlue})