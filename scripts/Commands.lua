--// Variables \\--

local Module        = {}

local Logger        = _G.Logger
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



    local FinalString = "# List of Commands\n"
    local AdminOnly = {}
    local Everyone = {}
    local OwnersOnly = {}

    for _, CommandData in pairs(Config.Commands) do  

        if CommandData.Hidden and not (Table.find(Config.Owners, Message.author.id)) then goto continue end
        
        Table.insert((CommandData.IsOwnerCommand and OwnersOnly) or (CommandData.AdminOnly and AdminOnly) or (Everyone), CommandData)

        ::continue::
    end 




    
    FinalString = FinalString.."## Public\n"
    for _, CommandData in pairs(Everyone) do  
        local Data = "### " .. (CommandData.Command)
        Data = Data .. "\n`" .. CommandData.CommandPrefix .. CommandData.Command .. "`\n" .. CommandData.Description 
        FinalString = FinalString .. Data .. "\n"
        ::continue::
    end

    FinalString = FinalString.."\n## Admins Only\n"
    for _, CommandData in pairs(AdminOnly) do  
        local Data = "### " .. (CommandData.Command)
        Data = Data .. "\n`" .. CommandData.CommandPrefix .. CommandData.Command .. "`\n" .. CommandData.Description 
        FinalString = FinalString .. Data .. "\n"
        ::continue::
    end

    FinalString = FinalString.."\n## Owners Only\n"
    for _, CommandData in pairs(OwnersOnly) do  
        local Data = "### " .. (CommandData.Command)
        Data = Data .. "\n`" .. CommandData.CommandPrefix .. CommandData.Command .. "`\n" .. CommandData.Description 
        FinalString = FinalString .. Data .. "\n"
        ::continue::
    end

    FinalString = FinalString .. "\n\n-# The bot has a cooldown of " .. tostring(Config.Cooldown) .." seconds per person"

    SubjectMessage.author:send({
        embed = {
            description = FinalString,
            color = 11022898
        }
    })

    if Message.guild then 
        SubjectMessage:reply({content = "Check your dms. If they are closed, please open them.", reference = {message = SubjectMessage, mention = true}})
    end 
end

function Module.Blacklist(Message)
    local s, f = pcall(function()
        local Type, Username, ID, Rblx  = string.lower(Message):match("!blacklist (.*), (.*), (.*), (.*)")

        local Channel = Client:getGuild(Config.BlacklistChannel.guild):getChannel(Config.BlacklistChannel.channel)
        local Files = {}

        for _, file in Message.attachments do 
            table.insert(Files, file.url)
        end 

        Channel:send({
            content = ("**Type**: " .. (Type or "Unknown") .. "\n**Discord Username**: ".. (Username or "Unknown") .. "(<@".. (ID or "0") .. ">)" .. "\n**Discord ID**:" .. (ID or "0") .. "\n**RBLX Profile**:" .. (Rblx or "Unknown") .. "**Proof**:" .. ((Message.attachments and #Message.attachments<1 and "No files available") or (""))), 
            files = Files
        })

        local User = ID
        local Reason = "Blacklist"

        pcall(function()
            Client:getUser(User):send({
                content = ("**Type**: " .. (Type or "Unknown") .. "\n**Discord Username**: ".. (Username or "Unknown") .. "(<@".. (ID or "0") .. ">)" .. "\n**Discord ID**:" .. (ID or "0") .. "\n**RBLX Profile**:" .. (Rblx or "Unknown") .. "**Proof**:" .. ((Message.attachments and #Message.attachments<1 and "No files available") or (""))), 
                files = Files
            })
        end)
        Message.guild:banUser(Client:getUser(User), Reason, 0)
    end)

    Message:addReaction((s and '✔') or '❌')
    Message:send({
        referencedMessage = Message, 
        content = "Failed to blacklist user (" .. tostring(f) or "no error available" .. ")."
    })
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




Logger:Log(0, "Recieved scripts/Commands.lua        : OK", {Text = "MODULES", Color = Logger.Colors.BrightBlue})



return Module