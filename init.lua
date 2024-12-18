--// Variables \\--

local Module        = {}

local Discordia     = require("Discordia")                                                  ; _G.Discordia    = Discordia
local Json          = require("Json")                                                       ; _G.Json         = Json
local Http          = require("coro-http")                                                  ; _G.Http         = Http
local Timer         = require("timer")                                                      ; _G.Timer        = Timer

local Questions     = Json.decode(io.open("./bin/questions.json", "r"):read("*all"))        ; _G.Questions    = Questions
local Config        = Json.decode(io.open("./bin/config.json", "r"):read("*all"))           ; _G.Config       = Config

local Client        = Discordia.Client()                                                    ; _G.Client       = Client

local Logger        = require("./scripts/Util/Logger.lua")                                  ; _G.Logger       = Logger
local Table         = require("./scripts/Util/Table.lua")                                   ; _G.Table        = Table
local File          = require("./scripts/Util/File.lua")                                    ; _G.File         = File
local Status        = require("./scripts/Status.lua")                                       ; _G.Status       = Status
local DataStore     = require("./scripts/DataStore.lua")                                    ; _G.DataStore    = DataStore
local Commands      = require("./scripts/Commands.lua")                                     ; _G.Commands     = Commands
local Messages      = require("./scripts/Messages.lua")                                     ; _G.Messages     = Messages

local DebugMode     = false

function _G:Restart(Channel)
    Logger:Log(2, "Restart pending...")
    Channel:send("Restarting...")
    Channel:send("Done!")
    os.execute("luvit ./init.lua")
end


if not DebugMode then 
    local S, E = pcall(function()
        Client:run("Bot " .. io.open("./bin/token.txt", "r"):read("*all"))
    end); if not S then 
        
        Client:getUser(Config.Owners[1]):send("**SILVER'S FAQ BOT ERROR**\n Hey Silver, Your bot, Silver's FAQ BOT, had an error at " .. os.date("%Y-%m-%d %H:%M:%S") .. ". We'll try to restart it.\nError: ```lua\n" .. E .. "\n```")
        _G:Restart(Client:getUser(Config.Owners[1])) 
    end 
else 
    Client:run("Bot " .. io.open("./bin/token.txt", "r"):read("*all"))
end 
