local Players = game:GetService("Players")
local BaseFolder = workspace:WaitForChild("Bases")


local function teleportToBase(player: Player, base) 
	local spawnLocation: Part = base:FindFirstChild("SpawnLocation")
	if not spawnLocation then
		warn("SpawnLocation not found in base: " .. base.Name)
		return
	end

	local character = player.Character
	local targetCFrame = spawnLocation.CFrame
		* CFrame.Angles(0, math.rad(180), 0)
		+ Vector3.new(0, 10, 0)
	
	character:PivotTo(targetCFrame)
end

local function updateBaseSign(base, text)
	local sign = base:FindFirstChild("Sign")
	if sign and sign:FindFirstChild("Gui") and sign.Gui:FindFirstChild("SignGui") then
		local label = sign.Gui.SignGui:FindFirstChild("SignTextLabel")
		if label then
			label.Text = text
		end
	end
end

Players.PlayerAdded:Connect(function(player)
    local playerBase = nil
    for _, base in BaseFolder:GetChildren() do
		if base:GetAttribute("OwnerId") == nil then
			base:SetAttribute("OwnerId", player.UserId)
			playerBase = base
            print("Set " .. player.Name .. " base to " .. base.name)
			break
		end
	end
	
	if not playerBase then
		warn("No more available bases for " .. player.Name .. ". Kick player...")
		player.Kick("Max players reached. Join another server.")
		return
	end
	
    updateBaseSign(playerBase, "" .. player.Name .. "'s Base")
	player.CharacterAdded:Connect(function(character: Model)
		teleportToBase(player, playerBase)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	for _, base in BaseFolder:GetChildren() do
		if base:GetAttribute("OwnerId") ~= player.UserId then
			continue
		end
		base:SetAttribute("OwnerId", nil)
        updateBaseSign(base, "Empty Base")

		print("Removed " .. player.Name .. " base")
		break
	end
end)