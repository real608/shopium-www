------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CloneTrooper1019, 2021
-- Realism Client (2007 Port LMAO)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local RunService = game:service("RunService")
local Players = game:service("Players")

local CharacterRealism = 
{
	Rotators = {};
	Player = Players.LocalPlayer;
	
	RotationFactors =
	{
		Head = 
		{
			Pitch = 0.8;
			Yaw = 0.75;
		};
		
		Torso =
		{
			Pitch =  0.4;
			Yaw   =  0.2;
		};
		
		["Left Arm"] =
		{
			Pitch =  0.0;
			Yaw   = -0.5;
		};
			
		["Right Arm"] =
		{
			Pitch =  0.0;
			Yaw   = -0.5;
		};

		["Left Leg"] =
		{
			Pitch =  0.0;
			Yaw   = -0.2;
		};
			
		["Right Leg"] =
		{
			Pitch =  0.0;
			Yaw   = -0.2;
		};
	};
}

function CharacterRealism:StepTowards(value, goal, rate)
	if math.abs(value - goal) < rate then
		return goal
	elseif value > goal then
		return value - rate
	elseif value < goal then
		return value + rate
	end
end

function CharacterRealism:GetComponents(cf)
	local value = tostring(cf)
	local components = {}
	
	for number in value:gmatch("[^,]+") do
		table.insert(components, tonumber(number))
	end

	return unpack(components)
end

function CharacterRealism:Clamp(value, min, max)
	return math.min(max, math.max(min, value))
end

function CharacterRealism:Dot(a, b)
	return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
end

function CharacterRealism:Connect(funcName, event)
	return event:connect(function (...)
		self[funcName](self, ...)
	end)
end

function CharacterRealism:AddMotor(rotator, motor)
	local parent = motor.Parent
	
	if parent and parent.Name == "Head" then
		motor.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		motor.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
		parent.CanCollide = false
	end
	
	while not motor.Part0 do
		wait()
	end

	while not motor.Part1 do
		wait()
	end
	
	local data = 
	{ 
		Motor = motor;
		C0 = motor.C0;
	}
    
	local id = motor.Part1.Name
	rotator.Motors[id] = data
end

function CharacterRealism:OnLookReceive(player, pitch, yaw)
	local character = player.Character
	local rotator = self.Rotators[character]
	
	if rotator then
		rotator.Pitch.Goal = pitch
		rotator.Yaw.Goal = yaw
	end
end

function CharacterRealism:IsInFirstPerson()
	local camera = workspace.CurrentCamera
	
	if camera then
		local focus = camera.Focus.p
		local origin = camera.CoordinateFrame.p
		
		return (focus - origin).magnitude <= 1
	end
	
	return false
end

function CharacterRealism:ComputeLookAngle(lookVector, useDir)
	local inFirstPerson = self:IsInFirstPerson()
	local pitch, yaw, dir = 0, 0, 1
	
	if not lookVector then
		local camera = workspace.CurrentCamera
		lookVector = camera.CoordinateFrame.lookVector
	end
	
	if lookVector then
		local character = self.Player.Character
		local rootPart = character and character:findFirstChild("Torso")
		
		if rootPart and rootPart.className == "Part" then
			local cf = rootPart.CFrame
			local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = self:GetComponents(cf)

			local rightVector = Vector3.new(R00, R10, R20)
			pitch = self:Dot(-rightVector, lookVector)
			
			if not inFirstPerson then
				local dot = self:Dot(cf.lookVector, lookVector)
				dir = self:Clamp(dot * 10, -1, 1)
			end
		end
		
		yaw = lookVector.y
	end
	
	if useDir then
		dir = useDir
	end
	
	pitch = pitch * dir
	yaw = yaw * dir
	
	return pitch, yaw
end

function CharacterRealism:StepValue(state, delta)
	local current = state.Current or 0
	local goal = state.Goal

	local pan = math.min(4, 4 / (delta * 10))
	local rate = math.min(1, (delta * 20) / 3)

	local step = math.min(rate, math.abs(goal - current) / pan)
	state.Current = self:StepTowards(current, goal, (step * 60) * delta)
	
	return state.Current
end

function CharacterRealism:UpdateLookAngles(elapsed, delta)
	-- Update our own look-angles with no latency
	local pitch, yaw = self:ComputeLookAngle()
	self:OnLookReceive(self.Player, pitch, yaw)
	
	-- Update all of the character look-angles
	local camera = workspace.CurrentCamera
	local camPos = camera.CoordinateFrame.p
	
	local player = self.Player
	local now = tick()
	local dropList
	
	for character, rotator in pairs(self.Rotators) do
		local motors = rotator.Motors
		local rootPart = character:findFirstChild("Torso")
		
		if motors and rootPart and character.Parent then
			local lastStep = rotator.LastStep or 0
			local stepDelta = now - lastStep
			
			local pitchState = rotator.Pitch
			self:StepValue(pitchState, stepDelta)

			local yawState = rotator.Yaw
			self:StepValue(yawState, stepDelta)
			
			rotator.LastStep = now
			
			for name, factors in pairs(self.RotationFactors) do
				local data = motors[name]

				if data then
					local motor = data.Motor
					local origin = data.C0
					
					local pitch = pitchState.Current or 0
					local yaw = yawState.Current or 0
	
					if rotator.SnapFirstPerson and name == "Head" then
						if self:IsInFirstPerson() then
							pitch = pitchState.Goal
							yaw = yawState.Goal
						end
					end
	
					local fPitch = pitch * factors.Pitch
					local fYaw = yaw * factors.Yaw
	
					-- HACK: Make the arms rotate with a tool.
					if name:sub(-4) == " Arm" then
						local tool

						for _,child in pairs(character:children()) do
							if child.className == "Tool" then
								tool = child
								break
							end
						end
						
						if tool then
							fYaw = yaw * .8
						end
					end
	
					local dirty = false
	
					if fPitch ~= pitchState.Value then
						pitchState.Value = fPitch
						dirty = true
					end
	
					if fYaw ~= yawState.Value then
						yawState.Value = fYaw
						dirty = true
					end
	
					if dirty then
						local rot = origin - origin.p
						
						local cf = CFrame.fromEulerAnglesXYZ(0, fPitch, 0)
						         * CFrame.fromEulerAnglesXYZ(fYaw, 0, 0)
						
						motor.C0 = origin * rot:inverse() * cf * rot
					end
				end
			end
		else
			if not dropList then
				dropList = {}
			end
			
			dropList[character] = true
		end
	end
	
	if dropList then
		for character in pairs(dropList) do
			local rotator = self.Rotators[character]
			local listener = rotator and rotator.Listener
			
			if listener then
				listener:disconnect()
			end
			
			self.Rotators[character] = nil
		end
	end
end

function CharacterRealism:MountLookAngle(character)	
	local rotator = character and self.Rotators[character]
	
	if not rotator then
		-- Create a rotator for this character.
		rotator = 
		{
			Motors = {};
			
			Pitch =
			{
				Goal = 0;
				Current = 0;
			};

			Yaw =
			{
				Goal = 0;
				Current = 0;
			};
		}
		
		-- If this is our character, the rotation 
		-- values should not be interpolated while 
		-- the client is in first person.
		
		local player = Players:playerFromCharacter(character)
		
		if player == self.Player then
			rotator.SnapFirstPerson = true
		end
		
		-- Register this rotator for the character.
		self.Rotators[character] = rotator
		
		-- Record all existing Motor joints
		-- and begin recording newly added ones.
		local onChildAdded
		
		function onChildAdded(child)
			if child.className == "Part" then
				for _,desc in pairs(child:children()) do
					onChildAdded(desc)
				end
				
				child.ChildAdded:connect(onChildAdded)
			elseif child.className == "Motor" or child.className == "Snap" then
				self:AddMotor(rotator, child)
			end
		end
		
		for _,child in pairs(character:children()) do
			onChildAdded(child)
		end
		
		rotator.Listener = character.ChildAdded:connect(onChildAdded)
	end
	
	return rotator
end

function CharacterRealism:OnPlayerAdded(player)
	if player.Character then
		self:MountLookAngle(player.Character)
	end

	player.Changed:connect(function (prop)
		if prop == "Character" then
			self:MountLookAngle(player.Character)
		end
	end)
end

function CharacterRealism:Start()
	assert(not _G.DefineRealismClient, "Realism can only be started once on the client!")
	_G.DefineRealismClient = true
	
	if self.Player then
		self:OnPlayerAdded(self.Player)
	end
	
	self:Connect("UpdateLookAngles", RunService.Heartbeat)
end

-- Start automatically.
CharacterRealism:Start()
