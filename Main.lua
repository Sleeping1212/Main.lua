local camlock = false
local lockedTarget = nil

-- Print message to indicate script has loaded
print("Batman Loaded")

-- Create ScreenGui and parent to CoreGui to persist after death
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui") -- Parent to CoreGui to persist through respawns

-- Create Toggle Button (TextButton for click detection)
local button = Instance.new("TextButton")
button.Parent = screenGui
button.Size = UDim2.new(0, 150, 0, 50) -- Size of the button
button.Position = UDim2.new(0.5, -75, 0.1, 0) -- Centered button
button.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Default to red (untoggled)
button.BorderSizePixel = 2
button.BorderColor3 = Color3.fromRGB(0, 0, 0) -- Border color
button.Text = "Batman ON"
button.TextScaled = true
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.Draggable = true -- Make the button draggable

-- Create Username Notification Label
local usernameLabel = Instance.new("TextLabel")
usernameLabel.Parent = screenGui
usernameLabel.Size = UDim2.new(0, 200, 0, 50)
usernameLabel.Position = UDim2.new(1, -210, 1, -60) -- Bottom-right position
usernameLabel.AnchorPoint = Vector2.new(1, 1)
usernameLabel.BackgroundTransparency = 0.5
usernameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
usernameLabel.TextColor3 = Color3.new(1, 1, 1)
usernameLabel.TextScaled = true
usernameLabel.Font = Enum.Font.GothamBold
usernameLabel.Visible = false -- Initially hidden

-- Toggle camlock on button click
button.MouseButton1Click:Connect(function()
    camlock = not camlock
    if camlock then
        button.Text = "Batman OFF"
        button.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Turn green when toggled on
    else
        button.Text = "Batman ON"
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Turn red when toggled off
        lockedTarget = nil -- Unlock target
        usernameLabel.Visible = false
    end
end)

-- Function to find the closest player
local function findClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge -- No limit on distance

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Smooth camera transition function with maximum aim prediction logic
local function smoothCameraTransition(targetPosition, targetVelocity)
    local camera = workspace.CurrentCamera
    local transitionSpeed = 0.15 -- Adjust for speed of transition

    while camlock and lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart") do
        local humanoidRootPart = lockedTarget.Character.HumanoidRootPart
        
        -- Advanced aim prediction
        local predictedPosition = humanoidRootPart.Position + humanoidRootPart.Velocity * 0.2
        local targetCFrame = CFrame.new(camera.CFrame.Position, predictedPosition)
        
        -- Smoothly transition the camera to follow the predicted position
        camera.CFrame = camera.CFrame:Lerp(targetCFrame, transitionSpeed)
        game:GetService("RunService").RenderStepped:Wait()
    end
end

-- Update the camera to look at the locked player's HumanoidRootPart
game:GetService("RunService").RenderStepped:Connect(function()
    if camlock then
        if not lockedTarget or not lockedTarget.Character or not lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
            -- Find a new target if the current one is invalid or doesn't exist
            lockedTarget = findClosestPlayer()
            if lockedTarget then
                usernameLabel.Text = "Locked onto: " .. lockedTarget.Name
                usernameLabel.Visible = true
                wait(3)
                usernameLabel.Visible = false
            end
        end

        if lockedTarget and lockedTarget.Character and lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
            smoothCameraTransition(lockedTarget.Character.HumanoidRootPart.Position, lockedTarget.Character.HumanoidRootPart.Velocity)
        end
    end
end)
