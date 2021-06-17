-- Script by supermarioclub231 as known as marioroblox102, and special thanks to jacko for some scripts things

-- Resize script
coroutine.resume(coroutine.create(

function()
    local CoreGui = game:GetService("CoreGui")
    while not CoreGui:FindFirstChild("RobloxGui") do
        CoreGui.ChildAdded:wait()
    end
    
    local RobloxGui = CoreGui.RobloxGui
    
    local BottomLeftControl = RobloxGui:FindFirstChild("BottomLeftControl")
    local BottomRightControl = RobloxGui:FindFirstChild("BottomRightControl")
    local TopLeftControl = RobloxGui:FindFirstChild("TopLeftControl")
    
    local BuildTools = RobloxGui:FindFirstChild("BuildTools")
    
    function makeYRelative()
        BottomLeftControl.SizeConstraint = 2
        BottomRightControl.SizeConstraint = 2
        if TopLeftControl then
            TopLeftControl.SizeConstraint = 2
        end
        if BuildTools then
            BuildTools.Frame.SizeConstraint = 2
        end
        BottomLeftControl.Position = UDim2.new(0, 0, 1, -BottomLeftControl.AbsoluteSize.Y)
        BottomRightControl.Position =
            UDim2.new(1, -BottomRightControl.AbsoluteSize.X, 1, -BottomRightControl.AbsoluteSize.Y)
    end
    
    function makeXRelative()
        BottomLeftControl.SizeConstraint = 1
        BottomRightControl.SizeConstraint = 1
        if TopLeftControl then
            TopLeftControl.SizeConstraint = 1
        end
        if BuildTools then
            BuildTools.Frame.SizeConstraint = 1
        end
        BottomLeftControl.Position = UDim2.new(0, 0, 1, -BottomLeftControl.AbsoluteSize.Y)
        BottomRightControl.Position =
            UDim2.new(1, -BottomRightControl.AbsoluteSize.X, 1, -BottomRightControl.AbsoluteSize.Y)
    end
    
    local function resize()
        if RobloxGui.AbsoluteSize.x > RobloxGui.AbsoluteSize.y then
            makeYRelative()
        else
            makeXRelative()
        end
    end
    
    RobloxGui.Changed:connect(
        function(property)
            if property == "AbsoluteSize" then
                wait()
                resize()
            end
        end
    )
    
    wait()
    resize()()
    
    
end))

-- Player
local plr = game.Players:CreateLocalPlayer(0)
game:GetService("Visit")
game:GetService("RunService"):run()
plr:LoadCharacter()

-- have to do this so that the same numbers arent generated every time
math.randomseed(os.time())
math.random(); math.random(); math.random()

digits = 4 -- the amount of times to add digits to the end of the player name

prefix = "NoName "
suffix = "" -- wouldnt wanna type anything here, the digits will be added here!

for i=1, digits do
    suffix = suffix .. math.random(1,9)
    i = i + 1;
end

plr.Name = prefix .. suffix

while true do
    wait(0.001)
    if plr.Character.Humanoid.Health <= 0 then
        wait(5)
        plr:LoadCharacter(true)
    elseif plr.Character.Parent  == nil then 
      wait(5) 
      plr:LoadCharacter(true) 
    end
end
