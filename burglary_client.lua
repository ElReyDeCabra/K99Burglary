local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local GUI = {} -- don't touch
ESX = nil -- don't touch
GUI.Time = 0 -- don't touch
local PlayerData = {} -- don't touch
local showPro = false -- don't touch
local stealing = false -- don't touch
local peeking = false -- don't touch
local CurrentAction		= nil
local timer = false
local secsRemaining = nil
local savedDoor = nil
local doorTime = {}
peds = {}
local houseIn = nil
------------------------------------------------------
------------------------------------------------------
local useQalleCameraSystem = true --( https://github.com/qalle-fivem/esx-qalle-camerasystem )
local chancePoliceNoti = 20 -- the procent police get notified (only numbers like 30, 10, 40. You get it.)
local useBlip = false -- if u want blip
local useInteractSound = true -- if you wanna use InteractSound (when u lockpick the door)
------------------------------------------------------
------------------------------------------------------

------ l o c a l e s ------
local noCar = "No car nearby"
local text = "~r~lockpick~w~ door?" -- lockpick the door
local textUnlock = "~g~[E]~w~ Enter" -- enter the house
local insideText = "~g~[E]~w~ Exit" -- exit the door
local abortConfirm = "You have aborted the lockpicking"
local searchText = "~g~[E]~w~ Search" -- search the spot
local emptyMessage = "There is nothing here!" -- if you press E where it is empty
local emptyMessage3D = "~r~Empty" -- if the spot is empty
local closetText = "~g~[E]~w~ Peek into closet" -- text at closet
local abortLock = "~g~[E]~w~ To abort lockpicking"
local noLockpickText = "You don't have any lockpick!" -- if you don't have a lockpick and you try to do the burglary
local carUnlocked = "You have unlocked the car"
local youFound = "From the" -- when you steal something
local burglaryDetected = "A burglary has been detected at" -- text 1 cops gets sent
local sentPhoto = "We've sent you a photo of the criminal." -- if you use qalle's camerasystem this will be in the message too
local item = {'ring', 'goldNecklace', 'laptop', 'coke_pooch', 'weed_pooch', 'samsungS10', 'rolex', 'camera'}
local exitPos = {pos = {x = 0, y = 0, z = 0, h = 0 }}
local lastDoor = 0
local noiseXYZ = { x = 346.53 , y = -1003.44 , z = -99.2}
---------------------------


local PlayerData = {}

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(1)
  end
while ESX.GetPlayerData() == nil do
  Citizen.Wait(10)
end
PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)



RegisterNetEvent('instance:onCreate')
AddEventHandler('instance:onCreate', function(instance)
if instance.type == 'burglary' then
TriggerEvent('instance:enter', instance)
end
end)

RegisterNetEvent('instance:onPlayerLeft')
AddEventHandler('instance:onPlayerLeft', function(instance, player)
if player == instance.host then
TriggerEvent('instance:leave')
end
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('99kr-burglary:onUse')
AddEventHandler('99kr-burglary:onUse', function()
	local playerPed		= GetPlayerPed(-1)
  local coords		= GetEntityCoords(playerPed)
	if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
		local vehicle = nil

		if IsPedInAnyVehicle(playerPed, false) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
		else
			vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		end

    if DoesEntityExist(vehicle) then
      lockpicking = false
      ---print(lockpicking)
      randi = math.random(1, 10)
      if randi == 1 then
      TriggerServerEvent('99kr-burglary:removeKit')
      end
			TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
			  if useInteractSound then
			    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.7)
			  end

			Citizen.CreateThread(function()
				ThreadID = GetIdOfThisThread()
				CurrentAction = 'lockpick'

				Citizen.Wait(22 * 1000)

        if CurrentAction ~= nil then
          procent(100)
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowNotification(carUnlocked)
				end
				
				CurrentAction = nil
				--TerminateThisThread()
			end)
		end

		Citizen.CreateThread(function()
			Citizen.Wait(0)

			if CurrentAction ~= nil then
				SetTextComponentFormat('STRING')
				AddTextComponentString(abortLock)
				DisplayHelpTextFromStringLabel(0, 0, 1, -1)

				if IsControlJustReleased(0, Keys["X"]) then
					TerminateThread(ThreadID)
					ESX.ShowNotification(abortConfirm)
					CurrentAction = nil
				end
			end

		end)
	end
end)




RegisterNetEvent('99kr-burglary:Lockpick')
AddEventHandler('99kr-burglary:Lockpick', function(xPlayer)
  lockpicking = true
  Citizen.Wait(100)
  lockpicking = false
end)

local burglaryPlaces = {
  
  ["Robban"] = {
    door = 1,
    locked = true,
    pos = { x = 1229.1, y = -725.47, z = 60.80, h = 89.98 }, -- door coords
    inside = { x = 346.52 , y = -1013.19 , z = -99.2, h = 357.81 }, -- Inside coords
    animPos = { x = 1229.53, y = -724.81, z = 60.96, h = 277.96 }, -- The animation position
    doorTime = {}
    },
  ["Grove Street 1"] = {
    door = 2,
    locked = true,
    pos = { x = 126.73, y = -1930.20, z = 22.0, h = 207.79 },  -- door coords
    inside = { x = 346.52 , y = -1013.19 , z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 126.73, y = -1930.00, z = 21.38, h = 207.79 }, -- The animation position
    doorTime = {}
  }, 
  ["Grove Street 2"] = {
    door = 3,
     locked = true,
    pos = { x = 72.18 , y = -1939.08 , z = 21.37, h = 128.35 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 72.18 , y = -1939.08 , z = 21.37, h = 128.35  }, -- The animation position
    doorTime = {}
   },
   ["Grove Street 3"] = {
    door = 3,
     locked = true,
    pos = { x = 118.45 , y = -19321.06 , z = 21.32, h = 238.72 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 118.45 , y = -19321.06 , z = 21.32, h = 238.72 }, -- The animation position
    doorTime = {}
   },
   ["Grove Street 4"] = {
    door = 3,
     locked = true,
    pos = { x = 100.98 , y = -1912.15 , z = 21.41, h = 329.72 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 100.98 , y = -1912.15 , z = 21.41, h = 329.72  }, -- The animation position
    doorTime = {}
   },
    ["Grove Street 5"] = {
    door = 3,
     locked = true,
    pos = { x = 114.31 , y = -1961.25 , z = 21.33, h = 198.26 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = {  x = 114.31 , y = -1961.25 , z = 21.33, h = 198.26  }, -- The animation position
    doorTime = {}
  },
   ["Covenant Street 1"] = {
    door = 3,
     locked = true,
    pos = { x = 103.99 , y = -1885.37 , z = 24.32, h = 149.1 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = {  x = 103.99 , y = -1885.37 , z = 24.32, h = 149.1  }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 2"] = {
    door = 3,
     locked = true,
    pos = { x = 130.5 , y = -1853.12 , z = 25.23, h = 335.41 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = {  x = 130.5 , y = -1853.12 , z = 25.23, h = 335.41  }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 3"] = {
    door = 3,
     locked = true,
    pos = { x = 128.28 , y = -1897.06 , z = 23.67, h = 250.58 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = {  x = 128.28 , y = -1897.06 , z = 23.67, h = 250.58  }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 4"] = {
    door = 3,
     locked = true,
    pos = { x = 149.91 , y = -1864.71 , z = 24.59, h = 330.76 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 149.91 , y = -1864.71 , z = 24.59, h = 330.76 }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 5"] = {
    door = 3,
     locked = true,
    pos = { x = 148.79 , y = -1904.49 , z = 23.53, h = 156.07 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 148.79 , y = -1904.49 , z = 23.53, h = 156.07 }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 6"] = {
    door = 3,
     locked = true,
    pos = { x = 171.68 , y = -1871.41 , z = 24.4, h = 243.42 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = {  x = 171.68 , y = -1871.41 , z = 24.4, h = 243.42  }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 7"] = {
    door = 3,
     locked = true,
    pos = { x = 192.19 , y = -1883.22 , z = 25.06, h = 335.14 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = {  x = 192.19 , y = -1883.22 , z = 25.06, h = 335.14 }, -- The animation position
    doorTime = {}
  },
    ["Covenant Street 8"] = {
    door = 3,
     locked = true,
    pos = { x = 208.53 , y = -1895.35 , z = 24.81, h = 229.65 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 208.53 , y = -1895.35 , z = 24.81, h = 229.65 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 1"] = {
    door = 3,
     locked = true,
    pos = { x = 144.24 , y = -1968.84 , z = 18.86, h = 324.03 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 144.24 , y = -1968.84 , z = 18.86, h = 324.03 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 2"] = {
    door = 3,
     locked = true,
    pos = { x = 148.88 , y = -1960.61 , z = 19.46, h = 47.68 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 148.88 , y = -1960.61 , z = 19.46, h = 47.68 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 3"] = {
    door = 3,
     locked = true,
    pos = { x = 165.09 , y = -1944.89 , z = 20.24, h = 56.72 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 165.09 , y = -1944.89 , z = 20.24, h = 56.72 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 4"] = {
    door = 3,
     locked = true,
    pos = { x = 179.21 , y = -1923.86 , z = 21.37, h = 324.89 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 179.21 , y = -1923.86 , z = 21.37, h = 324.89 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 5"] = {
    door = 3,
     locked = true,
    pos = { x = 250.82 , y = -1935.01 , z = 24.7, h = 229.53 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 250.82 , y = -1935.01 , z = 24.7, h = 229.53 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 6"] = {
    door = 3,
     locked = true,
    pos = { x = 258.3 , y = -1927.09 , z = 25.44, h = 323.99 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 258.3 , y = -1927.09 , z = 25.44, h = 323.99 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 7"] = {
    door = 3,
     locked = true,
    pos = { x = 270.37 , y = -1916.96 , z = 26.18, h = 317.57 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 270.37 , y = -1916.96 , z = 26.18, h = 317.57 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 8"] = {
    door = 3,
     locked = true,
    pos = { x = 282.9 , y = -1899.02 , z = 27.27, h = 223.07 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 282.9 , y = -1899.02 , z = 27.27, h = 223.07 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 9"] = {
    door = 3,
     locked = true,
    pos = { x = 282.9 , y = -1899.02 , z = 27.27, h = 223.07 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 282.9 , y = -1899.02 , z = 27.27, h = 223.07 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 9"] = {
    door = 3,
     locked = true,
    pos = { x = 320.32 , y = -1854.01 , z = 27.51, h = 225.76 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 320.32 , y = -1854.01 , z = 27.51, h = 225.76 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 10"] = {
    door = 3,
     locked = true,
    pos = { x = 329.3 , y = -1845.91 , z = 27.75, h = 229.79 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 329.3 , y = -1845.91 , z = 27.75, h = 229.79 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 11"] = {
    door = 3,
     locked = true,
    pos = { x = 338.65 , y = -1829.55 , z = 28.34, h = 132.3 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 338.65 , y = -1829.55 , z = 28.34, h = 132.3 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 12"] = {
    door = 3,
     locked = true,
    pos = { x = 348.76 , y = -1821.04 , z = 28.89, h = 135.37 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 348.76 , y = -1821.04 , z = 28.89, h = 135.37 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 13"] = {
    door = 3,
     locked = true,
    pos = { x = 288.68 , y = -1792.5 , z = 28.09, h = 142.88 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 288.68 , y = -1792.5 , z = 28.09, h = 142.88 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 14"] = {
    door = 3,
     locked = true,
    pos = { x = 300.26 , y = -1783.68 , z = 28.44, h = 327.11 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 300.26 , y = -1783.68 , z = 28.44, h = 327.11 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 15"] = {
    door = 3,
     locked = true,
    pos = { x = 304.45 , y = -1775.5 , z = 29.1, h = 44.43 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 304.45 , y = -1775.5 , z = 29.1, h = 44.43 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 16"] = {
    door = 3,
     locked = true,
    pos = { x = 332.98 , y = -1740.84 , z = 29.73, h = 314.89 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 332.98 , y = -1740.84 , z = 29.73, h = 314.89 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 17"] = {
    door = 3,
     locked = true,
    pos = { x = 405.91 , y = -1751.18 , z = 29.71, h = 327.36 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 405.91 , y = -1751.18 , z = 29.71, h = 327.36 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 18"] = {
    door = 3,
     locked = true,
    pos = { x = 419.05 , y = -1735.42 , z = 29.61, h = 323.25 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 419.05 , y = -1735.42 , z = 29.61, h = 323.25 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 19"] = {
    door = 3,
     locked = true,
    pos = { x = 419.05 , y = -1735.42 , z = 29.61, h = 323.25 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 419.05 , y = -1735.42 , z = 29.61, h = 323.25 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 20"] = {
    door = 3,
     locked = true,
    pos = { x = 431.29 , y = -1725.53 , z = 29.6, h = 321.7 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 431.29 , y = -1725.53 , z = 29.6, h = 321.7 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 21"] = {
    door = 3,
     locked = true,
    pos = { x = 443.46 , y = -1707.31 , z = 29.71, h = 224.42 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 443.46 , y = -1707.31 , z = 29.71, h = 224.42 }, -- The animation position
    doorTime = {}
  },
    ["Roy Lowenstein Blvd 22"] = {
    door = 3,
     locked = true,
    pos = { x = 320.62 , y = -1759.79 , z = 29.64, h = 48.62 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 320.62 , y = -1759.79 , z = 29.64, h = 48.62 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 1"] = {
    door = 3,
     locked = true,
    pos = { x = 500.62 , y = -1697.16 , z = 29.79, h = 324.35 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 500.62 , y = -1697.16 , z = 29.79, h = 324.35 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 2"] = {
    door = 3,
     locked = true,
    pos = { x = 489.56 , y = -1714.08 , z = 29.71, h = 68.94 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 489.56 , y = -1714.08 , z = 29.71, h = 68.94 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 3"] = {
    door = 3,
     locked = true,
    pos = { x = 479.68 , y = -1735.71 , z = 29.15, h = 338.67 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 479.68 , y = -1735.71 , z = 29.15, h = 338.67 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 4"] = {
    door = 3,
     locked = true,
    pos = { x = 474.42 , y = -1757.69 , z = 29.09, h = 70.03 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 474.42 , y = -1757.69 , z = 29.09, h = 70.03 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 5"] = {
    door = 3,
     locked = true,
    pos = { x = 472.05 , y = -1775.28 , z = 29.07, h = 81.25 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 472.05 , y = -1775.28 , z = 29.07, h = 81.25 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 6"] = {
    door = 3,
     locked = true,
    pos = { x = 514.27 , y = -1780.79 , z = 28.91, h = 270.53 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 514.27 , y = -1780.79 , z = 28.91, h = 270.53 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 7"] = {
    door = 3,
     locked = true,
    pos = { x = 512.51 , y = -1790.73 , z = 28.92, h = 277.24 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 512.51 , y = -1790.73 , z = 28.92, h = 277.24 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 8"] = {
    door = 3,
     locked = true,
    pos = { x = 500.4 , y = -1813.27 , z = 28.89, h = 137.91 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 500.4 , y = -1813.27 , z = 28.89, h = 137.91 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 9"] = {
    door = 3,
     locked = true,
    pos = { x = 495.29 , y = -1823.37 , z = 28.87, h = 138.73 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 495.29 , y = -1823.37 , z = 28.87, h = 138.73 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 10"] = {
    door = 3,
     locked = true,
    pos = { x = 440.59 , y = -1829.73 , z = 28.36, h = 313.21 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 440.59 , y = -1829.73 , z = 28.36, h = 313.21 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 11"] = {
    door = 3,
     locked = true,
    pos = { x = 427.2 , y = -1842.1 , z = 28.46, h = 134.24 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 427.2 , y = -1842.1 , z = 28.46, h = 134.24 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 12"] = {
    door = 3,
     locked = true,
    pos = { x = 412.4 , y = -1856.41 , z = 27.32, h = 139.08 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 412.4 , y = -1856.41 , z = 27.32, h = 139.08 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 13"] = {
    door = 3,
     locked = true,
    pos = { x = 399.33 , y = -1865.1 , z = 26.71, h = 139.28 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 399.33 , y = -1865.1 , z = 26.71, h = 139.28 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 14"] = {
    door = 3,
     locked = true,
    pos = { x = 399.33 , y = -1865.1 , z = 26.71, h = 139.28 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 399.33 , y = -1865.1 , z = 26.71, h = 139.28 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 15"] = {
    door = 3,
     locked = true,
    pos = { x = 385.04 , y = -1881.5 , z = 26.03, h = 47.29 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 385.04 , y = -1881.5 , z = 26.03, h = 47.29 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 16"] = {
    door = 3,
     locked = true,
    pos = { x = 368.75 , y = -1895.7 , z = 25.18, h = 316.06 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 368.75 , y = -1895.7 , z = 25.18, h = 316.06 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 17"] = {
    door = 3,
     locked = true,
    pos = { x = 324.35 , y = -1937.26 , z = 25.02, h = 316.3 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 324.35 , y = -1937.26 , z = 25.02, h = 316.3 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 18"] = {
    door = 3,
     locked = true,
    pos = { x = 311.92 , y = -1956.16 , z = 24.62, h = 49.62 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 311.92 , y = -1956.16 , z = 24.62, h = 49.62 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 19"] = {
    door = 3,
     locked = true,
    pos = { x = 295.68 , y = -1971.81 , z = 22.9, h = 45.42 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 295.68 , y = -1971.81 , z = 22.9, h = 45.42 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 20"] = {
    door = 3,
     locked = true,
    pos = { x = 291.54 , y = -1980.08 , z = 21.6, h = 329.7 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 291.54 , y = -1980.08 , z = 21.6, h = 329.7 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 21"] = {
    door = 3,
     locked = true,
    pos = { x = 279.53 , y = -1993.89 , z = 20.8, h = 147.8 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 279.53 , y = -1993.89 , z = 20.8, h = 147.8 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 22"] = {
    door = 3,
     locked = true,
    pos = { x = 256.35 , y = -2023.5 , z = 19.27, h = 53.33 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 256.35 , y = -2023.5 , z = 19.27, h = 53.33 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 23"] = {
    door = 3,
     locked = true,
    pos = { x = 251.11 , y = -2030.31 , z = 18.71, h = 133.62 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 251.11 , y = -2030.31 , z = 18.71, h = 133.62 }, -- The animation position
    doorTime = {}
  },
    ["Jamestown Steet 24"] = {
    door = 3,
     locked = true,
    pos = { x = 236.0 , y = -2046.35 , z = 18.38, h = 152.75 },  -- door coords
    inside = { x = 346.52, y = -1013.19, z = -99.2, h = 357.81 },  -- Inside the house coords
    animPos = { x = 236.0 , y = -2046.35 , z = 18.38, h = 152.75 }, -- The animation position
    doorTime = {}
  }
}

residents = {
	{
		coord = vec3(349.8, -996.141, -98.7399),
		rotation = 90.0,
		animation = { dict = "amb@lo_res_idles@", anim = "lying_face_up_lo_res_base" }, -- sleeping animation
		model = "a_f_y_hipster_01",
		aggressive = true -- if they should attack after waking up
	}
}




local burglaryInside = {
[" kitchen table you found "] = { x = 342.23, y = -1003.29, z = -99.0,  amount = 0},
[" tv draw you found "] = { x = 338.14, y = -997.69,  z = -99.2,  amount = 0},
[" bedroom draw you found "] = { x = 350.91, y = -999.26,  z = -99.2,  amount = 0},
[" bed side table you found "] = { x = 349.19, y = -994.83,  z = -99.2,  amount = 0},
[" book shelf you found "] = { x = 345.3,  y = -995.76,  z = -99.2,  amount = 0},
[" hallway table you found "] = { x = 346.14, y = -1001.55, z = -99.2,  amount = 0},
[" bathroom draw you found "] = { x = 347.23, y = -994.09,  z = -99.2,  amount = 0},
[" dinning table you found "] = { x = 339.23, y = -1003.35, z = -99.2,  amount = 0},
[" wardrobe you found "] = { x = 351.24, y = -993.53,  z = -99.2,  amount = 0}

}

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5)
    for k,v in pairs(burglaryPlaces) do
      local playerPed = PlayerPedId()
      local house = k
      local coords = GetEntityCoords(playerPed)
      local dist   = GetDistanceBetweenCoords(v.pos.x, v.pos.y, v.pos.z, coords.x, coords.y, coords.z, false)
    if GetClockHours() >= 23  or GetClockHours() < 7 then
      if dist <= 1.2 and v.locked == true then
          DrawText3D(v.pos.x, v.pos.y, v.pos.z, text, 0.4)                  
          if lockpicking == true then
            RemoveResidents()
            savedDoor = v.door
            houseIn = house
            v.doorTime = GetGameTimer() + 600 * 1000
            confMenu(house)
            for k, v in pairs(burglaryInside) do
              if v.amount < 1 then
              v.amount = v.amount + 1
              lockpicking = false
              end
            end
          end  
      else
        if dist <= 1.2 and timer == true then
         local secsRemaining = math.ceil((v.doorTime - GetGameTimer()) / 1000)
          secsRemaining = secsRemaining - 1
          if secsRemaining > 0 then
                DrawText3D(v.pos.x, v.pos.y, v.pos.z,'Please wait ~r~'..secsRemaining..'~w~ until you can Break in', 0.4)
          else
            timer = false
            v.locked = true 
            doorTime = {}      
          end
          
        end
      end
    else 
      if dist <= 1.2 then
        breakTime = 23 - GetClockHours() 
      DrawText3D(v.pos.x, v.pos.y, v.pos.z, 'you can break into the house in ~r~' ..breakTime.. ' ~w~hours', 0.4) 
      end
    end
    end
  end
end)

Citizen.CreateThread(function()
  while stealing == false do
    Citizen.Wait(5)
    for k, v in pairs(burglaryInside) do
      local playerPed = PlayerPedId()
      local coords = GetEntityCoords(playerPed)
      local dist = GetDistanceBetweenCoords(v.x, v.y, v.z, coords.x, coords.y, coords.z, false)
      if dist <= 1.2 and v.amount > 0 then
        DrawText3D(v.x, v.y, v.z, searchText, 0.4)
        if dist <= 0.5 and IsControlJustPressed(0, Keys["E"]) then
          steal(k)
        end
      elseif v.amount < 1 and dist <= 1.2 then
        DrawText3D(v.x, v.y, v.z, emptyMessage3D, 0.4)
        if IsControlJustPressed(0, Keys["E"]) and dist <= 0.5 then
          ESX.ShowNotification(emptyMessage)
        end
      end
    end
  end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5)
    for k, v in pairs(burglaryPlaces) do
      local playerPed = PlayerPedId()
      local coords = GetEntityCoords(playerPed)
      local house = k
      if GetDistanceBetweenCoords(noiseXYZ.x, noiseXYZ.y, noiseXYZ.z, coords.x, coords.y, coords.z, false) <= 14.0 then
        DrawNoiseBar(GetPlayerCurrentStealthNoise(PlayerId()), 3)
      end
      if GetDistanceBetweenCoords(v.inside.x, v.inside.y, v.inside.z, coords.x, coords.y, coords.z, false) <= 3.0 then
        DrawText3D(v.inside.x, v.inside.y, v.inside.z, insideText, 0.4)
        if GetDistanceBetweenCoords(v.inside.x, v.inside.y, v.inside.z, coords.x, coords.y, coords.z, false) <= 1.2 and IsControlJustPressed(0, Keys["E"]) then
          RemoveResidents()
          fade()
          TriggerEvent('instance:close')
          teleport(exitPos)
          lastDoor = 0
          timer = true
          
        end
      end
    end
  end
end)


Citizen.CreateThread(function()
	while true do
    Citizen.Wait(6)
    if showPro == true then
      local playerPed = PlayerPedId()
		  local coords = GetEntityCoords(playerPed)
      DrawText3D(coords.x, coords.y, coords.z, TimeLeft .. '~g~%', 0.4)
    end
	end
end)

function confMenu(house)
  Citizen.Wait(6)
  RemoveResidents()
  local v = GetHouseValues(house, burglaryPlaces)
  exitPos = {pos ={x = v.pos.x, y = v.pos.y, z = v.pos.z, h = v.pos.h }}
  Citizen.CreateThread(function()
    local inventory = ESX.GetPlayerData().inventory
    local LockpickAmount = nil
      for i=1, #inventory, 1 do                          
        if inventory[i].name == 'lockpick' then
          LockpickAmount = inventory[i].count
        end
      end
        if LockpickAmount > 0 then
          SpawnResidents(home)
          HouseBreak(house)
          v.locked = false
          Citizen.Wait(math.random(15000,30000))
          local random = math.random(0, 100)
          if random <= chancePoliceNoti then 
            TriggerServerEvent('esx_addons_gcphone:startCall', 'police', burglaryDetected .. '\n ' .. house, { x = exitPos.pos.x, y = exitPos.pos.y, z = exitPos.pos.z })
          end
        else 
          ESX.ShowNotification(noLockpickText)
        end
	end)
end
                        
function steal(k)
  local goods = item[math.random(#item)] 
  local values = GetHouseValues(k, burglaryInside)
  local playerPed = PlayerPedId()
  stealing = true
  FreezeEntityPosition(playerPed, true)
  TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
  Citizen.Wait(2000)
  procent(50)
  TriggerServerEvent('99kr-burglary:Add', goods, 1)
  ESX.ShowNotification(youFound .. k ..' '.. goods)
  values.amount = values.amount - 1
  ClearPedTasks(playerPed)
  FreezeEntityPosition(playerPed, false)
  stealing = false
end

function HouseBreak(house)
  local v = GetHouseValues(house, burglaryPlaces)
  local playerPed = PlayerPedId()
  fade()
  FreezeEntityPosition(playerPed, true)
  SetEntityCoords(playerPed, v.animPos.x, v.animPos.y, v.animPos.z - 0.98)
  SetEntityHeading(playerPed, v.animPos.h)
  loaddict("mini@safe_cracking")
  TaskPlayAnim(playerPed, "mini@safe_cracking", "idle_base", 3.5, - 8, - 1, 2, 0, 0, 0, 0, 0)
  if useInteractSound then
    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 3.0, 'lockpick', 0.7)
  end
  procent(70)
  rand = math.random(1, 10)
  if rand == 1 then
    TriggerServerEvent('99kr-burglary:Remove', 'lockpick', 1)
  end  
  fade()
  ClearPedTasks(playerPed)
  FreezeEntityPosition(playerPed, false)
  TriggerEvent('instance:create', 'burglary', {burglary = house, owner = ESX.GetPlayerData().identifier})
  SetCoords(playerPed, v.inside.x, v.inside.y, v.inside.z - 0.98)
  SetEntityHeading(playerPed, v.inside.h)
end 

function ShowSubtitle(text)
  BeginTextCommandPrint("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandPrint(3500, 1)
end

function SetCoords(playerPed, x, y, z)
  SetEntityCoords(playerPed, x, y, z)
  Citizen.Wait(100)
  SetEntityCoords(playerPed, x, y, z)
end

function DrawTimerBar(title, text, barIndex)
	local width = 0.13
	local hTextMargin = 0.003
	local rectHeight = 0.038
	local textMargin = 0.008
	
	local rectX = GetSafeZoneSize() - width + width / 2
	local rectY = GetSafeZoneSize() - rectHeight + rectHeight / 2 - (barIndex - 1) * (rectHeight + 0.005)
	
	DrawSprite("timerbars", "all_black_bg", rectX, rectY, width, 0.038, 0, 0, 0, 0, 128)
	
	DrawText2d(title, GetSafeZoneSize() - width + hTextMargin, rectY - textMargin, 0.32)
	DrawText2d(string.upper(text), GetSafeZoneSize() - hTextMargin, rectY - 0.0175, 0.5, true, width / 2)
end

function DrawNoiseBar(noise, barIndex)
	DrawTimerBar("NOISE", math.floor(noise), barIndex)
end

function DrawText2d(text, x, y, scale, right, width)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(254, 254, 254, 255)

	if right then
		SetTextWrap(x - width, x)
		SetTextRightJustify(true)
	end
	
	BeginTextCommandDisplayText("STRING")	
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x, y)
end

function callCops(house)
    if  savedDoor ~= lastDoor then
    TriggerServerEvent('esx_addons_gcphone:startCall', 'police', burglaryDetected .. '\n ' .. houseIn, { x = exitPos.pos.x, y = exitPos.pos.y, z = exitPos.pos.z })
    lastDoor = savedDoor
    end
end

function fade()
  DoScreenFadeOut(1000)
  Citizen.Wait(1000)
  DoScreenFadeIn(1000)
end

function loaddict(dict)
  while not HasAnimDictLoaded(dict) do
    RequestAnimDict(dict)
    Wait(10)
  end
end

Citizen.CreateThread(function(house)
	while true do
    Citizen.Wait(6)
    if GetPlayerCurrentStealthNoise(PlayerId()) > 5 then
    if CanPedHearPlayer(PlayerId(), peds[1]) then
      callCops(house)
      ClearPedTasks(peds[1])
      Citizen.Wait(5)
      PlayPain(peds[1], 7, 0)
      if HasPedGotWeapon(peds[1], GetHashKey("WEAPON_PISTOL"), false) then
        SetCurrentPedWeapon(peds[1], GetHashKey("WEAPON_PISTOL"), true)
        Citizen.Wait(5)
        TaskShootAtEntity(peds[1], PlayerPedId(), -1, 2685983626)
        Citizen.Wait(7000)
      end
    end
    end
  end
end)

function SpawnResidents(home)
 
		RequestModel("a_f_y_hipster_01")
		while not HasModelLoaded("a_f_y_hipster_01") do 
		  Wait(0)
    end
    for _,resident in pairs(residents) do
		 ped = CreatePed(4, resident.model, resident.coord, resident.rotation, false, false)
			table.insert(peds, ped)
			-- animation
      RequestAnimDict(resident.animation.dict)
      while not HasAnimDictLoaded(resident.animation.dict) do 
        Wait(0) 
      end
      
      TaskPlayAnimAdvanced(ped, resident.animation.dict, resident.animation.anim, resident.coord, 0.0, 0.0, resident.rotation, 8.0, 1.0, -1, 1, 1.0, true, true)
      SetFacialIdleAnimOverride(ped, "mood_sleeping_1", 0)

      SetPedHearingRange(ped, 3.0)
			SetPedSeeingRange(ped, 3.0)
      SetPedAlertness(ped, 1)

      if resident.aggressive then
        GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 255, true, false)
      end

      
  end
      
  
end

function RemoveResidents()
	for _,ped in pairs(peds) do
		SetPedAsNoLongerNeeded(ped)
    DeletePed(ped)
   
	end
	
  peds = {}
end


function DrawText3D(x, y, z, text, scale)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
  SetTextScale(scale, scale)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextEntry("STRING")
  SetTextCentre(1)
  SetTextColour(255, 255, 255, 255)
  SetTextOutline()
  AddTextComponentString(text)
  DrawText(_x, _y)
  local factor = (string.len(text)) / 270
  DrawRect(_x, _y + 0.015, 0.005 + factor, 0.03, 31, 31, 31, 155)
end

function procent(time)
  showPro = true
  TimeLeft = 0
  repeat
  TimeLeft = TimeLeft + 1 -- thank you (github.com/Loffes)
  Citizen.Wait(time)
  until(TimeLeft == 100)
  showPro = false
end

function teleport(confMenu)
  local values = GetHouseValues(house, burglaryPlaces)
  local playerPed = PlayerPedId()
  SetCoords(playerPed, confMenu.pos.x, confMenu.pos.y, confMenu.pos.z - 0.98)
  SetEntityHeading(playerPed, confMenu.pos.h)
  DoingBreak = false
end

function GetHouseValues(house, pair)
  for k, v in pairs(pair) do
    if k == house then
      return v
    end
  end
end

if useBlip then
  Citizen.CreateThread(function()
    for k, v in pairs(burglaryPlaces) do
       local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
       SetBlipSprite (blip, 40)
       SetBlipDisplay(blip, 4)
       SetBlipScale (blip, 0.8)
       SetBlipColour (blip, 39)
       SetBlipAsShortRange(blip, true)
       BeginTextCommandSetBlipName("STRING")
       AddTextComponentString('Burglary')
       EndTextCommandSetBlipName(blip)
    end
  end)
end

RegisterNetEvent('99kr-burglary:Sound')
AddEventHandler('99kr-burglary:Sound', function(sound1, sound2)
PlaySoundFrontend(-1, sound1, sound2)
end)

--------------  Pawn Shop ---------------------------
function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local blips = {
  {title="Pawnshop", colour=4, id=133, x = 412.31, y = 314.11, z = 103.02}
}

Citizen.CreateThread(function()
  for _, info in pairs(blips) do
    info.blip = AddBlipForCoord(info.x, info.y, info.z)
    SetBlipSprite(info.blip, info.id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 1.0)
    SetBlipColour(info.blip, info.colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(info.title)
    EndTextCommandSetBlipName(info.blip)
  end
end)

local gym = {
  {x = 412.31, y = 314.11, z = 103.02}
}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      for k in pairs(gym) do
          DrawMarker(21, gym[k].x, gym[k].y, gym[k].z, 0, 0, 0, 0, 0, 0, 0.301, 0.301, 0.3001, 0, 153, 255, 255, 0, 0, 0, 0)
      end
  end
end)

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      for k in pairs(gym) do
        local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
        local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, gym[k].x, gym[k].y, gym[k].z)
        if dist <= 0.5 then
          DrawText3D(plyCoords.x, plyCoords.y, plyCoords.z, "~w~Press ~r~[H] ~w~ to use pawn shop!", 0.4)
          if IsControlJustPressed(0, Keys['H'])then
            OpenSellMenu()
          end
        end		
      end
  end
end)

function OpenSellMenu()
  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'pawn_sell_menu',
      {
          title    = 'Do you have any of the following you want to sell?',
          elements = {
              {label = 'Ring ($50)', value = 'ring'},
              {label = 'Rolex ($250)', value = 'rolex'},
              {label = 'Camera ($35)', value = 'camera'},
              {label = 'Gold Necklace ($100)', value = 'goldNecklace'},
              {label = 'Laptop ($250)', value = 'laptop'},
              {label = 'Samsung S10($425)', value = 'samsungS10'},
          }
      },
      function(data, menu)
          if data.current.value == 'ring' then
              TriggerServerEvent('99kr-burglary:sellring')
          elseif data.current.value == 'rolex' then
              TriggerServerEvent('99kr-burglary:sellrolex')
          elseif data.current.value == 'camera' then
              TriggerServerEvent('99kr-burglary:sellcamera')
          elseif data.current.value == 'goldNecklace' then
              TriggerServerEvent('99kr-burglary:sellgoldNecklace')
          elseif data.current.value == 'laptop' then
              TriggerServerEvent('99kr-burglary:selllaptop')
          elseif data.current.value == 'samsungS10' then
              TriggerServerEvent('99kr-burglary:sellsamsungS10')
          end
      end,
      function(data, menu)
          menu.close()
      end
  )
end
