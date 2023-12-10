QBCore = exports['qb-core']:GetCoreObject()
Config = {}
QBCore.PlayerData = QBCore.PlayerData or {}

Config.emergencyJobs = { -- Put here the job that you want to drive in the emergencyVehicles below
    'police',
    'ambulance',
    'leo',
    'ems',
}
Config.emergencyVehicles = { -- Put here the vehicles that you want only emergency services to be able to get in
    "police",
    "ambulance",
}
RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
QBCore.PlayerData = QBCore.Functions.GetPlayerData()
end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
QBCore.PlayerData = QBCore.Functions.GetPlayerData()
end)

Citizen.CreateThread(function()
    while QBCore and QBCore.PlayerData do
        local playerPed = PlayerPedId()
        if playerPed ~= 0 then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle ~= 0 then
                local seat = GetPedInVehicleSeat(vehicle, -1)
                if seat == playerPed then
                    local isEmergencyJob = getEmergencyJob()
                    if not isEmergencyJob then
                        local isVehicleBlacklisted = getVehicleBlacklist(GetEntityModel(vehicle))
                        if isVehicleBlacklisted then
                            TaskLeaveVehicle(playerPed, vehicle, 1)
                                QBCore.Functions.Notify('This vehicle is for emergency services only!', 'error')
                        end
                    end
                end
            end
        end
        Citizen.Wait(1000)
    end
end)

function getEmergencyJob()
    for _, v in ipairs(Config.emergencyJobs) do
        if QBCore.PlayerData.job and QBCore.PlayerData.job.name == v then
            return true
        end
    end 
    return false
end

function getVehicleBlacklist(model)
    for _, v in ipairs(Config.emergencyVehicles) do
        if model == GetHashKey(v) then
            return true
        end
    end
    return false
end
