-- UI Setup
local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TaskToggleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true



local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = frame


local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.BorderSizePixel = 0
closeButton.Parent = frame
closeButton.ZIndex = 2
closeButton.AutoButtonColor = true

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- State and refs
local taskStates = {}
local buttonMap = {}

-- Checkbox creation
local function createCheckbox(name, defaultState, loopFunc)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 24, 0, 24)
    checkbox.Position = UDim2.new(0, 0, 0.5, -12)
    checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.AutoButtonColor = false
    checkbox.Parent = container

    local checkmark = Instance.new("ImageLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.Position = UDim2.new(0, 0, 0, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Image = "rbxassetid://6031094678" -- checkmark icon
    checkmark.ImageColor3 = Color3.new(1, 1, 1)
    checkmark.Visible = defaultState
    checkmark.Parent = checkbox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    taskStates[name] = defaultState

    checkbox.MouseButton1Click:Connect(function()
        taskStates[name] = not taskStates[name]
        checkmark.Visible = taskStates[name]

        if taskStates[name] then
            print(name .. " enabled")
            task.spawn(function()
                loopFunc()
            end)
        else
            print(name .. " disabled")
        end
    end)

    buttonMap[name] = {
        button = checkbox,
        checkmark = checkmark,
        label = label,
        container = container
    }
end

-- Remote path
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
    :WaitForChild("Framework", 9e9)
    :WaitForChild("Network", 9e9)
    :WaitForChild("Remote", 9e9)
    :WaitForChild("Event", 9e9)

-- Task 1: BlowBubble loop
createCheckbox("Blow Bubble", false, function()
    while taskStates["Blow Bubble"] do
        local args = { [1] = "BlowBubble" }
        remote:FireServer(unpack(args))
        task.wait(0.1)
    end
end)

-- Task 2: Unlock Rift Chest loop
createCheckbox("Open Island Chest", false, function()
    while taskStates["Open Island Chest"] do
        local args = {
            [1] = "UnlockRiftChest",
            [2] = "golden-chest"
        }
        remote:FireServer(unpack(args))
        task.wait(0.1)
    end
end)

createCheckbox("Claim Chests", false, function()
    task.spawn(function()
        while taskStates["Claim Chests"] do
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
                :WaitForChild("Framework", 9e9)
                :WaitForChild("Network", 9e9)
                :WaitForChild("Remote", 9e9)
                :WaitForChild("Event", 9e9)

            -- Fire Infinity Chest
            remote:FireServer("ClaimChest", "Infinity Chest")

            -- Fire Void Chest
            remote:FireServer("ClaimChest", "Void Chest", true)

            -- Fire Giant Chest
            remote:FireServer("ClaimChest", "Giant Chest", true)

            task.wait(10)
        end
    end)
end)
