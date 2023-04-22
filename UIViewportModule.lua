--[[ // Made by DreamyMythic // ]]

--[[

]]

--//Services//
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--//Tables//
local ViewportModule = {}

--//Functions//
function ViewportModule.new(Object: Model, ViewportFrame: ViewportFrame, Camera: Camera, Rotate: boolean)
    assert(typeof(Object) == "Instance", `Object must be Instance. Got: {typeof(Object)}`)
    assert(typeof(ViewportFrame) == "Instance", `ViewportFrame must be Instance. Got: {typeof(ViewportFrame)}`)
    assert(typeof(Camera) == "Instance", `Camera must be Instance. Got: {typeof(Camera)}`)
    assert(typeof(Rotate) == "boolean", `Rotate must be boolean. Got: {typeof(Rotate)}`)

    local self = setmetatable(
        {
            _Object = Object,
            _ViewportFrame = ViewportFrame,
            _Camera = Camera,
            _Rotate = Rotate,
            Succeed = function()
                if (typeof(Object) == "Instance" and Object:IsA("Model") and Object ~= nil)
                    and (typeof(ViewportFrame) == "Instance" and ViewportFrame:IsA("ViewportFrame") and ViewportFrame ~= nil)
                    and (typeof(Camera) == "Instance" and Camera:IsA("Camera") and ViewportFrame ~= nil)
                    and (typeof(Rotate) == "boolean" and Rotate ~= nil)
                then
                    return true
                else
                    return false
                end
            end
        },
        ViewportModule
    )

    return self
end

function ViewportModule:AddicateObject(CameraFieldOfView: number)
    assert(typeof(CameraFieldOfView) == "number", `CameraFieldOfView must be number. Got: {typeof(CameraFieldOfView)}`)

    if (self._Object ~= nil)
        and (self._Object.PrimaryPart ~= nil)
        and (self._ViewportFrame ~= nil)
        and (self._Camera ~= nil)
        and (CameraFieldOfView ~= nil)
        and self.Succeed()
    then
        local CloneObject = self._Object:Clone()
        CloneObject.Parent = self._ViewportFrame

        self._Camera.FieldOfView = CameraFieldOfView
        self._Camera.CFrame = CFrame.lookAt(
            CloneObject.PrimaryPart.Position,
            CloneObject.PrimaryPart.Position,
            Vector3.new(0, 0, 0)
        )

        self._ViewportFrame.CurrentCamera = self._Camera

        setmetatable(
            {
                _ClonedObject = CloneObject
            },
            ViewportModule
        )
    else
        return warn("Could not add Object into your ViewportFrame. Makesure to use a correct function call\nOr this module maybe contains errors.")
    end
end

function ViewportModule:RemoveObject()
    if (self._ClonedObject.Parent == self._ViewportFrame)
        and self.Succeed()
    then
        self._ClonedObject:Destroy()
        self._ClonedObject = nil
    else
        return warn("Could not remove Object from your ViewportFrame. Makesure to use a correct function call\nOr this module maybe contains errors.")
    end
end

function ViewportModule:RotateObject(Rotation: Vector3, TweenSetting: TweenInfo)
    assert(typeof(Rotation) == "number", `CameraFieldOfView must be number. Got: {typeof(Rotation)}`)
    
    if TweenSetting then
        assert(typeof(TweenSetting) == "TweenInfo", `TweenSetting must be TweenInfo. Got: {typeof(TweenSetting)}`)

        local Tween = TweenService:Create(self._Object, TweenSetting, {Orientation = Rotation})
        Tween:Play()
    else
        local Connection = RunService.Heartbeat:Connect(function()
            self._Object.PrimaryPart.Orientation = Rotation
        end)

        setmetatable(
            {
                _Connection = Connection
            },
            ViewportModule
        )
    end
end

return ViewportModule