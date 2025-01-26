local target = nil

RegisterCommand("documents", function()
  repeat
    Wait(0)
  until ESX.PlayerLoaded

  local elements = {}
  local documents = {}

  if Config.Jobs[ESX.PlayerData.job.name] and Config.Jobs[ESX.PlayerData.job.name].ranks[ESX.PlayerData.job.grade] then
    table.insert(elements, {
      label = "Dokument ausstellen",
      value = "create"
    })
  end

  table.insert(elements, {
    label = "Dokumente einsehen",
    value = "view"
  })

  ESX.TriggerServerCallback("document:getDocuments", function(data)
    for k, v in next, data do
      table.insert(documents, {
        label = v.header.title .. " - " .. v.footer.date,
        value = v
      })
    end
  end, GetPlayerServerId(PlayerId()))

  ESX.UI.Menu.Open("default", GetCurrentResourceName(), "documents", {
    title = "Documents",
    align = "top-left",
    elements = elements
  }, function(data, menu)
    if data.current.value == "create" then
      local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

      if closestPlayer == -1 or closestDistance > 3.0 then
        return ESX.ShowNotification("Kein Spieler in der Nähe.")
      end

      target = GetPlayerServerId(closestPlayer)
      local year, month, day, hour, minute, second = GetLocalTime()

      OpenDocument(ESX.PlayerData.job.name, true, {
        header = {
          title = Config.Jobs[ESX.PlayerData.job.name].title,
          subtitle = {
            department = Config.Jobs[ESX.PlayerData.job.name].subtitle.department,
            name = ESX.PlayerData.name,
            zone = Config.Jobs[ESX.PlayerData.job.name].subtitle.zone,
            postal = Config.Jobs[ESX.PlayerData.job.name].subtitle.postal
          }
        },
        body = {
          title = "Text eingeben...",
          description = "Text eingeben..."
        },
        footer = {
          date = string.format("%02d.%02d.%04d", day, month, year),
          signature = ESX.PlayerData.name,
          name = ESX.PlayerData.name
        }
      })
    elseif data.current.value == "view" then
      ESX.UI.Menu.Open("default", GetCurrentResourceName(), "documents_view", {
        title = "Documents",
        align = "top-left",
        elements = documents
      }, function(data2, menu2)
        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "documents_view_options", {
          title = "Options",
          align = "top-left",
          elements = {
            { label = "Dokument anschauen", value = "open" },
            { label = "Dokument zeigen", value = "show" },
            { label = "Dokument zerreißen", value = "delete" }
          }
        }, function(data3, menu3)
          if data3.current.value == "open" then
            OpenDocument(data2.current.value.job, false, data2.current.value)
          elseif data3.current.value == "show" then
            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

            if closestPlayer == -1 or closestDistance > 3.0 then
              return ESX.ShowNotification("Kein Spieler in der Nähe.")
            end

            TriggerServerEvent("document:show", GetPlayerServerId(closestPlayer), data2.current.value)
          elseif data3.current.value == "delete" then
            ESX.TriggerServerCallback("document:delete", function(success)
              if success then
                ESX.UI.Menu.CloseAll()
                ESX.ShowNotification("Dokument zerissen.")
              else
                ESX.ShowNotification("Fehler beim Zerreißen des Dokuments.")
              end
            end, GetPlayerServerId(PlayerId()), data2.current.value.id)
          end
        end, function(data3, menu3)
          menu3.close()
        end)
      end, function(data2, menu2)
        menu2.close()
      end)
    end
  end, function(data, menu)
    menu.close()
  end)
end, false)

function OpenDocument(job, edit, data)
  SetNuiFocus(true, true)

  SendNUIMessage({
    action = "open",
    data = {
      job = job,
      canEdit = edit,
      header = {
        title = data.header.title,
        subtitle = {
          department = data.header.subtitle.department,
          name = data.header.subtitle.name,
          zone = data.header.subtitle.zone,
          postal = data.header.subtitle.postal
        }
      },
      body = {
        title = data.body.title,
        description = data.body.description
      },
      footer = {
        date = data.footer.date,
        signature = data.footer.signature,
        name = data.footer.name
      }
    }
  })
end

RegisterNUICallback("close", function(data)
  SetNuiFocus(false, false)
  target = nil
end)

RegisterNUICallback("save", function(data)
  SetNuiFocus(false, false)
  ESX.TriggerServerCallback("document:save", function(success)
    if success then
      ESX.UI.Menu.CloseAll()
      ESX.ShowNotification("Dokument ausgestellt.")
    else
      ESX.ShowNotification("Fehler beim Ausstellen des Dokuments.")
    end
  end, target, data)
end)

RegisterNetEvent("document:show", function(data)
  OpenDocument(data.job, false, data)
end)