--// Variables \\--

local Module        = {}

local Discordia     = _G.Discordia
local Json          = _G.Json 
local Http          = _G.Http 

local Table         = _G.Table

local Client        = _G.Client



--// Methods \\--
function Module:ReplyFile(Message, Content, File)
    local FileName = File:match("([^/\\]+)$")
    local CurrentFile = io.open(File, "r")

    if not CurrentFile then return end

    local CurrentFileData = CurrentFile:read("*a")
    CurrentFile:close()
    

    Message.channel:send({content = Content, reference= {message = Message, mention = true}, file = {FileName, CurrentFileData}})
end 

function Module:ReplaceJson(Message, ToReplaceName)
    local Replacing = "./bin/" .. ToReplaceName 
    if not Message.attachment then return false, "You must attach a file." end 

    local _, file = Http.request("GET", Message.attachment.url)

    io.open(Replacing, "w+"):write(file):close()
    return true, ""
end


return Module
