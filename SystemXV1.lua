if true or game.PlaceId == 136162036182779 then
    local OrionLib
    if type(readfile) == "function" and type(isfile) == "function" and isfile("Xeno.lua") then
        OrionLib = loadstring(readfile("Xeno.lua"))()
    else
        OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Lennart567/Main/refs/heads/main/main.lua"))()
    end

    if not OrionLib then
        error("OrionLib konnte nicht geladen werden", 2)
    end
    print("Orion Library erfolgreich geladen")

    local player = game.Players.LocalPlayer
    if not player then
        error("LocalPlayer nicht gefunden", 2)
    end

    local playerGui = player:WaitForChild("PlayerGui")
    local orionGui = game:GetService("CoreGui"):FindFirstChild("Orion") or playerGui:FindFirstChild("Orion")
    if orionGui then
        orionGui.Parent = playerGui
        orionGui.Enabled = true
        print("Orion GUI wurde nach PlayerGui verschoben")
    end

    local Window = OrionLib:MakeWindow({
        Name = "Shadow",
        HidePremium = true,
        PremiumText = "discord.gg/QBAggVjwtW",
        IntroText = "Shadow",
        IntroEnabled = true,
        SaveConfig = true,
        ConfigFolder = "Shadow"
    })

    -- ============================
    -- Services & Variablen
    -- ============================
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local defaultSpeed = 16
    local defaultJumpPower = 50
    local flyEnabled = false
    local flyConnection = nil
    local flySpeed = 50
    local flyAttachment = nil
    local alignOri = nil
    local linVel = nil
    local speedEnabled = false
    local speedConnection = nil
    local customSpeed = 100
    local jumpEnabled = false
    local customJumpPower = 150
    local noclipEnabled = false
    local infJumpEnabled = false

    -- ============================
    -- Hilfsfunktionen
    -- ============================
    local function getChar() return LocalPlayer.Character end
    local function getHum() local c = getChar() return c and c:FindFirstChildWhichIsA("Humanoid") end
    local function getRoot() local c = getChar() return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end

    -- ============================
    -- Fly
    -- ============================
    local function startFly()
        if flyEnabled then return end
        local root = getRoot()
        if not root then return end
        flyAttachment = Instance.new("Attachment")
        flyAttachment.Parent = root
        alignOri = Instance.new("AlignOrientation")
        alignOri.Attachment0 = flyAttachment
        alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOri.MaxTorque = 1000000
        alignOri.Responsiveness = 200
        alignOri.Parent = root
        linVel = Instance.new("LinearVelocity")
        linVel.Attachment0 = flyAttachment
        linVel.MaxForce = 1000000
        linVel.VectorVelocity = Vector3.new()
        linVel.Parent = root
        flyEnabled = true
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled then return end
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveDir += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveDir -= Vector3.new(0, 1, 0)
            end
            if moveDir.Magnitude > 0 then
                linVel.VectorVelocity = moveDir.Unit * flySpeed
            else
                linVel.VectorVelocity = Vector3.new()
            end
            alignOri.CFrame = cam.CFrame
        end)
    end

    local function stopFly()
        flyEnabled = false
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if linVel then linVel:Destroy() linVel = nil end
        if alignOri then alignOri:Destroy() alignOri = nil end
        if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    end

    local function toggleFly()
        if flyEnabled then stopFly() else startFly() end
    end

    -- ============================
    -- Speed Toggle
    -- ============================
    local function toggleSpeed()
        speedEnabled = not speedEnabled
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        local hum = getHum()
        if hum then
            hum.WalkSpeed = speedEnabled and customSpeed or defaultSpeed
        end
        if speedEnabled then
            speedConnection = RunService.Heartbeat:Connect(function()
                local h = getHum()
                if h then h.WalkSpeed = customSpeed end
            end)
        end
    end

    -- ============================
    -- Respawn Handling
    -- ============================
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        local hum = getHum()
        if hum then
            hum.WalkSpeed = speedEnabled and customSpeed or defaultSpeed
            hum.JumpPower = jumpEnabled and customJumpPower or defaultJumpPower
        end
        if flyEnabled then
            startFly()
        end
    end)

    -- ============================
    -- Tabs
    -- ============================
    local PlayerTab = Window:MakeTab({
        Name = "Player",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })

    -- FLY GANZ OBEN IM PLAYER TAB
    PlayerTab:AddSection({Name = "Fly"})

    PlayerTab:AddBind({
        Name = "Toggle Fly (Keybind)",
        Default = Enum.KeyCode.F,
        Hold = false,
        Callback = function() toggleFly() end
    })

    PlayerTab:AddToggle({
        Name = "Enable Fly",
        Default = false,
        Callback = function(v)
            if v then startFly() else stopFly() end
        end
    })

    PlayerTab:AddSlider({
        Name = "Fly Speed",
        Min = 20, Max = 300, Default = 50, Increment = 10,
        Callback = function(v) flySpeed = v end
    })

    -- Speed Section
    PlayerTab:AddSection({Name = "Speed"})
    PlayerTab:AddBind({
        Name = "Toggle Speed (Keybind)",
        Default = Enum.KeyCode.T,
        Hold = false,
        Callback = function() toggleSpeed() end
    })
    PlayerTab:AddSlider({
        Name = "Speed Value",
        Min = 16, Max = 500, Default = 100, Increment = 5,
        Callback = function(v)
            customSpeed = v
            if speedEnabled then
                local hum = getHum()
                if hum then hum.WalkSpeed = v end
            end
        end
    })
    PlayerTab:AddToggle({
        Name = "Enable Speed (GUI Toggle)",
        Default = false,
        Callback = function(v)
            speedEnabled = v
            if speedConnection then speedConnection:Disconnect() speedConnection = nil end
            local hum = getHum()
            if hum then hum.WalkSpeed = v and customSpeed or defaultSpeed end
            if v then
                speedConnection = RunService.Heartbeat:Connect(function()
                    local h = getHum()
                    if h then h.WalkSpeed = customSpeed end
                end)
            end
        end
    })

    -- Jump Section
    PlayerTab:AddSection({Name = "Jump"})
    PlayerTab:AddSlider({
        Name = "Jump Power Value",
        Min = 50, Max = 1000, Default = 150, Increment = 10,
        Callback = function(v)
            customJumpPower = v
            if jumpEnabled then
                local hum = getHum()
                if hum then hum.JumpPower = v end
            end
        end
    })
    PlayerTab:AddToggle({
        Name = "Enable Super Jump",
        Default = false,
        Callback = function(v)
            jumpEnabled = v
            local hum = getHum()
            if hum then hum.JumpPower = v and customJumpPower or defaultJumpPower end
        end
    })
    PlayerTab:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(v) infJumpEnabled = v end
    })

    -- ============================
    -- Movement Tab (nur Noclip)
    -- ============================
    local MoveTab = Window:MakeTab({
        Name = "Movement",
        Icon = "rbxassetid://7733715400"
    })

    MoveTab:AddToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(v)
            noclipEnabled = v
            if not v then
                local char = getChar()
                if char then
                    for _, part in char:GetDescendants() do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end
    })

    -- ============================
    -- Teleport Tab
    -- ============================
    local TpTab = Window:MakeTab({
        Name = "Teleport",
        Icon = "rbxassetid://7734053495",
        PremiumOnly = false
    })

    TpTab:AddSection({Name = "Teleport to Player"})
    local playerDropdown
    local function updatePlayerDropdown()
        local names = {}
        for _, plr in Players:GetPlayers() do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(names, plr.Name)
            end
        end
        if playerDropdown then
            playerDropdown:Refresh(names, true)
        end
    end

    playerDropdown = TpTab:AddDropdown({
        Name = "Select Player",
        Options = {},
        Callback = function(selectedName)
            local target = Players:FindFirstChild(selectedName)
            if target and target.Character then
                local root = getRoot()
                local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if root and targetRoot then
                    root.CFrame = targetRoot.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    })

    updatePlayerDropdown()
    Players.PlayerAdded:Connect(updatePlayerDropdown)
    Players.PlayerRemoving:Connect(updatePlayerDropdown)

    -- ============================
    -- Information Tab
    -- ============================
    local InfoTab = Window:MakeTab({
        Name = "Information",
        Icon = "rbxassetid://6031280882",
        PremiumOnly = false
    })

    InfoTab:AddSection({Name = "About"})
    InfoTab:AddLabel("Made by Shadow")
    InfoTab:AddLabel("Discord Server:")
    InfoTab:AddLabel("https://discord.gg/QBAggVjwtW")

    InfoTab:AddSection({Name = "Status"})
    InfoTab:AddLabel("Version: 1.0")
	InfoTab:AddLabel("Game: German Voice")

    -- ============================
    -- Connections
    -- ============================
    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled then
            local hum = getHum()
            if hum then hum:ChangeState("Jumping") end
        end
    end)

    RunService.Stepped:Connect(function()
        if noclipEnabled then
            local char = getChar()
            if char then
                for _, part in char:GetDescendants() do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)

    OrionLib:Init()
    print("Orion:Init() aufgerufen - Menu mit INSERT / RightShift öffnen")

    task.delay(2, function()
        local gui = playerGui:FindFirstChild("Orion") or game:GetService("CoreGui"):FindFirstChild("Orion")
        if gui then
            gui.Enabled = true
            print("GUI wurde manuell Enabled")
        end
    end)
end
