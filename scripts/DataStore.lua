--// Variables \\--

local Module        = {}

local Discordia     = _G.Discordia
local Json          = _G.Json 
local Http          = _G.Http

local Client        = _G.Client

local Config        = _G.Config



--// Functions \\--

function Module.LoadData()
    local Channel = Client:getGuild(Config.DataChannel.guild):getChannel(Config.DataChannel.channel)

    local Messages = Channel:getMessages()
    local LoadedData = nil
    
    for Message in Messages:iter() do
        if not (Message.author == Client.user and Message.attachments) then goto continue end
        
        LoadedData = Message

        ::continue::
    end
    
    if LoadedData and LoadedData.attachment then
        local _, file = Http.request("GET", LoadedData.attachment.url)
        local DecodedData = Json.decode(file)

        return DecodedData
    else
        return {}
    end
end


function Module.RemoveOldData()
    local Channel = Client:getGuild(Config.DataChannel.guild):getChannel(Config.DataChannel.channel)
    local Messages = Channel:getMessages()

    for Message in Messages:iter() do 
        if Message.author~=Client.user then goto continue end 
        
        Message:delete()

        ::continue::
    end 

end


function Module.CreateNewData(DataTable, Retrial, Err)
    Retrial = Retrial or 0; if Retrial>=15 then error("Failed to save data: " .. (Err or "No error available")) return end


    local Channel = Client:getGuild(Config.DataChannel.guild):getChannel(Config.DataChannel.channel)
    local EncodedData = Json.Encoded(DataTable)
    
    Module.RemoveOldData()

    local Success, ErrorMessage = pcall(function()
        Channel:send{file = {"localdata.json", EncodedData}}
    end)

    if Success then return true 
    else Discordia.sleep(5000); return Module.CreateNewData(DataTable, Retrial+1, ErrorMessage) 
    end 
end 



return Module 
