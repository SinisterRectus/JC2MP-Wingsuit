class 'Wingsuit'

function Wingsuit:__init()
	
	self.default_speed = 51 -- 51 m/s default
	self.max_speed = 300 -- 300 m/s default
	self.speed = self.default_speed
	
	Events:Subscribe("KeyUp", self, self.Activate)

end

function Wingsuit:Activate(args)

	if args.key == VirtualKey.Shift and not self.velocity_sub and LocalPlayer:GetState() == PlayerState.OnFoot then
		if not self.timer or self.timer:GetMilliseconds() > 500 then
			self.timer = Timer()
		elseif self.timer:GetMilliseconds() < 500 and not self.delay then
			self.timer = nil
			self.camera_sub = Events:Subscribe("CalcView", self, self.Camera)
			local timer = Timer()
			self.delay = Events:Subscribe("PreTick", self, function(self)
				LocalPlayer:SetLinearVelocity(LocalPlayer:GetAngle() * Vector3(0, 5, -5))
				if timer:GetMilliseconds() > 1000 then
					self.speed = self.default_speed
					Events:Unsubscribe(self.delay)
					self.delay = nil
					LocalPlayer:SetBaseState(AnimationState.SSkydive)
					self.velocity_sub = Events:Subscribe("Render", self, self.Velocity)
					self.input_sub = Events:Subscribe("LocalPlayerInput", self, self.InputBlock)
				end
			end)
		end
	elseif args.key == VirtualKey.Control and self.velocity_sub then
		if not self.timer or self.timer:GetMilliseconds() > 500 then
			self.timer = Timer()
		elseif self.timer:GetMilliseconds() < 500 then
			LocalPlayer:SetLinearVelocity(LocalPlayer:GetLinearVelocity() * 0)
			LocalPlayer:SetBaseState(AnimationState.SFall)
			Events:Unsubscribe(self.velocity_sub)
			Events:Unsubscribe(self.camera_sub)
			Events:Unsubscribe(self.input_sub)
			self.velocity_sub = nil
			self.camera_sub = nil
			self.input_sub = nil
		end
	end

end


function Wingsuit:Velocity()

	if LocalPlayer:GetBaseState() ~= AnimationState.SSkydive then
		Events:Unsubscribe(self.velocity_sub)
		Events:Unsubscribe(self.camera_sub)
		Events:Unsubscribe(self.input_sub)
		self.velocity_sub = nil
		self.camera_sub = nil
		self.input_sub = nil
		return
	end
	
	if Key:IsDown(VirtualKey.Shift) and self.speed < self.max_speed then
		self.speed = self.speed + 1
	elseif Key:IsDown(VirtualKey.Control) and self.speed > 0 then
		self.speed = self.speed - 1
	end
	
	-- local speed = self.speed - math.sin(LocalPlayer:GetAngle().pitch) * 0.2 * self.speed
	local speed = self.speed - math.sin(LocalPlayer:GetAngle().pitch) * 20
		
	LocalPlayer:SetLinearVelocity(LocalPlayer:GetAngle() * Vector3(0, 0, -speed))
	
	local speed_string = string.format("%i km/h   %i m", LocalPlayer:GetLinearVelocity():Length() * 3.6, LocalPlayer:GetPosition().y - 200)
	local position = Vector2(0.5 * Render.Width - 0.5 * Render:GetTextWidth(speed_string, TextSize.Large), Render.Height - Render:GetTextHeight(speed_string, TextSize.Large))
	
	Render:DrawText(position, speed_string, Color.White, TextSize.Large)

end

function Wingsuit:InputBlock(args)

	if args.input == Action.LookLeft or args.input == Action.LookRight or args.input == Action.LookUp or args.input == args.input == Action.LookDown then
		return false
	end

end

function Wingsuit:Camera()

	Camera:SetPosition(LocalPlayer:GetPosition() + LocalPlayer:GetAngle() * Vector3(0, 2, 7))
	Camera:SetAngle(Angle.Slerp(Camera:GetAngle(), LocalPlayer:GetAngle(), 0.9))

end

Wingsuit = Wingsuit()
