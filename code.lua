-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
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

EnabledFeatures = EnabledFeatures or {}

-- Variables para guardado de posiciones
local EnabledFeatures = {}
local RespawnPoint
local HumanoidRootPart = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
HumanoidRootPart = HumanoidRootPart:WaitForChild("HumanoidRootPart")


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
            Speed = "Velocidad",
            SuperJump = "Super Salto",
            InfiniteJump = "Salto Infinito",
            NoClip = "Atravesar Paredes",
            AumentV = "Aumento de vida",
            ESP = "ESP",
            Chams = "Siluetas",
            Tracers = "Trazadores",
            Fullbright = "Brillo Total",
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
            SpeedBoost = "Aumento de Velocidad",
            JumpBoost = "Aumento de Salto",
            Levitation = "Levitación",
            Wallbang = "Disparar a través de Paredes",
            AutoHeal = "Auto Curación",
            SpinBot = "Giro Automático",
            HitboxExpander = "Expandir Hitbox",
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
LoadingFrame.BackgroundTransparency = 1 -- fondo invisible
LoadingFrame.ZIndex = 10000
LoadingFrame.Parent = LoadingGui

-- Efecto de desenfoque (blur)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Size = 0 -- Comienza sin desenfoque
BlurEffect.Name = "LoadingBlur"
BlurEffect.Parent = game:GetService("Lighting")

-- Animación del desenfoque
local blurTween = game:GetService("TweenService"):Create(
    BlurEffect, 
    TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
    {Size = 20} -- Valor máximo del desenfoque
)
blurTween:Play()

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
local TweenService = game:GetService("TweenService")
local loadingTween = TweenService:Create(LoadingFill, TweenInfo.new(3), {Size = UDim2.new(1, 0, 1, 0)})
loadingTween:Play()
loadingTween.Completed:Connect(function()
    -- Quitar el desenfoque cuando termine la carga
    local unblurTween = TweenService:Create(
        BlurEffect, 
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
        {Size = 0}
    )
    unblurTween:Play()
    unblurTween.Completed:Connect(function()
        BlurEffect:Destroy() -- Eliminar el efecto de desenfoque
    end)
end)
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
ToggleButton.Image = "rbxassetid://125017430901101"
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

-- Función para crear botones completos
local function CreateButton(name, section, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, 0, 0, 40)
    ButtonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ButtonFrame.Parent = section
    ButtonFrame.ZIndex = 9006
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ButtonFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 1, 0)
    Button.BackgroundTransparency = 1
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = Texts.features[name]
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Parent = ButtonFrame
    Button.ZIndex = 9007
    
    Button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return Button
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
local function ToggleSpeed(value)
    EnabledFeatures["Speed"] = value
    Humanoid.WalkSpeed = value
end

local function ToggleVida(value)
    EnabledFeatures["AumentV"] = value
    Humanoid.MaxHealth = value
    Humanoid.Health = value -- Esto también pone la vida actual al nuevo valor
end

local function ToggleSuperJump(value)
    EnabledFeatures["SuperJump"] = value
    Humanoid.JumpPower = value
    Humanoid.JumpHeight = 7.2
end

local function DeleteRespawn()
    EnabledFeatures["SaveRespawn"] = false
    RespawnPoint = nil

    -- Notificación de que se borró el punto
    local gui = Instance.new("ScreenGui")
    gui.Name = "DeleteRespawnNotification"
    gui.ResetOnSpawn = false
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 50)
    label.Position = UDim2.new(0.5, -150, 0.8, 0)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Text = "❌ Punto de reaparición borrado"
    label.Parent = gui

    task.delay(3, function() gui:Destroy() end)
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

local function AutoHeal(enabled)
    EnabledFeatures["AutoHeal"] = enabled
    local connection

    if enabled then
        connection = RunService.Heartbeat:Connect(function()
            if Humanoid.Health < Humanoid.MaxHealth then
                healEvent:FireServer() -- 🔁 Pide al servidor que cure
            end
        end)

        -- ⏱️ Desactivar automáticamente a los 5 segundos
        task.delay(5, function()
            if connection then
                connection:Disconnect()
                EnabledFeatures["AutoHeal"] = false
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

-- Función mejorada de HitboxExpander para que persista cuando los jugadores mueren y reaparecen
local function HitboxExpander(enabled)
    EnabledFeatures["HitboxExpander"] = enabled
    
    -- Función para expandir el hitbox de un jugador
    local function expandHitbox(player)
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Verificar si el jugador está en un vehículo
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local inVehicle = humanoid and humanoid.SeatPart and humanoid.SeatPart.Parent
            
            -- SOLUCIÓN: No expandir el hitbox de jugadores en vehículos
            if inVehicle then
                -- Mantener tamaño normal para jugadores en vehículos
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = 1
                
                -- Crear un hitbox separado que siga al vehículo si no existe ya
                local vehicle = humanoid.SeatPart.Parent
                if enabled and vehicle:IsA("Model") and not vehicle:FindFirstChild("VehicleHitbox") then
                    local vehicleHitbox = Instance.new("Part")
                    vehicleHitbox.Name = "VehicleHitbox"
                    vehicleHitbox.Size = Vector3.new(10, 10, 10)
                    vehicleHitbox.Transparency = 0.5
                    vehicleHitbox.CanCollide = false
                    vehicleHitbox.Anchored = false
                    vehicleHitbox.Material = Enum.Material.Neon
                    
                    -- Crear un BillboardGui para mostrar el nombre del jugador sobre el hitbox
                    local billboardGui = Instance.new("BillboardGui")
                    billboardGui.Size = UDim2.new(0, 100, 0, 30)
                    billboardGui.Adornee = vehicleHitbox
                    billboardGui.AlwaysOnTop = true
                    
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Size = UDim2.new(1, 0, 1, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.TextStrokeTransparency = 0
                    nameLabel.Text = player.Name
                    nameLabel.TextScaled = true
                    nameLabel.Parent = billboardGui
                    
                    billboardGui.Parent = vehicleHitbox
                    
                    -- Vincular el hitbox al vehículo
                    if vehicle.PrimaryPart then
                        local attachment = Instance.new("Attachment")
                        attachment.Parent = vehicleHitbox
                        
                        local attachment2 = Instance.new("Attachment")
                        attachment2.Parent = vehicle.PrimaryPart
                        
                        local alignPosition = Instance.new("AlignPosition")
                        alignPosition.Attachment0 = attachment
                        alignPosition.Attachment1 = attachment2
                        alignPosition.RigidityEnabled = true
                        alignPosition.Parent = vehicleHitbox
                        
                        vehicleHitbox.Parent = vehicle
                    end
                end
            else
                -- Aplicar el tamaño expandido solo para jugadores a pie
                player.Character.HumanoidRootPart.Size = enabled and Vector3.new(10, 10, 10) or Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = enabled and 0.5 or 1
                player.Character.HumanoidRootPart.CanCollide = false -- Prevenir problemas de colisión
            end
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
    local humanoidStateChangedConnections = {}
    
    if enabled then
        -- Cuando se activa, configurar todas las conexiones necesarias
        
        -- Para jugadores nuevos que se unen
        playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            -- Cuando un jugador se une, configurar la conexión para cuando su personaje aparezca
            characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Pequeña espera para asegurar que el HumanoidRootPart esté cargado
                expandHitbox(player)
                
                -- Detectar cuando el jugador se sube o baja de un vehículo
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoidStateChangedConnections[player] = humanoid.StateChanged:Connect(function(oldState, newState)
                        if newState == Enum.HumanoidStateType.Seated or oldState == Enum.HumanoidStateType.Seated then
                            -- El jugador se subió o bajó de un vehículo
                            task.wait(0.1)
                            expandHitbox(player)
                        end
                    end)
                end
            end)
        end)
        
        -- Para jugadores existentes cuando reaparecen
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                characterAddedConnections[player] = player.CharacterAdded:Connect(function(character)
                    task.wait(0.5)
                    expandHitbox(player)
                    
                    -- Detectar cuando el jugador se sube o baja de un vehículo
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoidStateChangedConnections[player] = humanoid.StateChanged:Connect(function(oldState, newState)
                            if newState == Enum.HumanoidStateType.Seated or oldState == Enum.HumanoidStateType.Seated then
                                -- El jugador se subió o bajó de un vehículo
                                task.wait(0.1)
                                expandHitbox(player)
                            end
                        end)
                    end
                end)
                
                -- Para personajes actuales
                if player.Character then
                    local humanoid = player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoidStateChangedConnections[player] = humanoid.StateChanged:Connect(function(oldState, newState)
                            if newState == Enum.HumanoidStateType.Seated or oldState == Enum.HumanoidStateType.Seated then
                                -- El jugador se subió o bajó de un vehículo
                                task.wait(0.1)
                                expandHitbox(player)
                            end
                        end)
                    end
                end
            end
        end
        
        -- Limpiar conexiones cuando un jugador se va
        playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
            if characterAddedConnections[player] then
                characterAddedConnections[player]:Disconnect()
                characterAddedConnections[player] = nil
            end
            
            if humanoidStateChangedConnections[player] then
                humanoidStateChangedConnections[player]:Disconnect()
                humanoidStateChangedConnections[player] = nil
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
        
        for player, connection in pairs(humanoidStateChangedConnections) do
            connection:Disconnect()
            humanoidStateChangedConnections[player] = nil
        end
        
        -- Restaurar hitboxes normales
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                player.Character.HumanoidRootPart.Transparency = 1
            end
        end
        
        -- Eliminar hitboxes de vehículos
        for _, vehicle in pairs(workspace:GetDescendants()) do
            if vehicle:IsA("Model") and vehicle:FindFirstChild("VehicleHitbox") then
                vehicle.VehicleHitbox:Destroy()
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

local function SaveRespawn()
    EnabledFeatures["SaveRespawn"] = true
    RespawnPoint = HumanoidRootPart.Position

    -- Notificación visual
    local gui = Instance.new("ScreenGui")
    gui.Name = "RespawnNotification"
    gui.ResetOnSpawn = false
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 50)
    label.Position = UDim2.new(0.5, -150, 0.8, 0)
    label.BackgroundTransparency = 0.3
    label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Text = string.format("📌 Posición guardada: (%.1f, %.1f, %.1f)", RespawnPoint.X, RespawnPoint.Y, RespawnPoint.Z)
    label.Parent = gui

    task.delay(3, function() gui:Destroy() end)

    -- Mantener el bucle de teleport en cada respawn
    task.spawn(function()
        while EnabledFeatures["SaveRespawn"] and RespawnPoint do
            local char = Players.LocalPlayer.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Wait()
                local newChar = Players.LocalPlayer.CharacterAdded:Wait()
                local newRoot = newChar:WaitForChild("HumanoidRootPart")
                task.wait(0.3)
                newRoot.CFrame = CFrame.new(RespawnPoint)
            end
            task.wait(1)
        end
    end)
end


-- Implementación mejorada del ESP con colores de equipo
local function ESP(enabled)
    EnabledFeatures["ESP"] = enabled
    
    -- Primero, limpiamos cualquier instancia anterior
    local existingFolder = game.CoreGui:FindFirstChild("ESPFolder")
    if existingFolder then
        existingFolder:Destroy()
    end
    
    -- Salir si está deshabilitado
    if not enabled then
        return
    end
    
    -- Crear el folder principal
    local ESPFolder = Instance.new("Folder")
    ESPFolder.Name = "ESPFolder"
    ESPFolder.Parent = game.CoreGui
    
    -- Variables y referencias
    local espData = {}
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer
    local updateFrequency = 0.05 -- Actualización más frecuente para mayor estabilidad
    local updateConnection
    
    -- Función para obtener el color del equipo
    local function getTeamColor(player)
        if player.Team then
            return player.Team.TeamColor.Color
        end
        return Color3.fromRGB(255, 0, 0)
    end
    
    -- Función para crear ESP para un jugador
    local function createESP(player)
        if player == LocalPlayer then return end
        
        local espObject = {}
        
        -- Crear ESP GUI directamente en el CoreGui para máxima estabilidad
        local gui = Instance.new("ScreenGui")
        gui.Name = player.Name .. "_ESP"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = ESPFolder
        espObject.gui = gui
        
        -- Crear el highlight para ver a través de las paredes
        local highlight = Instance.new("Highlight")
        highlight.Name = player.Name .. "Highlight"
        highlight.FillColor = getTeamColor(player)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = ESPFolder
        espObject.highlight = highlight
        
        -- Crear el texto para el nombre y distancia
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 200, 0, 50)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = getTeamColor(player)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 18
        nameLabel.Text = player.Name .. "\n0 studs"
        nameLabel.TextYAlignment = Enum.TextYAlignment.Top
        nameLabel.ZIndex = 10
        nameLabel.Parent = gui
        espObject.nameLabel = nameLabel
        
        -- Función para actualizar el ESP de este jugador específico
        local function updatePlayerESP()
            if not player or not player.Parent then return end
            
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
               LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
               player.Character:FindFirstChild("Head") then
                
                -- Actualizar el highlight
                highlight.Parent = player.Character
                
                -- Calcular posición en pantalla
                local hrpPosition = player.Character.Head.Position
                local vector, onScreen = workspace.CurrentCamera:WorldToScreenPoint(hrpPosition)
                
                -- Calcular distancia
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                -- Asignar color según equipo
                local teamColor = getTeamColor(player)
                highlight.FillColor = teamColor
                nameLabel.TextColor3 = teamColor
                
                -- Actualizar texto y posición solo si está en pantalla
                if onScreen then
                    nameLabel.Text = string.format("%s\n%.1f studs", player.Name, distance)
                    nameLabel.Position = UDim2.new(0, vector.X - 100, 0, vector.Y - 50)
                    
                    -- Limitar el tamaño del texto basado en la distancia
                    -- Tamaño mínimo: 14, tamaño máximo: 18, disminuye con la distancia
                    local textSize = math.clamp(18 - (distance / 100), 14, 18)
                    nameLabel.TextSize = textSize
                    
                    nameLabel.Visible = true
                else
                    nameLabel.Visible = false
                end
            else
                nameLabel.Visible = false
                if highlight then
                    highlight.Parent = ESPFolder
                end
            end
        end
        
        -- Conexión inicial para este jugador
        local connection = RunService.RenderStepped:Connect(updatePlayerESP)
        espObject.connection = connection
        
        return espObject
    end
    
    -- Crear ESP para jugadores existentes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            espData[player] = createESP(player)
        end
    end
    
    -- Conexión para nuevos jugadores
    local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
        espData[player] = createESP(player)
    end)
    
    -- Conexión para jugadores que se van
    local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if espData[player] then
            if espData[player].connection then
                espData[player].connection:Disconnect()
            end
            if espData[player].gui then
                espData[player].gui:Destroy()
            end
            if espData[player].highlight then
                espData[player].highlight:Destroy()
            end
            espData[player] = nil
        end
    end)
    
    -- Verificar estado de activación periódicamente
    local monitorConnection = RunService.Heartbeat:Connect(function()
        if not enabled or not ESPFolder or not ESPFolder.Parent then
            cleanupESP()
        end
    end)
    
    -- Función para limpiar todo cuando se desactiva
    function cleanupESP()
        if monitorConnection then
            monitorConnection:Disconnect()
            monitorConnection = nil
        end
        
        if playerAddedConnection then
            playerAddedConnection:Disconnect()
            playerAddedConnection = nil
        end
        
        if playerRemovingConnection then
            playerRemovingConnection:Disconnect()
            playerRemovingConnection = nil
        end
        
        -- Limpiar todos los datos de ESP
        for player, data in pairs(espData) do
            if data.connection then
                data.connection:Disconnect()
            end
            if data.gui then
                data.gui:Destroy()
            end
            if data.highlight then
                data.highlight:Destroy()
            end
        end
        
        espData = {}
        
        -- Limpiar el folder principal
        if ESPFolder and ESPFolder.Parent then
            ESPFolder:Destroy()
        end
        
        EnabledFeatures["ESP"] = false
    end
    
    -- Exponer la función de limpieza
    getgenv().CleanupESP = cleanupESP
    
    -- Si se desactiva mediante el parámetro
    if not enabled then
        cleanupESP()
    end
end

local function TeleportToPosition(enabled)
    EnabledFeatures["TeleportToPosition"] = enabled

    local uiFolder = CoreGui:FindFirstChild("PlayersUIFolder") or Instance.new("Folder")
    uiFolder.Name = "PlayersUIFolder"
    uiFolder.Parent = CoreGui

    -- Limpia el contenido anterior si existe
    for _, child in pairs(uiFolder:GetChildren()) do
        child:Destroy()
    end

    if enabled then
        local yOffset = 0
        for _, player in pairs(Players:GetPlayers()) do
            local label = Instance.new("TextLabel")
            label.Name = "PlayerLabel"
            label.Text = player.Name
            label.Size = UDim2.new(0, 200, 0, 25)
            label.Position = UDim2.new(0, 10, 0, 100 + yOffset)
            label.BackgroundTransparency = 0.3
            label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 18
            label.Parent = uiFolder
            yOffset = yOffset + 30
        end

        -- Refrescar al entrar o salir un jugador
        Players.PlayerAdded:Connect(function()
            if EnabledFeatures["ShowPlayersUI"] then
                ShowPlayersUI(true)
            end
        end)

        Players.PlayerRemoving:Connect(function()
            if EnabledFeatures["ShowPlayersUI"] then
                ShowPlayersUI(true)
            end
        end)
    else
        uiFolder:Destroy()
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
    {name = "Speed", callback = ToggleSpeed, slider = true, min = 16, max = 500, default = 16},
    {name = "AumentV", callback = ToggleVida, slider = true, min = 100, max = 500, default = 100},
    {name = "SuperJump", callback = ToggleSuperJump, slider = true, min = 50, max = 500, default = 50},
    {name = "InfiniteJump", callback = InfiniteJump},
    {name = "NoClip", callback = NoClip},
    {name = "BunnyHop", callback = BunnyHop},
    {name = "Levitation", callback = Levitation}
}

local CombatFeatures = {
    {name = "AutoHeal", callback = AutoHeal},
    {name = "SpinBot", callback = SpinBot},
    {name = "HitboxExpander", callback = HitboxExpander}
}

local VisualFeatures = {
    {name = "ESP", callback = ESP},
    {name = "Chams", callback = Chams},
    {name = "Tracers", callback = Tracers},
    {name = "Fullbright", callback = Fullbright}
}

local PlayerFeatures = {
    {name = "AntiAFK", callback = function() end},
    {name = "AutoReset", callback = function() end},
    {name = "SaveRespawn", callback = function() SaveRespawn(true) end, isButton = true},
    {name = "DeleteRespawn", callback = function() DeleteRespawn() end, isButton = true},
    {name = "SavePosition", callback = function() end},
    {name = "TeleportToPosition", callback = function() end},
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
    if feature.isButton then
        CreateButton(feature.name, Sections.Player, feature.callback)
    else
        CreateToggle(feature.name, Sections.Player, feature.callback)
    end
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
                if feature == "Speed" then
                    Humanoid.WalkSpeed = value
                elseif feature == "AumentV" then
                    Humanoid.MaxHealth = value
                elseif feature == "SuperJump" then
                    Humanoid.JumpPower = value
                    Humanoid.JumpHeight = 7.2
                elseif feature == "InfiniteJump" then
                    InfiniteJump(true)
                elseif feature == "NoClip" then
                    NoClip(true)
                elseif feature == "AutoHeal" then
                    AutoHeal(true)
                elseif feature == "BunnyHop" then
                    BunnyHop(true)
                elseif feature == "SpinBot" then
                    SpinBot(true)
                elseif feature == "HitboxExpander" then
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
