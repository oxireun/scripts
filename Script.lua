local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = playerGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 250, 0, 200)
    Frame.Position = UDim2.new(0.5, -125, 0.5, -100)
    Frame.BackgroundColor3 = Color3.new(0, 0, 0)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.new(1, 1, 1)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    local TitleBar = Instance.new("TextLabel")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Text = "Collect for UGC"
    TitleBar.TextColor3 = Color3.new(1, 1, 1)
    TitleBar.Font = Enum.Font.SourceSansBold
    TitleBar.TextSize = 20
    TitleBar.Parent = Frame

    local YTLabel = Instance.new("TextLabel")
    YTLabel.Size = UDim2.new(0, 100, 0, 20)
    YTLabel.Position = UDim2.new(0, 0, 1, -25)
    YTLabel.BackgroundTransparency = 1
    YTLabel.Text = "Yt: oxireun"
    YTLabel.TextColor3 = Color3.new(1, 1, 1)
    YTLabel.Font = Enum.Font.SourceSans
    YTLabel.TextSize = 14
    YTLabel.Parent = Frame

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -30, 0, 3)
    CloseButton.BackgroundColor3 = Color3.new(0, 0, 1)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = Frame

    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -70, 0, 0)
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 20
    MinimizeButton.Parent = Frame

    local CollectButton = Instance.new("TextButton")
    CollectButton.Size = UDim2.new(0, 150, 0, 40)
    CollectButton.Position = UDim2.new(0.5, -75, 0, 70)
    CollectButton.BackgroundColor3 = Color3.new(0, 0, 1)
    CollectButton.Text = "Collect"
    CollectButton.TextColor3 = Color3.new(1, 1, 1)
    CollectButton.Font = Enum.Font.SourceSansBold
    CollectButton.TextSize = 18
    CollectButton.Parent = Frame

    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        if minimized then
            Frame.Size = UDim2.new(0, 250, 0, 200)
            CollectButton.Visible = true
            YTLabel.Visible = true
            MinimizeButton.Text = "-"
        else
            Frame.Size = UDim2.new(0, 250, 0, 30)
            CollectButton.Visible = false
            YTLabel.Visible = false
            MinimizeButton.Text = "+"
        end
        minimized = not minimized
    end)

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Uçma işlemi için fonksiyonlar
    local character = player.Character or player.CharacterAdded:Wait()

    -- Heart objesinin bulunduğu yer
    local heartsFolder = game.Workspace.Map.Interactable.Hearts

    -- Uçma hızı (5 olarak ayarlandı)
    local flightSpeed = 5
    -- Uçma süresi (3 saniye olarak ayarlandı)
    local flightTime = 3
    -- 0.6 saniye bekleme süresi
    local waitTime = 0.6

    -- En yakın Heart'i bulma fonksiyonu
    local function getClosestHeart()
        local closestHeart = nil
        local shortestDistance = math.huge -- Başlangıçta çok büyük bir mesafe

        -- Hearts içinde tüm Heart objelerine bak
        for _, heart in pairs(heartsFolder:GetChildren()) do
            -- Heart'e olan mesafeyi hesapla
            local distance = (character.HumanoidRootPart.Position - heart.Position).magnitude

            -- Eğer bu mesafe daha kısa ise, en yakın Heart'i güncelle
            if distance < shortestDistance then
                closestHeart = heart
                shortestDistance = distance
            end
        end

        return closestHeart
    end

    -- Uçma işlemi için fonksiyon
    local function flyToHeart(heart)
        local targetPosition = heart.Position
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000) -- Güç sınırları
        bodyVelocity.Velocity = (targetPosition - character.HumanoidRootPart.Position).unit * flightSpeed
        bodyVelocity.Parent = character.HumanoidRootPart

        -- Uçma hareketi tamamlandığında BodyVelocity'yi kaldır
        game:GetService("TweenService"):Create(character.HumanoidRootPart, TweenInfo.new(flightTime), {CFrame = heart.CFrame}):Play()
        
        -- Biraz zaman sonra bodyVelocity'yi kaldır
        wait(flightTime)
        bodyVelocity:Destroy()
    end

    -- Kolay durdurulabilir bir while döngüsü için
    local collecting = false

    CollectButton.MouseButton1Click:Connect(function()
        collecting = not collecting
        if collecting then
            CollectButton.Text = "Stop Collecting"
            -- 0.6 saniyede bir en yakın Heart'e git
            spawn(function()
                while collecting do
                    local closestHeart = getClosestHeart()
                    if closestHeart then
                        flyToHeart(closestHeart)
                    end
                    wait(waitTime) -- 0.6 saniye bekle
                end
            end)
        else
            CollectButton.Text = "Collect"
        end
    end)
end

-- Karakter resetlendiğinde GUI'yi yeniden oluştur
player.CharacterAdded:Connect(function()
    createGUI()
end)

-- İlk GUI oluşturma
createGUI()
