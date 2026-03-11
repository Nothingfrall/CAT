-- [[ NEBULA HUB v19.0 — CATCH AND TAME ]]
-- Authority: iPowfu | Discord: discord.gg/dyt7dd55Ct
-- FIXED: Auto Breed, Weather Breed, GetGardenPlot, weatherBreedLock

local cloneref = (cloneref or clonereference or function(i) return i end)
local setclip  = setclipboard or toclipboard
    or (syn and syn.clipboard)
    or (fluxus and fluxus.setClipboard)
    or Clipboard and Clipboard.set
    or function() end

local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace         = game:GetService("Workspace")
local lp                = Players.LocalPlayer

-- ============================================================
-- [ KEY SYSTEM ]
-- ============================================================
local ASSET_ID      = "rbxassetid://108071691061975"
local GITHUB_TOKEN  = "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"
local GITHUB_URL    = "https://api.github.com/repos/Nothingfrall/keysystem/contents/keys.json"
local TweenService  = game:GetService("TweenService")

local KeyScreenGui = Instance.new("ScreenGui")
KeyScreenGui.Name = "NebulaFinalV19"
KeyScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if gethui then KeyScreenGui.Parent = gethui() else KeyScreenGui.Parent = lp:WaitForChild("PlayerGui") end

local function createNotif(title, msg, color)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 60)
    NotifFrame.Position = UDim2.new(1, 20, 1, -80)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = KeyScreenGui
    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", NotifFrame)
    Stroke.Color = color
    Stroke.Thickness = 1.5
    local TTitle = Instance.new("TextLabel", NotifFrame)
    TTitle.Text = title
    TTitle.Size = UDim2.new(1, -20, 0, 25)
    TTitle.Position = UDim2.new(0, 10, 0, 5)
    TTitle.BackgroundTransparency = 1
    TTitle.TextColor3 = color
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 14
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    local TMsg = Instance.new("TextLabel", NotifFrame)
    TMsg.Text = msg
    TMsg.Size = UDim2.new(1, -20, 0, 20)
    TMsg.Position = UDim2.new(0, 10, 0, 28)
    TMsg.BackgroundTransparency = 1
    TMsg.TextColor3 = Color3.fromRGB(200, 200, 200)
    TMsg.Font = Enum.Font.Gotham
    TMsg.TextSize = 12
    TMsg.TextXAlignment = Enum.TextXAlignment.Left
    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -270, 1, -80)}):Play()
    task.delay(3, function()
        local out = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -80)})
        out:Play()
        out.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

local function saveKey(key)
    if writefile then writefile("NebulaHub_Config.json", HttpService:JSONEncode({SavedKey = key})) end
end

local function loadKey()
    if isfile and isfile("NebulaHub_Config.json") then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile("NebulaHub_Config.json")) end)
        if s and d and d.SavedKey then return d.SavedKey end
    end
    return ""
end

local function fetchDB()
    local request = (syn and syn.request) or (http and http.request) or (request) or nil
    if request then
        local ok, res = pcall(function()
            return request({
                Url     = GITHUB_URL,
                Method  = "GET",
                Headers = {
                    ["Authorization"] = "token " .. GITHUB_TOKEN,
                    ["Accept"]        = "application/vnd.github.v3.raw",
                    ["User-Agent"]    = "NebulaHub",
                },
            })
        end)
        if ok and res and res.Body and res.Body ~= "" then
            return res.Body
        end
    end
    local ok2, res2 = pcall(function()
        return game:HttpGet(GITHUB_URL .. "?t=" .. tostring(tick()))
    end)
    if ok2 and res2 then return res2 end
    return nil
end

local function validateKey(inputKey)
    local raw = fetchDB()
    if not raw then return false, "Failed to connect to database!" end
    local s, db = pcall(function() return HttpService:JSONDecode(raw) end)
    if not s or not db then return false, "Database parse error!" end
    if db.content then
        local b64 = db.content:gsub("\n", "")
        local s2, db2 = pcall(function()
            local base64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
            local result = {}
            b64 = b64:gsub("[^"..base64chars.."=]", "")
            for i = 1, #b64, 4 do
                local a,b,c,d = b64:byte(i,i+3)
                local function idx(x) return base64chars:find(string.char(x or 61)) - 1 end
                local n = idx(a)*262144 + idx(b)*4096 + idx(c)*64 + idx(d)
                table.insert(result, string.char(math.floor(n/65536)))
                if c ~= 61 then table.insert(result, string.char(math.floor(n/256)%256)) end
                if d ~= 61 then table.insert(result, string.char(n%256)) end
            end
            return HttpService:JSONDecode(table.concat(result))
        end)
        if s2 and db2 then db = db2 else return false, "Database decode error!" end
    end
    local keyData = db[inputKey]
    if not keyData then return false, "Invalid Key!" end
    if not keyData.is_permanent and os.time() > keyData.expiry then
        return false, "Key has expired!"
    end
    return true, "Success"
end

local function tw(obj, info, goal)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), goal)
    tween:Play()
    return tween
end

local Main = Instance.new("CanvasGroup")
Main.Size = UDim2.new(0, 560, 0, 360)
Main.Position = UDim2.new(0.5, -280, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
Main.GroupTransparency = 1
Main.Parent = KeyScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.8
MainStroke.Color = Color3.fromRGB(110, 60, 255)

local TopBar = Instance.new("Frame", Main)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 10

local HeaderTitle = Instance.new("TextLabel", TopBar)
HeaderTitle.Text = ".iPowfu | Nebula Hub Key System"
HeaderTitle.Size = UDim2.new(1, -120, 1, 0)
HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.TextColor3 = Color3.fromRGB(150, 140, 190)
HeaderTitle.Font = Enum.Font.GothamMedium
HeaderTitle.TextSize = 13
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

local ControlFrame = Instance.new("Frame", TopBar)
ControlFrame.Size = UDim2.new(0, 80, 1, 0)
ControlFrame.Position = UDim2.new(1, -90, 0, 0)
ControlFrame.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", ControlFrame)
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.VerticalAlignment = Enum.VerticalAlignment.Center
UIList.Padding = UDim.new(0, 8)

local function btn(col)
    local b = Instance.new("TextButton", ControlFrame)
    b.Size = UDim2.new(0, 12, 0, 12)
    b.BackgroundColor3 = col
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    return b
end

local CloseBtn = btn(Color3.fromRGB(255, 95, 87))
local MiniBtn  = btn(Color3.fromRGB(255, 189, 46))
local FullBtn  = btn(Color3.fromRGB(39, 201, 63))

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1

local LeftPane = Instance.new("Frame", Content)
LeftPane.Size = UDim2.new(0.38, 0, 1, 0)
LeftPane.ClipsDescendants = true
LeftPane.BorderSizePixel = 0

local BrandingImage = Instance.new("ImageLabel", LeftPane)
BrandingImage.Size = UDim2.new(1, 0, 1, 0)
BrandingImage.Image = ASSET_ID
BrandingImage.ScaleType = Enum.ScaleType.Crop
BrandingImage.ImageColor3 = Color3.fromRGB(150, 150, 150)

local LeftOverlay = Instance.new("Frame", LeftPane)
LeftOverlay.Size = UDim2.new(1, 0, 1, 0)
LeftOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LeftOverlay.BackgroundTransparency = 0.5

local LeftTitle = Instance.new("TextLabel", LeftOverlay)
LeftTitle.Text = "NEBULA\nHUB"
LeftTitle.Size = UDim2.new(1, -30, 0, 80)
LeftTitle.Position = UDim2.new(0, 20, 0, 10)
LeftTitle.BackgroundTransparency = 1
LeftTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LeftTitle.TextSize = 30
LeftTitle.Font = Enum.Font.GothamBold
LeftTitle.TextXAlignment = Enum.TextXAlignment.Left

local RightPane = Instance.new("Frame", Content)
RightPane.Size = UDim2.new(0.62, 0, 1, 0)
RightPane.Position = UDim2.new(0.38, 0, 0, 0)
RightPane.BackgroundTransparency = 1
RightPane.ClipsDescendants = true

local LoginView = Instance.new("Frame", RightPane)
LoginView.Size = UDim2.new(1, 0, 1, 0)
LoginView.BackgroundTransparency = 1

local InputContainer = Instance.new("Frame", LoginView)
InputContainer.Size = UDim2.new(0, 240, 0, 40)
InputContainer.Position = UDim2.new(0.5, -120, 0, 100)
InputContainer.BackgroundColor3 = Color3.fromRGB(15, 12, 25)
local IC_Stroke = Instance.new("UIStroke", InputContainer)
IC_Stroke.Color = Color3.fromRGB(60, 50, 90)
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 4)

local Input = Instance.new("TextBox", InputContainer)
Input.Size = UDim2.new(1, -20, 1, 0)
Input.Position = UDim2.new(0, 10, 0, 0)
Input.BackgroundTransparency = 1
Input.PlaceholderText = "> INSERT KEY"
Input.Text = loadKey()
Input.Font = Enum.Font.Code
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.TextSize = 14

local StatusLabel = Instance.new("TextLabel", LoginView)
StatusLabel.Size = UDim2.new(0, 240, 0, 20)
StatusLabel.Position = UDim2.new(0.5, -120, 0, 148)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

local LoginBtn = Instance.new("TextButton", LoginView)
LoginBtn.Size = UDim2.new(0, 240, 0, 42)
LoginBtn.Position = UDim2.new(0.5, -120, 0, 175)
LoginBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 210)
LoginBtn.Text = "EXECUTE ACCESS"
LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.TextSize = 13
Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 4)

local ExtraBtnsFrame = Instance.new("Frame", LoginView)
ExtraBtnsFrame.Size = UDim2.new(0, 240, 0, 38)
ExtraBtnsFrame.Position = UDim2.new(0.5, -120, 0, 225)
ExtraBtnsFrame.BackgroundTransparency = 1

local ExtraLayout = Instance.new("UIListLayout", ExtraBtnsFrame)
ExtraLayout.FillDirection = Enum.FillDirection.Horizontal
ExtraLayout.Padding = UDim.new(0, 10)
ExtraLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createSubBtn(name, color)
    local b = Instance.new("TextButton", ExtraBtnsFrame)
    b.Size = UDim2.new(0, 115, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
    b.Text = name
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", b)
    s.Color = color
    s.Thickness = 1.2
    return b
end

local GetFreeBtn   = createSubBtn("GET FREE KEY",  Color3.fromRGB(60, 50, 90))
local BuyKeyTabBtn = createSubBtn("BUY PREMIUM",   Color3.fromRGB(110, 60, 255))

local ShopView = Instance.new("Frame", RightPane)
ShopView.Size = UDim2.new(1, 0, 1, 0)
ShopView.Position = UDim2.new(1.1, 0, 0, 0)
ShopView.BackgroundTransparency = 1
ShopView.Visible = false

local ShopTitle = Instance.new("TextLabel", ShopView)
ShopTitle.Text = "NEBULA STORE"
ShopTitle.Size = UDim2.new(1, 0, 0, 30)
ShopTitle.Position = UDim2.new(0, 0, 0, 40)
ShopTitle.BackgroundTransparency = 1
ShopTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ShopTitle.Font = Enum.Font.GothamBold
ShopTitle.TextSize = 18

local BackBtn = Instance.new("TextButton", ShopView)
BackBtn.Text = "< BACK"
BackBtn.Size = UDim2.new(0, 60, 0, 20)
BackBtn.Position = UDim2.new(0, 20, 0, 15)
BackBtn.BackgroundTransparency = 1
BackBtn.TextColor3 = Color3.fromRGB(110, 60, 255)
BackBtn.Font = Enum.Font.GothamBold
BackBtn.TextSize = 12

local ShopList = Instance.new("Frame", ShopView)
ShopList.Size = UDim2.new(0, 240, 0, 150)
ShopList.Position = UDim2.new(0.5, -120, 0, 100)
ShopList.BackgroundTransparency = 1
local SL_Layout = Instance.new("UIListLayout", ShopList)
SL_Layout.Padding = UDim.new(0, 10)

local function createShopItem(name, price)
    local Item = Instance.new("TextButton", ShopList)
    Item.Size = UDim2.new(1, 0, 0, 40)
    Item.BackgroundColor3 = Color3.fromRGB(20, 18, 35)
    Item.Text = name .. " [" .. price .. "]"
    Item.TextColor3 = Color3.fromRGB(255, 255, 255)
    Item.Font = Enum.Font.GothamBold
    Item.TextSize = 12
    Instance.new("UICorner", Item).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", Item)
    s.Color = Color3.fromRGB(45, 40, 70)
    return Item
end

createShopItem("1 DAY ACCESS",  "50 RBX")
createShopItem("3 DAY ACCESS",  "100 RBX")
createShopItem("PERMANENT",     "500 RBX")

BuyKeyTabBtn.MouseButton1Click:Connect(function()
    ShopView.Visible = true
    tw(LoginView, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut}, {Position = UDim2.new(-1.1, 0, 0, 0)})
    tw(ShopView,  {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut}, {Position = UDim2.new(0, 0, 0, 0)})
end)

BackBtn.MouseButton1Click:Connect(function()
    LoginView.Visible = true
    tw(ShopView,  {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut}, {Position = UDim2.new(1.1, 0, 0, 0)})
    tw(LoginView, {0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut}, {Position = UDim2.new(0, 0, 0, 0)})
end)

GetFreeBtn.MouseButton1Click:Connect(function()
    setclip("https://discord.gg/dyt7dd55Ct")
    createNotif("COPIED", "Discord link copied!", Color3.fromRGB(110, 60, 255))
end)

CloseBtn.MouseButton1Click:Connect(function() KeyScreenGui:Destroy() end)

local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

tw(Main, {0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out}, {GroupTransparency = 0})

local keyVerified = false

local savedKey = loadKey()
if savedKey ~= "" then
    StatusLabel.Text = "Checking saved key..."
    local isValid, message = validateKey(savedKey)
    if isValid then
        keyVerified = true
        KeyScreenGui:Destroy()
    else
        StatusLabel.Text = "Saved key invalid: " .. message
        saveKey("")
    end
end

if not keyVerified then
    LoginBtn.MouseButton1Click:Connect(function()
        if LoginBtn.Text == "CHECKING..." then return end
        LoginBtn.Text = "CHECKING..."
        LoginBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        StatusLabel.Text = "Validating key..."
        task.spawn(function()
            local isValid, message = validateKey(Input.Text)
            if isValid then
                saveKey(Input.Text)
                StatusLabel.Text = "Access granted!"
                createNotif("SUCCESS", "Welcome to Nebula Hub!", Color3.fromRGB(50, 220, 110))
                tw(LoginBtn, {0.3}, {BackgroundColor3 = Color3.fromRGB(50, 220, 110)})
                LoginBtn.Text = "ACCESS GRANTED"
                task.wait(0.7)
                KeyScreenGui:Destroy()
                keyVerified = true
            else
                StatusLabel.Text = message
                createNotif("ERROR", message, Color3.fromRGB(255, 80, 80))
                LoginBtn.Text = "EXECUTE ACCESS"
                LoginBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 210)
                local orig = InputContainer.Position
                for i = 1, 8 do
                    InputContainer.Position = orig + UDim2.new(0, math.random(-6, 6), 0, 0)
                    task.wait(0.02)
                end
                InputContainer.Position = orig
            end
        end)
    end)

    repeat task.wait(0.1) until keyVerified
end

-- ============================================================
-- [ LOAD WINDUI ]
-- ============================================================
local WindUI
do
    local ok, result = pcall(function()
        return require(game:GetService("ProjectResources"):WaitForChild("Init"))
    end)
    if ok then
        WindUI = result
    else
        local success, res = pcall(function()
            if cloneref(RunService):IsStudio() then
                return require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
            else
                return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
            end
        end)
        if success then WindUI = res end
    end
end
if not WindUI then return end

pcall(function()
    local Creator = WindUI.Creator
    if Creator and Creator.ShowConfirm then
        Creator.ShowConfirm = function(_, callback)
            if callback then callback(true) end
        end
    end
    local oldCreate = WindUI.CreateWindow
    WindUI.CreateWindow = function(self, config)
        config = config or {}
        config.HideConfirm = true
        config.ConfirmClose = false
        local win = oldCreate(self, config)
        pcall(function()
            if win and win.ConfirmFrame then
                win.ConfirmFrame.Visible = false
                win.ConfirmFrame:Destroy()
            end
        end)
        return win
    end
end)

-- ============================================================
-- [ HELPERS ]
-- ============================================================
local function safeWaitForChild(parent, name, timeout)
    return parent:WaitForChild(name, timeout or 15)
end

local function safeIter(tbl)
    if type(tbl) ~= "table" then return {} end
    local isArr = true
    for k in pairs(tbl) do if type(k) ~= "number" then isArr = false break end end
    if isArr then return tbl end
    local r = {}
    for k, v in pairs(tbl) do if v == true and type(k) == "string" then table.insert(r, k) end end
    return r
end

local function normalizeDropdownValue(v) return safeIter(v) end

local function normalize(str)
    return string.lower(string.gsub(tostring(str or ""), "%s+", ""))
end

-- ============================================================
-- [ WORKSPACE FOLDERS ]
-- ============================================================
local RoamingPetsRoot     = safeWaitForChild(Workspace, "RoamingPets", 15)
local PetFolder           = RoamingPetsRoot and safeWaitForChild(RoamingPetsRoot, "Pets", 15)
local SkyIslandRoot       = safeWaitForChild(Workspace, "SkyIslandPets", 15)
local SkyIslandPetsFolder = SkyIslandRoot and safeWaitForChild(SkyIslandRoot, "Pets", 15)
local DragonPetsFolder    = SkyIslandPetsFolder
local WaterIslandRoot     = safeWaitForChild(Workspace, "WaterIslandPets", 15)
local WaterPetsFolder     = WaterIslandRoot and safeWaitForChild(WaterIslandRoot, "Pets", 15)

-- ============================================================
-- [ REMOTES ]
-- ============================================================
local Remotes           = safeWaitForChild(ReplicatedStorage, "Remotes", 15)
local KnitPackages      = safeWaitForChild(ReplicatedStorage, "Packages", 15)
local KnitIndex         = KnitPackages and safeWaitForChild(KnitPackages, "_Index", 15)
local KnitServices      = KnitIndex and KnitIndex["sleitnick_knit@1.7.0"] and KnitIndex["sleitnick_knit@1.7.0"].knit.Services
local TimerServiceRF    = KnitServices and KnitServices.TimerService and KnitServices.TimerService.RF
local BreedRequest      = Remotes and safeWaitForChild(Remotes, "breedRequest", 10)
local CollectCashRemote = Remotes and safeWaitForChild(Remotes, "collectAllPetCash", 10)

-- ============================================================
-- [ LISTS ]
-- ============================================================
local FoodList = { "Steak", "Prime Feed", "Bone", "Hay", "Enriched Feed", "Farmers Feed" }
local PetList  = { "Axolotl", "Cerberus", "Kitsune", "Red Panda", "elephant", "gorilla", "eagle", "yeti", "Phoenix" }
local LassoList = {
    "Basic Lasso", "Rancher's Rope", "Metal Lasso", "Steelcoil Lasso",
    "Stormwrangler", "Sunforged Lasso", "Nightveil Lasso", "Voidweave Lasso",
    "Celestial Tether", "Nebula Lasso", "Fragmented Lasso", "Blackhole Lasso",
    "Helion Lasso", "Stellar Lasso", "Valentines Lasso",
    "Peppermint Lasso", "Frost Lasso", "Festive Lasso", "Holiday Lasso",
}

-- ============================================================
-- [ CONFIG ]
-- ============================================================
local Config = {
    AutoFarmMode = "Main", AutoFarm = false,
    Main_UseRarity = true,   Main_UseMutation = false, Main_UseSize = false,
    Main_SelectedRarities   = {"Secret","Mythic"}, Main_SelectedMutations  = {"Shiny","Albino","Melanistic"},
    Main_SelectedSizes      = {"Huge","Colossal"}, Main_SelectedSizeRarity = "None",
    Dragon_UseRarity = true, Dragon_UseMutation = false, Dragon_UseSize = false,
    Dragon_SelectedRarities = {"Secret","Mythic"}, Dragon_SelectedMutations = {"Shiny","Albino","Melanistic"},
    Dragon_SelectedSizes    = {"Huge","Colossal"}, Dragon_SelectedSizeRarity = "None",
    Water_UseRarity  = true, Water_UseMutation  = false, Water_UseSize  = false,
    Water_SelectedRarities  = {"Secret","Mythic"}, Water_SelectedMutations  = {"Shiny","Albino","Melanistic"},
    Water_SelectedSizes     = {"Huge","Colossal"}, Water_SelectedSizeRarity  = "None",
    JumpSize = 8, SkippedAnimals = {}, WalkSpeed = 16, InfiniteJump = false, FlySpeed = 50,
    EnableESP = false, RenderDist = 1200, EspSelectedRarities = {"Secret","Mythic","Legendary"},
    AutoMerchant = false, AutoBuyFood = false, AutoBreed = false,
    BreedTarget1 = "", BreedTarget2 = "",
    AutoPickupAll = false, AutoPickupEggs = false, AutoCollectMoney = false,
    AntiAFK = false, AutoRejoin = false, AutoHideName = false, FPSBoost = false,
    AutoEquipBestLasso = false, EasyTamingMode = false, FakeLassoName = "Stellar Lasso",
    WeatherBreed_Rain_Enabled     = false, WeatherBreed_Rain_Slot     = 1, WeatherBreed_Rain_Pet1     = "", WeatherBreed_Rain_Pet2     = "",
    WeatherBreed_Aurora_Enabled   = false, WeatherBreed_Aurora_Slot   = 1, WeatherBreed_Aurora_Pet1   = "", WeatherBreed_Aurora_Pet2   = "",
    WeatherBreed_Cosmic_Enabled   = false, WeatherBreed_Cosmic_Slot   = 1, WeatherBreed_Cosmic_Pet1   = "", WeatherBreed_Cosmic_Pet2   = "",
    WeatherBreed_Eruption_Enabled = false, WeatherBreed_Eruption_Slot = 1, WeatherBreed_Eruption_Pet1 = "", WeatherBreed_Eruption_Pet2 = "",
}

local isTaming          = false
local Flying            = false
local Noclip            = false
local NoclipConn, AntiAFKConn, RejoinConn, HideNameConn
local InviteCode        = "dyt7dd55Ct"
local espWasEnabled     = false
local easytamingHooked  = false
local originalLassoName = nil
local cachedPenIndex    = nil

-- ============================================================
-- [ SAVE / LOAD ]
-- ============================================================
local function SaveSettings()
    pcall(function() writefile("NebulaHub_v19.0.json", HttpService:JSONEncode({ Config = Config })) end)
end

local function LoadSettings()
    if isfile and isfile("NebulaHub_v19.0.json") then
        pcall(function()
            local decoded = HttpService:JSONDecode(readfile("NebulaHub_v19.0.json"))
            if decoded.Config then
                for k, v in pairs(decoded.Config) do Config[k] = v end
                if type(Config.SkippedAnimals) == "string" then
                    Config.SkippedAnimals = string.split(Config.SkippedAnimals, ",")
                end
                local arrayFields = {
                    "Main_SelectedRarities","Main_SelectedMutations","Main_SelectedSizes",
                    "Dragon_SelectedRarities","Dragon_SelectedMutations","Dragon_SelectedSizes",
                    "Water_SelectedRarities","Water_SelectedMutations","Water_SelectedSizes",
                    "EspSelectedRarities","SkippedAnimals",
                }
                for _, f in ipairs(arrayFields) do
                    if type(Config[f]) == "table" then Config[f] = safeIter(Config[f])
                    elseif Config[f] == nil then Config[f] = {} end
                end
                if Config.AutoFarmMode == "Underwater" then Config.AutoFarmMode = "Water" end
            end
        end)
    end
end
LoadSettings()

-- ============================================================
-- [ WEATHER MONITOR ]
-- ============================================================
local currentWeather   = "Default"
local WeatherServiceRE = nil
local WeatherServiceRF2= nil

pcall(function()
    local knit = require(ReplicatedStorage.Packages.knit)
    local ws = knit.GetService("WeatherService")
    WeatherServiceRE  = ws and ws.RE and ws.RE.WeatherChanged
    WeatherServiceRF2 = ws and ws.RF and ws.RF.GetActiveWeather
end)
if not WeatherServiceRF2 then
    pcall(function()
        WeatherServiceRF2 = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.WeatherService.RF.GetActiveWeather
    end)
end
if not WeatherServiceRE then
    pcall(function()
        WeatherServiceRE = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.WeatherService.RE.WeatherChanged
    end)
end

local function GetCurrentWeather()
    if WeatherServiceRF2 then
        local ok, result = pcall(function() return WeatherServiceRF2:InvokeServer() end)
        if ok and result then
            if type(result) == "string" and result ~= "" then return result
            elseif type(result) == "table" then return tostring(result.Name or result.name or result[1] or "Default") end
        end
    end
    return currentWeather
end

if WeatherServiceRE then
    pcall(function()
        WeatherServiceRE.OnClientEvent:Connect(function(weatherName)
            local name = type(weatherName) == "table"
                and (weatherName.Name or weatherName.name or weatherName[1] or "Default")
                or tostring(weatherName or "Default")
            if name ~= currentWeather then
                currentWeather = name
                WindUI:Notify({ Title = "Weather Changed", Icon = "solar:cloud-waterdrops-bold", Content = "Current: "..currentWeather, Duration = 4 })
            end
        end)
    end)
end

task.spawn(function()
    task.wait(3)
    local init = GetCurrentWeather()
    if init then currentWeather = init end
    while true do
        task.wait(5)
        local d = GetCurrentWeather()
        if d and d ~= currentWeather then
            currentWeather = d
            WindUI:Notify({ Title = "Weather Changed", Icon = "solar:cloud-waterdrops-bold", Content = "Current: "..currentWeather, Duration = 4 })
        end
    end
end)

-- ============================================================
-- [ SWITCH SLOT ]
-- ============================================================
local getSaveInfoRemote
pcall(function()
    getSaveInfoRemote = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("getSaveInfo", 10)
end)

local function SwitchSlot(slotNumber)
    if not getSaveInfoRemote then return end
    local ok = pcall(function() getSaveInfoRemote:InvokeServer(slotNumber, true) end)
    if ok then cachedPenIndex = nil end
end

-- ============================================================
-- [ GAME LOGIC ]
-- ============================================================
local function ApplyEasyTaming()
    if not Config.EasyTamingMode then return end
    pcall(function()
        local knit = require(ReplicatedStorage.Packages.knit)
        local LC = knit.GetController("LassoController")
        if LC then
            originalLassoName = originalLassoName or LC.EquippedLasso
            LC.EquippedLasso = Config.FakeLassoName
        end
        if not easytamingHooked then
            local SP = game:GetService("StarterPlayer")
            for _, v in pairs(SP.StarterPlayerScripts:GetDescendants()) do
                if v.Name == "lassoMinigameHandler" then
                    local ok, module = pcall(require, v)
                    if ok and module and module.StartMinigame then
                        local hok = pcall(function()
                            debug.setupvalue(module.StartMinigame, 6, function() return 1 end)
                        end)
                        if hok then easytamingHooked = true end
                    end
                    break
                end
            end
        end
    end)
end

local function RemoveEasyTaming()
    pcall(function()
        local knit = require(ReplicatedStorage.Packages.knit)
        local LC = knit.GetController("LassoController")
        if LC and originalLassoName then
            LC.EquippedLasso = originalLassoName
            originalLassoName = nil
        end
        easytamingHooked = false
    end)
end

local function StartAntiAFK()
    if AntiAFKConn then AntiAFKConn:Disconnect() end
    AntiAFKConn = RunService.Heartbeat:Connect(function()
        if not Config.AntiAFK then return end
        pcall(function() VirtualUser:CaptureController() VirtualUser:ClickButton2(Vector2.new()) end)
    end)
end
local function StopAntiAFK()
    if AntiAFKConn then AntiAFKConn:Disconnect() AntiAFKConn = nil end
end

local function StartAutoRejoin()
    if RejoinConn then RejoinConn:Disconnect() end
    RejoinConn = lp:GetPropertyChangedSignal("Parent"):Connect(function()
        if not lp.Parent and Config.AutoRejoin then
            task.wait(5 + math.random(3, 8))
            pcall(function() TeleportService:Teleport(game.PlaceId, lp) end)
        end
    end)
end
local function StopAutoRejoin()
    if RejoinConn then RejoinConn:Disconnect() RejoinConn = nil end
end

local function ServerHop()
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, v in ipairs(servers.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                WindUI:Notify({ Title = "Server Hop", Icon = "solar:arrow-right-up-bold", Content = "Hopping ("..v.playing.."/"..v.maxPlayers..")..." })
                task.wait(1.5)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, lp)
                return
            end
        end
        WindUI:Notify({ Title = "Server Hop", Icon = "solar:close-circle-bold", Content = "No suitable server found." })
    end)
end

local function UpdateHideName()
    if not Config.AutoHideName then return end
    pcall(function()
        local char = lp.Character
        if char and char:FindFirstChild("Head") then
            local bb = char.Head:FindFirstChildOfClass("BillboardGui")
            if bb then bb.Enabled = false end
        end
    end)
end

local function ApplyFPSBoost()
    if not Config.FPSBoost then return end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire")
        or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
end

local function AutoEquipBestLasso()
    if not Config.AutoEquipBestLasso then return end
    pcall(function()
        local best, bestPower = nil, 0
        for _, tool in ipairs(lp.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("lasso") or tool:GetAttribute("Power")) then
                local power = tonumber(tool:GetAttribute("Power") or 1) or 1
                if power > bestPower then bestPower = power best = tool end
            end
        end
        if best and lp.Character and not lp.Character:FindFirstChildWhichIsA("Tool") then
            best.Parent = lp.Character
        end
    end)
end

local function IsPetOnCooldown(pet)
    if not pet then return false end
    local t = tonumber(pet:GetAttribute("CooldownEnd"))
    return t and tick() < t or false
end

local function IsPetBreeding(pet)
    if not pet then return false end
    local ok, tagged = pcall(function() return CollectionService:HasTag(pet, "Breeding") end)
    if ok and tagged then return true end
    return pet:GetAttribute("Breeding") and true or false
end

local function IsValidTarget(v, mode)
    if not v:IsA("Model") then return false end
    if v:FindFirstAncestor("Plots") or v:FindFirstAncestor("PlayerPens") then return false end
    if mode == "Main"   and (v.Parent == SkyIslandPetsFolder or v.Parent == WaterPetsFolder) then return false end
    if mode == "Dragon" and (v.Parent == PetFolder or v.Parent == WaterPetsFolder) then return false end
    if mode == "Water"  and (v.Parent == PetFolder or v.Parent == SkyIslandPetsFolder) then return false end
    local petName  = normalize(v:GetAttribute("Name") or v.Name)
    local rarity   = normalize(v:GetAttribute("Rarity") or "")
    local mutation = normalize(v:GetAttribute("Mutation") or "None")
    local size     = normalize(v:GetAttribute("SizeName") or "Normal")
    if type(Config.SkippedAnimals) == "table" then
        for _, skip in ipairs(safeIter(Config.SkippedAnimals)) do
            local cs = normalize(skip)
            if cs ~= "" and petName:find(cs, 1, true) then return false end
        end
    end
    local useRarity   = Config[mode.."_UseRarity"]
    local useMutation = Config[mode.."_UseMutation"]
    local useSize     = Config[mode.."_UseSize"]
    local selRar      = safeIter(Config[mode.."_SelectedRarities"])
    local selMut      = safeIter(Config[mode.."_SelectedMutations"])
    local selSize     = safeIter(Config[mode.."_SelectedSizes"])
    local selSizeRar  = Config[mode.."_SelectedSizeRarity"]
    if useMutation then
        local m = false
        for _, s in ipairs(selMut) do if mutation:find(normalize(s), 1, true) then m = true break end end
        if not m then return false end
    end
    if useSize then
        local sm = false
        for _, s in ipairs(selSize) do
            local t2 = normalize(s)
            if size == t2 or (t2 == "large" and size == "big") then sm = true break end
        end
        if not sm then return false end
        if selSizeRar ~= "None" and not rarity:find(normalize(selSizeRar), 1, true) then return false end
    elseif useRarity then
        local rm = false
        for _, s in ipairs(selRar) do if rarity:find(normalize(s), 1, true) then rm = true break end end
        if not rm then return false end
    end
    return true
end

local function GetHabitatFolders(mode)
    if mode == "Main"   then return { PetFolder }
    elseif mode == "Dragon" then return { DragonPetsFolder }
    elseif mode == "Water"  then return { WaterPetsFolder } end
    return {}
end

local function GetNextTarget()
    local closest, minDist = nil, math.huge
    local charRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return nil end
    for _, folder in ipairs(GetHabitatFolders(Config.AutoFarmMode)) do
        if folder then
            for _, pet in ipairs(folder:GetChildren()) do
                if IsValidTarget(pet, Config.AutoFarmMode) then
                    local root = pet.PrimaryPart or pet:FindFirstChildWhichIsA("BasePart")
                    if root then
                        local dist = (charRoot.Position - root.Position).Magnitude
                        if dist < minDist then minDist = dist closest = pet end
                    end
                end
            end
        end
    end
    return closest
end

-- ============================================================
-- [FIX] GetGardenPlot — lebih robust, multi-pass
-- ============================================================
local function GetGardenPlot()
    local pens = Workspace:FindFirstChild("PlayerPens")
    if not pens then return nil end

    local myId   = tostring(lp.UserId)
    local myName = tostring(lp.Name)

    -- cek cache dulu
    if cachedPenIndex then
        local cached = pens:FindFirstChild(cachedPenIndex)
        if cached and cached:FindFirstChild("Pets") then return cached end
        cachedPenIndex = nil
    end

    local function isMyPen(pen)
        for _, attr in ipairs({"Owner","UserId","PlayerId","OwnerName","OwnerID"}) do
            local v = pen:GetAttribute(attr)
            if v then
                local s = tostring(v)
                if s == myId or s:lower() == myName:lower() then return true end
            end
        end
        if pen.Name == myId or pen.Name:lower() == myName:lower() then return true end
        return false
    end

    -- pass 1: cari pen yang benar-benar milik player
    for _, pen in ipairs(pens:GetChildren()) do
        if pen:FindFirstChild("Pets") and isMyPen(pen) then
            cachedPenIndex = pen.Name
            return pen
        end
    end

    -- pass 2: fallback ke pen dengan pet terbanyak
    local bestPen, bestCount = nil, -1
    for _, pen in ipairs(pens:GetChildren()) do
        local pf = pen:FindFirstChild("Pets")
        if pf then
            local c = #pf:GetChildren()
            if c > bestCount then bestCount = c bestPen = pen end
        end
    end
    if bestPen then
        cachedPenIndex = bestPen.Name
        return bestPen
    end
    return nil
end

-- ============================================================
-- [FIX] GetBreedingSpots — ambil dari plot
-- ============================================================
local function GetBreedingSpots(plot)
    local bp1 = Vector3.new(-111.035, 12, -2961.374)
    local bp2 = Vector3.new(-106.887, 12, -2944.675)
    if not plot then return bp1, bp2 end
    pcall(function()
        local sp = plot:FindFirstChild("StarterPen")
        if sp then
            local b1 = sp:FindFirstChild("BreedingSpot1") or sp:FindFirstChild("BreedSpot1")
            local b2 = sp:FindFirstChild("BreedingSpot2") or sp:FindFirstChild("BreedSpot2")
            if b1 and b1:IsA("BasePart") then bp1 = b1.Position end
            if b2 and b2:IsA("BasePart") then bp2 = b2.Position end
        end
    end)
    return bp1, bp2
end

-- ============================================================
-- [FIX] GetAvailablePetsFromFolder — helper utama breeding
-- ============================================================
local function GetAvailablePetsFromFolder(petsFolder, targetName)
    local result = {}
    if not petsFolder then return result end
    local nt = normalize(targetName)
    for _, p in ipairs(petsFolder:GetChildren()) do
        if not p:IsA("Model") then continue end
        if not p.Parent then continue end
        local pName = normalize(tostring(p:GetAttribute("Name") or p.Name))
        if pName ~= nt then continue end
        if IsPetBreeding(p) then continue end
        if IsPetOnCooldown(p) then continue end
        -- jangan skip secret untuk weather breed — uncomment baris bawah jika mau skip secret
        -- if p:GetAttribute("Rarity") == "Secret" then continue end
        table.insert(result, p)
    end
    return result
end

-- ============================================================
-- [FIX] DoAutoBreed — pakai referensi langsung dari petsFolder
-- ============================================================
local function DoAutoBreed()
    if not BreedRequest then return end
    if not Config.AutoBreed then return end
    if Config.BreedTarget1 == "" or Config.BreedTarget2 == "" then return end

    local plot = GetGardenPlot()
    if not plot then return end

    -- PERBAIKAN UTAMA: gunakan plot:FindFirstChild("Pets") langsung
    local petsFolder = plot:FindFirstChild("Pets")
    if not petsFolder then return end

    local bp1, bp2 = GetBreedingSpots(plot)
    local usedNames = {}
    local breedCount = 0

    if Config.BreedTarget1 == Config.BreedTarget2 then
        local avail = GetAvailablePetsFromFolder(petsFolder, Config.BreedTarget1)
        local i = 1
        while i + 1 <= #avail do
            local p1, p2 = avail[i], avail[i + 1]
            if p1 and p2
                and p1.Parent and p2.Parent
                and not usedNames[p1.Name] and not usedNames[p2.Name]
                and not IsPetBreeding(p1) and not IsPetBreeding(p2)
                and not IsPetOnCooldown(p1) and not IsPetOnCooldown(p2) then

                local ok, err = pcall(function()
                    BreedRequest:InvokeServer(p1, p2, bp1, bp2)
                end)
                if ok then
                    usedNames[p1.Name] = true
                    usedNames[p2.Name] = true
                    breedCount += 1
                    task.wait(1.2)
                else
                    warn("[Nebula AutoBreed] Error:", tostring(err))
                    task.wait(0.5)
                end
            end
            i += 2
        end
    else
        local a1 = GetAvailablePetsFromFolder(petsFolder, Config.BreedTarget1)
        local a2 = GetAvailablePetsFromFolder(petsFolder, Config.BreedTarget2)
        local usedA2 = {}

        for _, p1 in ipairs(a1) do
            if not p1.Parent or usedNames[p1.Name]
                or IsPetBreeding(p1) or IsPetOnCooldown(p1) then continue end

            local p2 = nil
            for _, c in ipairs(a2) do
                if c.Parent and not usedA2[c.Name]
                    and not IsPetBreeding(c) and not IsPetOnCooldown(c) then
                    p2 = c
                    break
                end
            end
            if not p2 then break end

            local ok, err = pcall(function()
                BreedRequest:InvokeServer(p1, p2, bp1, bp2)
            end)
            if ok then
                usedNames[p1.Name] = true
                usedA2[p2.Name] = true
                breedCount += 1
                task.wait(1.2)
            else
                warn("[Nebula AutoBreed] Error:", tostring(err))
                task.wait(0.5)
            end
        end
    end

    if breedCount > 0 then
        WindUI:Notify({
            Title   = "Auto Breed",
            Icon    = "solar:heart-bold",
            Content = breedCount .. " pasang berhasil dibreed!",
            Duration = 4
        })
    end
end

-- ============================================================
-- [FIX] DoWeatherBreed — perbaikan total: validasi, path, lock
-- ============================================================
local weatherBreedLock = false

local function DoWeatherBreed(pet1Name, pet2Name)
    if not BreedRequest then return end
    if pet1Name == "" or pet2Name == "" then return end
    if weatherBreedLock then return end
    weatherBreedLock = true

    -- ambil pen
    local plot = GetGardenPlot()
    if not plot then
        warn("[Nebula WeatherBreed] Plot tidak ditemukan")
        weatherBreedLock = false
        return
    end

    -- PERBAIKAN UTAMA: gunakan plot:FindFirstChild("Pets") langsung
    local petsFolder = plot:FindFirstChild("Pets")
    if not petsFolder then
        warn("[Nebula WeatherBreed] Pets folder tidak ditemukan di plot:", plot.Name)
        weatherBreedLock = false
        return
    end

    -- cek apakah kedua pet ada di pen
    local n1, n2 = normalize(pet1Name), normalize(pet2Name)
    local hasP1, hasP2 = false, false
    for _, p in ipairs(petsFolder:GetChildren()) do
        if not p:IsA("Model") then continue end
        local pn = normalize(tostring(p:GetAttribute("Name") or p.Name))
        if pn == n1 then hasP1 = true end
        if pn == n2 then hasP2 = true end
        if hasP1 and hasP2 then break end
    end

    if not hasP1 or not hasP2 then
        local missing = (not hasP1 and pet1Name or "") .. (not hasP2 and " & "..pet2Name or "")
        WindUI:Notify({
            Title   = "Weather Breed",
            Icon    = "solar:close-circle-bold",
            Content = "Pet tidak ditemukan: " .. missing,
            Duration = 5
        })
        weatherBreedLock = false
        return
    end

    local bp1, bp2 = GetBreedingSpots(plot)
    local a1 = GetAvailablePetsFromFolder(petsFolder, pet1Name)
    local a2 = (pet1Name == pet2Name) and a1 or GetAvailablePetsFromFolder(petsFolder, pet2Name)

    local usedNames, usedA2 = {}, {}
    local breedCount = 0

    if pet1Name == pet2Name then
        local i = 1
        while i + 1 <= #a1 do
            local p1, p2 = a1[i], a1[i + 1]
            if p1 and p2
                and p1.Parent and p2.Parent
                and not usedNames[p1.Name] and not usedNames[p2.Name]
                and not IsPetBreeding(p1) and not IsPetBreeding(p2)
                and not IsPetOnCooldown(p1) and not IsPetOnCooldown(p2) then

                local ok, err = pcall(function()
                    BreedRequest:InvokeServer(p1, p2, bp1, bp2)
                end)
                if ok then
                    usedNames[p1.Name] = true
                    usedNames[p2.Name] = true
                    breedCount += 1
                    task.wait(1.2)
                else
                    warn("[Nebula WeatherBreed] Error:", tostring(err))
                    task.wait(0.5)
                end
            end
            i += 2
        end
    else
        for _, p1 in ipairs(a1) do
            if not p1.Parent or usedNames[p1.Name]
                or IsPetBreeding(p1) or IsPetOnCooldown(p1) then continue end

            local p2 = nil
            for _, c in ipairs(a2) do
                if c.Parent and not usedA2[c.Name]
                    and not IsPetBreeding(c) and not IsPetOnCooldown(c) then
                    p2 = c
                    break
                end
            end
            if not p2 then break end

            local ok, err = pcall(function()
                BreedRequest:InvokeServer(p1, p2, bp1, bp2)
            end)
            if ok then
                usedNames[p1.Name] = true
                usedA2[p2.Name] = true
                breedCount += 1
                task.wait(1.2)
            else
                warn("[Nebula WeatherBreed] Error:", tostring(err))
                task.wait(0.5)
            end
        end
    end

    if breedCount > 0 then
        WindUI:Notify({
            Title   = "Weather Breed",
            Icon    = "solar:heart-bold",
            Content = breedCount .. " pasang dibreed! (" .. pet1Name .. " x " .. pet2Name .. ")",
            Duration = 5
        })
    else
        WindUI:Notify({
            Title   = "Weather Breed",
            Icon    = "solar:info-circle-bold",
            Content = "Tidak ada pet tersedia untuk dibreed saat ini",
            Duration = 4
        })
    end

    -- PERBAIKAN: selalu release lock
    weatherBreedLock = false
end

-- ============================================================
-- [FIX] SwitchSlotAndWait — tunggu pen berubah, lalu release jika gagal
-- ============================================================
local function SwitchSlotAndWait(slotNumber, pet1Name, pet2Name)
    cachedPenIndex = nil
    SwitchSlot(slotNumber)

    local n1, n2 = normalize(pet1Name), normalize(pet2Name)

    for _ = 1, 25 do
        task.wait(1)
        cachedPenIndex = nil
        local pens = Workspace:FindFirstChild("PlayerPens")
        if pens then
            for _, pen in ipairs(pens:GetChildren()) do
                local pf = pen:FindFirstChild("Pets")
                if not pf then continue end
                local f1, f2 = false, false
                for _, p in ipairs(pf:GetChildren()) do
                    if not p:IsA("Model") then continue end
                    local pn = normalize(tostring(p:GetAttribute("Name") or p.Name))
                    if pn == n1 then f1 = true end
                    if pn == n2 then f2 = true end
                end
                if f1 and f2 then
                    cachedPenIndex = pen.Name
                    return true
                end
            end
        end
    end

    -- timeout: reset lock agar tidak stuck
    cachedPenIndex = nil
    weatherBreedLock = false
    return false
end

-- ============================================================
-- [TETAP] Garden helpers lainnya
-- ============================================================
local function GetGardenPetNames()
    local names = {}
    pcall(function()
        local plot = GetGardenPlot()
        if plot and plot:FindFirstChild("Pets") then
            for _, p in ipairs(plot.Pets:GetChildren()) do
                local n = p:GetAttribute("Name") or p.Name
                if not table.find(names, n) then table.insert(names, n) end
            end
        end
    end)
    table.sort(names)
    return #names > 0 and names or { "No Pets Found" }
end

local function DoManualPickup()
    pcall(function()
        local plot = GetGardenPlot()
        if not plot then return end
        local delay = 0
        if plot:FindFirstChild("Pets") then
            for _, pet in ipairs(plot.Pets:GetChildren()) do
                local cp = pet
                task.delay(delay, function() pcall(function() Remotes.pickupRequest:InvokeServer("Pet", cp.Name, cp) end) end)
                delay += 0.08
            end
        end
        if plot:FindFirstChild("Eggs") then
            for _, egg in ipairs(plot.Eggs:GetChildren()) do
                local ce = egg
                task.delay(delay, function() pcall(function() Remotes.pickupRequest:InvokeServer("Egg", ce.Name, ce) end) end)
                delay += 0.08
            end
        end
    end)
end

local function DoManualPickupEggs()
    pcall(function()
        local plot = GetGardenPlot()
        if plot and plot:FindFirstChild("Eggs") then
            local delay = 0
            for _, egg in ipairs(plot.Eggs:GetChildren()) do
                local ce = egg
                task.delay(delay, function() pcall(function() Remotes.pickupRequest:InvokeServer("Egg", ce.Name, ce) end) end)
                delay += 0.08
            end
        end
    end)
end

local function DoManualBuyFood()
    pcall(function()
        local buyRem = ReplicatedStorage.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.FoodService.RE.BuyFood
        for _, food in ipairs(FoodList) do buyRem:FireServer(food, 5) end
        WindUI:Notify({ Title = "Shop", Icon = "solar:cart-large-2-bold", Content = "Auto Buy Food executed!" })
    end)
end

local function DoManualMerchantBuy()
    local mr = ReplicatedStorage:FindFirstChild("BuyMerchant", true)
    local mg = lp.PlayerGui:FindFirstChild("Merchant") and lp.PlayerGui.Merchant:FindFirstChild("Items")
    if mr then
        for slot = 1, 9 do
            local can = true
            if mg then
                local f = mg:FindFirstChild(tostring(slot))
                if f and f:FindFirstChild("Stock") then
                    if (tonumber(f.Stock.Text:match("%d+")) or 0) <= 0 then can = false end
                end
            end
            if can then for _, food in ipairs(FoodList) do pcall(function() mr:FireServer(slot, food) end) end end
        end
        WindUI:Notify({ Title = "Merchant", Icon = "solar:cart-check-bold", Content = "Merchant purchase executed!" })
    end
end

-- ============================================================
-- [ ESP ]
-- ============================================================
local ESP_CACHE = {}

local function GetTag(model)
    local tag = model:FindFirstChild("NebulaTag")
    if not tag then
        tag = Instance.new("BillboardGui")
        tag.Name = "NebulaTag"
        tag.AlwaysOnTop = true
        tag.Size = UDim2.new(0, 180, 0, 70)
        tag.ExtentsOffset = Vector3.new(0, 3.5, 0)
        tag.Parent = model
        local txt = Instance.new("TextLabel")
        txt.Name = "MainLabel"
        txt.BackgroundTransparency = 1
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 13
        txt.TextStrokeTransparency = 0.4
        txt.RichText = true
        txt.Parent = tag
    end
    return tag
end

local function ClearESP()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and obj.Name == "NebulaTag" then obj:Destroy() end
    end
    ESP_CACHE = {}
end

local function UpdateESP()
    if not Config.EnableESP then
        if espWasEnabled then ClearESP() espWasEnabled = false end
        return
    end
    espWasEnabled = true
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local pos = char.HumanoidRootPart.Position
    local now = tick()
    local habitats = {}
    if PetFolder           then table.insert(habitats, PetFolder) end
    if SkyIslandPetsFolder then table.insert(habitats, SkyIslandPetsFolder) end
    if WaterPetsFolder     then table.insert(habitats, WaterPetsFolder) end
    for model, data in pairs(ESP_CACHE) do
        if not model.Parent or (pos - data.root.Position).Magnitude > Config.RenderDist + 300 then
            if model:FindFirstChild("NebulaTag") then model.NebulaTag:Destroy() end
            ESP_CACHE[model] = nil
        end
    end
    for _, folder in ipairs(habitats) do
        for _, pet in ipairs(folder:GetChildren()) do
            if pet:IsA("Model") then
                local root = pet.PrimaryPart or pet:FindFirstChildWhichIsA("BasePart")
                if not root then continue end
                local dist = (pos - root.Position).Magnitude
                if dist > Config.RenderDist then
                    if pet:FindFirstChild("NebulaTag") then pet.NebulaTag.Enabled = false end
                    continue
                end
                local r = tostring(pet:GetAttribute("Rarity") or "Common")
                local show = false
                for _, s in ipairs(safeIter(Config.EspSelectedRarities)) do
                    if r:lower():find(s:lower()) then show = true break end
                end
                if show then
                    local tag = GetTag(pet)
                    tag.Enabled = true
                    if not ESP_CACHE[pet] then
                        ESP_CACHE[pet] = { root = root, name = pet:GetAttribute("Name") or pet.Name, mut = pet:GetAttribute("Mutation") or "None", sz = pet:GetAttribute("SizeName") or "Normal", rarity = r }
                    end
                    local c2 = ESP_CACHE[pet]
                    tag.MainLabel.Text = string.format("<b>%s</b> <font color='#00FFFF'>[%s]</font>\n<font size='11'>Mut: %s | Sz: %s</font>\n<b>%.0fm</b>", c2.name, c2.rarity, c2.mut, c2.sz, dist)
                    local color
                    if c2.rarity:lower():find("secret")    then color = Color3.fromRGB(0, 255, 255)
                    elseif c2.rarity:lower():find("mythic") then color = Color3.fromHSV(now % 5 / 5, 0.8, 1)
                    elseif c2.rarity:lower():find("legendary") then color = Color3.fromRGB(170, 0, 255)
                    else color = Color3.fromRGB(220, 220, 220) end
                    tag.MainLabel.TextColor3 = color
                else
                    if pet:FindFirstChild("NebulaTag") then pet.NebulaTag:Destroy() end
                    ESP_CACHE[pet] = nil
                end
            end
        end
    end
end
task.spawn(function() while true do task.wait(0.45) pcall(UpdateESP) end end)

-- ============================================================
-- [ CREATE WINDOW ]
-- ============================================================
local Window = WindUI:CreateWindow({
    Title       = "Nebula Hub  |  Catch and Tame",
    Folder      = "nebula_configs",
    Icon        = "solar:planet-2-bold-duotone",
    IconColor   = Color3.fromHex("#BB86FC"),
    NewElements = true,
    AccentColor = Color3.fromHex("#6200EE"),
    HideSearchBar = false,
    Topbar = { Height = 44, ButtonsType = "Default", HideConfirm = true },
    OpenButton = {
        Title = "Nebula Hub", CornerRadius = UDim.new(0, 8), StrokeThickness = 2,
        Enabled = true, Draggable = true, OnlyMobile = false, Scale = 0.6,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromHex("#BB86FC")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#BB86FC")),
            ColorSequenceKeypoint.new(1,   Color3.fromHex("#BB86FC")),
        }),
    },
})

Window:Tag({ Title = " iPowfu ", Icon = "solar:shield-user-bold", Color = Color3.fromHex("#2D1B69"), Border = true })
Window:Tag({ Title = " V25.0 ", Icon = "solar:star-fall-bold", Color = Color3.fromHex("#3B0764"), Border = true })

task.spawn(function()
    task.wait(0.8)
    pcall(function()
        local pg = lp:WaitForChild("PlayerGui")
        local windGui = nil
        for _, v in ipairs(pg:GetChildren()) do
            if v:IsA("ScreenGui") and (v.Name:lower():find("wind") or v.Name:lower():find("nebula") or v.Name:lower():find("hub")) then windGui = v break end
        end
        if not windGui then for _, v in ipairs(pg:GetChildren()) do if v:IsA("ScreenGui") then windGui = v end end end
        if not windGui then return end
        local sidebar = nil
        local function findSidebar(parent, depth)
            depth = depth or 0
            if depth > 6 then return end
            for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("Frame") or v:IsA("ScrollingFrame") then
                    local abs = v.AbsoluteSize
                    if abs.X > 100 and abs.X < 260 and abs.Y > 300 then sidebar = v return end
                    findSidebar(v, depth + 1)
                end
            end
        end
        findSidebar(windGui)
        if not sidebar then return end
        local avatarImg = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=60&h=60"
        local card = Instance.new("Frame")
        card.Name = "NebulaProfile"
        card.Size = UDim2.new(1, -16, 0, 52)
        card.Position = UDim2.new(0, 8, 1, -60)
        card.BackgroundColor3 = Color3.fromHex("#1A1025")
        card.BorderSizePixel = 0
        card.ZIndex = 10
        card.Parent = sidebar
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", card)
        stroke.Color = Color3.fromHex("#3B1F6B") stroke.Thickness = 1 stroke.Transparency = 0.4
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.new(0, 36, 0, 36) avatar.Position = UDim2.new(0, 8, 0.5, -18)
        avatar.BackgroundColor3 = Color3.fromHex("#2D1B69") avatar.BorderSizePixel = 0
        avatar.Image = avatarImg avatar.ScaleType = Enum.ScaleType.Crop avatar.ZIndex = 11 avatar.Parent = card
        Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 6)
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -56, 0, 18) nameLabel.Position = UDim2.new(0, 52, 0, 8)
        nameLabel.BackgroundTransparency = 1 nameLabel.Text = lp.DisplayName ~= "" and lp.DisplayName or lp.Name
        nameLabel.TextColor3 = Color3.fromHex("#E2D9F3") nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12 nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd nameLabel.ZIndex = 11 nameLabel.Parent = card
        local handleLabel = Instance.new("TextLabel")
        handleLabel.Size = UDim2.new(1, -56, 0, 14) handleLabel.Position = UDim2.new(0, 52, 0, 28)
        handleLabel.BackgroundTransparency = 1 handleLabel.Text = "@" .. lp.Name
        handleLabel.TextColor3 = Color3.fromHex("#7C5FA8") handleLabel.Font = Enum.Font.Gotham
        handleLabel.TextSize = 10 handleLabel.TextXAlignment = Enum.TextXAlignment.Left
        handleLabel.TextTruncate = Enum.TextTruncate.AtEnd handleLabel.ZIndex = 11 handleLabel.Parent = card
    end)
end)

task.spawn(function()
    task.wait(1)
    pcall(function()
        local Creator = WindUI and WindUI.Creator
        if Creator then
            for key, val in pairs(Creator) do
                if type(val) == "function" and key:lower():find("confirm") then
                    Creator[key] = function(...) local args = {...} for _, a in ipairs(args) do if type(a) == "function" then a(true) return end end end
                end
            end
        end
        local CoreGui = game:GetService("CoreGui")
        local function hookGui(guiRoot)
            pcall(function()
                guiRoot.DescendantAdded:Connect(function(obj)
                    pcall(function()
                        if obj:IsA("TextButton") and obj.Text == "Cancel" then
                            task.defer(function()
                                pcall(function()
                                    local p = obj.Parent local depth = 0
                                    while p and depth < 8 do
                                        if p.Name:lower():find("wind") or p.Name:lower():find("confirm") then
                                            obj.Visible = false obj.Size = UDim2.new(0,0,0,0) return
                                        end
                                        p = p.Parent depth += 1
                                    end
                                end)
                            end)
                        end
                    end)
                end)
            end)
        end
        hookGui(lp:WaitForChild("PlayerGui"))
        pcall(function() hookGui(CoreGui) end)
    end)
end)

-- ============================================================
-- [ SECTIONS ]
-- ============================================================
local MainSection  = Window:Section({ Title = "Main" })
local FarmSection  = Window:Section({ Title = "Farming" })
local BreedSection = Window:Section({ Title = "Breeding" })
local UtilSection  = Window:Section({ Title = "Utilities" })

-- ============================================================
-- [ HOME TAB ]
-- ============================================================
local HomeTab = MainSection:Tab({ Title = "Home", Icon = "solar:home-smile-bold", IconColor = Color3.fromHex("#3B1F6B"), IconShape = "Square", Border = true })

local DiscordAPI = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"
local DR = {}
pcall(function()
    DR = WindUI.cloneref(game:GetService("HttpService")):JSONDecode(
        WindUI.Creator.Request and WindUI.Creator.Request({ Url = DiscordAPI, Method = "GET", Headers = { ["User-Agent"] = "WindUI/NebulaHub", ["Accept"] = "application/json" } }).Body or "{}"
    )
end)

local HS1 = HomeTab:Section({ Title = "Discord Community" })
if DR and DR.guild then
    if DR.guild.banner then HS1:Image({ Image = "https://cdn.discordapp.com/banners/"..DR.guild.id.."/"..DR.guild.banner..".png?size=512", AspectRatio = "16:9", Radius = 9 }) HS1:Space({ Columns = 2 }) end
    HS1:Paragraph({ Title = tostring(DR.guild.name), Desc = tostring(DR.guild.description or "Catch and Tame automation & support"),
        Image = "https://cdn.discordapp.com/icons/"..DR.guild.id.."/"..DR.guild.icon..".png?size=256", ImageSize = 48,
        Buttons = {{ Title = "Join Discord", Icon = "link", Callback = function() setclip("https://discord.gg/"..InviteCode) WindUI:Notify({ Title = "Discord", Icon = "solar:share-circle-bold", Content = "Link copied!", Duration = 3 }) end }} })
else
    HS1:Space()
    HS1:Section({ Title = "Nebula Hub  —  Catch and Tame", TextSize = 22, FontWeight = Enum.FontWeight.Bold })
    HS1:Space()
    HS1:Section({ Title = "The most complete automation script for Catch and Tame.\n\nAuto Farm  •  Weather Breed  •  Pet ESP\nLasso Hack  •  Auto Breed  •  Auto Collect", TextSize = 15, TextTransparency = 0.25, FontWeight = Enum.FontWeight.Medium })
    HS1:Space({ Columns = 2 })
    HomeTab:Button({ Title = "Join Discord  —  discord.gg/"..InviteCode, Icon = "solar:share-circle-bold", Color = Color3.fromHex("#5865F2"), Justify = "Center",
        Callback = function() setclip("https://discord.gg/"..InviteCode) WindUI:Notify({ Title = "Discord", Icon = "solar:share-circle-bold", Content = "discord.gg/"..InviteCode.." — copied!", Duration = 4 }) end })
end

HomeTab:Space({ Columns = 1 }) HomeTab:Divider()
HomeTab:Section({ Title = "Script Info" })
HomeTab:Paragraph({ Title = "Script",   Desc = "Nebula Hub v19.0  [FIXED]",       Image = "solar:planet-2-bold-duotone",     ImageSize = 32 })
HomeTab:Paragraph({ Title = "Author",   Desc = "iPowfu",                           Image = "solar:shield-user-bold",          ImageSize = 32 })
HomeTab:Paragraph({ Title = "Version",  Desc = "19.0 Fixed",                       Image = "solar:tag-bold",                  ImageSize = 32 })
HomeTab:Paragraph({ Title = "Status",   Desc = "✦ Active",                         Image = "solar:check-circle-bold",         ImageSize = 32 })
HomeTab:Paragraph({ Title = "Game",     Desc = "Catch and Tame",                   Image = "solar:gamepad-bold",              ImageSize = 32 })
HomeTab:Paragraph({ Title = "Fix",      Desc = "Auto Breed + Weather Breed",       Image = "solar:confetti-minimalistic-bold",ImageSize = 32 })
HomeTab:Space() HomeTab:Divider()
HomeTab:Section({ Title = "Core Features" })
HomeTab:Paragraph({ Title = "Auto Farm",       Desc = "Automatically tames wild pets matching your rarity, mutation and size filters across Main World, Dragon Island, and Underwater.", Image = "solar:repeat-one-minimalistic-bold", ImageSize = 36 })
HomeTab:Paragraph({ Title = "Weather Breed",   Desc = "Detects active weather and auto-breeds the right pet pair. Rain +25%, Aurora Borealis +300%, Cosmic Shower +200%, Volcanic Eruption +200%.", Image = "solar:cloud-waterdrops-bold", ImageSize = 36 })
HomeTab:Paragraph({ Title = "Pet ESP",         Desc = "Floating tags above wild pets showing name, rarity, mutation, size, and distance. Rarity filter and scan radius up to 5000 studs.", Image = "solar:eye-bold", ImageSize = 36 })
HomeTab:Paragraph({ Title = "Lasso Hack",      Desc = "Spoofs lasso name to server up to Stellar Lasso (3100 power) and locks taming minigame to Level 1.", Image = "solar:magic-stick-3-bold", ImageSize = 36 })
HomeTab:Paragraph({ Title = "My Plot",         Desc = "Auto Breed, Auto Pickup items or eggs, and Auto Collect cash — all passively in the background.", Image = "solar:streets-map-point-bold", ImageSize = 36 })
HomeTab:Paragraph({ Title = "Shop & Merchant", Desc = "Auto-buys food from shop and merchant on a timer. Manual trigger available anytime.", Image = "solar:cart-large-2-bold", ImageSize = 36 })

-- ============================================================
-- [ AUTO FARM TAB ]
-- ============================================================
local FarmTab = FarmSection:Tab({ Title = "Auto Farm", Icon = "solar:repeat-one-minimalistic-bold", IconColor = Color3.fromHex("#2D1B69"), IconShape = "Square", Border = true })

FarmTab:Section({ Title = "Farm Control" })
FarmTab:Dropdown({ Title = "Farm Location", Desc = "Choose which world to auto-farm", Values = { "Main World", "Dragon Island", "Underwater" },
    Value = Config.AutoFarmMode == "Main" and "Main World" or Config.AutoFarmMode == "Dragon" and "Dragon Island" or "Underwater",
    Callback = function(v) Config.AutoFarmMode = v == "Main World" and "Main" or v == "Dragon Island" and "Dragon" or "Water" SaveSettings() end })
FarmTab:Toggle({ Title = "Enable Auto Farm", Desc = "Tame pets matching filters automatically", Value = Config.AutoFarm, Callback = function(v) Config.AutoFarm = v SaveSettings() end })
FarmTab:Slider({ Title = "Taming Speed", Desc = "Higher = faster taming progress", Step = 1, Value = { Min = 1, Max = 50, Default = Config.JumpSize }, Callback = function(v) Config.JumpSize = v SaveSettings() end })

local function addFarmFilters(tab, prefix, label)
    tab:Divider() tab:Section({ Title = label .. " — Filters" })
    tab:Toggle({   Title = "Filter by Rarity",   Value = Config[prefix.."_UseRarity"],   Callback = function(v) Config[prefix.."_UseRarity"] = v   SaveSettings() end })
    tab:Dropdown({ Title = "Target Rarities",     Multi = true, Values = {"Common","Rare","Epic","Legendary","Mythic","Secret"}, Value = Config[prefix.."_SelectedRarities"],  Callback = function(v) Config[prefix.."_SelectedRarities"] = normalizeDropdownValue(v)  SaveSettings() end })
    tab:Toggle({   Title = "Filter by Mutation",  Value = Config[prefix.."_UseMutation"], Callback = function(v) Config[prefix.."_UseMutation"] = v SaveSettings() end })
    tab:Dropdown({ Title = "Target Mutations",    Multi = true, Values = {"Shiny","Albino","Melanistic","Negative"}, Value = Config[prefix.."_SelectedMutations"], Callback = function(v) Config[prefix.."_SelectedMutations"] = normalizeDropdownValue(v) SaveSettings() end })
    tab:Toggle({   Title = "Filter by Size",      Value = Config[prefix.."_UseSize"],     Callback = function(v) Config[prefix.."_UseSize"] = v     SaveSettings() end })
    tab:Dropdown({ Title = "Size + Rarity Combo", Values = {"None","Common","Rare","Epic","Legendary","Mythic","Secret"}, Value = Config[prefix.."_SelectedSizeRarity"], Callback = function(v) Config[prefix.."_SelectedSizeRarity"] = v SaveSettings() end })
    tab:Dropdown({ Title = "Target Sizes", Multi = true, Values = {"Any Size","Tiny","Normal","Big","Large","Huge","Colossal"},
        Value = (function() local t = {} for _,s in ipairs(Config[prefix.."_SelectedSizes"]) do table.insert(t,s) end if #t==0 then table.insert(t,"Any Size") end return t end)(),
        Callback = function(v) local c={} for _,s in ipairs(safeIter(v)) do if s~="Any Size" then table.insert(c,s) end end Config[prefix.."_SelectedSizes"]=c SaveSettings() end })
end

addFarmFilters(FarmTab, "Main",   "Main World")
addFarmFilters(FarmTab, "Dragon", "Dragon Island")
addFarmFilters(FarmTab, "Water",  "Underwater")

FarmTab:Divider() FarmTab:Section({ Title = "Global Blacklist" })
local skipDropdown = FarmTab:Dropdown({ Title = "Exclude Species", Desc = "Skip these pets across all modes", Multi = true, Values = PetList, Value = Config.SkippedAnimals, Callback = function(v) Config.SkippedAnimals = normalizeDropdownValue(v) SaveSettings() end })
task.delay(1, function() if skipDropdown and skipDropdown.Refresh then skipDropdown:Refresh(PetList, Config.SkippedAnimals) end end)

-- ============================================================
-- [ MY PLOT TAB ]
-- ============================================================
local PlotTab = BreedSection:Tab({ Title = "My Plot", Icon = "solar:streets-map-point-bold", IconColor = Color3.fromHex("#1E1B4B"), IconShape = "Square", Border = true })

PlotTab:Section({ Title = "Plot Automation" })
PlotTab:Toggle({ Title = "Auto Collect Cash", Value = Config.AutoCollectMoney, Callback = function(v) Config.AutoCollectMoney = v SaveSettings() end })
PlotTab:Toggle({ Title = "Auto Pickup All",   Value = Config.AutoPickupAll,    Callback = function(v) Config.AutoPickupAll = v    SaveSettings() end })
PlotTab:Toggle({ Title = "Auto Pickup Eggs",  Value = Config.AutoPickupEggs,   Callback = function(v) Config.AutoPickupEggs = v   SaveSettings() end })
PlotTab:Divider() PlotTab:Section({ Title = "Auto Breeding" })
PlotTab:Paragraph({ Title = "Quick Setup", Desc = "1. Click Sync Pet List\n2. Select Breed Target 1 & 2\n3. Enable Auto Breed" })
PlotTab:Toggle({ Title = "Enable Auto Breed", Value = Config.AutoBreed, Callback = function(v) Config.AutoBreed = v SaveSettings() end })
local p1Dropdown = PlotTab:Dropdown({ Title = "Breed Target 1", Values = GetGardenPetNames(), Value = Config.BreedTarget1, Callback = function(v) Config.BreedTarget1 = v SaveSettings() end })
local p2Dropdown = PlotTab:Dropdown({ Title = "Breed Target 2", Values = GetGardenPetNames(), Value = Config.BreedTarget2, Callback = function(v) Config.BreedTarget2 = v SaveSettings() end })
PlotTab:Button({ Title = "Sync Pet List", Icon = "solar:refresh-square-bold", Color = Color3.fromHex("#00d4ff"),
    Callback = function() local list = GetGardenPetNames() p1Dropdown:Refresh(list) p2Dropdown:Refresh(list) WindUI:Notify({ Title = "My Plot", Icon = "solar:refresh-square-bold", Content = "Pet list synced!" }) end })
PlotTab:Button({ Title = "Breed Now (Manual)", Icon = "solar:heart-bold", Color = Color3.fromHex("#ff69b4"),
    Callback = function() task.spawn(DoAutoBreed) end })

-- ============================================================
-- [ WEATHER BREED TAB ]
-- ============================================================
local WeatherTab = BreedSection:Tab({ Title = "Weather Breed", Icon = "solar:cloud-waterdrops-bold", IconColor = Color3.fromHex("#1A1040"), IconShape = "Square", Border = true })

WeatherTab:Section({ Title = "Weather Breed" })
WeatherTab:Paragraph({ Title = "How It Works", Desc = "Auto-breed on weather events:\n  Rain              +25% Luck\n  Aurora Borealis  +300% Luck\n  Cosmic Shower    +200% Luck\n  Volcanic Eruption +200% Luck" })
WeatherTab:Button({ Title = "Check Current Weather", Icon = "solar:cloud-waterdrops-bold", Color = Color3.fromHex("#00d4ff"),
    Callback = function() local w = GetCurrentWeather() if w then currentWeather = w end WindUI:Notify({ Title = "Weather", Content = "Current: "..currentWeather, Duration = 5 }) end })

local weatherDefs = {
    { key="Rain",          label="Rain (+25% Luck)",              icon="solar:cloud-waterdrops-bold", color="#33aaff", eKey="WeatherBreed_Rain_Enabled",     sKey="WeatherBreed_Rain_Slot",     p1Key="WeatherBreed_Rain_Pet1",     p2Key="WeatherBreed_Rain_Pet2" },
    { key="AuroraBorealis",label="Aurora Borealis (+300% Luck)",  icon="solar:stars-bold",            color="#4dffcc", eKey="WeatherBreed_Aurora_Enabled",   sKey="WeatherBreed_Aurora_Slot",   p1Key="WeatherBreed_Aurora_Pet1",   p2Key="WeatherBreed_Aurora_Pet2" },
    { key="CosmicShower",  label="Cosmic Shower (+200% Luck)",    icon="solar:star-shine-bold",       color="#c778ff", eKey="WeatherBreed_Cosmic_Enabled",   sKey="WeatherBreed_Cosmic_Slot",   p1Key="WeatherBreed_Cosmic_Pet1",   p2Key="WeatherBreed_Cosmic_Pet2" },
    { key="Eruption",      label="Volcanic Eruption (+200% Luck)",icon="solar:fire-bold",             color="#ff6600", eKey="WeatherBreed_Eruption_Enabled", sKey="WeatherBreed_Eruption_Slot", p1Key="WeatherBreed_Eruption_Pet1", p2Key="WeatherBreed_Eruption_Pet2" },
}

local weatherDropdowns = {}
for _, wd in ipairs(weatherDefs) do
    WeatherTab:Divider() WeatherTab:Section({ Title = wd.label })
    WeatherTab:Toggle({ Title = "Enable", Value = Config[wd.eKey], Callback = function(v) Config[wd.eKey] = v SaveSettings() end })
    WeatherTab:Dropdown({ Title = "Save Slot", Values = {"1","2","3","4"}, Value = tostring(Config[wd.sKey]), Callback = function(v) Config[wd.sKey] = tonumber(v) or 1 SaveSettings() end })
    local d1 = WeatherTab:Dropdown({ Title = "Pet 1", Values = GetGardenPetNames(), Value = Config[wd.p1Key], Callback = function(v) Config[wd.p1Key] = v SaveSettings() end })
    local d2 = WeatherTab:Dropdown({ Title = "Pet 2", Values = GetGardenPetNames(), Value = Config[wd.p2Key], Callback = function(v) Config[wd.p2Key] = v SaveSettings() end })
    local cd1, cd2 = d1, d2
    local wdCapture = wd
    WeatherTab:Button({ Title = "Sync Pets", Icon = "solar:refresh-square-bold", Color = Color3.fromHex(wd.color),
        Callback = function() local l = GetGardenPetNames() cd1:Refresh(l) cd2:Refresh(l) WindUI:Notify({ Title = wdCapture.label, Content = "Pet list synced!" }) end })
    WeatherTab:Button({ Title = "Breed Now (Manual)", Icon = "solar:heart-bold", Color = Color3.fromHex(wd.color),
        Callback = function()
            local p1 = Config[wdCapture.p1Key]
            local p2 = Config[wdCapture.p2Key]
            if p1 == "" or p2 == "" then
                WindUI:Notify({ Title = wdCapture.label, Icon = "solar:close-circle-bold", Content = "Pilih Pet 1 dan Pet 2 dulu!", Duration = 4 })
                return
            end
            task.spawn(function() DoWeatherBreed(p1, p2) end)
        end })
    table.insert(weatherDropdowns, { d1=d1, d2=d2 })
end

-- ============================================================
-- [ VISUAL / ESP TAB ]
-- ============================================================
local VisualTab = UtilSection:Tab({ Title = "Visual / ESP", Icon = "solar:eye-bold", IconColor = Color3.fromHex("#241657"), IconShape = "Square", Border = true })
VisualTab:Section({ Title = "Pet ESP" })
VisualTab:Paragraph({ Title = "Overview", Desc = "Shows name, rarity, mutation, size & distance above wild pets within your scan radius." })
VisualTab:Toggle({   Title = "Enable ESP",       Value = Config.EnableESP,   Callback = function(v) Config.EnableESP = v SaveSettings() if not v then ClearESP() espWasEnabled = false end end })
VisualTab:Slider({   Title = "Scan Radius",      Step = 100, Value = { Min = 100, Max = 5000, Default = Config.RenderDist }, Callback = function(v) Config.RenderDist = v SaveSettings() end })
VisualTab:Dropdown({ Title = "Visible Rarities", Multi = true, Values = {"Common","Rare","Epic","Legendary","Mythic","Secret"}, Value = Config.EspSelectedRarities, Callback = function(v) Config.EspSelectedRarities = normalizeDropdownValue(v) SaveSettings() end })

-- ============================================================
-- [ SHOP TAB ]
-- ============================================================
local ShopTab = UtilSection:Tab({ Title = "Shop", Icon = "solar:cart-large-2-bold", IconColor = Color3.fromHex("#2E1065"), IconShape = "Square", Border = true })
ShopTab:Section({ Title = "Food & Supplies" })
ShopTab:Toggle({ Title = "Auto Buy Food",     Value = Config.AutoBuyFood,  Callback = function(v) Config.AutoBuyFood = v  SaveSettings() end })
ShopTab:Button({ Title = "Buy Food Now",       Icon = "solar:cart-large-2-bold", Color = Color3.fromHex("#00ff9d"), Callback = DoManualBuyFood })
ShopTab:Divider() ShopTab:Section({ Title = "Merchant" })
ShopTab:Toggle({ Title = "Auto Buy Merchant", Value = Config.AutoMerchant, Callback = function(v) Config.AutoMerchant = v SaveSettings() end })
ShopTab:Button({ Title = "Buy Merchant Now",   Icon = "solar:cart-check-bold",   Color = Color3.fromHex("#FFD700"),  Callback = DoManualMerchantBuy })

-- ============================================================
-- [ LASSO HACK TAB ]
-- ============================================================
local LassoTab = UtilSection:Tab({ Title = "Lasso Hack", Icon = "solar:magic-stick-3-bold", IconColor = Color3.fromHex("#3B0764"), IconShape = "Square", Border = true })
LassoTab:Section({ Title = "Easy Taming System" })
LassoTab:Paragraph({ Title = "How It Works", Desc = "Method 1 — Forces taming minigame to Level 1\nMethod 2 — Spoofs powerful lasso name to server\n\nResult: Any pet tamed effortlessly with a weak lasso." })
LassoTab:Toggle({ Title = "Enable Easy Taming", Value = Config.EasyTamingMode,
    Callback = function(v) Config.EasyTamingMode = v SaveSettings()
        if v then ApplyEasyTaming() WindUI:Notify({ Title = "Easy Taming ON",  Icon = "solar:magic-stick-3-bold", Content = "Fake: "..Config.FakeLassoName, Duration = 5 })
        else RemoveEasyTaming() WindUI:Notify({ Title = "Easy Taming OFF", Icon = "solar:magic-stick-3-bold", Content = "Original lasso restored", Duration = 4 }) end end })
LassoTab:Dropdown({ Title = "Fake Lasso Name", Values = LassoList, Value = Config.FakeLassoName,
    Callback = function(v) Config.FakeLassoName = v SaveSettings() if Config.EasyTamingMode then ApplyEasyTaming() WindUI:Notify({ Title = "Lasso Updated", Content = "Now using: "..v, Duration = 3 }) end end })
LassoTab:Divider() LassoTab:Section({ Title = "Lasso Power Reference" })
LassoTab:Paragraph({ Title = "Strength Values", Desc = "Stellar Lasso    → 3100  ★ Recommended\nHelion Lasso     → 2600\nBlackhole Lasso  → 2100\nFragmented Lasso → 1700\nNebula Lasso     → 1400\nCelestial Tether → 1100\nVoidweave Lasso  → 850\nNightveil Lasso  → 600\nBasic Lasso      → 10  (Hardest)" })
LassoTab:Divider()
LassoTab:Button({ Title = "Re-Apply Easy Taming", Icon = "solar:magic-stick-3-bold", Color = Color3.fromHex("#00ff9d"),
    Callback = function() if Config.EasyTamingMode then ApplyEasyTaming() WindUI:Notify({ Title = "Re-Applied", Content = "Fake: "..Config.FakeLassoName, Duration = 4 })
    else WindUI:Notify({ Title = "Not Active", Content = "Enable Easy Taming first", Duration = 3 }) end end })
LassoTab:Button({ Title = "Check Equipped Lasso", Icon = "solar:eye-bold", Color = Color3.fromHex("#a5d8ff"),
    Callback = function() pcall(function()
        local lc = require(ReplicatedStorage.Packages.knit).GetController("LassoController")
        if lc then WindUI:Notify({ Title = "Lasso Info", Content = "Equipped: "..tostring(lc.EquippedLasso), Duration = 5 })
        else WindUI:Notify({ Title = "Error", Content = "LassoController not found", Duration = 4 }) end
    end) end })

-- ============================================================
-- [ MISC TAB ]
-- ============================================================
local MiscTab = UtilSection:Tab({ Title = "Misc", Icon = "solar:settings-bold", IconColor = Color3.fromHex("#1C1033"), IconShape = "Square", Border = true })
MiscTab:Section({ Title = "Movement" })
MiscTab:Slider({ Title = "Walk Speed", Desc = "Default: 16", Step = 1, Value = { Min = 16, Max = 250, Default = Config.WalkSpeed }, Callback = function(v) Config.WalkSpeed = v SaveSettings() end })
MiscTab:Toggle({ Title = "Infinite Jump", Value = Config.InfiniteJump, Callback = function(v) Config.InfiniteJump = v SaveSettings() end })
MiscTab:Divider() MiscTab:Section({ Title = "Advanced Movement" })
MiscTab:Toggle({ Title = "Flight Mode", Value = false, Callback = function(v)
    Flying = v
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        if Flying then
            local bg = Instance.new("BodyGyro", root) bg.Name = "NebulaFlyGyro" bg.P = 9e4 bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
            local bv = Instance.new("BodyVelocity", root) bv.Name = "NebulaFlyVelocity" bv.MaxForce = Vector3.new(9e9,9e9,9e9)
            task.spawn(function()
                while Flying do
                    RunService.RenderStepped:Wait()
                    local cam = Workspace.CurrentCamera
                    local vel = Vector3.new(0, 0.1, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel += cam.CFrame.LookVector * Config.FlySpeed end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel -= cam.CFrame.LookVector * Config.FlySpeed end
                    bv.Velocity = vel bg.CFrame = cam.CFrame
                end
                bg:Destroy() bv:Destroy()
            end)
        end
    end
end })
MiscTab:Toggle({ Title = "Noclip", Value = false, Callback = function(v)
    Noclip = v
    if Noclip then NoclipConn = RunService.Stepped:Connect(function() if lp.Character then for _, part in pairs(lp.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)
    else if NoclipConn then NoclipConn:Disconnect() end end
end })
MiscTab:Divider() MiscTab:Section({ Title = "Stability & Anti-Detection" })
MiscTab:Toggle({ Title = "Anti-AFK",             Value = Config.AntiAFK,           Callback = function(v) Config.AntiAFK = v           SaveSettings() if v then StartAntiAFK()    else StopAntiAFK()    end end })
MiscTab:Toggle({ Title = "Auto Rejoin",           Value = Config.AutoRejoin,         Callback = function(v) Config.AutoRejoin = v         SaveSettings() if v then StartAutoRejoin() else StopAutoRejoin() end end })
MiscTab:Toggle({ Title = "Hide Username",         Value = Config.AutoHideName,       Callback = function(v) Config.AutoHideName = v       SaveSettings() if v then HideNameConn = RunService.Heartbeat:Connect(UpdateHideName) else if HideNameConn then HideNameConn:Disconnect() HideNameConn = nil end end end })
MiscTab:Toggle({ Title = "FPS Boost",             Value = Config.FPSBoost,           Callback = function(v) Config.FPSBoost = v           SaveSettings() ApplyFPSBoost() end })
MiscTab:Toggle({ Title = "Auto Equip Best Lasso", Value = Config.AutoEquipBestLasso, Callback = function(v) Config.AutoEquipBestLasso = v SaveSettings() end })
MiscTab:Divider() MiscTab:Section({ Title = "Server" })
MiscTab:Button({ Title = "Server Hop", Icon = "solar:arrow-right-up-bold", Color = Color3.fromHex("#00d4ff"), Callback = ServerHop })

-- ============================================================
-- [ DEVELOPER TAB ]
-- ============================================================
local DevTab = UtilSection:Tab({ Title = "Developer", Icon = "solar:code-bold", IconColor = Color3.fromHex("#150D2E"), IconShape = "Square", Border = true })
DevTab:Section({ Title = "External Tools" })
DevTab:Paragraph({ Title = "Developer Utilities", Desc = "Load external tools for remote monitoring, workspace exploration, and admin commands." })
DevTab:Button({ Title = "Load Infinite Yield",   Icon = "solar:link-bold", Color = Color3.fromHex("#00ff9d"), Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end })
DevTab:Button({ Title = "Load Dex Explorer",     Icon = "solar:link-bold", Color = Color3.fromHex("#a5d8ff"), Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))() end })
DevTab:Button({ Title = "Load Cobalt RemoteSpy", Icon = "solar:link-bold", Color = Color3.fromHex("#FFD700"), Callback = function() loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))() end })

-- ============================================================
-- [ BACKGROUND LOOPS ]
-- ============================================================
task.spawn(function()
    if not Remotes then return end
    local nr = Remotes:WaitForChild("notification", 10)
    if not nr then return end
    nr.OnClientEvent:Connect(function(data)
        if Config.AutoMerchant and data and typeof(data) == "table" and data.Title and data.Title:find("Merchant") then task.wait(1) DoManualMerchantBuy() end
    end)
end)

task.spawn(function() while true do task.wait(1.5) if Config.AutoPickupAll then DoManualPickup() end end end)
task.spawn(function() while true do task.wait(1.5) if Config.AutoPickupEggs and not Config.AutoPickupAll then DoManualPickupEggs() end end end)
task.spawn(function() while true do task.wait(2)   if Config.AutoCollectMoney and CollectCashRemote then pcall(function() CollectCashRemote:FireServer() end) end end end)
task.spawn(function() while true do task.wait(300) if Config.AutoMerchant then DoManualMerchantBuy() end end end)
task.spawn(function() while true do task.wait(10)  if Config.AutoBuyFood   then DoManualBuyFood()    end end end)

-- ============================================================
-- [FIX] Auto Breed Loop — bersih, pakai DoAutoBreed()
-- ============================================================
task.spawn(function()
    while true do
        task.wait(3)
        if Config.AutoBreed and Config.BreedTarget1 ~= "" and Config.BreedTarget2 ~= "" then
            pcall(DoAutoBreed)
        end
    end
end)

-- ============================================================
-- [FIX] Weather Breed Loop — pakai DoWeatherBreed() yang sudah diperbaiki
-- ============================================================
task.spawn(function()
    local lastTriggered = ""
    while true do
        task.wait(5)
        local w = currentWeather
        local wcs = {
            { key="Rain",           name="Rain",              icon="solar:cloud-waterdrops-bold", enabled=Config.WeatherBreed_Rain_Enabled,     slot=Config.WeatherBreed_Rain_Slot,     p1=Config.WeatherBreed_Rain_Pet1,     p2=Config.WeatherBreed_Rain_Pet2 },
            { key="AuroraBorealis", name="Aurora Borealis",   icon="solar:stars-bold",            enabled=Config.WeatherBreed_Aurora_Enabled,   slot=Config.WeatherBreed_Aurora_Slot,   p1=Config.WeatherBreed_Aurora_Pet1,   p2=Config.WeatherBreed_Aurora_Pet2 },
            { key="CosmicShower",   name="Cosmic Shower",     icon="solar:star-shine-bold",       enabled=Config.WeatherBreed_Cosmic_Enabled,   slot=Config.WeatherBreed_Cosmic_Slot,   p1=Config.WeatherBreed_Cosmic_Pet1,   p2=Config.WeatherBreed_Cosmic_Pet2 },
            { key="Eruption",       name="Volcanic Eruption", icon="solar:fire-bold",             enabled=Config.WeatherBreed_Eruption_Enabled, slot=Config.WeatherBreed_Eruption_Slot, p1=Config.WeatherBreed_Eruption_Pet1, p2=Config.WeatherBreed_Eruption_Pet2 },
        }
        -- baca config terbaru setiap iterasi
        wcs[1].enabled  = Config.WeatherBreed_Rain_Enabled
        wcs[1].slot     = Config.WeatherBreed_Rain_Slot
        wcs[1].p1       = Config.WeatherBreed_Rain_Pet1
        wcs[1].p2       = Config.WeatherBreed_Rain_Pet2
        wcs[2].enabled  = Config.WeatherBreed_Aurora_Enabled
        wcs[2].slot     = Config.WeatherBreed_Aurora_Slot
        wcs[2].p1       = Config.WeatherBreed_Aurora_Pet1
        wcs[2].p2       = Config.WeatherBreed_Aurora_Pet2
        wcs[3].enabled  = Config.WeatherBreed_Cosmic_Enabled
        wcs[3].slot     = Config.WeatherBreed_Cosmic_Slot
        wcs[3].p1       = Config.WeatherBreed_Cosmic_Pet1
        wcs[3].p2       = Config.WeatherBreed_Cosmic_Pet2
        wcs[4].enabled  = Config.WeatherBreed_Eruption_Enabled
        wcs[4].slot     = Config.WeatherBreed_Eruption_Slot
        wcs[4].p1       = Config.WeatherBreed_Eruption_Pet1
        wcs[4].p2       = Config.WeatherBreed_Eruption_Pet2

        local matched = false
        for _, wc in ipairs(wcs) do
            if w == wc.key and wc.enabled and wc.p1 ~= "" and wc.p2 ~= "" then
                matched = true
                if lastTriggered ~= wc.key then
                    lastTriggered = wc.key
                    -- pindah slot dulu, tunggu pen load
                    local loaded = SwitchSlotAndWait(wc.slot, wc.p1, wc.p2)
                    WindUI:Notify({
                        Title   = wc.name .. " Active!",
                        Icon    = wc.icon,
                        Content = "Slot " .. wc.slot .. " | " .. wc.p1 .. " x " .. wc.p2 .. (loaded and "" or " [TIMEOUT — coba manual]"),
                        Duration = 6
                    })
                end
                -- [FIX] langsung panggil DoWeatherBreed (bukan fungsi lama)
                task.spawn(function()
                    DoWeatherBreed(wc.p1, wc.p2)
                end)
                break
            end
        end
        if not matched then
            if lastTriggered ~= "" then
                lastTriggered = ""
                weatherBreedLock = false
            end
        end
    end
end)

-- ============================================================
-- [ AUTO FARM LOOP ]
-- ============================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoFarm and not isTaming then
            if Config.EasyTamingMode then ApplyEasyTaming() end
            local target = GetNextTarget()
            if target and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
                if tRoot then
                    isTaming = true
                    local ok = pcall(function()
                        lp.Character.HumanoidRootPart.CFrame = tRoot.CFrame * CFrame.new(0, 1.5, 4.2)
                        if Remotes then pcall(function() Remotes.retrieveData:InvokeServer() end) pcall(function() Remotes.equipLassoVisual:InvokeServer() end) end
                        task.wait(0.1)
                        if Remotes then pcall(function() Remotes.ThrowLasso:FireServer(0.9, (tRoot.Position - lp.Character.HumanoidRootPart.Position).Unit) end) end
                        task.wait(0.2)
                        if Remotes then pcall(function() Remotes.minigameRequest:InvokeServer(target, tRoot.CFrame) end) end
                        local progress, attempts = 0, 0
                        while progress < 100 and Config.AutoFarm and attempts < 120 do
                            task.wait(math.random(15, 25) / 100)
                            progress += Config.JumpSize + math.random(-50, 50) / 100
                            if Remotes then pcall(function() Remotes.UpdateProgress:FireServer(math.min(progress, 100)) end) end
                            attempts += 1
                        end
                        task.wait(0.3)
                    end)
                    if not ok then isTaming = false end
                    isTaming = false
                end
            end
        end
        if Config.AutoEquipBestLasso then AutoEquipBestLasso() end
    end
end)

RunService.RenderStepped:Connect(function()
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = Config.WalkSpeed end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid:ChangeState("Jumping") end
end)

if Config.AntiAFK      then StartAntiAFK() end
if Config.AutoRejoin   then StartAutoRejoin() end
if Config.AutoHideName then HideNameConn = RunService.Heartbeat:Connect(UpdateHideName) end
if Config.FPSBoost     then ApplyFPSBoost() end
espWasEnabled = Config.EnableESP
if not Config.EnableESP then ClearESP() end
if Config.EasyTamingMode then ApplyEasyTaming() end

task.delay(0.5, function() pcall(function() Window:SelectTab(HomeTab) end) end)

WindUI:Notify({ Title = "NEBULA HUB v19.0 [FIXED]", Icon = "solar:planet-2-bold-duotone", Content = "Breed fix loaded successfully!", Duration = 5 })
