RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:addSuggestion')
RegisterServerEvent('chat:removeSuggestion')
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end

    local command = message:sub(1, 1) == '/' and message:sub(2) or message

end)

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)
    local cleanedCommand = command:sub(1, 1) == '/' and command:sub(2) or command

    CancelEvent()
end)

local function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()

        local suggestions = {}

        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                -- Add command with '/' prefix
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })

                -- Add command without '/' prefix
                table.insert(suggestions, {
                    name = command.name,
                    help = ''
                })
            end
        end

        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end

AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Wait(500)

    for _, player in ipairs(GetPlayers()) do
        refreshCommands(player)
    end
end)


--  suraj  
local QBCore = exports['qb-core']:GetCoreObject()

local canAdvertise = true
local crimetoggle = false

if Config.EnableOOCCommand then
	RegisterCommand(Config.OOCCommand, function(source, args, rawCommand)
		local Player = QBCore.Functions.GetPlayer(source)
		local length = string.len(Config.OOCCommand)
		local message = rawCommand:sub(length + 1)
		local time = os.date(Config.DateFormat)
		playerName = Player.PlayerData.name
		TriggerClientEvent('chat:ooc', -1, source, playerName, message, time)
	end)
end
   