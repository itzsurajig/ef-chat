local chatInputActive = false
local chatInputActivating = false
local chatHidden = true
local chatLoaded = false

RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addTemplate')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:removeSuggestion')
-- RegisterNetEvent('chat:clear')
RegisterNetEvent('__cfx_internal:serverPrint')
RegisterNetEvent('_chat:messageEntered')

AddEventHandler('chatMessage', function(author, ctype, text)
    local args = {text}
    if author ~= "" then table.insert(args, 1, author) end
    local ctype = ctype ~= false and ctype or "normal"
    SendNUIMessage({
        type = 'ON_MESSAGE',
        message = {
            template = '<div class="chat-message ' .. ctype ..
                '"><div class="chat-message-body"><strong>{0}:</strong> {1}</div></div>',
            args = {author, text}
        }
    })
end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
    SendNUIMessage({
        type = 'ON_MESSAGE',
        message = {templateId = 'print', multiline = true, args = {msg}}
    })
end)

AddEventHandler('chat:addMessage', function(message)
    SendNUIMessage({type = 'ON_MESSAGE', message = message})
end)

AddEventHandler('chat:addSuggestion', function(name, help, params)
    SendNUIMessage({
        type = 'ON_SUGGESTION_ADD',
        suggestion = {name = name, help = help, params = params or nil}
    })
    local hasSlash = string.find(name, '/')
    if hasSlash then
        local nameWithoutSlash = string.gsub(name, '/', '')
        SendNUIMessage({
            type = 'ON_SUGGESTION_ADD',
            suggestion = {
                name = nameWithoutSlash,
                help = help,
                params = params or nil
            }
        })
    end
end)

AddEventHandler('chat:addSuggestions', function(suggestions)
    for _, suggestion in ipairs(suggestions) do
        SendNUIMessage({type = 'ON_SUGGESTION_ADD', suggestion = suggestion})

        local hasSlash = string.find(suggestion.name, '/')
        if hasSlash then
            local nameWithoutSlash = string.gsub(suggestion.name, '/', '')
            SendNUIMessage({
                type = 'ON_SUGGESTION_ADD',
                suggestion = {
                    name = nameWithoutSlash,
                    help = suggestion.help,
                    params = suggestion.params or nil
                }
            })
        end
    end
end)

AddEventHandler('chat:removeSuggestion', function(name)
    SendNUIMessage({type = 'ON_SUGGESTION_REMOVE', name = name})

    local hasSlash = string.find(name, '/')
    if hasSlash then
        local nameWithoutSlash = string.gsub(name, '/', '')
        SendNUIMessage({type = 'ON_SUGGESTION_REMOVE', name = nameWithoutSlash})
    end
end)

AddEventHandler('chat:addTemplate', function(id, html)
    SendNUIMessage({type = 'ON_TEMPLATE_ADD', template = {id = id, html = html}})
end)

-- AddEventHandler('chat:clear',
--                 function(name) SendNUIMessage({type = 'ON_CLEAR'}) end)


                


RegisterNUICallback('chatResult', function(data, cb)
    chatInputActive = false
    SetNuiFocus(false, false)

    if not data.canceled then

        if data.message:sub(1, 1) == '/' then
            ExecuteCommand(data.message:sub(2))
        else
            ExecuteCommand(data.message:sub(1))
        end
    end

    cb('ok')
end)

RegisterNetEvent('chat:clear')
AddEventHandler("chat:clear", function(data) 
    SendNUIMessage({
        action = "clear"
    })
end)

local function refreshCommands()
  if GetRegisteredCommands then
      local registeredCommands = GetRegisteredCommands()

      local suggestions = {}

      for _, command in ipairs(registeredCommands) do
          if IsAceAllowed(('command.%s'):format(command.name)) then
              -- Check if the command name contains "/"
              local hasSlash = string.find(command.name, '/')

              -- Add command without '/' prefix
              table.insert(suggestions, {name = command.name, help = ''})

              -- Add command with '/' prefix if it doesn't already contain '/'
              if not hasSlash then
                  table.insert(suggestions, {name = '/' .. command.name, help = ''})
              end
          end
      end

      TriggerEvent('chat:addSuggestions', suggestions)
  end
end

local function refreshThemes()
    local themes = {}

    for resIdx = 0, GetNumResources() - 1 do
        local resource = GetResourceByFindIndex(resIdx)

        if GetResourceState(resource) == 'started' then
            local numThemes = GetNumResourceMetadata(resource, 'chat_theme')

            if numThemes > 0 then
                local themeName = GetResourceMetadata(resource, 'chat_theme')
                local themeData = json.decode(
                                      GetResourceMetadata(resource,
                                                          'chat_theme_extra') or
                                          'null')

                if themeName and themeData then
                    themeData.baseUrl = 'nui://' .. resource .. '/'
                    themes[themeName] = themeData
                end
            end
        end
    end

    SendNUIMessage({type = 'ON_UPDATE_THEMES', themes = themes})
end

AddEventHandler('onClientResourceStart', function(resName)
    Wait(500)
    refreshCommands()
    refreshThemes()
end)

AddEventHandler('onClientResourceStop', function(resName)
    Wait(500)
    refreshCommands()
    refreshThemes()
end)

RegisterNUICallback('loaded', function(data, cb)
    TriggerServerEvent('chat:init')
    refreshCommands()
    refreshThemes()
    chatLoaded = true
    cb('ok')
end)

RegisterKeyMapping('chatopen', 'Opens Chat Window', 'keyboard', 't')
RegisterCommand('chatopen', function()
    SetTextChatEnabled(false)
    SetNuiFocus(false, false)
    if not chatInputActive then
        chatInputActive = true
        chatInputActivating = true

        SendNUIMessage({type = 'ON_OPEN'})
    end

    if chatInputActivating then
        SetNuiFocus(true)
        chatInputActivating = false
    end

    if chatLoaded then
        local shouldBeHidden = false

        if IsScreenFadedOut() or IsPauseMenuActive() then
            shouldBeHidden = true
        end

        if (shouldBeHidden and not chatHidden) or
            (not shouldBeHidden and chatHidden) then
            chatHidden = shouldBeHidden

            SendNUIMessage({
                type = 'ON_SCREEN_STATE_CHANGE',
                shouldHide = shouldBeHidden
            })
        end
    end
end)


