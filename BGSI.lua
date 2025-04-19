local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TaskToggleUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true

-- Title Bar
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Text = "Task Toggle UI"
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 18
titleBar.TextXAlignment = Enum.TextXAlignment.Center
titleBar.Parent = frame

-- Scrollable container
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -40)
scrollingFrame.Position = UDim2.new(0, 5, 0, 35)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = frame

-- Layout inside scroll
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame

-- Dynamically adjust canvas height
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.BorderSizePixel = 0
closeButton.Parent = frame
closeButton.ZIndex = 2
closeButton.AutoButtonColor = true

-- Minimize/Maximize toggle
local isMinimized = false

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 30, 0, 30)
toggleButton.Position = UDim2.new(1, -70, 0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 120, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Text = "-"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 20
toggleButton.BorderSizePixel = 0
toggleButton.Parent = frame
toggleButton.ZIndex = 2
toggleButton.AutoButtonColor = true

toggleButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        scrollingFrame.Visible = false
        toggleButton.Text = "+"
        frame.Size = UDim2.new(0, 300, 0, 30)
    else
        scrollingFrame.Visible = true
        toggleButton.Text = "-"
        frame.Size = UDim2.new(0, 300, 0, 350)
    end
end)



-- State and refs
local taskStates = {}
local buttonMap = {}


-- Terminate all tasks on close
closeButton.MouseButton1Click:Connect(function()
    for name, _ in pairs(taskStates) do
        taskStates[name] = false
    end
    screenGui:Destroy()
end)



-- Checkbox creation
local function createCheckbox(name, defaultState, loopFunc, displayName)
    displayName = displayName or name
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = scrollingFrame

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
    label.Text = displayName
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    taskStates[name] = defaultState

    if defaultState then
        task.spawn(loopFunc)
    end

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

function getGemAmount()
    local Players = game:GetService("Players")
    local player = Players:GetPlayers()[1]
    local username = player.Name
    
    local gemValue = player:WaitForChild("PlayerGui")
    :WaitForChild("ScreenGui"):WaitForChild("HUD"):WaitForChild("Left"):WaitForChild("Currency"):WaitForChild("Gems"):WaitForChild("Frame"):WaitForChild("Label").Text
    
    print("Username: ", username)
    print(gemValue)
    
    local gemAmount = tonumber(gemValue:gsub(",", ""))
    return gemAmount
end

function openGifts(amount)
    local args = {
        [1] = "UseGift",
        [2] = "Mystery Box",
        [3] = amount
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

    for _, gift in pairs(game:GetService("Workspace"):WaitForChild("Rendered"):WaitForChild("Gifts"):getChildren()) do
        local args = {
            [1] = "ClaimGift",
            [2] = gift.Name
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

        gift:Destroy()
    end
end

createCheckbox("Blow Bubble", true, function()
    task.spawn(function()
        while taskStates["Blow Bubble"] do
            local args = { [1] = "BlowBubble" }
            remote:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

local originalSellPos
createCheckbox("Auto Sell", false, function()
    task.spawn(function()
        while taskStates["Auto Sell"] do
            local args = {
                [1] = "SellBubble"
            }
            local autoSellRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("Twilight"):WaitForChild("Island"):WaitForChild("Sell"):WaitForChild("Root")
            if not originalSellPos then
                originalSellPos = autoSellRoot.CFrame
            end


            local player =game.Players.localPlayer
            local name = player.Name

            workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame = autoSellRoot.CFrame

            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

            task.wait(0.1)
        end
    end)
end,
"Auto Sell - Broken")

createCheckbox("Open Island Chest", false, function()
    task.spawn(function()
        while taskStates["Open Island Chest"] do
            local args = {
                [1] = "UnlockRiftChest",
                [2] = "golden-chest",
                [3] = false
            }
            remote:FireServer(unpack(args))
            task.wait(0.1)
        end
    end)
end)

createCheckbox("Claim Chests", true, function()
    task.spawn(function()
        while taskStates["Claim Chests"] do
            local remote = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9)
                :WaitForChild("Framework", 9e9)
                :WaitForChild("Network", 9e9)
                :WaitForChild("Remote", 9e9)
                :WaitForChild("Event", 9e9)

            remote:FireServer("ClaimChest", "Infinity Chest")

            remote:FireServer("ClaimChest", "Void Chest", true)

            remote:FireServer("ClaimChest", "Giant Chest", true)

            remote:FireServer("ClaimRiftGift", "gift-rift")

            task.wait(10)
        end
    end)
end)

afk_counter = 0

createCheckbox("Anti AFK", true, function()
    task.spawn(function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            if taskStates["Anti AFK"] then
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                print("Anti-AFK triggered VirtualUser input.")
                task.wait(600)
            end
        end)
    end)
end)


createCheckbox("Auto Craft Potions", false, function() 
    potionTypes = {"Lucky", "Speed", "Mythic", "Coins"}

    for _, potion in potionTypes do
        for i = 1, 5 do
            local args = {
                [1] = "CraftPotion";
                [2] = potion;
                [3] = i;
                [4] = true;
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
        end
    end

    taskStates["Auto Craft Potions"] = false
    local ref = buttonMap["Auto Craft Potions"]
    if ref then
        ref.checkmark.Visible = false
    end
end)

createCheckbox("Buy Alien Shop", true, function()
    task.spawn(function()
        while taskStates["Buy Alien Shop"] do
            for i = 1, 3 do
                local args = {
                    [1] = "BuyShopItem";
                    [2] = "alien-shop";
                    [3] = i;
                }

                game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
            end

            task.wait(0.1)
        end
    end)
end)

createCheckbox("Buy Blackmarket Shop", true, function()
    task.spawn(function()
        while taskStates["Buy Blackmarket Shop"] do
            for i = 1, 3 do
                local args = {
                    [1] = "BuyShopItem",
                    [2] = "shard-shop",
                    [3] = i
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
            end

            task.wait(0.1)
        end
    end)
end)

createCheckbox("Claim Playtime Rewards", true, function()
    task.spawn(function()
        while taskStates["Claim Playtime Rewards"] do
            for i=1, 9 do 
                local args = {
                    [1] = "ClaimPlaytime";
                    [2] = i;
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Function", 9e9):InvokeServer(unpack(args))
            end

        task.wait(10)
        end
    end)
end)

createCheckbox("Claim Spinwheels", true, function()
    task.spawn(function()
        while taskStates["Claim Spinwheels"] do
            local args = {
                [1] = "ClaimFreeWheelSpin";
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))

            task.wait(10)
        end
    end)
end)

createCheckbox("Use Tickets", false, function()
    task.spawn(function()
        while taskStates["Use Tickets"] do

            local args = {
                [1] = "WheelSpin";
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Function", 9e9):InvokeServer(unpack(args))

            local args = {
                [1] = "ClaimWheelSpinQueue";
            }

            game:GetService("ReplicatedStorage"):WaitForChild("Shared", 9e9):WaitForChild("Framework", 9e9):WaitForChild("Network", 9e9):WaitForChild("Remote", 9e9):WaitForChild("Event", 9e9):FireServer(unpack(args))
            
            task.wait(0.1)
        end
    end)
    end,
    "Use Tickets <Only Enable if in zone and disable afterwards otherwise bugs out>"
)

createCheckbox("Myster Gift", false, function()
    task.spawn(function()
        while taskStates["Myster Gift"] do
            openGifts(10)

            task.wait(0.1)
        end
    end)
end, "Mystery Gift x10")

createCheckbox("Auto Collect Coints", false, function()
    task.spawn(function()
        while taskStates["Auto Collect Coints"] do
            local renderedStorage = Workspace:WaitForChild("Rendered")

            for _, folder in pairs(renderedStorage:getChildren()) do
                if folder.Name == "Chunker" then
                    for _, chunker in pairs(folder:getChildren()) do
                        if (chunker:IsA("Model")) and chunker.Name:match("%x%-") then
                            local args = {
                                [1] = chunker.Name
                            }
                        
                            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Pickups"):WaitForChild("CollectPickup"):FireServer(unpack(args))
                            chunker:Destroy()
                        end
                    end
                end
            end

            task.wait(0.1)
        end
    end)
end)

local genieOldPos
local isOpenGenie = false
createCheckbox("Open Genie Menu", false, function()
    taskStates["Open Genie Menu"] = false
    local genieRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("Zen"):WaitForChild("Island"):WaitForChild("GemGenie"):WaitForChild("Root")

    if isOpenGenie then
        genieRoot.CFrame = genieOldPos
        isOpenGenie = false
        local ref = buttonMap["Open Genie Menu"]
        if ref then
            ref.checkmark.Visible = false
        end
        return
    end

    local player =game.Players.localPlayer
    local name = player.Name

    local cframePos = workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame

    genieOldPos = genieRoot.CFrame

    genieRoot.CFrame = cframePos
    isOpenGenie = true
end)

local blackmarkedOldPos
local isOpenBlack = false
createCheckbox("Open Blackmarked", false, function()
    taskStates["Open Blackmarked"] = false
    local blackmarkedRoot = workspace:WaitForChild("Worlds"):WaitForChild("The Overworld"):WaitForChild("Islands"):WaitForChild("The Void"):WaitForChild("Island"):WaitForChild("Vendor"):WaitForChild("Activation"):WaitForChild("Root")

    if isOpenBlack then
        blackmarkedRoot.CFrame = blackmarkedOldPos
        isOpenBlack = false
        local ref = buttonMap["Open Blackmarked"]
        if ref then
            ref.checkmark.Visible = false
        end
        return
    end 

    local player =game.Players.localPlayer
    local name = player.Name

    local cframePos = workspace:WaitForChild(name):WaitForChild("HumanoidRootPart").CFrame

    blackmarkedOldPos = blackmarkedRoot.CFrame

    blackmarkedRoot.CFrame = cframePos
    isOpenBlack = true
end)
