--// Variables \\--

local Module        = {}

local DataStore     = _G.DataStore
local Table         = _G.Table
local Status        = _G.Status 
local File          = _G.File 

local Client        = _G.Client

local Questions     = _G.Questions
local Config        = _G.Config



function Refer(Message, Reference)
    local SubjectMessage = Message.referencedMessage or Message
    
    SubjectMessage:reply({content = Config.Messages[Reference], reference = {message = SubjectMessage, mention = true}})
end



--// Methods \\--

function Module:HasPermission(Target, Command)
    if (not (Command.IsAdminCommand or Command.IsOwnerCommand) )then return true end
    if (Command.IsAdminCommand and not Command.IsOwnerCommand) then return (Table.find(Config.Admins, Target.id) or Table.find(Config.Owners, Target.id)) and true end 
    if Command.IsOwnerCommand then return (Table.find(Config.Owners, Target.id)) and true end 
end 


function Module:GetCommandFromMessage(Message)
    for Command, Data in pairs(Config.Commands) do 
        local CommandString = string.lower(Data.CommandPrefix .. Data.Command)
        
        if Message.content:lower():sub(1, #CommandString):lower()==CommandString then 
            return Command, Module:HasPermission(Message.author, Data), Data.IsAdminCommand
        end 
    end 

    return nil, "No command", false 
end 



--// Command Functions \\--

function Module.AskedFAQ(Message)
    Refer(Message, "FAQ" .. ((Message.guild and "") or ("_DM")))  
end

function Module.RequestFAQ(Message)
    if Message.referencedMessage then 
        Refer(Message, "FAQ") 
    else 
        Refer(Message, "RequestedFAQ")  
    end 
end

function Module.ListCommands(Message)
    local SubjectMessage = Message.referencedMessage or Message

    local FinalString = "# List of Commands\n" .. (function() 
        local CMDList="" 
        for _, CommandData in pairs(Config.Commands) do  
            if CommandData.Hidden and not (Table.find(Config.Owners, Message.author.id)) then goto continue end
            CMDList = CMDList .. "``" .. CommandData.CommandPrefix .. CommandData.Command .. "`` :  " .. ((CommandData.Hidden and "*") or "") .. CommandData.Description  .. " " .. (((CommandData.IsAdminCommand and not CommandData.IsOwnerCommand) and "(Admins only)") or ((CommandData.IsOwnerCommand and not CommandData.IsOwnerCommand) and "(Owners only)") or "") .. ((CommandData.Hidden and "*") or "") .. "\n" 
            ::continue::
        end; return CMDList
    end)() .. "-# The bot has a cooldown of " .. tostring(Config.Cooldown) .." seconds per person"


    SubjectMessage:reply({content = FinalString, reference = {message = SubjectMessage, mention = true}})
end

function Module.ReferSupport(Message)
    Refer(Message, "Support" .. ((Message.guild and "") or ("_DM")))  
end 

function Module.ReferVersions(Message)
    Refer(Message, "Versions" .. ((Message.guild and "") or ("_DM")))  
end 

function Module.ReferACSV3(Message)
    Refer(Message, "ACSV3" .. ((Message.guild and "") or ("_DM")))  
end 

function Module.ReferAnimation(Message)
    Refer(Message, "Animation" .. ((Message.guild and "") or ("_DM"))) 
end 

--// Utility Commands \\--

function Module.Excempt(Message)
    local Users = Message.mentionedUsers
    local Roles = Message.mentionedRoles
    local Channels = Message.mentionedChannels
    
    if not (#Users>=1 or #Roles>=1 or #Channels>=1) then 
        Message:reply({content = "Please mention a role, user, or channel to add it to the excemption list.", reference = {message = Message, mention = true}})
        return 
    end 

    local LoadedData = DataStore.LoadData()

    LoadedData.Excemptions = LoadedData.Excemptions or {Users = {}, Roles = {}, Channels = {}}

    for Index, MentionType in pairs({Users = Users, Roles = Roles, Channels = Channels}) do 
        for Mention in MentionType:iter() do 
            table.insert(LoadedData.Excemptions[Index], Mention.id)  
        end 
    end 


    DataStore.CreateNewData(LoadedData)

    Message:reply({content = "Done!", reference = {message = Message, mention = true}})
end 


function Module.Unexcempt(Message)
    local Users = Message.mentionedUsers
    local Roles = Message.mentionedRoles
    local Channels = Message.mentionedChannels

        
     if not (#Users>=1 or #Roles>=1 or #Channels>=1) then 
        Message:reply({content = "Please mention a role, user, or channel to remove it from the excemption list.", reference = {message = Message, mention = true}})
        return 
     end 

    local LoadedData = DataStore.LoadData()

    LoadedData.Excemptions = LoadedData.Excemptions or {Users = {}, Roles = {}, Channels = {}}
        
    for Index, MentionType in pairs({Users = Users, Roles = Roles, Channels = Channels}) do 
        for Mention in MentionType:iter() do 
            table.remove(LoadedData.Excemptions[Index], (table.find(LoadedData.Excemptions[Index], Mention.id)))  
        end 
    end 

    DataStore.CreateNewData(LoadedData)

    Message:reply({content = "Done!", reference = {message = Message, mention = true}})
end 


function Module.Ping(Message)
    local NewMessage = Message:reply({content = "Pinging... Please wait.", reference = {message = Message, mention = true}})

    local success, ping = pcall(function()
        return io.popen("ping -n 4 www.discord.com"):read("*a")
    end)

    NewMessage:update{
        reference = {message = Message, mention = true},
        embed = {
            title = "Ping",
            description = "Pong!",
            fields = {
                {
                    name = "Result",
                    value = "```" .. ((success and ping) or ("Ping failed. Please try again later.")) .. "```",
                    inline = true
                }
             },
             footer = {
                text = "Reply from www.discord.com"
            },
            color = 11022898
        }
    }
end

function Module.ClearConsole(Message)
   local NewMessage = Message:reply({content = "Clearing console...", reference = {message = Message, mention = true}})
   os.execute("cls")
   NewMessage:update({content = "Done!", reference = {message = Message, mention = true}})
end

function Module.GetConfig(Message)
    File:ReplyFile(Message, "Here you go!", "./bin/config.json")
end 

function Module.GetQuestions(Message)
    File:ReplyFile(Message, "Here you go!", "./bin/questions.json")
end 

function Module.SetConfig(Message)
    local NewMessage = Message:reply({content = "Setting new config..", reference = {message = Message, mention = true}})
    local Success, M = File:ReplaceJson(Message, "config.json")

    if Success then 
        NewMessage:update({content = "Done!", reference = {message = Message, mention = true}})
    else 
        NewMessage:update({content = M, reference = {message = Message, mention = true}})
    end 
end 

function Module.SetQuestions(Message)
    local NewMessage = Message:reply({content = "Setting new questions..", reference = {message = Message, mention = true}})
    local Success, M = File:ReplaceJson(Message, "questions.json")
    if Success then 
        NewMessage:update({content = "Done!", reference = {message = Message, mention = true}})
    else 
        NewMessage:update({content = M, reference = {message = Message, mention = true}})
    end 
end 

function Module.SetStatus(Message)
    Status:SetStatus(Message)
    Message:reply({content = "Done!", reference = {message = Message, mention = true}})
end 

function Module.ResetStatus(Message)
    Status:SetStatus(Config.Status.Message)
    Message:reply({content = "Done!", reference = {message = Message, mention = true}})
end

function Module.RemoveStatus(Message)
    Status:RemoveStatus()
    Message:reply({content = "Done!", reference = {message = Message, mention = true}})
end

function Module.RestartBot(Message)
    _G:Restart(Message.channel)
end



return Module
