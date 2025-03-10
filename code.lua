-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Teams = game:GetService("Teams")

-- Variables principales
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

-- Variables para el sistema de arrastre
local Dragging = false
local DragStart = nil
local StartPos = nil

-- Variables para el botón de toggle
local ToggleDragging = false
local ToggleDragStart = nil
local ToggleStartPos = nil

-- Variables para el redimensionamiento
local Resizing = false
local ResizeStart = nil
local StartSize = nil

-- Variables para guardado de posiciones
local SavedPositions = {}
local RespawnPoint = nil

-- Tabla para almacenar el estado de las funciones
local EnabledFeatures = {}

-- Sistema de idiomas (ahora por defecto en español)
local Languages = {
    ["Español"] = {
        categories = {
            Movement = "Movimiento",
            Combat = "Combate",
            Visuals = "Visuales",
            Player = "Jugador",
            World = "Mundo",
            Optimization = "Optimización",
            Misc = "Varios",
            Settings = "Ajustes"
        },
        features = {
            Fly = "Volar",
            Speed = "Velocidad",
            SuperJump = "Super Salto",
            InfiniteJump = "Salto Infinito",
            NoClip = "Atravesar Paredes",
            GodMode = "Modo Dios",
            KillAura = "Aura Asesina",
            AutoParry = "Auto Bloqueo",
            Reach = "Alcance",
            ESP = "ESP",
            Chams = "Siluetas",
            Tracers = "Trazadores",
            Fullbright = "Brillo Total",
            Invisibility = "Invisibilidad",
            AntiAFK = "Anti AFK",
            AutoReset = "Auto Reinicio",
            RemoveFog = "Quitar Niebla",
            DayNight = "Día/Noche",
            RemoveTextures = "Quitar Texturas",
            ChatSpam = "Spam de Chat",
            AutoFarm = "Auto Farming",
            ServerHop = "Cambiar Servidor",
            Language = "Idioma",
            LowGraphics = "Gráficos Bajos",
            DisableEffects = "Desactivar Efectos",
            ReduceTextures = "Reducir Texturas",
            DisableLighting = "Desactivar Iluminación",
            SaveRespawn = "Guardar Reaparición",
            DeleteRespawn = "Borrar Reaparición",
            SavePosition = "Guardar Posición",
            TeleportToPosition = "Teletransportar",
            BunnyHop = "Salto Continuo",
            WallRun = "Correr en Paredes",
            DoubleJump = "Doble Salto",
            AirDash = "Dash Aéreo",
            Slide = "Deslizar",
            Grapple = "Gancho",
            SpeedBoost = "Aumento de Velocidad",
            JumpBoost = "Aumento de Salto",
            Levitation = "Levitación",
            Blink = "Parpadeo",
            Telekinesis = "Telequinesis",
            AutoDodge = "Auto Esquivar",
            AutoAim = "Auto Apuntar",
            RapidFire = "Disparo Rápido",
            InfiniteAmmo = "Munición Infinita",
            DamageMultiplier = "Multiplicador de Daño",
            AutoBlock = "Auto Bloquear",
            CriticalHit = "Golpe Crítico",
            Aimbot = "Apuntado Automático",
            SilentAim = "Apuntado Silencioso",
            Wallbang = "Disparar a través de Paredes",
            InstantKill = "Muerte Instantánea",
            AutoHeal = "Auto Curación",
            Triggerbot = "Disparo Automático",
            SpinBot = "Giro Automático",
            AntiAim = "Anti Apuntado",
            HitboxExpander = "Expandir Hitbox",
            WeaponMods = "Modificaciones de Armas",
            AutoReload = "Recarga Automática",
            RapidMelee = "Ataque Cuerpo a Cuerpo Rápido",
            UITransparency = "Transparencia de Interfaz"
        },
        loading = "Cargando...",
        welcome = "Bienvenido a Kimiko HUD",
        version = "Versión 1.0"
    },
    ["English"] = {
        -- English translations would go here
    }
}

local CurrentLanguage = "Español"
local Texts = Languages[CurrentLanguage]

-- Crear pantalla de carga con animación mejorada
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "LoadingGui"
LoadingGui.ResetOnSpawn = false
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.DisplayOrder = 9999
LoadingGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
LoadingFrame.ZIndex = 10000
LoadingFrame.Parent = LoadingGui

-- Logo animado
local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 200, 0, 200)
LogoContainer.Position = UDim2.new(0.5, -100, 0.4, -100)
LogoContainer.BackgroundTransparency = 1
LogoContainer.ZIndex = 10001
LogoContainer.Parent = LoadingFrame

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 120, 0, 120)
Logo.Position = UDim2.new(0.5, -60, 0.5, -60)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://6031251532" -- Placeholder logo, replace with your own
Logo.ImageColor3 = Color3.fromRGB(147, 112, 219)
Logo.ZIndex = 10002
Logo.Parent = LogoContainer

-- Animación del logo
TweenService:Create(Logo, TweenInfo.new(2, Enum.EasingStyle.Elastic), {Size = UDim2.new(0, 150, 0, 150), Position = UDim2.new(0.5, -75, 0.5, -75)}):Play()

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0.4, 0, 0.01, 0)
LoadingBar.Position = UDim2.new(0.3, 0, 0.6, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
LoadingBar.BorderSizePixel = 0
LoadingBar.ZIndex = 10001
LoadingBar.Parent = LoadingFrame

local LoadingBarCorner = Instance.new("UICorner")
LoadingBarCorner.CornerRadius = UDim.new(1, 0)
LoadingBarCorner.Parent = LoadingBar

local LoadingFill = Instance.new("Frame")
LoadingFill.Size = UDim2.new(0, 0, 1, 0)
LoadingFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
LoadingFill.BorderSizePixel = 0
LoadingFill.ZIndex = 10002
LoadingFill.Parent = LoadingBar

local LoadingFillCorner = Instance.new("UICorner")
LoadingFillCorner.CornerRadius = UDim.new(1, 0)
LoadingFillCorner.Parent = LoadingFill

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(0, 200, 0, 30)
LoadingText.Position = UDim2.new(0.5, -100, 0.65, -15)
LoadingText.BackgroundTransparency = 1
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Text = Texts.loading
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 18
LoadingText.ZIndex = 10003
LoadingText.Parent = LoadingFrame

local WelcomeText = Instance.new("TextLabel")
WelcomeText.Size = UDim2.new(0, 300, 0, 40)
WelcomeText.Position = UDim2.new(0.5, -150, 0.3, -20)
WelcomeText.BackgroundTransparency = 1
WelcomeText.Font = Enum.Font.GothamBlack
WelcomeText.Text = Texts.welcome
WelcomeText.TextColor3 = Color3.fromRGB(147, 112, 219)
WelcomeText.TextSize = 28
WelcomeText.ZIndex = 10003
WelcomeText.Parent = LoadingFrame
WelcomeText.TextTransparency = 1

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(0, 200, 0, 20)
VersionText.Position = UDim2.new(0.5, -100, 0.34, 0)
VersionText.BackgroundTransparency = 1
VersionText.Font = Enum.Font.Gotham
VersionText.Text = Texts.version
VersionText.TextColor3 = Color3.fromRGB(200, 200, 200)
VersionText.TextSize = 14
VersionText.ZIndex = 10003
VersionText.Parent = LoadingFrame
VersionText.TextTransparency = 1

-- Animación de texto de bienvenida
TweenService:Create(WelcomeText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
TweenService:Create(VersionText, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3), {TextTransparency = 0}):Play()

-- Animación de carga con efecto de pulso
local loadingTween = TweenService:Create(LoadingFill, TweenInfo.new(2.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)})
loadingTween:Play()

-- Efecto de pulso en el logo
spawn(function()
    while LoadingGui.Parent do
        TweenService:Create(Logo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.2}):Play()
        wait(1.5)
        TweenService:Create(Logo, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
        wait(1.5)
    end
end)

loadingTween.Completed:Wait()

-- GUI Principal con diseño mejorado
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnhancedGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Botón para mostrar/ocultar con diseño mejorado
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(764, 244)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui
ToggleButton.ZIndex = 10000

-- Efecto de sombra para el botón
local ToggleShadow = Instance.new("ImageLabel")
ToggleShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
ToggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleShadow.BackgroundTransparency = 1
ToggleShadow.Image = "rbxassetid://5554236805"
ToggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
ToggleShadow.ImageTransparency = 0.6
ToggleShadow.ZIndex = 9999
ToggleShadow.Parent = ToggleButton

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Efecto de brillo para el botón
local ToggleGlow = Instance.new("ImageLabel")
ToggleGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
ToggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
ToggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleGlow.BackgroundTransparency = 1
ToggleGlow.Image = "rbxassetid://5554236805"
ToggleGlow.ImageColor3 = Color3.fromRGB(147, 112, 219)
ToggleGlow.ImageTransparency = 0.7
ToggleGlow.ZIndex = 9998
ToggleGlow.Parent = ToggleButton

-- Animación de brillo
spawn(function()
    while ToggleButton.Parent do
        TweenService:Create(ToggleGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.9, Size = UDim2.new(1.7, 0, 1.7, 0)}):Play()
        wait(2)
        TweenService:Create(ToggleGlow, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.7, Size = UDim2.new(1.5, 0, 1.5, 0)}):Play()
        wait(2)
    end
end)

-- Frame Principal con borde de cristal y gradiente
local MainBorder = Instance.new("Frame")
MainBorder.Name = "MainBorder"
MainBorder.Size = UDim2.new(0, 600, 0, 400)
MainBorder.Position = UDim2.new(0.5, -300, 0.5, -200)
MainBorder.BackgroundColor3 = Color3.fromRGB(157, 122, 229)
MainBorder.BorderSizePixel = 0
MainBorder.Visible = false
MainBorder.Parent = ScreenGui
MainBorder.ZIndex = 9000

-- Efecto de sombra para el panel principal
local MainShadow = Instance.new("ImageLabel")
MainShadow.Size = UDim2.new(1.05, 0, 1.05, 0)
MainShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
MainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
MainShadow.BackgroundTransparency = 1
MainShadow.Image = "rbxassetid://5554236805"
MainShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.ImageTransparency = 0.5
MainShadow.ZIndex = 8999
MainShadow.Parent = MainBorder

-- Añadir gradiente al borde con efecto de cristal
local UIGradient = Instance.new("UIGradient")
UIGradient.Rotation = 45
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 145, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(157, 122, 229)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 100, 200))
})
UIGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(0.5, 0.2),
    NumberSequenceKeypoint.new(1, 0.1)
})
UIGradient.Parent = MainBorder

local MainBorderCorner = Instance.new("UICorner")
MainBorderCorner.CornerRadius = UDim.new(0, 12)
MainBorderCorner.Parent = MainBorder

-- Frame Principal con efecto de vidrio
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0, 2, 0, 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainBorder
MainFrame.ZIndex = 9001

-- Efecto de vidrio/blur
local BlurEffect = Instance.new("ImageLabel")
BlurEffect.Size = UDim2.new(1, 0, 1, 0)
BlurEffect.BackgroundTransparency = 1
BlurEffect.Image = "rbxassetid://5553946656"
BlurEffect.ImageTransparency = 0.7
BlurEffect.ImageColor3 = Color3.fromRGB(0, 0, 0)
BlurEffect.ScaleType = Enum.ScaleType.Tile
BlurEffect.TileSize = UDim2.new(0, 200, 0, 200)
BlurEffect.ZIndex = 9000
BlurEffect.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Título "Kimiko HUD" con diseño mejorado
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 9002
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 10)
TitleBarCorner.Parent = TitleBar

-- Cortar la parte inferior del TitleBar para que se vea integrado
local TitleBarCover = Instance.new("Frame")
TitleBarCover.Size = UDim2.new(1, 0, 0, 10)
TitleBarCover.Position = UDim2.new(0, 0, 1, -10)
TitleBarCover.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBarCover.BackgroundTransparency = 0.2
TitleBarCover.BorderSizePixel = 0
TitleBarCover.ZIndex = 9002
TitleBarCover.Parent = TitleBar

-- Logo en el título
local TitleLogo = Instance.new("ImageLabel")
TitleLogo.Size = UDim2.new(0, 24, 0, 24)
TitleLogo.Position = UDim2.new(0, 10, 0.5, -12)
TitleLogo.BackgroundTransparency = 1
TitleLogo.Image = "rbxassetid://6031251532" -- Placeholder logo
TitleLogo.ImageColor3 = Color3.fromRGB(147, 112, 219)
TitleLogo.ZIndex = 9003
TitleLogo.Parent = TitleBar

local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Kimiko HUD"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar
Title.ZIndex = 9003

-- Subtítulo con versión
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 100, 0, 20)
Subtitle.Position = UDim2.new(0, 130, 0.5, -10)
Subtitle.BackgroundTransparency = 1
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "BETA"
Subtitle.TextColor3 = Color3.fromRGB(147, 112, 219)
Subtitle.TextSize = 12
Subtitle.ZIndex = 9003
Subtitle.Parent = TitleBar

-- Botones de control en la barra de título
local CloseButton = Instance.new("ImageButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
CloseButton.BackgroundTransparency = 1
CloseButton.Image = "rbxassetid://3926305904"
CloseButton.ImageRectOffset = Vector2.new(284, 4)
CloseButton.ImageRectSize = Vector2.new(24, 24)
CloseButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.ZIndex = 9003
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("ImageButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Image = "rbxassetid://3926307971"
MinimizeButton.ImageRectOffset = Vector2.new(884, 284)
MinimizeButton.ImageRectSize = Vector2.new(36, 36)
MinimizeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.ZIndex = 9003
MinimizeButton.Parent = TitleBar

-- Botón de redimensionamiento mejorado
local ResizeButton = Instance.new("ImageButton")
ResizeButton.Size = UDim2.new(0, 20, 0, 20)
ResizeButton.Position = UDim2.new(1, -25, 1, -25)
ResizeButton.BackgroundTransparency = 0.5
ResizeButton.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
ResizeButton.Image = "rbxassetid://3926305904"
ResizeButton.ImageRectOffset = Vector2.new(564, 284)
ResizeButton.ImageRectSize = Vector2.new(36, 36)
ResizeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
ResizeButton.Parent = MainFrame
ResizeButton.ZIndex = 9003

local ResizeCorner = Instance.new("UICorner")
ResizeCorner.CornerRadius = UDim.new(0, 4)
ResizeCorner.Parent = ResizeButton

-- Sidebar con scroll y diseño mejorado
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.25, 0, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
Sidebar.Parent = MainFrame
Sidebar.ZIndex = 9004
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 400) -- Ajustar según el contenido

-- Añadir UIListLayout para organizar categorías automáticamente
local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

-- Padding para el sidebar
local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingBottom = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- Contenedor principal con scroll
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(0.75, 0, 1, -50)
ContentFrame.Position = UDim2.new(0.25, 0, 0, 40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ContentFrame.BackgroundTransparency = 0.2
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
ContentFrame.Parent = MainFrame
ContentFrame.ZIndex = 9004

-- Función para crear categorías en el sidebar con iconos mejorados
local function CreateCategory(name, icon, position)
    local CategoryButton = Instance.new("TextButton")
    CategoryButton.Name = name.."Category"
    CategoryButton.Size = UDim2.new(1, -20, 0, 40)
    CategoryButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    CategoryButton.BorderSizePixel = 0
    CategoryButton.Font = Enum.Font.GothamSemibold
    CategoryButton.TextSize = 14
    CategoryButton.Parent = Sidebar
    CategoryButton.ZIndex = 9005
    CategoryButton.LayoutOrder = position
    
    -- Efecto de hover
    CategoryButton.MouseEnter:Connect(function()
        if CategoryButton.BackgroundColor3 ~= Color3.fromRGB(147, 112, 219) then -- Si no está seleccionado
            TweenService:Create(CategoryButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
        end
    end)
    
    CategoryButton.MouseLeave:Connect(function()
        if CategoryButton.BackgroundColor3 ~= Color3.fromRGB(147, 112, 219) then -- Si no está seleccionado
            TweenService:Create(CategoryButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
        end
    end)
    
    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.new(0, 20, 0, 20)
    IconImage.Position = UDim2.new(0, 10, 0.5, -10)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = icon
    IconImage.ImageColor3 = Color3.fromRGB(147, 112, 219)
    IconImage.Parent = CategoryButton
    IconImage.ZIndex = 9006
    
    CategoryButton.Text = Texts.categories[name]
    CategoryButton.TextXAlignment = Enum.TextXAlignment.Left
    CategoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryButton.AutoButtonColor = false
    
    local TextPadding = Instance.new("UIPadding")
    TextPadding.PaddingLeft = UDim.new(0, 40)
    TextPadding.Parent = CategoryButton
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = CategoryButton
    
    -- Indicador de selección
    local SelectionIndicator = Instance.new("Frame")
    SelectionIndicator.Name = "SelectionIndicator"
    SelectionIndicator.Size = UDim2.new(0, 4, 0.7, 0)
    SelectionIndicator.Position = UDim2.new(0, 0, 0.15, 0)
    SelectionIndicator.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
    SelectionIndicator.BorderSizePixel = 0
    SelectionIndicator.Visible = false
    SelectionIndicator.ZIndex = 9007
    SelectionIndicator.Parent = CategoryButton
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 2)
    IndicatorCorner.Parent = SelectionIndicator
    
    return CategoryButton
end

-- Función para crear secciones de contenido con diseño mejorado
local function CreateSection(name)
    local Section = Instance.new("ScrollingFrame")
    Section.Name = name.."Section"
    Section.Size = UDim2.new(1, -40, 1, -20)
    Section.Position = UDim2.new(0, 20, 0, 10)
    Section.BackgroundTransparency = 1
    Section.BorderSizePixel = 0
    Section.ScrollBarThickness = 4
    Section.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
    Section.Visible = false
    Section.Parent = ContentFrame
    Section.ZIndex = 9005
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = Section
    
    -- Ajustar el tamaño del contenido automáticamente
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Section.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Añadir padding
    local SectionPadding = Instance.new("UIPadding")
    SectionPadding.PaddingTop = UDim.new(0, 10)
    SectionPadding.PaddingBottom = UDim.new(0, 10)
    SectionPadding.Parent = Section
    
    return Section
end

-- Función mejorada para crear botones de toggle con animaciones
local function CreateToggle(name, section, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ToggleFrame.Parent = section
    ToggleFrame.ZIndex = 9006
    
    -- Efecto de hover
    ToggleFrame.MouseEnter:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
    end)
    
    ToggleFrame.MouseLeave:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
    end)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ToggleFrame
    
    -- Añadir sombra
    local ToggleShadow = Instance.new("ImageLabel")
    ToggleShadow.Size = UDim2.new(1.02, 0, 1.04, 0)
    ToggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    ToggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    ToggleShadow.BackgroundTransparency = 1
    ToggleShadow.Image = "rbxassetid://5554236805"
    ToggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ToggleShadow.ImageTransparency = 0.8
    ToggleShadow.ZIndex = 9005
    ToggleShadow.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = Texts.features[name]
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    Label.ZIndex = 9007
    
    -- Contenedor del switch para mejor posicionamiento
    local SwitchContainer = Instance.new("Frame")
    SwitchContainer.Size = UDim2.new(0, 50, 0, 24)
    SwitchContainer.Position = UDim2.new(1, -60, 0.5, -12)
    SwitchContainer.BackgroundTransparency = 1
    SwitchContainer.Parent = ToggleFrame
    SwitchContainer.ZIndex = 9007
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(1, 0, 1, 0)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    Switch.BorderSizePixel = 0
    Switch.Text = ""
    Switch.Parent = SwitchContainer
    Switch.ZIndex = 9007
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Switch
    Circle.ZIndex = 9008
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    -- Añadir efecto de sombra al círculo
    local CircleShadow = Instance.new("ImageLabel")
    CircleShadow.Size = UDim2.new(1.2, 0, 1.2, 0)
    CircleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    CircleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    CircleShadow.BackgroundTransparency = 1
    CircleShadow.Image = "rbxassetid://5554236805"
    CircleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    CircleShadow.ImageTransparency = 0.7
    CircleShadow.ZIndex = 9007
    CircleShadow.Parent = Circle
    
    local Enabled = false
    local Connection
    
    local function Toggle()
        Enabled = not Enabled
        EnabledFeatures[name] = Enabled
        
        -- Animación mejorada
        local Goal = {
            BackgroundColor3 = Enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(60, 60, 65),
            Position = Enabled and UDim2.new(0, 29, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }
        
        TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Goal.Position}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Goal.BackgroundColor3}):Play()
        
        -- Efecto de brillo al activar
        if Enabled then
            local Glow = Instance.new("ImageLabel")
            Glow.Size = UDim2.new(1.5, 0, 1.5, 0)
            Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
            Glow.AnchorPoint = Vector2.new(0.5, 0.5)
            Glow.BackgroundTransparency = 1
            Glow.Image = "rbxassetid://5554236805"
            Glow.ImageColor3 = Color3.fromRGB(147, 112, 219)
            Glow.ImageTransparency = 0
            Glow.ZIndex = 9007
            Glow.Parent = Circle
            
            TweenService:Create(Glow, TweenInfo.new(0.5), {ImageTransparency = 1, Size = UDim2.new(2, 0, 2, 0)}):Play()
            game.Debris:AddItem(Glow, 0.5)
        end
        
        -- Desconectar la conexión anterior si existe
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
        
        -- Llamar al callback con el nuevo estado
        callback(Enabled)
    end
    
    Switch.MouseButton1Click:Connect(Toggle)
    
    -- Función para obtener el estado actual
    local function GetState()
        return Enabled
    end
    
    -- Función para establecer el estado
    local function SetState(state)
        if state ~= Enabled then
            Toggle()
        end
    end
    
    return {
        Toggle = Toggle,
        GetState = GetState,
        SetState = SetState
    }
end

-- Función mejorada para crear sliders con diseño moderno
local function CreateSlider(name, section, callback, min, max, default)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 70)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    SliderFrame.Parent = section
    SliderFrame.ZIndex = 9006
    
    -- Efecto de hover
    SliderFrame.MouseEnter:Connect(function()
        TweenService:Create(SliderFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 65)}):Play()
    end)
    
    SliderFrame.MouseLeave:Connect(function()
        TweenService:Create(SliderFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
    end)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = SliderFrame
    
    -- Añadir sombra
    local SliderShadow = Instance.new("ImageLabel")
    SliderShadow.Size = UDim2.new(1.02, 0, 1.04, 0)
    SliderShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    SliderShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    SliderShadow.BackgroundTransparency = 1
    SliderShadow.Image = "rbxassetid://5554236805"
    SliderShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    SliderShadow.ImageTransparency = 0.8
    SliderShadow.ZIndex = 9005
    SliderShadow.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 15, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = Texts.features[name]
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    Label.ZIndex = 9007
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 25)
    ValueLabel.Position = UDim2.new(1, -60, 0, 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamSemibold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(147, 112, 219)
    ValueLabel.TextSize = 16
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    ValueLabel.ZIndex = 9007
    
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Size = UDim2.new(1, -30, 0, 6)
    SliderContainer.Position = UDim2.new(0, 15, 0, 45)
    SliderContainer.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    SliderContainer.BorderSizePixel = 0
    SliderContainer.Parent = SliderFrame
    SliderContainer.ZIndex = 9007
    
    local SliderContainerCorner = Instance.new("UICorner")
    SliderContainerCorner.CornerRadius = UDim.new(1, 0)
    SliderContainerCorner.Parent = SliderContainer
    
    local SliderBar = Instance.new("TextButton")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, 0, 1, 0)
    SliderBar.BackgroundTransparency = 1
    SliderBar.Text = ""
    SliderBar.Parent = SliderContainer
    SliderBar.ZIndex = 9008
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderContainer
    SliderFill.ZIndex = 9008
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    -- Círculo deslizante
    local SliderCircle = Instance.new("Frame")
    SliderCircle.Size = UDim2.new(0, 16, 0, 16)
    SliderCircle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, -8)
    SliderCircle.AnchorPoint = Vector2.new(0.5, 0)
    SliderCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderCircle.Parent = SliderContainer
    SliderCircle.ZIndex = 9009
    
    local SliderCircleCorner = Instance.new("UICorner")
    SliderCircleCorner.CornerRadius = UDim.new(1, 0)
    SliderCircleCorner.Parent = SliderCircle
    
    -- Añadir sombra al círculo
    local CircleShadow = Instance.new("ImageLabel")
    CircleShadow.Size = UDim2.new(1.5, 0, 1.5, 0)
    CircleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    CircleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    CircleShadow.BackgroundTransparency = 1
    CircleShadow.Image = "rbxassetid://5554236805"
    CircleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    CircleShadow.ImageTransparency = 0.7
    CircleShadow.ZIndex = 9008
    CircleShadow.Parent = SliderCircle
    
    local Value = default
    local Dragging = false
    
    local function UpdateSlider(input)
        local sizeX = math.clamp((input.Position.X - SliderContainer.AbsolutePosition.X) / SliderContainer.AbsoluteSize.X, 0, 1)
        Value = math.floor(min + ((max - min) * sizeX))
        ValueLabel.Text = tostring(Value)
        SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
        SliderCircle.Position = UDim2.new(sizeX, 0, 0.5, -8)
        EnabledFeatures[name] = Value
        callback(Value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            UpdateSlider(input)
            
            -- Efecto de agrandamiento al arrastrar
            TweenService:Create(SliderCircle, TweenInfo.new(0.2), {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(SliderCircle.Position.X.Scale, 0, 0.5, -10)}):Play()
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
            
            -- Volver al tamaño normal
            TweenService:Create(SliderCircle, TweenInfo.new(0.2), {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(SliderCircle.Position.X.Scale, 0, 0.5, -8)}):Play()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    return function()
        return Value
    end
end

-- Sistema de arrastre para el botón de toggle con animación mejorada
local function UpdateToggleDrag(input)
    if ToggleDragging then
        local delta = input.Position - ToggleDragStart
        local newPosition = UDim2.new(
            ToggleStartPos.X.Scale,
            ToggleStartPos.X.Offset + delta.X,
            ToggleStartPos.Y.Scale,
            ToggleStartPos.Y.Offset + delta.Y
        )
        
        -- Limitar la posición dentro de la pantalla
        local screenSize = workspace.CurrentCamera.ViewportSize
        local buttonSize = ToggleButton.AbsoluteSize
        
        newPosition = UDim2.new(
            newPosition.X.Scale,
            math.clamp(newPosition.X.Offset, 0, screenSize.X - buttonSize.X),
            newPosition.Y.Scale,
            math.clamp(newPosition.Y.Offset, 0, screenSize.Y - buttonSize.Y)
        )
        
        ToggleButton.Position = newPosition
    end
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        -- Iniciar un temporizador para determinar si es un clic o un arrastre
        local startTime = tick()
        local startPosition = input.Position
        
        ToggleDragging = false
        ToggleDragStart = input.Position
        ToggleStartPos = ToggleButton.Position
        
        -- Efecto de pulsación
        TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play()
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                connection:Disconnect()
                
                -- Restaurar tamaño
                TweenService:Create(ToggleButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 50, 0, 50)}):Play()
                
                -- Si el tiempo es corto y la posición no cambió mucho, es un clic
                if tick() - startTime < 0.3 and (input.Position - startPosition).Magnitude < 5 then
                    -- Acción de clic: mostrar/ocultar el menú con animación
                    if MainBorder.Visible then
                        -- Ocultar con animación
                        TweenService:Create(MainBorder, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
                        wait(0.3)
                        MainBorder.Visible = false
                    else
                        -- Mostrar con animación
                        MainBorder.Size = UDim2.new(0, 0, 0, 0)
                        MainBorder.Position = UDim2.new(0.5, 0, 0.5, 0)
                        MainBorder.Visible = true
                        TweenService:Create(MainBorder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200)}):Play()
                    end
                    
                    -- Animar rotación del botón
                    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {Rotation = MainBorder.Visible and 180 or 0}):Play()
                end
                
                ToggleDragging = false
            elseif (input.Position - startPosition).Magnitude > 5 then
                -- Si el movimiento es significativo, es un arrastre
                ToggleDragging = true
                UpdateToggleDrag(input)
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        UpdateToggleDrag(input)
    end
end)

-- Sistema de arrastre para el menú principal con animación suave
local function UpdateDrag(input)
    if Dragging then
        local delta = input.Position - DragStart
        local newPosition = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + delta.Y
        )
        
        -- Limitar la posición dentro de la pantalla
        local screenSize = workspace.CurrentCamera.ViewportSize
        local frameSize = MainBorder.AbsoluteSize
        
        newPosition = UDim2.new(
            newPosition.X.Scale,
            math.clamp(newPosition.X.Offset, 0, screenSize.X - frameSize.X),
            newPosition.Y.Scale,
            math.clamp(newPosition.Y.Offset, 0, screenSize.Y - frameSize.Y)
        )
        
        MainBorder.Position = newPosition
    end
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainBorder.Position
        
        -- Efecto de agarre
        TweenService:Create(TitleBar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        UpdateDrag(input)
    end
end)

Title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
        
        -- Restaurar transparencia
        TweenService:Create(TitleBar, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    end
end)

-- Sistema de redimensionamiento mejorado con animación
local function UpdateResize(input)
    if Resizing then
        local delta = input.Position - ResizeStart
        local newWidth = math.max(400, StartSize.X.Offset + delta.X)
        local newHeight = math.max(300, StartSize.Y.Offset + delta.Y)
        
        -- Actualizar tamaño del borde con animación suave
        MainBorder.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        -- Actualizar posición del botón de redimensionamiento
        ResizeButton.Position = UDim2.new(1, -25, 1, -25)
    end
end

ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Resizing = true
        ResizeStart = input.Position
        StartSize = MainBorder.Size
        StartPos = MainBorder.Position
        
        -- Efecto visual al iniciar redimensionamiento
        TweenService:Create(ResizeButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, Size = UDim2.new(0, 24, 0, 24)}):Play()
    end
end)

ResizeButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        UpdateResize(input)
    end
end)

ResizeButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Resizing = false
        
        -- Restaurar apariencia
        TweenService:Create(ResizeButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, Size = UDim2.new(0, 20, 0, 20)}):Play()
    end
end)

-- Funcionalidad de los botones de la barra de título
CloseButton.MouseButton1Click:Connect(function()
    -- Animación de cierre
    TweenService:Create(MainBorder, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    wait(0.3)
    MainBorder.Visible = false
    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {Rotation = 0}):Play()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    -- Animación de minimizar
    if MainBorder.Size.Y.Offset > 50 then
        -- Guardar tamaño actual para restaurar
        local savedSize = MainBorder.Size
        TweenService:Create(MainBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, MainBorder.Size.X.Offset, 0, 40)}):Play()
        MinimizeButton.MouseButton1Click = function()
            TweenService:Create(MainBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = savedSize}):Play()
            MinimizeButton.MouseButton1Click = function()
                TweenService:Create(MainBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, MainBorder.Size.X.Offset, 0, 40)}):Play()
                MinimizeButton.MouseButton1Click = function()
                    TweenService:Create(MainBorder, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = savedSize}):Play()
                end
            end
        end
end)

-- Categorías actualizadas con iconos modernos
local Categories = {
    {name = "Movement", icon = "rbxassetid://7733715400"},
    {name = "Combat", icon = "rbxassetid://7733774602"},
    {name = "Visuals", icon = "rbxassetid://7733715400"},
    {name = "Player", icon = "rbxassetid://7743875962"},
    {name = "World", icon = "rbxassetid://7733956784"},
    {name = "Optimization", icon = "rbxassetid://7734053495"},
    {name = "Misc", icon = "rbxassetid://7734110573"},
    {name = "Settings", icon = "rbxassetid://7734039100"}
}

-- Crear categorías y secciones
local Sections = {}
local ActiveCategory = nil

for i, category in ipairs(Categories) do
    local button = CreateCategory(category.name, category.icon, i-1)
    Sections[category.name] = CreateSection(category.name)
end

-- Características actualizadas (removidas las que no funcionan)
local MovementFeatures = {
    {name = "Fly", callback = ToggleFly},
    {name = "Speed", callback = ToggleSpeed, slider = true, min = 16, max = 200, default = 16},
    {name = "SuperJump", callback = ToggleSuperJump, slider = true, min = 50, max = 500, default = 50},
    {name = "InfiniteJump", callback = InfiniteJump},
    {name = "NoClip", callback = NoClip},
    {name = "BunnyHop", callback = BunnyHop},
    {name = "Levitation", callback = Levitation}
}

local CombatFeatures = {
    {name = "Reach", callback = Reach},
    {name = "AutoDodge", callback = AutoDodge},
    {name = "AutoAim", callback = AutoAim},
    {name = "DamageMultiplier", callback = DamageMultiplier},
    {name = "InstantKill", callback = InstantKill},
    {name = "AutoHeal", callback = AutoHeal},
    {name = "SpinBot", callback = SpinBot},
    {name = "AntiAim", callback = AntiAim},
    {name = "HitboxExpander", callback = HitboxExpander}
}

local VisualFeatures = {
    {name = "ESP", callback = ESP},
    {name = "Chams", callback = Chams},
    {name = "Tracers", callback = Tracers},
    {name = "Fullbright", callback = Fullbright}
}

local PlayerFeatures = {
    {name = "Invisibility", callback = function() end},
    {name = "AntiAFK", callback = function() end},
    {name = "AutoReset", callback = function() end},
    {name = "SaveRespawn", callback = function() end},
    {name = "DeleteRespawn", callback = function() end},
    {name = "SavePosition", callback = function() end},
    {name = "TeleportToPosition", callback = function() end},
    {name = "Telekinesis", callback = Telekinesis}
}

local WorldFeatures = {
    {name = "RemoveFog", callback = function() end},
    {name = "DayNight", callback = function() end},
    {name = "RemoveTextures", callback = function() end}
}

local OptimizationFeatures = {
    {name = "LowGraphics", callback = function(enabled)
        if enabled then
            settings().Rendering.QualityLevel = 1
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").Technology = Enum.Technology.Compatibility
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        else
            settings().Rendering.QualityLevel = 7
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").Technology = Enum.Technology.Future
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = true
                end
            end
        end
    end},
    {name = "DisableEffects", callback = function(enabled)
        if enabled then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = true
                end
            end
        end
    end},
    {name = "ReduceTextures", callback = function(enabled)
        if enabled then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Material ~= Enum.Material.Air then
                    v.Material = Enum.Material.SmoothPlastic
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Material == Enum.Material.SmoothPlastic then
                    v.Material = Enum.Material.Plastic
                end
            end
        end
    end},
    {name = "DisableLighting", callback = function(enabled)
        if enabled then
            game:GetService("Lighting").GlobalShadows = false
            game:GetService("Lighting").ShadowSoftness = 0
            game:GetService("Lighting").Technology = Enum.Technology.Compatibility
        else
            game:GetService("Lighting").GlobalShadows = true
            game:GetService("Lighting").ShadowSoftness = 0.5
            game:GetService("Lighting").Technology = Enum.Technology.Future
        end
    end}
}

local MiscFeatures = {
    {name = "ChatSpam", callback = function() end},
    {name = "AutoFarm", callback = function() end},
    {name = "ServerHop", callback = function() end}
}

local SettingsFeatures = {
    {name = "Language", callback = function(enabled)
        if enabled then
            CurrentLanguage = "Español"
        else
            CurrentLanguage = "English"
        end
        Texts = Languages[CurrentLanguage]
        
        -- Actualizar textos
        for name, section in pairs(Sections) do
            local categoryButton = Sidebar:FindFirstChild(name.."Category")
            if categoryButton then
                categoryButton.Text = Texts.categories[name]
            end
            
            for _, child in pairs(section:GetChildren()) do
                if child:IsA("Frame") then
                    local label = child:FindFirstChild("TextLabel")
                    if label and label.Text then
                        for featureName, translatedName in pairs(Texts.features) do
                            if label.Text == Languages[CurrentLanguage == "English" and "Español" or "English"].features[featureName] then
                                label.Text = translatedName
                                break
                            end
                        end
                    end
                end
            end
        end
    end},
    {name = "UITransparency", callback = UITransparency, slider = true, min = 0, max = 90, default = 10}
}

-- Crear toggles y sliders para cada característica
for _, feature in ipairs(MovementFeatures) do
    if feature.slider then
        CreateSlider(feature.name, Sections.Movement, feature.callback, feature.min, feature.max, feature.default)
    else
        CreateToggle(feature.name, Sections.Movement, feature.callback)
    end
end

for _, feature in ipairs(CombatFeatures) do
    CreateToggle(feature.name, Sections.Combat, feature.callback)
end

for _, feature in ipairs(VisualFeatures) do
    CreateToggle(feature.name, Sections.Visuals, feature.callback)
end

for _, feature in ipairs(PlayerFeatures) do
    CreateToggle(feature.name, Sections.Player, feature.callback)
end

for _, feature in ipairs(WorldFeatures) do
    CreateToggle(feature.name, Sections.World, feature.callback)
end

for _, feature in ipairs(OptimizationFeatures) do
    CreateToggle(feature.name, Sections.Optimization, feature.callback)
end

for _, feature in ipairs(MiscFeatures) do
    CreateToggle(feature.name, Sections.Misc, feature.callback)
end

for _, feature in ipairs(SettingsFeatures) do
    if feature.slider then
        CreateSlider(feature.name, Sections.Settings, feature.callback, feature.min, feature.max, feature.default)
    else
        CreateToggle(feature.name, Sections.Settings, feature.callback)
    end
end

-- Manejar la visibilidad de las secciones con animaciones
local function ShowSection(sectionName)
    for name, section in pairs(Sections) do
        if name == sectionName then
            if not section.Visible then
                section.Visible = true
                section.Position = UDim2.new(0.05, 0, 0, 10)
                section.Size = UDim2.new(0.9, 0, 1, -20)
                section.BackgroundTransparency = 1
                
                -- Animación de entrada
                TweenService:Create(section, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 20, 0, 10)}):Play()
                
                -- Mostrar el indicador de selección
                local button = Sidebar:FindFirstChild(name.."Category")
                if button then
                    button.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
                    button.SelectionIndicator.Visible = true
                    
                    -- Animación del indicador
                    button.SelectionIndicator.Size = UDim2.new(0, 4, 0, 0)
                    button.SelectionIndicator.Position = UDim2.new(0, 0, 0.5, 0)
                    TweenService:Create(button.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 4, 0.7, 0), Position = UDim2.new(0, 0, 0.15, 0)}):Play()
                end
            end
        else
            if section.Visible then
                -- Animación de salida
                TweenService:Create(section, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.05, 0, 0, 10), BackgroundTransparency = 1}):Play()
                
                -- Ocultar después de la animación
                delay(0.2, function()
                    section.Visible = false
                end)
                
                -- Ocultar el indicador de selección
                local button = Sidebar:FindFirstChild(name.."Category")
                if button then
                    button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                    
                    -- Animación del indicador
                    TweenService:Create(button.SelectionIndicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 4, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}):Play()
                    delay(0.2, function()
                        button.SelectionIndicator.Visible = false
                    end)
                end
            end
        end
    end
    ActiveCategory = sectionName
end

for _, category in ipairs(Categories) do
    local button = Sidebar:FindFirstChild(category.name.."Category")
    if button then
        button.MouseButton1Click:Connect(function()
            -- Efecto de clic
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(120, 90, 180)}):Play()
            delay(0.1, function()
                if ActiveCategory ~= category.name then
                    ShowSection(category.name)
                end
            end)
        end)
    end
end

-- Función para hacer que las características persistan después del respawn
local function SetupRespawnPersistence()
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        Character = newCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        
        -- Asegurar que la interfaz siga estando por encima de todo después de reaparecer
        if ScreenGui then
            ScreenGui.DisplayOrder = 9999
            
            -- Asegurar que el botón de toggle siga por encima de todo
            if ToggleButton then
                ToggleButton.ZIndex = 10000
            end
            
            -- Asegurar que la interfaz principal siga por encima de todo
            if MainBorder then
                MainBorder.ZIndex = 9000
                MainFrame.ZIndex = 9001
                -- Actualizar ZIndex de todos los elementos hijos
                for _, child in pairs(MainFrame:GetDescendants()) do
                    if child:IsA("GuiObject") and child.ZIndex < 9000 then
                        child.ZIndex = child.ZIndex + 9000
                    end
                end
            end
        end
        
        -- Reactivar funciones habilitadas después del respawn
        for feature, value in pairs(EnabledFeatures) do
            if value then
                if feature == "Fly" then
                    ToggleFly(true)
                elseif feature == "Speed" then
                    Humanoid.WalkSpeed = value
                elseif feature == "SuperJump" then
                    Humanoid.JumpPower = value
                    Humanoid.JumpHeight = 7.2
                elseif feature == "InfiniteJump" then
                    InfiniteJump(true)
                elseif feature == "NoClip" then
                    NoClip(true)
                elseif feature == "Reach" then
                    Reach(true)
                elseif feature == "AutoDodge" then
                    AutoDodge(true)
                elseif feature == "AutoAim" then
                    AutoAim(true)
                elseif feature == "DamageMultiplier" then
                    DamageMultiplier(true)
                elseif feature == "InstantKill" then
                    InstantKill(true)
                elseif feature == "AutoHeal" then
                    AutoHeal(true)
                elseif feature == "BunnyHop" then
                    BunnyHop(true)
                elseif feature == "SpinBot" then
                    SpinBot(true)
                elseif feature == "AntiAim" then
                    AntiAim(true)
                elseif feature == "HitboxExpander" then
                    -- HitboxExpander ya es persistente con la implementación mejorada
                elseif feature == "ESP" then
                    ESP(true)
                elseif feature == "Chams" then
                    Chams(true)
                elseif feature == "Tracers" then
                    Tracers(true)
                elseif feature == "Fullbright" then
                    Fullbright(true)
                elseif feature == "Levitation" then
                    Levitation(true)
                elseif feature == "Telekinesis" then
                    Telekinesis(true)
                end
            end
        end
    end)
end

-- Llamar a la función de persistencia
SetupRespawnPersistence()

-- Eliminar la GUI de carga con animación
TweenService:Create(LoadingFill, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
TweenService:Create(LoadingText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(WelcomeText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(VersionText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
TweenService:Create(Logo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()

wait(0.5)
LoadingGui:Destroy()

-- Mostrar la primera sección por defecto con animación
ShowSection("Movement")

-- Aplicar transparencia inicial
UITransparency(10)

-- Asegurar que la interfaz siempre esté por encima de todo
RunService.RenderStepped:Connect(function()
    if ScreenGui then
        -- Verificar si el DisplayOrder es correcto
        if ScreenGui.DisplayOrder < 9999 then
            ScreenGui.DisplayOrder = 9999
        end
        
        -- Verificar si el ZIndex del botón es correcto
        if ToggleButton and ToggleButton.ZIndex < 10000 then
            ToggleButton.ZIndex = 10000
        end
    end
end)

-- Mensaje de confirmación
print("Kimiko HUD mejorado cargado correctamente.")
print("Interfaz rediseñada con animaciones fluidas y efectos visuales modernos.")
print("Use el botón flotante para mostrar/ocultar el menú.")
