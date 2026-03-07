--by Soliviant, Put this thing in StarterCharacterScripts as either a script or localscript
local Velocity = Vector3.new()
local CurrentVelocity = Vector3.new()
local Grav = Vector3.new(0,-workspace.Gravity,0) -- gets gravity from workspace and turns it into a vector
local walkspeed = 16 -- How much player's input should apply
local Pivot = nil -- the part or something it pivots around, SET SOMETHING HERE.
--this thing below determines the pivot's position, it checks if the Pivot variable is an instance, then handle accordinly, Model does not have a .Position right away currently, so it must be handled specifically.
local PivotPosition = ((Pivot and typeof(Pivot) == 'Instance') and (Pivot:IsA('Model') and Pivot:GetPivot().Position or Pivot:IsA('BasePart') and  Pivot.Position)) or Vector3.new(0,50,0)
local maxVelocity = 100	 -- Terminal velocity
local springConstant = 500 -- ts called K in the spring formula (F = kx; simple harmonic, look it up), try messing with it
local dampingConstant = 50 -- (To interrupt the ideal oscillation from going on forever), try messing with it
local Length = 30 -- Rope Length

while script:FindFirstAncestorWhichIsA('Model') do -- checks whether there is a model parent, usually character
	local dt = task.wait() -- do you know task.wait() returns the time that it waited?
	local character = script:FindFirstAncestorWhichIsA('Model') --  well, set the variable, what about it?
	--PivotPosition = Vector3.new(math.sin(os.clock()) * 50, 50 + math.sin(os.clock() * 4) * 10, math.cos(os.clock()) * 50) --[[u can change the thing during runtime]]
	local dist = -(PivotPosition - character:GetPivot().Position) -- so uhh, you can just swap the two, I'm too lazy for that
	--ts exist in things that should try to pull you back when exceeding the range and stuff
	local tension = -dist.Unit * math.max(0, (springConstant * (dist.Magnitude - Length) --[[if the distance of the chracter to the pivot is under ropelength, it will be 0, this can only increase]]) + (dampingConstant * CurrentVelocity:Dot(dist.Unit) -- [[air resistance that should only apply onto the rope, dot here kinda tells how similar two vectors are, In roblox for some reason they are -1 to 1, that only happens if they are both unit vectors(vector with single magnitude, mostly only made to show direction)]]
		))
	-- so there's like two forces, damping and uhh spring(since we remove the thing from ever creating the force for the character getting too near the pivot, it will only tryna pull back from extending the rope too much)
	if dist.Magnitude > Length * 1.2 then -- lowky just making the rope flexible with that extra 0.2 (in which wouldn't happen IRL because ropes are rigid)
		dist=dist.Unit * math.min(dist.Magnitude, Length * 1.2)
		character:PivotTo(character:GetPivot().Rotation + (PivotPosition + dist)) 
	end
	local PlayerInput = Vector3.new(0, 0, 0) -- fallback when there's no humanoid
		local Hum = character:FindFirstChildOfClass('Humanoid') -- humanoid
		if Hum then -- is it real?
			PlayerInput = (Hum.MoveDirection / dt) * walkspeed -- gets the movedirection from humanoid and cancels out the delta time(because dt will be multiplied with ts later), then make the already unit vector have the magnitude of walkspeed
		if character:FindFirstChildOfClass('Humanoid').RootPart then
			character:FindFirstChildOfClass('Humanoid').RootPart.Anchored = true -- you need to lock the rootpart or Roblox's physics might do the funny.
		end
	end
	local DecayFactor = math.clamp(dt / 5, 0, 0.1) -- decay overtime
	local NetForce = Grav + tension + PlayerInput -- it just adds up all the forces
	if NetForce.Magnitude < 0.01 then
		CurrentVelocity = CurrentVelocity * math.clamp(1 - DecayFactor * 2.5,0,1) -- decay by removing that 100% with some of the decay
	else
		CurrentVelocity = (CurrentVelocity + NetForce * dt) * math.clamp(1 - DecayFactor,0,1)
	end
	if CurrentVelocity.Magnitude > maxVelocity then
		CurrentVelocity = CurrentVelocity.Unit * maxVelocity
		-- terminal vel 2 the backup
	end
	character:PivotTo(character:GetPivot() + CurrentVelocity * dt) -- move the character according to the velocity, End = Start + (Velcity * ElapsedTime)
end