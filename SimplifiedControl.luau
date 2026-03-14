--By @Solivion; SimplifiedControl.luau; Alternative Character Update 2026; Solivion's Place V1
--ts got Thumbstick support for both Mobile and Gamepad, and buttons for PC and DPad
--this function is from Roblox's ControlModule from PlayerModule, Check it out.
function calculateRawMoveVector(humanoid, cameraRelativeMoveVector)
	local camera = workspace.CurrentCamera
	if typeof(cameraRelativeMoveVector) ~= 'Vector3' then return Vector3.new() end
	if not camera or camera.ClassName ~= 'Camera' then
		return cameraRelativeMoveVector
	end

	if typeof(humanoid) == 'Instance' and humanoid.ClassName == 'Humanoid' and humanoid:GetState() == Enum.HumanoidStateType.Swimming then
		return camera.CFrame:VectorToWorldSpace(cameraRelativeMoveVector)
	end

	local c, s
	local _, _, _, R00, R01, R02, _, _, R12, _, _, R22 = camera.CFrame:GetComponents()
	if R12 < 1 and R12 > -1 then
		c = R22
		s = R02
	else
		c = R00
		s = -R01*math.sign(R12)
	end
	local norm = math.sqrt(c*c + s*s)
	return Vector3.new(
		(c*cameraRelativeMoveVector.x + s*cameraRelativeMoveVector.z)/norm,
		0,
		(c*cameraRelativeMoveVector.z - s*cameraRelativeMoveVector.x)/norm
	)
end

local thumbstickRadius = 50 -- maximum distance from center
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("ContextActionService")
local forward, rightward, leftward, backward = false, false, false, false
local thumbstickMovement = Vector3.new(0, 0, 0) -- For analog gamepad movement
local Fkey, BKey, LKey, RKey = Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.A, Enum.KeyCode.D -- main key
local AFkey, ABKey, ALKey, ARKey = Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right -- alt
local JumpKey = Enum.KeyCode.Space
local player = game:GetService('Players').LocalPlayer
local Mobile = false
local Jump = false
local MBJump = false
local GamepadEnabled = false

pcall(function() -- destroy old
	local plrGUI = player:FindFirstChildOfClass('PlayerGui')
	if plrGUI then
		for i,v in plrGUI:GetChildren() do
			if v.Name == 'MOBILECONTROLLERUI' and v.ClassName == 'ScreenGui' then
				v:Destroy()
			end
		end
	end
end)

function isGamepadButtonPressed(keyCode)
	for _, gamepad in pairs(UIS:GetConnectedGamepads()) do
		local gamepadState = UIS:GetGamepadState(gamepad)
		for _, button in gamepadState do
			if button.KeyCode == keyCode then
				return button.UserInputState == Enum.UserInputState.Begin
			end
		end
	end
	return false
end

function getThumbstickPosition()
	for _, gamepad in pairs(UIS:GetConnectedGamepads()) do
		local gamepadState = UIS:GetGamepadState(gamepad)
		for _, button in gamepadState do
			if button.KeyCode == Enum.KeyCode.Thumbstick1 then
				return button.Position
			end
		end
	end
	return Vector3.new(0, 0, 0)
end

if UIS.GamepadEnabled then
	GamepadEnabled = true
	Fkey, BKey, LKey, RKey = Enum.KeyCode.Thumbstick1Up, Enum.KeyCode.Thumbstick1Down, Enum.KeyCode.Thumbstick1Left, Enum.KeyCode.Thumbstick1Right
	AFkey, ABKey, ALKey, ARKey = Enum.KeyCode.DPadUp, Enum.KeyCode.DPadDown, Enum.KeyCode.DPadLeft, Enum.KeyCode.DPadRight
	JumpKey = Enum.KeyCode.ButtonA
elseif UIS.KeyboardEnabled then
	Fkey, BKey, LKey, RKey = Enum.KeyCode.W, Enum.KeyCode.S, Enum.KeyCode.A, Enum.KeyCode.D
	AFkey, ABKey, ALKey, ARKey = Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right
	JumpKey = Enum.KeyCode.Space
else
	--[[CS:BindAction("Forward", function(n,s,o) if s == Enum.UserInputState.Begin then forward = true elseif s == Enum.UserInputState.End then forward = false end end, true)
	CS:BindAction("Backward", function(n,s,o) if s == Enum.UserInputState.Begin then backward = true elseif s == Enum.UserInputState.End then backward = false end  end, true)
	CS:BindAction("Left", function(n,s,o) if s == Enum.UserInputState.Begin then leftward = true elseif s == Enum.UserInputState.End then leftward = false end  end, true)
	CS:BindAction("Right", function(n,s,o) if s == Enum.UserInputState.Begin then rightward = true elseif s == Enum.UserInputState.End then rightward = false end  end, true)
	CS:BindAction("Jump", function(n,s,o) if s == Enum.UserInputState.Begin then Jump = true end  end, true)
	]] -- old ver, couldn't get it to organized into D-PAD
	Mobile = true
end

while task.wait() and player do
	if not Mobile then
		if GamepadEnabled then
			local thumbstick = getThumbstickPosition()
			if thumbstick.Magnitude > 0.2 then
				thumbstickMovement = Vector3.new(thumbstick.X, 0, -thumbstick.Y)
				thumbstickMovement = thumbstickMovement.Unit * thumbstick.Magnitude
			else
				thumbstickMovement = Vector3.new(0, 0, 0)
			end
			-- D-pad still works as digital input
			forward = isGamepadButtonPressed(Fkey) or isGamepadButtonPressed(AFkey)
			backward = isGamepadButtonPressed(BKey) or isGamepadButtonPressed(ABKey)
			leftward = isGamepadButtonPressed(LKey) or isGamepadButtonPressed(ALKey)
			rightward = isGamepadButtonPressed(RKey) or isGamepadButtonPressed(ARKey)
			Jump = isGamepadButtonPressed(JumpKey)
		else
			if UIS:IsKeyDown(Fkey) or UIS:IsKeyDown(AFkey) then
				forward = true
			else
				forward = false
			end 
			if UIS:IsKeyDown(BKey) or UIS:IsKeyDown(ABKey) then
				backward = true
			else
				backward = false
			end 
			if UIS:IsKeyDown(LKey) or UIS:IsKeyDown(ALKey) then
				leftward = true
			else
				leftward = false
			end 
			if UIS:IsKeyDown(RKey) or UIS:IsKeyDown(ARKey) then
				rightward = true
			else
				rightward = false
			end 
			if UIS:IsKeyDown(JumpKey) then
				Jump = true
			end
		end
	else
		local plrGUI = player:FindFirstChildOfClass('PlayerGui')
		if plrGUI then
			if not plrGUI:FindFirstChild('MOBILECONTROLLERUI') then
				local Holder = Instance.new('ScreenGui', plrGUI)
				Holder.Name = "MOBILECONTROLLERUI"
				local ThumbstickFirst = Instance.new('Frame', Holder)
				local ThumbStickEnd = Instance.new('Frame', Holder)
				pcall(function()
					ThumbstickFirst.Name = 'Ref'
					ThumbStickEnd.Name = 'End' end)
				pcall(function()
					ThumbstickFirst.Size = UDim2.new(0, 100, 0, 100)
					ThumbstickFirst.Position = UDim2.new(0, 40, 1, -140)
					ThumbstickFirst.AnchorPoint = Vector2.new(0, 0)
					ThumbstickFirst.BackgroundColor3 = Color3.new(0, 0, 0)
					ThumbstickFirst.BackgroundTransparency = 0.5
					ThumbstickFirst.Active = true end)
				pcall(function()
					ThumbStickEnd.Size = UDim2.new(0, 20, 0, 20)
					ThumbStickEnd.AnchorPoint = Vector2.new(0.5, 0.5)
					ThumbStickEnd.BackgroundColor3 = Color3.new(1, 1, 1)
					ThumbStickEnd.BackgroundTransparency = 0.5
					ThumbStickEnd.Active = false end)
				local Jump = Instance.new('TextButton', Holder)
				pcall(function()
					Jump.Size = UDim2.new(0, 60, 0, 60)
					Jump.Position = UDim2.new(1, -100, 1, -110)
					Jump.AnchorPoint = Vector2.new(0, 0)
					Jump.BackgroundColor3 = Color3.new(0, 0, 0)
					Jump.BackgroundTransparency = 0.1
					Jump.Text = 'JUMP'
					Jump.TextScaled = true
					Jump.TextColor3 = Color3.new(1, 1, 1)
					Jump.Font = Enum.Font.Code
					Jump.Active = true 
				end)
				pcall(function()
					Jump.MouseButton1Down:Connect(function()
						if Jump.Text == 'JUMP' then
							Jump.BackgroundColor3 = Color3.new(0.5, 0.5, 0.5)
							Jump.Text = 'JUMPIN'
							Jump.TextColor3 = Color3.new(0, 0, 0)
							Jump.BackgroundTransparency = 0.5
							MBJump = true
						end
					end)
					Jump.MouseButton1Up:Connect(function()
						if Jump.Text == 'JUMPIN' then
							Jump.BackgroundColor3 = Color3.new(0, 0, 0)
							Jump.Text = 'JUMP'
							Jump.TextColor3 = Color3.new(1, 1, 1)
							Jump.BackgroundTransparency = 0.1
							MBJump = false
						end
					end)
				end)
				pcall(function()
					local UICORNER2 = Instance.new('UICorner', Jump)
					UICORNER2.CornerRadius = UDim.new(1, 0) end) 
				pcall(function()
					local UICORNER = Instance.new('UICorner', ThumbstickFirst)
					UICORNER.CornerRadius = UDim.new(1, 0) end) pcall(function()
					local UICORNER2 = Instance.new('UICorner', ThumbStickEnd)
					UICORNER2.CornerRadius = UDim.new(0.5, 0) end) pcall(function()
					local Stroke = Instance.new('UIStroke', ThumbstickFirst)
					Stroke.Thickness = 0.1
					Stroke.Color = Color3.new(0, 0, 0)
					Stroke.Transparency = 0.5
					Stroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize end)
				curmoveDir = Vector3.new()

				local thumbstickActive = false -- flag check
				local thumbstickTouchId = nil -- like the id check, check if the touchobject is from same mem address or same enough
				local thumbstickCenter = Vector2.new(ThumbstickFirst.AbsolutePosition.X + ThumbstickFirst.AbsoluteSize.X/2, ThumbstickFirst.AbsolutePosition.Y + ThumbstickFirst.AbsoluteSize.Y/2)
				ThumbStickEnd.Position = UDim2.new(0,thumbstickCenter.X,0,thumbstickCenter.Y) -- refresh to the middle

				ThumbstickFirst.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Touch then
						thumbstickActive = true
						thumbstickTouchId = input
						thumbstickCenter = Vector2.new(ThumbstickFirst.AbsolutePosition.X + ThumbstickFirst.AbsoluteSize.X/2, ThumbstickFirst.AbsolutePosition.Y + ThumbstickFirst.AbsoluteSize.Y/2)
						curmoveDir = Vector3.new()
					end
				end)

				UIS.InputEnded:Connect(function(input, gameProcessed)
					if input == thumbstickTouchId then
						thumbstickActive = false
						thumbstickTouchId = nil
						ThumbStickEnd.Position = UDim2.new(0,thumbstickCenter.X,0,thumbstickCenter.Y)
						curmoveDir = Vector3.new()
					end
				end)

				UIS.InputChanged:Connect(function(input, gameProcessed)
					if input == thumbstickTouchId and thumbstickActive then
						local touchPos = Vector2.new(input.Position.X, input.Position.Y)
						local delta = touchPos - thumbstickCenter
						local distance = math.min(delta.Magnitude, thumbstickRadius)
						local direction = delta.Magnitude > 0 and delta.Unit or Vector2.new(0, 0)
						local newPos = direction * distance
						ThumbStickEnd.Position = UDim2.new(0, thumbstickCenter.X + newPos.X - 10 + ThumbStickEnd.AbsoluteSize.X/2, 0, thumbstickCenter.Y + newPos.Y - 10 + ThumbStickEnd.AbsoluteSize.Y/2)
						curmoveDir = Vector3.new(delta.X * 4/ThumbstickFirst.AbsoluteSize.X, 0, delta.Y * 4/ThumbstickFirst.AbsoluteSize.Y)
					end
				end)
			end
			if typeof(MBJump) == 'boolean' then Jump = MBJump end
		end
	end
	local moveDir = Vector3.new(0, 0, 0)
	if Mobile then
		moveDir = typeof(curmoveDir) == 'Vector3' and curmoveDir or Vector3.new()
	elseif GamepadEnabled and thumbstickMovement.Magnitude > 0 then
		moveDir = thumbstickMovement
	else
		if forward then
			moveDir -= Vector3.new(0, 0, 1)
		end
		if backward then
			moveDir += Vector3.new(0, 0, 1)
		end
		if rightward then
			moveDir += Vector3.new(1, 0, 0)
		end
		if leftward then
			moveDir -= Vector3.new(1, 0, 0)
		end
	end
	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit * math.clamp(moveDir.Magnitude,0,1)
		moveDir = calculateRawMoveVector(typeof(player.Character) == 'Instance' and player.Character:FindFirstChildOfClass('Humanoid') ,moveDir)
	end
	if typeof(moveDir) ~= 'Vector3' or moveDir.X ~= moveDir.X or moveDir.Y ~= moveDir.Y or moveDir.Z ~= moveDir.Z or moveDir.Magnitude == math.huge then moveDir = Vector3.new() end
	if typeof(player.Character) == 'Instance' then local Humanoid = player.Character:FindFirstChildOfClass('Humanoid') if Humanoid then if Jump then Humanoid.Jump = true Jump = false end Humanoid:Move(moveDir, not (typeof(workspace.CurrentCamera) == 'Instance' and workspace.CurrentCamera.ClassName == 'Camera')) end end
	local MVD = typeof(RS) == 'Instance' and RS:FindFirstChild('MVDat') if typeof(MVD) == 'Instance' and MVD.ClassName:match('RemoteEvent') then MVD:FireServer(typeof(moveDir) == 'Vector3' and moveDir or Vector3.new(), typeof(Jump) == 'boolean' and Jump or false) end
	Jump = false -- fixes the glitch where it kinda goes on forever
end