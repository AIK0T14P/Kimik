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
            Homenaje = "Lugar",
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
        loading = "Cargando..."
    },
    ["English"] = {
        -- ... (English translations)
    }
}

local CurrentLanguage = "Español"
local Texts = Languages[CurrentLanguage]

-- Crear pantalla de carga
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "LoadingGui"
LoadingGui.ResetOnSpawn = false
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.DisplayOrder = 9999 -- Asegurar que esté por encima de todo
LoadingGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LoadingFrame.ZIndex = 10000 -- Valor muy alto para estar por encima de todo
LoadingFrame.Parent = LoadingGui

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0.4, 0, 0.02, 0)
LoadingBar.Position = UDim2.new(0.3, 0, 0.5, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LoadingBar.BorderSizePixel = 0
LoadingBar.ZIndex = 10001
LoadingBar.Parent = LoadingFrame

local LoadingFill = Instance.new("Frame")
LoadingFill.Size = UDim2.new(0, 0, 1, 0)
LoadingFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
LoadingFill.BorderSizePixel = 0
LoadingFill.ZIndex = 10002
LoadingFill.Parent = LoadingBar

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(0, 200, 0, 30)
LoadingText.Position = UDim2.new(0.5, -100, 0.45, -15)
LoadingText.BackgroundTransparency = 1
LoadingText.Font = Enum.Font.GothamBold
LoadingText.Text = Texts.loading
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.TextSize = 18
LoadingText.ZIndex = 10003
LoadingText.Parent = LoadingFrame

-- Animación de carga
local loadingTween = TweenService:Create(LoadingFill, TweenInfo.new(3), {Size = UDim2.new(1, 0, 1, 0)})
loadingTween:Play()
loadingTween.Completed:Wait()

-- GUI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EnhancedGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999 -- Asegurar que esté por encima de todo
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Botón para mostrar/ocultar (ahora con arrastre y por encima de todo)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 0, 10)
ToggleButton.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
ToggleButton.Image = "rbxassetid://3926305904"
ToggleButton.ImageRectOffset = Vector2.new(764, 244)
ToggleButton.ImageRectSize = Vector2.new(36, 36)
ToggleButton.Parent = ScreenGui
ToggleButton.ZIndex = 10000 -- Valor extremadamente alto para estar por encima de todo

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

-- Frame Principal con borde morado y gradiente
local MainBorder = Instance.new("Frame")
MainBorder.Name = "MainBorder"
MainBorder.Size = UDim2.new(0, 600, 0, 400)
MainBorder.Position = UDim2.new(0.5, -300, 0.5, -200)
MainBorder.BackgroundColor3 = Color3.fromRGB(157, 122, 229)
MainBorder.BorderSizePixel = 0
MainBorder.Visible = false
MainBorder.Parent = ScreenGui
MainBorder.ZIndex = 9000 -- Alto pero menor que el botón

-- Añadir gradiente al borde
local UIGradient = Instance.new("UIGradient")
UIGradient.Rotation = 90
UIGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(0.8, 0),
    NumberSequenceKeypoint.new(1, 1)
})
UIGradient.Parent = MainBorder

local MainBorderCorner = Instance.new("UICorner")
MainBorderCorner.CornerRadius = UDim.new(0, 12)
MainBorderCorner.Parent = MainBorder

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, -4, 1, -4)
MainFrame.Position = UDim2.new(0, 2, 0, 2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = MainBorder
MainFrame.ZIndex = 9001

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Título "Kimiko HUD Beta"
local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 10)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Kimiko HUD Beta"
Title.TextColor3 = Color3.fromRGB(147, 112, 219)
Title.TextSize = 24
Title.Parent = MainFrame
Title.ZIndex = 9002

-- Botón de redimensionamiento (mejorado)
local ResizeButton = Instance.new("TextButton")
ResizeButton.Size = UDim2.new(0, 30, 0, 30)
ResizeButton.Position = UDim2.new(1, -35, 1, -35)
ResizeButton.BackgroundTransparency = 0.5
ResizeButton.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
ResizeButton.Text = "⤡"
ResizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResizeButton.TextSize = 24
ResizeButton.Font = Enum.Font.SourceSansBold
ResizeButton.Parent = MainFrame
ResizeButton.ZIndex = 9003

local ResizeCorner = Instance.new("UICorner")
ResizeCorner.CornerRadius = UDim.new(0, 6)
ResizeCorner.Parent = ResizeButton

-- Sistema de arrastre para el botón de toggle
local function UpdateToggleDrag(input)
    if ToggleDragging then
        local delta = input.Position - ToggleDragStart
        ToggleButton.Position = UDim2.new(
            ToggleStartPos.X.Scale,
            ToggleStartPos.X.Offset + delta.X,
            ToggleStartPos.Y.Scale,
            ToggleStartPos.Y.Offset + delta.Y
        )
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
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                connection:Disconnect()
                
                -- Si el tiempo es corto y la posición no cambió mucho, es un clic
                if tick() - startTime < 0.3 and (input.Position - startPosition).Magnitude < 5 then
                    -- Acción de clic: mostrar/ocultar el menú
                    MainBorder.Visible = not MainBorder.Visible
                    local goal = {
                        Rotation = MainBorder.Visible and 180 or 0
                    }
                    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {Rotation = goal.Rotation}):Play()
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

-- Sistema de arrastre para el menú principal
local function UpdateDrag(input)
    if Dragging then
        local delta = input.Position - DragStart
        MainBorder.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + delta.Y
        )
    end
end

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainBorder.Position
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
    end
end)

-- Sistema de redimensionamiento mejorado
local function UpdateResize(input)
    if Resizing then
        local delta = input.Position - ResizeStart
        local newWidth = math.max(300, StartSize.X.Offset + delta.X)
        local newHeight = math.max(200, StartSize.Y.Offset + delta.Y)
        
        -- Actualizar tamaño del borde
        MainBorder.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        -- Actualizar posición del botón de redimensionamiento
        ResizeButton.Position = UDim2.new(1, -35, 1, -35)
    end
end

ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Resizing = true
        ResizeStart = input.Position
        StartSize = MainBorder.Size
        StartPos = MainBorder.Position
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
    end
end)

-- Sidebar con scroll
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.25, 0, 1, -60)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 4
Sidebar.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
Sidebar.Parent = MainFrame
Sidebar.ZIndex = 9004

-- Contenedor principal con scroll
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(0.75, 0, 1, -60)
ContentFrame.Position = UDim2.new(0.25, 0, 0, 50)
ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ContentFrame.BackgroundTransparency = 0.1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 6
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(147, 112, 219)
ContentFrame.Parent = MainFrame
ContentFrame.ZIndex = 9004

-- Función para crear categorías en el sidebar
local function CreateCategory(name, icon, position)
    local CategoryButton = Instance.new("TextButton")
    CategoryButton.Name = name.."Category"
    CategoryButton.Size = UDim2.new(1, -20, 0, 40)
    CategoryButton.Position = UDim2.new(0, 10, 0, position)
    CategoryButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    CategoryButton.BorderSizePixel = 0
    CategoryButton.Font = Enum.Font.GothamSemibold
    CategoryButton.TextSize = 14
    CategoryButton.Parent = Sidebar
    CategoryButton.ZIndex = 9005
    
    local IconImage = Instance.new("ImageLabel")
    IconImage.Size = UDim2.new(0, 20, 0, 20)
    IconImage.Position = UDim2.new(0, 2, 0.5, -10)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = icon
    IconImage.Parent = CategoryButton
    IconImage.ZIndex = 9006
    
    CategoryButton.Text = Texts.categories[name]
    CategoryButton.TextXAlignment = Enum.TextXAlignment.Left
    CategoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CategoryButton.AutoButtonColor = false
    
    local TextPadding = Instance.new("UIPadding")
    TextPadding.PaddingLeft = UDim.new(0, 25)
    TextPadding.Parent = CategoryButton
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = CategoryButton
    
    return CategoryButton
end

-- Función para crear secciones de contenido
local function CreateSection(name)
    local Section = Instance.new("ScrollingFrame")
    Section.Name = name.."Section"
    Section.Size = UDim2.new(1, -40, 1, -20)
    Section.Position = UDim2.new(0, 20, 0, 10)
    Section.BackgroundTransparency = 1
    Section.BorderSizePixel = 0
    Section.ScrollBarThickness = 6
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
    
    return Section
end

-- Función mejorada para crear botones de toggle
local function CreateToggle(name, section, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleFrame.Parent = section
    ToggleFrame.ZIndex = 9006
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = Texts.features[name]
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    Label.ZIndex = 9007
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Switch.BorderSizePixel = 0
    Switch.Text = ""
    Switch.Parent = ToggleFrame
    Switch.ZIndex = 9007
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Switch
    Circle.ZIndex = 9008
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle
    
    local Enabled = false
    local Connection
    
    local function Toggle()
        Enabled = not Enabled
        EnabledFeatures[name] = Enabled
        local Goal = {
            BackgroundColor3 = Enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(60, 60, 60),
            Position = Enabled and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }
        TweenService:Create(Circle, TweenInfo.new(0.2), {Position = Goal.Position}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Goal.BackgroundColor3}):Play()
        
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

-- Función mejorada para crear sliders
local function CreateSlider(name, section, callback, min, max, default)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderFrame.Parent = section
    SliderFrame.ZIndex = 9006
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = Texts.features[name] .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    Label.ZIndex = 9007
    
    local SliderBar = Instance.new("TextButton")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, -20, 0, 20)
    SliderBar.Position = UDim2.new(0, 10, 0, 30)
    SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBar.BorderSizePixel = 0
    SliderBar.AutoButtonColor = false
    SliderBar.Text = ""
    SliderBar.Parent = SliderFrame
    SliderBar.ZIndex = 9007
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBar
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(147, 112, 219)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar
    SliderFill.ZIndex = 9008
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    local Value = default
    local Dragging = false
    
    local function UpdateSlider(input)
        local sizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Value = math.floor(min + ((max - min) * sizeX))
        SliderFill.Size = UDim2.new(sizeX, 0, 1, 0)
        Label.Text = Texts.features[name] .. ": " .. Value
        EnabledFeatures[name] = Value
        callback(Value)
    end
    
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            UpdateSlider(input)
        end
    end)
    
    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
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

-- Funciones de habilidades mejoradas
local function ToggleFly(enabled)
    EnabledFeatures["Fly"] = enabled
    if enabled then
        local BG = Instance.new("BodyGyro", HumanoidRootPart)
        BG.P = 9e4
        BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = CFrame.new(HumanoidRootPart.Position)

        local BV = Instance.new("BodyVelocity", HumanoidRootPart)
        BV.Velocity = Vector3.new(0, 0.1, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        -- Controles
        local keyW, keyA, keyS, keyD = false, false, false, false
        local keySpace, keyShift = false, false

        local player = game.Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")

        local existingGui = playerGui:FindFirstChild("FlyControlsGui")
        if existingGui then existingGui:Destroy() end

        local controlsGui = Instance.new("ScreenGui")
        controlsGui.Name = "FlyControlsGui"
        controlsGui.ResetOnSpawn = false
        controlsGui.Parent = playerGui

        -- Joystick (más a la derecha)
        local joystickBg = Instance.new("Frame")
        joystickBg.Name = "JoystickBg"
        joystickBg.Size = UDim2.new(0, 150, 0, 150)
        joystickBg.Position = UDim2.new(0.35, -75, 0.7, -75) -- Más a la derecha
        joystickBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        joystickBg.BackgroundTransparency = 0.7
        joystickBg.BorderSizePixel = 0
        joystickBg.AnchorPoint = Vector2.new(0.5, 0.5)
        joystickBg.Parent = controlsGui

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = joystickBg

        local joystickHandle = Instance.new("Frame")
        joystickHandle.Name = "Handle"
        joystickHandle.Size = UDim2.new(0, 50, 0, 50)
        joystickHandle.Position = UDim2.new(0.5, 0, 0.5, 0)
        joystickHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        joystickHandle.BackgroundTransparency = 0.3
        joystickHandle.BorderSizePixel = 0
        joystickHandle.AnchorPoint = Vector2.new(0.5, 0.5)
        joystickHandle.Parent = joystickBg

        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(1, 0)
        handleCorner.Parent = joystickHandle

        -- Botones (derecha)
        local upButton = Instance.new("TextButton")
        upButton.Name = "UpButton"
        upButton.Size = UDim2.new(0, 70, 0, 70)
        upButton.Position = UDim2.new(0.85, 0, 0.6, 0)
        upButton.Text = "▲"
        upButton.TextSize = 30
        upButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        upButton.BackgroundTransparency = 0.5
        upButton.BorderSizePixel = 0
        upButton.Parent = controlsGui

        local downButton = Instance.new("TextButton")
        downButton.Name = "DownButton"
        downButton.Size = UDim2.new(0, 70, 0, 70)
        downButton.Position = UDim2.new(0.85, 0, 0.75, 0)
        downButton.Text = "▼"
        downButton.TextSize = 30
        downButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        downButton.BackgroundTransparency = 0.5
        downButton.BorderSizePixel = 0
        downButton.Parent = controlsGui

        -- Variables de joystick
        local isDragging = false
        local startPos = nil
        local joystickRadius = joystickBg.AbsoluteSize.X / 2
        local maxDistance = joystickRadius - (joystickHandle.AbsoluteSize.X / 2)

        -- Función para actualizar la dirección del joystick
        local function updateJoystickDirection(input)
            if not isDragging then return end

            local delta = input.Position - startPos
            local distance = math.min(delta.Magnitude, maxDistance)

            local normalizedX = math.clamp(delta.X / maxDistance, -1, 1)
            local normalizedY = math.clamp(delta.Y / maxDistance, -1, 1)

            -- Mover joystick
            joystickHandle.Position = UDim2.new(0.5, 0, 0.5, 0) + UDim2.new(0, delta.X * (distance / delta.Magnitude), 0, delta.Y * (distance / delta.Magnitude))

            -- Dirección corregida
            keyW = normalizedY < -0.5
            keyS = normalizedY > 0.5
            keyA = normalizedX < -0.5
            keyD = normalizedX > 0.5
        end

        -- Eventos del joystick
        joystickBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                startPos = input.Position
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
                joystickHandle.Position = UDim2.new(0.5, 0, 0.5, 0)
                keyW, keyA, keyS, keyD = false, false, false, false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and isDragging then
                updateJoystickDirection(input)
            end
        end)

        -- Eventos de botones
        upButton.MouseButton1Down:Connect(function() keySpace = true end)
        upButton.MouseButton1Up:Connect(function() keySpace = false end)
        downButton.MouseButton1Down:Connect(function() keyShift = true end)
        downButton.MouseButton1Up:Connect(function() keyShift = false end)

        -- Movimiento basado en la cámara
        RunService:BindToRenderStep("Fly", 100, function()
            if not enabled then return end

            local cameraCFrame = workspace.CurrentCamera.CFrame
            local lookVector = cameraCFrame.LookVector
            local rightVector = cameraCFrame.RightVector
            local upVector = cameraCFrame.UpVector

            local moveDirection = Vector3.new(
                (keyD and 1 or 0) - (keyA and 1 or 0),
                (keySpace and 1 or 0) - (keyShift and 1 or 0),
                (keyW and -1 or 0) + (keyS and 1 or 0)
            )

            local velocity = (rightVector * moveDirection.X + upVector * moveDirection.Y + lookVector * moveDirection.Z) * 50
            BV.Velocity = velocity.Magnitude > 0 and velocity or Vector3.new(0, 0.1, 0)
        end)
    else
        RunService:UnbindFromRenderStep("Fly")
        local controlsGui = player.PlayerGui:FindFirstChild("FlyControlsGui")
        if controlsGui then controlsGui:Destroy() end
        for _, v in pairs(HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

local function ToggleSpeed(value)
    EnabledFeatures["Speed"] = value
    Humanoid.WalkSpeed = value
end

local function ToggleSpeed(value)
    EnabledFeatures["Speed"] = value
    Humanoid.WalkSpeed = value
end

local function ToggleSuperJump(value)
    EnabledFeatures["SuperJump"] = value
    Humanoid.JumpPower = value
    Humanoid.JumpHeight = 7.2
end

local function InfiniteJump(enabled)
    EnabledFeatures["InfiniteJump"] = enabled
    local connection
    if enabled then
        connection = UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local NoClipConnection

local function NoClip(enabled)
    EnabledFeatures["NoClip"] = enabled

    if enabled then
        if NoClipConnection then NoClipConnection:Disconnect() end
        NoClipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if NoClipConnection then
            NoClipConnection:Disconnect()
            NoClipConnection = nil
        end
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end
local function Reach(enabled)
    EnabledFeatures["Reach"] = enabled
    if enabled then
        for _, tool in pairs(Character:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local originalSize = handle.Size
                    handle.Size = originalSize * 2
                    handle.Massless = true
                end
            end
        end
    else
        for _, tool in pairs(Character:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    handle.Size = handle.Size / 2
                    handle.Massless = false
                end
            end
        end
    end
end

local function AutoDodge(enabled)
    EnabledFeatures["AutoDodge"] = enabled
    local connection
    if enabled then
        connection = RunService.Heartbeat:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                    if distance <= 10 then
                        local randomDirection = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
                        Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame + randomDirection * 5
                    end
                end
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local function AutoAim(enabled)
    EnabledFeatures["AutoAim"] = enabled
    local connection
    if enabled then
        connection = RunService.RenderStepped:Connect(function()
            local closestPlayer = nil
            local closestDistance = math.huge
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestPlayer = player
                        closestDistance = distance
                    end
                end
            end
            if closestPlayer then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local function DamageMultiplier(enabled)
    EnabledFeatures["DamageMultiplier"] = enabled
    local connection
    local oldHealth = Humanoid.MaxHealth
    
    if enabled then
        -- Guardar conexión para poder desconectarla después
        connection = Humanoid.HealthChanged:Connect(function()
            if Humanoid.Health < Humanoid.MaxHealth then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end)
        
        -- Hacer que el personaje no pueda morir
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        Humanoid.MaxHealth = 1000000
        Humanoid.Health = 1000000
        
        -- Guardar la conexión en una variable global para acceder después
        _G.ImmortalityConnection = connection
    else
        -- Restaurar estado normal
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        Humanoid.MaxHealth = oldHealth
        Humanoid.Health = oldHealth
        
        -- Desconectar el evento
        if _G.ImmortalityConnection then
            _G.ImmortalityConnection:Disconnect()
            _G.ImmortalityConnection = nil
        end
        
        -- También desconectar si hay una conexión local
        if connection then
            connection:Disconnect()
        end
    end
end

local function InstantKill(enabled)
    EnabledFeatures["InstantKill"] = enabled
    local connection
    local LocalPlayer = game.Players.LocalPlayer
    
    if enabled then
        -- Crear una conexión que se ejecuta en cada heartbeat
        connection = RunService.Heartbeat:Connect(function()
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= LocalPlayer then  -- No te mates a ti mismo
                    local character = player.Character
                    if character and character:FindFirstChild("Humanoid") then
                        local humanoid = character:FindFirstChild("Humanoid")
                        
                        -- Intentar varios métodos para matar al jugador
                        -- Método 1: Daño directo
                        humanoid.Health = 0
                        
                        -- Método 2: Usar BreakJoints para destruir el personaje
                        if character:FindFirstChild("Head") then
                            character.Head:BreakJoints()
                        end
                        
                        -- Método 3: Eliminar el Humanoid
                        if humanoid.Parent then
                            humanoid:Destroy()
                        end
                        
                        -- Método 4: Forzar el estado muerto
                        pcall(function()
                            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
                        end)
                    end
                end
            end
        end)
        
        -- Guardar la conexión
        _G.KillAllConnection = connection
    else
        -- Desconectar el evento cuando se desactiva
        if _G.KillAllConnection then
            _G.KillAllConnection:Disconnect()
            _G.KillAllConnection = nil
        end
        
        -- También desconectar si hay una conexión local
        if connection then
            connection:Disconnect()
        end
    end
end

local function AutoHeal(enabled)
    EnabledFeatures["AutoHeal"] = enabled
    local connection
    if enabled then
        connection = RunService.Heartbeat:Connect(function()
            if Humanoid.Health < Humanoid.MaxHealth then
                Humanoid.Health = Humanoid.Health + 1
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local function BunnyHop(enabled)
    EnabledFeatures["BunnyHop"] = enabled
    local connection
    if enabled then
        connection = RunService.Heartbeat:Connect(function()
            if Humanoid:GetState() == Enum.HumanoidStateType.Running then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local function SpinBot(enabled)
    EnabledFeatures["SpinBot"] = enabled
    local connection
    if enabled then
        connection = RunService.RenderStepped:Connect(function()
            Character:SetPrimaryPartCFrame(Character:GetPrimaryPartCFrame() * CFrame.Angles(0, math.rad(10), 0))
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local function AutoAim(enabled)
    EnabledFeatures["AutoAim"] = enabled
    
    -- Crear círculo de asistencia
    local aimCircle = Drawing.new("Circle")
    aimCircle.Thickness = 1
    aimCircle.Color = Color3.new(1, 0, 0)
    aimCircle.Transparency = 0.5
    aimCircle.Visible = enabled
    aimCircle.Radius = 100 -- Radio del círculo de asistencia
    
    -- Crear retícula central
    local crosshairSize = 10
    local crosshairThickness = 2
    local crosshairColor = Color3.new(0, 1, 0)
    
    local crosshairH = Drawing.new("Line")
    local crosshairV = Drawing.new("Line")
    
    crosshairH.Thickness = crosshairThickness
    crosshairH.Color = crosshairColor
    crosshairH.Transparency = 1
    crosshairH.Visible = enabled
    
    crosshairV.Thickness = crosshairThickness
    crosshairV.Color = crosshairColor
    crosshairV.Transparency = 1
    crosshairV.Visible = enabled
    
    local function updateCrosshair()
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        aimCircle.Position = center
        
        crosshairH.From = Vector2.new(center.X - crosshairSize, center.Y)
        crosshairH.To = Vector2.new(center.X + crosshairSize, center.Y)
        
        crosshairV.From = Vector2.new(center.X, center.Y - crosshairSize)
        crosshairV.To = Vector2.new(center.X, center.Y + crosshairSize)
    end
    
    -- Función para verificar si un punto está dentro del círculo
    local function isInCircle(point, center, radius)
        return (point - center).Magnitude <= radius
    end
    
    -- Variables para el auto-aim
    local isAiming = false
    local currentTarget = nil
    
    -- Detectar cuando el jugador está disparando
    UserInputService.InputBegan:Connect(function(input)
        if not enabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isAiming = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isAiming = false
            currentTarget = nil
        end
    end)
    
    -- Conexión principal para el auto-aim
    local connection
    if enabled then
        updateCrosshair()
        connection = RunService.RenderStepped:Connect(function()
            updateCrosshair()
            
            if not isAiming then return end
            
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local closestDistance = math.huge
            local closestPlayer = nil
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and 
                   player.Character:FindFirstChild("HumanoidRootPart") and 
                   player.Character:FindFirstChild("Humanoid") and 
                   player.Character.Humanoid.Health > 0 then
                    
                    local vector, onScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local screenPos = Vector2.new(vector.X, vector.Y)
                        
                        -- Verificar si el jugador está dentro del círculo
                        if isInCircle(screenPos, center, aimCircle.Radius) then
                            local distance = (screenPos - center).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
            
            -- Actualizar objetivo y aplicar auto-aim
            if closestPlayer and closestPlayer.Character then
                currentTarget = closestPlayer
                local targetPos = currentTarget.Character.HumanoidRootPart.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
        aimCircle.Visible = false
        crosshairH.Visible = false
        crosshairV.Visible = false
    end
    
    -- Limpiar al desactivar
    if not enabled then
        if aimCircle then
            aimCircle:Remove()
        end
        if crosshairH then
            crosshairH:Remove()
        end
        if crosshairV then
            crosshairV:Remove()
        end
    end
end

-- Función mejorada de HitboxExpander para que persista cuando los jugadores mueren y reaparecen
local function HitboxExpander(enabled)
    EnabledFeatures["HitboxExpander"] = enabled
    
    -- Función para expandir el hitbox de un jugador
    local function expandHitbox(player)
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Size = enabled and Vector3.new(10, 10, 10) or Vector3.new(2, 2, 1)
            player.Character.HumanoidRootPart.Transparency = enabled and 0.5 or 1
            player.Character.HumanoidRootPart.CanCollide = false -- Prevenir problemas de colisión
        end
    end
    
    -- Aplicar a todos los jugadores actuales
    for _, player in pairs(Players:GetPlayers()) do
        expandHitbox(player)
    end
    
    -- Conexiones para mantener el hitbox expandido
    local playerAddedConnection
    local playerRemovingConnection
    local characterAddedConnections = {}
    
    if enabled then
        -- Cuando se activa, configurar todas las conexiones necesarias
        
        -- Para jugadores nuevos que se unen
        playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            -- Cuando un jugador se une, configurar la conexión para cuando su personaje aparezca
            characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Pequeña espera para asegurar que el HumanoidRootPart esté cargado
                expandHitbox(player)
            end)
        end)
        
        -- Para jugadores existentes cuando reaparecen
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
                    task.wait(0.5)
                    expandHitbox(player)
                end)
            end
        end
        
        -- Limpiar conexiones cuando un jugador se va
        playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
            if characterAddedConnections[player] then
                characterAddedConnections[player]:Disconnect()
                characterAddedConnections[player] = nil
            end
        end)
        
        -- Ejecutar periódicamente para asegurar que todos los hitboxes estén expandidos
        spawn(function()
            while EnabledFeatures["HitboxExpander"] do
                for _, player in pairs(Players:GetPlayers()) do
                    expandHitbox(player)
                end
                task.wait(1) -- Verificar cada segundo
            end
        end)
    else
        -- Cuando se desactiva, limpiar todas las conexiones
        if playerAddedConnection then
            playerAddedConnection:Disconnect()
            playerAddedConnection = nil
        end
        
        if playerRemovingConnection then
            playerRemovingConnection:Disconnect()
            playerRemovingConnection = nil
        end
        
        for player, connection in pairs(characterAddedConnections) do
            connection:Disconnect()
            characterAddedConnections[player] = nil
        end
        
        -- Restaurar hitboxes normales
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end

local function Levitation(enabled)
    EnabledFeatures["Levitation"] = enabled
    local connection
    if enabled then
        connection = RunService.Heartbeat:Connect(function()
            HumanoidRootPart.Velocity = Vector3.new(0, 5, 0)
        end)
    else
        if connection then
            connection:Disconnect()
        end
    end
end

local function Telekinesis(enabled)
    EnabledFeatures["Telekinesis"] = enabled
    local mouse = LocalPlayer:GetMouse()
    local heldObject = nil
    local connection

    if enabled then
        connection = mouse.Button1Down:Connect(function()
            local target = mouse.Target
            if target and target:IsA("BasePart") and not target:IsDescendantOf(Character) then
                heldObject = target
                local bodyPosition = Instance.new("BodyPosition")
                bodyPosition.Position = heldObject.Position
                bodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bodyPosition.Parent = heldObject
            end
        end)

        mouse.Button1Up:Connect(function()
            if heldObject then
                heldObject:FindFirstChildOfClass("BodyPosition"):Destroy()
                heldObject = nil
            end
        end)

        RunService.RenderStepped:Connect(function()
            if heldObject then
                local bodyPosition = heldObject:FindFirstChildOfClass("BodyPosition")
                if bodyPosition then
                    bodyPosition.Position = mouse.Hit.Position
                end
            end
        end)
    else
        if connection then
            connection:Disconnect()
        end
        if heldObject and heldObject:FindFirstChildOfClass("BodyPosition") then
            heldObject:FindFirstChildOfClass("BodyPosition"):Destroy()
        end
    end
end

-- Implementación mejorada del ESP con colores de equipo
local function ESP(enabled)
    EnabledFeatures["ESP"] = enabled
    
    if game.CoreGui:FindFirstChild("ESPFolder") then
        game.CoreGui:FindFirstChild("ESPFolder"):Destroy()
    end
    
    local ESPFolder
    if enabled then
        ESPFolder = Instance.new("Folder")
        ESPFolder.Name = "ESPFolder"
        ESPFolder.Parent = game.CoreGui
    else
        return
    end
    
    local connections = {}
    local drawingObjects = {}
    
    local function createESP(player)
        if player == LocalPlayer then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "_Highlight"
        highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Adornee = nil
        highlight.Parent = ESPFolder
        
        local nameTag = Drawing.new("Text")
        nameTag.Visible = false
        nameTag.Center = true
        nameTag.Outline = true
        nameTag.Size = 18
        nameTag.Color = Color3.new(1, 0, 0)
        nameTag.OutlineColor = Color3.new(0, 0, 0)
        table.insert(drawingObjects, nameTag)
        
        local healthTag = Drawing.new("Text")
        healthTag.Visible = false
        healthTag.Center = true
        healthTag.Outline = true
        healthTag.Size = 18
        healthTag.Color = Color3.new(0, 1, 0)
        healthTag.OutlineColor = Color3.new(0, 0, 0)
        table.insert(drawingObjects, healthTag)
        
        local function updateESP()
            if not EnabledFeatures["ESP"] then
                nameTag.Visible = false
                healthTag.Visible = false
                return
            end
            
            -- Intentar obtener el personaje actual del jugador
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if not humanoid or not head then
                nameTag.Visible = false
                healthTag.Visible = false
                return
            end
            
            highlight.Adornee = character
            
            local headPos = head.Position + Vector3.new(0, 1, 0)
            local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
            
            if onScreen then
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                local scaleFactor = math.clamp(30 / distance, 0.5, 2)
                local textSize = math.floor(18 * scaleFactor)
                
                nameTag.Size = textSize
                healthTag.Size = textSize
                
                nameTag.Text = player.Name
                nameTag.Position = Vector2.new(screenPos.X, screenPos.Y)
                nameTag.Visible = true
                
                local health = math.floor(humanoid.Health)
                local maxHealth = math.floor(humanoid.MaxHealth)
                
                healthTag.Text = string.format("%d/%d", health, maxHealth)
                healthTag.Position = Vector2.new(screenPos.X, screenPos.Y + textSize + 2)
                healthTag.Visible = true
            else
                nameTag.Visible = false
                healthTag.Visible = false
            end
        end
        
        local function onCharacterAdded()
            task.wait(0.5) -- Esperar a que el personaje cargue completamente
            updateESP()
        end
        
        -- Conectar actualización del ESP
        local connection = RunService.RenderStepped:Connect(updateESP)
        table.insert(connections, connection)
        
        -- Detectar cuando el personaje reaparece
        player.CharacterAdded:Connect(onCharacterAdded)
        
        return {
            highlight = highlight,
            nameTag = nameTag,
            healthTag = healthTag,
            connection = connection
        }
    end
    
    local espData = {}
    
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                espData[player] = createESP(player)
            end
        end
        
        local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            espData[player] = createESP(player)
        end)
        table.insert(connections, playerAddedConnection)
        
        local function cleanupESP()
            if not EnabledFeatures["ESP"] then
                for _, data in pairs(espData) do
                    if data.highlight then data.highlight:Destroy() end
                    if data.nameTag then data.nameTag:Remove() end
                    if data.healthTag then data.healthTag:Remove() end
                    if data.connection then data.connection:Disconnect() end
                end
                
                for _, obj in ipairs(drawingObjects) do
                    obj:Remove()
                end
                
                if ESPFolder and ESPFolder.Parent then
                    ESPFolder:Destroy()
                end
            end
        end
        
        local gameExitConnection = game:BindToClose(cleanupESP)
        table.insert(connections, gameExitConnection)
        
        _G.CleanupESP = cleanupESP
    end
    
    return espData
end

local function DisableESP()
    EnabledFeatures["ESP"] = false
    
    if _G.CleanupESP then
        _G.CleanupESP()
    end
    
    if game.CoreGui:FindFirstChild("ESPFolder") then
        game.CoreGui:FindFirstChild("ESPFolder"):Destroy()
    end
end

-- Función para Chams
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function Chams(enabled)
    EnabledFeatures["Chams"] = enabled

    local ChamsFolder = game.CoreGui:FindFirstChild("ChamsFolder") or Instance.new("Folder")
    ChamsFolder.Name = "ChamsFolder"
    ChamsFolder.Parent = game.CoreGui

    local chamsData = {}

    local function createChams(player)
        if player == LocalPlayer then return end
        
        -- Función para aplicar Chams a una parte
        local function applyChams(part)
            local chamPart = Instance.new("BoxHandleAdornment")
            chamPart.Name = player.Name .. "_Cham"
            chamPart.Adornee = part
            chamPart.AlwaysOnTop = true
            chamPart.ZIndex = 9500
            chamPart.Size = part.Size
            chamPart.Transparency = 0.5
            chamPart.Color3 = player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
            chamPart.Parent = ChamsFolder
            return chamPart
        end

        local function updateChams()
            -- Asegurar que el personaje existe antes de aplicar Chams
            if player.Character then
                -- Eliminar chams antiguos del jugador
                if chamsData[player] then
                    for _, cham in pairs(chamsData[player]) do
                        cham:Destroy()
                    end
                end
                chamsData[player] = {}

                -- Aplicar chams a cada parte válida del personaje
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        chamsData[player][part] = applyChams(part)
                    end
                end
            end
        end

        -- Evento cuando un personaje reaparece
        player.CharacterAdded:Connect(updateChams)

        -- Evento para eliminar chams cuando el personaje muere
        player.CharacterRemoving:Connect(function()
            if chamsData[player] then
                for _, cham in pairs(chamsData[player]) do
                    cham:Destroy()
                end
                chamsData[player] = nil
            end
        end)

        -- Aplicar chams si el personaje ya está en el juego
        updateChams()
    end

    if enabled then
        -- Aplicar Chams a todos los jugadores actuales
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createChams(player)
            end
        end

        -- Evento para aplicar Chams a nuevos jugadores
        Players.PlayerAdded:Connect(createChams)

        -- Evento para remover Chams cuando un jugador se va
        Players.PlayerRemoving:Connect(function(player)
            if chamsData[player] then
                for _, cham in pairs(chamsData[player]) do
                    cham:Destroy()
                end
                chamsData[player] = nil
            end
        end)
    else
        -- Desactivar los Chams y limpiar todo
        for _, data in pairs(chamsData) do
            for _, cham in pairs(data) do
                cham:Destroy()
            end
        end
        chamsData = {}
        ChamsFolder:Destroy()
    end
end

-- Función para Tracers
local function Tracers(enabled)
    EnabledFeatures["Tracers"] = enabled
    local TracersFolder = Instance.new("Folder")
    TracersFolder.Name = "TracersFolder"
    TracersFolder.Parent = game.CoreGui

    local function createTracer(player)
        if player == LocalPlayer then return end
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
        tracer.Thickness = 1
        tracer.Transparency = 1

        local function updateTracer()
            if player.Character and EnabledFeatures["Tracers"] then
                local torso = player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("HumanoidRootPart")
                if torso then
                    -- Obtener la posición del torso en el mundo 3D
                    local torsoPosition = torso.Position
                    
                    -- Importante: Necesitamos un punto de referencia fijo para la línea
                    local bottomScreenPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    
                    -- Convertir la posición del torso a coordenadas de pantalla
                    local torsoScreenPos, onScreen = Camera:WorldToViewportPoint(torsoPosition)
                    
                    if onScreen then
                        -- Lo importante aquí es usar WorldToViewportPoint en lugar de WorldToScreenPoint
                        -- y usar los valores X e Y directamente como Vector2
                        tracer.From = bottomScreenPos
                        tracer.To = Vector2.new(torsoScreenPos.X, torsoScreenPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        end

        -- Conexión para actualizar el trazado cada fotograma
        local connection = RunService.RenderStepped:Connect(updateTracer)
        
        return {
            tracer = tracer,
            connection = connection
        }
    end

    local tracersData = {}
    
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                tracersData[player] = createTracer(player)
            end
        end
        
        -- Conectar eventos para nuevos jugadores
        local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            tracersData[player] = createTracer(player)
        end)
        
        local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
            if tracersData[player] then
                tracersData[player].tracer:Remove()
                tracersData[player].connection:Disconnect()
                tracersData[player] = nil
            end
        end)
        
        -- Guardar las conexiones para desconectarlas después
        TracersFolder:SetAttribute("PlayerAddedConnection", playerAddedConnection)
        TracersFolder:SetAttribute("PlayerRemovingConnection", playerRemovingConnection)
    else
        -- Limpiar todas las conexiones y trazadores
        for player, data in pairs(tracersData) do
            if data.tracer then
                data.tracer:Remove()
            end
            if data.connection then
                data.connection:Disconnect()
            end
            tracersData[player] = nil
        end
        
        -- Desconectar eventos si existen
        local playerAddedConnection = TracersFolder:GetAttribute("PlayerAddedConnection")
        local playerRemovingConnection = TracersFolder:GetAttribute("PlayerRemovingConnection")
        
        if playerAddedConnection then playerAddedConnection:Disconnect() end
        if playerRemovingConnection then playerRemovingConnection:Disconnect() end
        
        TracersFolder:Destroy()
    end
    
    return tracersData
end

-- Función para Fullbright
local function Fullbright(enabled)
    EnabledFeatures["Fullbright"] = enabled
    if enabled then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").ClockTime = 12
        game:GetService("Lighting").FogEnd = 10000
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(127, 127, 127)
    end
end

-- Función mejorada para controlar la transparencia de la interfaz
local function UITransparency(value)
    -- Convertir el valor (0-100) a transparencia (0-1)
    local transparency = value / 100
    
    -- Aplicar transparencia a todos los elementos de la interfaz excepto el borde principal
    MainFrame.BackgroundTransparency = transparency
    Sidebar.BackgroundTransparency = transparency
    ContentFrame.BackgroundTransparency = transparency
    
    -- Mantener el borde principal visible (no transparente)
    MainBorder.BackgroundTransparency = transparency
    
    
    -- Aplicar a todos los elementos dentro de las secciones
    for _, section in pairs(Sections) do
        for _, child in pairs(section:GetChildren()) do
            if child:IsA("Frame") then
                child.BackgroundTransparency = transparency
            end
        end
    end
end

-- Categorías actualizadas
local Categories = {
    {name = "Movement", icon = "rbxassetid://3926307971"},
    {name = "Combat", icon = "rbxassetid://3926307971"},
    {name = "Visuals", icon = "rbxassetid://3926307971"},
    {name = "Player", icon = "rbxassetid://3926307971"},
    {name = "World", icon = "rbxassetid://3926307971"},
    {name = "Optimization", icon = "rbxassetid://3926307971"},
    {name = "Misc", icon = "rbxassetid://3926307971"},
    {name = "Settings", icon = "rbxassetid://3926307971"}
}

-- Crear categorías y secciones
local Sections = {}
local ActiveCategory = nil

for i, category in ipairs(Categories) do
    local button = CreateCategory(category.name, category.icon, (i-1) * 50)
    Sections[category.name] = CreateSection(category.name)
end

-- Características actualizadas (removidas las que no funcionan)
local MovementFeatures = {
    {name = "Fly", callback = ToggleFly},
    {name = "Speed", callback = ToggleSpeed, slider = true, min = 16, max = 500, default = 16},
    {name = "SuperJump", callback = ToggleSuperJump, slider = true, min = 50, max = 500, default = 50},
    {name = "InfiniteJump", callback = InfiniteJump},
    {name = "NoClip", callback = NoClip},
    {name = "BunnyHop", callback = BunnyHop},
    {name = "WallRun", callback = WallRun},
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
            -- Restore original textures (this is a simplified version, you might want to store original textures)
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

-- Manejar la visibilidad de las secciones y mantener el color morado
local function ShowSection(sectionName)
    for name, section in pairs(Sections) do
        section.Visible = (name == sectionName)
        local button = Sidebar:FindFirstChild(name.."Category")
        if button then
            button.BackgroundColor3 = (name == sectionName) and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(45, 45, 45)
        end
    end
    ActiveCategory = sectionName
end

for _, category in ipairs(Categories) do
    local button = Sidebar:FindFirstChild(category.name.."Category")
    if button then
        button.MouseButton1Click:Connect(function()
            ShowSection(category.name)
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

-- Eliminar la GUI de carga
LoadingGui:Destroy()

-- Mostrar la primera sección por defecto
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
print("Script mejorado cargado correctamente. Use el botón en la izquierda para mostrar/ocultar el menú.")
print("Ahora puede arrastrar el botón de toggle a cualquier posición, redimensionar el menú y ajustar la transparencia.")
print("Las funciones ahora persisten después de morir y reaparecer, especialmente el HitboxExpander.")
print("La interfaz y el botón ahora están siempre por encima de todo, incluso después de reaparecer.")
