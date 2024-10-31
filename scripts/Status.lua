--// Variables \\--

local Module = {}

local Discordia     = _G.Discordia

local Logger        = _G.Logger

local Client        = _G.Client

local Questions     = _G.Questions
local Config        = _G.Config

function Module:SetStatus(Message)

    Client:setActivity(Message.content:sub(#(Config.Commands.SetStatus.CommandPrefix .. Config.Commands.SetStatus.Command)+2, #Message.content))

end 

function Module:RemoveStatus(Message)

    Client:setActivity()

end 

Client:on("ready", function()

    Client:setActivity(Config.Status.Message)

end)



Logger:Log(0, "Recieved scripts/Status.lua          : OK", {Text = "MODULES", Color = Logger.Colors.BrightBlue})

return Module