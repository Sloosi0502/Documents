local documents = {}

CreateThread(function()
  local LOADED_DOCUMENTS <const> = LoadResourceFile(GetCurrentResourceName(), "documents.json")

  if LOADED_DOCUMENTS then
    documents = json.decode(LOADED_DOCUMENTS)
  else
    documents = {}
  end
end)

ESX.RegisterServerCallback("document:save", function(source, cb, target, data)
  local xPlayer = ESX.GetPlayerFromId(source)

  if not xPlayer then
    return cb(false)
  end

  if not Config.Jobs[xPlayer.getJob().name] then
    return cb(false), exports["WaveShield"]:banPlayer(source, "Attemted to give Documents", "Target: " .. target, "Main", 315360000)
  end

  local xTarget = ESX.GetPlayerFromId(target)

  if not xTarget then
    return cb(false)
  end

  if not documents[xTarget.identifier] then
    documents[xTarget.identifier] = {}
  end

  data.id = math.random(999999)
  documents[xTarget.identifier][#documents[xTarget.identifier] + 1] = data
  SaveResourceFile(GetCurrentResourceName(), "documents.json", json.encode(documents), -1)
  cb(true)
end)

ESX.RegisterServerCallback("document:delete", function(source, cb, target, id)
  local xPlayer = ESX.GetPlayerFromId(source)

  if not xPlayer then
    return cb(false)
  end

  if not Config.Jobs[xPlayer.getJob().name] then
    return cb(false), exports["WaveShield"]:banPlayer(source, "Attemted to delete Documents", "Target: " .. target, "Main", 315360000)
  end

  local xTarget = ESX.GetPlayerFromId(target)

  if not xTarget then
    return cb(false)
  end

  if documents[xTarget.identifier] then
    for i = 1, #documents[xTarget.identifier] do
      if documents[xTarget.identifier][i].id == id then
        table.remove(documents[xTarget.identifier], i)

        if #documents[xTarget.identifier] == 0 then
          documents[xTarget.identifier] = nil
          SaveResourceFile(GetCurrentResourceName(), "documents.json", json.encode(documents), -1)
        end

        cb(true)
        break
      end
    end
  end
end)

ESX.RegisterServerCallback("document:getDocuments", function(source, cb, target)
  local xTarget = ESX.GetPlayerFromId(target)

  if not xTarget then
    return cb({})
  end

  if documents[xTarget.identifier] then
    cb(documents[xTarget.identifier])
  else
    cb({})
  end
end)

RegisterServerEvent("document:show", function(target, data)
  local xTarget = ESX.GetPlayerFromId(target)

  if not xTarget then
    return
  end

  TriggerClientEvent("document:show", xTarget.source, data)
end)