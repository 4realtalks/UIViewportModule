--[[ // Made by DreamyMythic // ]]

--[[
    Note: Do not edit anything if you're don't know what you're doing.
    Recommendations:
        Put this in ReplicatedStorage to make this module accessible in the client-side.

    Note Number 2: Use the correct function calls in prevent for less errors.

    Common Questions:
        1. What does this module made for?
            This module considered to be an easy way to add an object into your ViewportFrame.

        2. After I call "ViewportModule:AddicateObject()" do I need to put any arguments?
            No, this function call should use Object from the metatable that came from ViewportModule.new().

        3. Do I need to rotate an object manually?
            Yes, you need to manually call "ViewportModule:RotateObject()" which uses a cloned object
            from "ViewportModule:AddicateObject()" then rotates the object to your specified arguments.

    
    Need more help?, Join discord server: https://discord.gg/GmGfpVyC9X (Thai-Made)
    Or ask a question in Jackhammer Studios' group wall.
]]

--[[
    Note: This is a free module for developers that allows you to add an object into your ViewportFrame easily.

    Available functions:
    ViewportModule.new(Object, ViewportFrame, Camera)
        Inits a new ViewportModule.
        Object: Model,
        ViewportFrame: ViewportFrame,
        Camera: Camera

    ViewportModule:AddicateObject(CameraFieldOfView)
        Adds an object you specified in ViewportModule.new()
        and modifies FOV in your specified Camera.
        CameraFieldOfView: number

    ViewportModule:RemoveObject()
        Removes an object you specified in ViewportModule.new()
        out from specified ViewportFrame in ViewportModule.new().

    ViewportModule:RotateObject(Rotation, TweenSetting (Optional))
        Rotates a specified Object in Viewport.new() with a specified Rotation.
        Recommended to put in TweenSetting which is type of TweenInfo to make the
        rotation smoother.
        Rotation: Vector3
        TweenSetting: TweenInfo

    ViewportModule:AlreadyCreated()
        Checks if the ViewportModule:AddicateObject() was called
        by checking the current cloned object.

    ViewportModule:IsRotating()
        Checks if the current cloned object rotating.

    ViewportModule:RemoveRotationAfterTweeningCompletes(): Not Recommended
        Deletes the rotation after the rotation tween completed.
        
    ViewportModule:IsCloneRemoved()
        Checks if the cloned object was removed.

    ViewportModule:Yield(YieldTime)
        Yields the current thread. (Similiar to wait() and task.wait())
        YieldTime: number

    ViewportModule:IsYielding()
        Checks if the current thread is yielding.

    ViewportModule:CheckError(Callback)
        Checks if the Callback have an error of your function call or the module.
        Callback: function

    Examples:
    local Viewport = ViewportModule.new(
        workspace.DreamyMythic,
        player.PlayerGui.ScreenGui.ViewportFrame,
        Instance.new("Camera", player.PlayerGui.ScreenGui.ViewportFrame),
    )

    Viewport:AddicateObject()
    Viewport:RotateObject(
        Vector3.new(
            1,
            0,
            0
        ),
        TweenInfo.new(
            1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )
    )
]]

--//Services//
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--//Tables//
local ViewportModule = {}
ViewportModule.__index = ViewportModule

--//Variables//
local CurrentYieldTime = 0

--//Functions//
function ViewportModule.new(Object: Model, ViewportFrame: ViewportFrame, Camera: Camera)
	assert(typeof(Object) == "Instance", `❌Object must be Instance. Got: {typeof(Object)}`)
	assert(typeof(ViewportFrame) == "Instance", `❌ViewportFrame must be Instance. Got: {typeof(ViewportFrame)}`)
	assert(typeof(Camera) == "Instance", `❌Camera must be Instance. Got: {typeof(Camera)}`)

	local self = setmetatable(
		{
			_Object = Object;
			_ViewportFrame = ViewportFrame;
			_Camera = Camera;
            _ClonedObject = nil;
            _Connection = nil;
            _Yeilding = false;
			Succeed = function()
				if (typeof(Object) == "Instance" and Object:IsA("Model") and Object ~= nil)
					and (typeof(ViewportFrame) == "Instance" and ViewportFrame:IsA("ViewportFrame") and ViewportFrame ~= nil)
					and (typeof(Camera) == "Instance" and Camera:IsA("Camera"))
				then
					return true
				else
					return false
				end
			end;
		},
		ViewportModule
	)

	return self
end

function ViewportModule:AddicateObject(CameraFieldOfView: number)
	assert(typeof(CameraFieldOfView) == "number", `❌CameraFieldOfView must be number. Got: {typeof(CameraFieldOfView)}`)

	if (self._Object ~= nil)
		and (self._Object.PrimaryPart ~= nil)
		and (self._ViewportFrame ~= nil)
		and (self._Camera ~= nil)
		and (CameraFieldOfView ~= nil)
		and self.Succeed()
	then
		local CloneObject = self._Object:Clone()
		CloneObject.Parent = self._ViewportFrame

		CloneObject:PivotTo(CFrame.new(0, 0, 0))

		self._Camera.FieldOfView = CameraFieldOfView
		self._Camera.CFrame = CFrame.lookAt(
			CloneObject.PrimaryPart.Position,
			CloneObject.PrimaryPart.Position,
			Vector3.new(0, 0, -5)
		)

		self._ViewportFrame.CurrentCamera = self._Camera

        self._ClonedObject = CloneObject
	else
		warn("❌Could not add Object into your ViewportFrame. Makesure to use a correct function call\nOr this module maybe contains errors.")
	end
end

function ViewportModule:RotateObject(Rotation: Vector3, TweenSetting: TweenInfo)
	assert(typeof(Rotation) == "Vector3", `❌CameraFieldOfView must be number. Got: {typeof(Rotation)}`)

	if TweenSetting then
		assert(typeof(TweenSetting) == "TweenInfo", `❌TweenSetting must be TweenInfo. Got: {typeof(TweenSetting)}`)

		if (self._ClonedObject ~= nil and self._ClonedObject:IsA("Model")) then
			local Tween = TweenService:Create(self._ClonedObject, TweenSetting, {Orientation = Rotation})
			Tween:Play()

			self._Connection = Tween
		else
			warn(`{self._ClonedObject} is not a Model. Current class: {self._ClonedObject.ClassName}`)
		end
	else
		if (self._ClonedObject ~= nil and self._ClonedObject:IsA("Model")) then
			self._ClonedObject.PrimaryPart.Orientation = self._ClonedObject.PrimaryPart.Orientation + Rotation
		else
			warn(`{self._ClonedObject} is not a Model. Current class: {self._ClonedObject.ClassName}`)
		end
	end
end

function ViewportModule:AlreadyCreated()
	if self._ClonedObject ~= nil then
		return true
	else
		return false
	end
end

function ViewportModule:IsRotating()
	if self._Connection ~= nil then
		return true
	else
		return false
	end
end

function ViewportModule:RemoveRotationAfterTweeningCompletes()
	if typeof(self._Connection) ~= "RBXScriptConnection" then
		self._Connection.Completed:Connect(function()
			self._Connection = nil
		end)
	else
		return
	end
end

function ViewportModule:RemoveObject()
	if (self._ClonedObject.Parent == self._ViewportFrame)
		and self.Succeed()
	then
		self._ClonedObject:Destroy()
		self._ClonedObject = nil
	else
		warn("❌Could not remove Object from your ViewportFrame. Makesure to use a correct function call\nOr this module maybe contains errors.")
	end
end

function ViewportModule:IsCloneRemoved()
	if self._ClonedObject == nil then
		return true
	else
		return false
	end
end

-- function ViewportModule:Yield(YieldTime: number)
-- 	assert(typeof(YieldTime) == "number", `❌YieldTime must be number. Got: {typeof(YieldTime)}`)

-- 	CurrentYieldTime = 0

-- 	RunService.Heartbeat:Connect(function()
-- 		if CurrentYieldTime < YieldTime then
-- 			CurrentYieldTime = CurrentYieldTime + (YieldTime / 60)
--             self._Yeilding = true
-- 		elseif CurrentYieldTime >= YieldTime then
--             self._Yeilding = false
-- 		end
-- 	end)

-- 	return task.wait(YieldTime)
-- end

-- function ViewportModule:IsYielding()
-- 	if self._Yeilding then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

function ViewportModule:CheckError(Callback)
	assert(typeof(Callback) == "function", `❌Callback must be a function call. Got: {typeof(Callback)}`)

	if Callback then
		local Success, Errormessage = pcall(Callback)

		if not Success then
			warn(`❌Errors found in "{Callback}". ({Errormessage})`)
		else
			print(`✅No errors found in the callback "{Callback}"`)
		end
	end
end

return ViewportModule