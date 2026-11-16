-- Nocturne UI 1.1 | Client-side Luau | Optional custom Tahoma font downloads.
-- ModuleScript: require(module). Executor: loadstring(source)().
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local Library = { Version = "1.3.0" }
local Window, Tab, Section = {}, {}, {}
Window.__index, Tab.__index, Section.__index = Window, Tab, Section
local C = {
    Outer = Color3.fromRGB(19,19,19), Panel = Color3.fromRGB(25,25,25),
    Field = Color3.fromRGB(19,19,19), Border = Color3.fromRGB(48,48,48),
    Text = Color3.fromRGB(222,220,224), Muted = Color3.fromRGB(136,134,139),
    Accent = Color3.fromRGB(159,148,174),
}

local Images = {}
local function imageAsset(name)
    if Images[name]~=nil then return Images[name] or nil end
    local asset=getcustomasset or getsynasset
    if type(asset)~="function" or type(writefile)~="function" then Images[name]=false return nil end
    local ok,result=pcall(function()
        local path="Nocturne_Image_"..name
        if type(isfile)~="function" or not isfile(path) then
            local bytes=game:HttpGet("https://raw.githubusercontent.com/sametexe001/images/main/"..name)
            assert(bytes:sub(1,8)==string.char(137,80,78,71,13,10,26,10),"Invalid PNG")
            writefile(path,bytes)
        end
        return asset(path)
    end)
    Images[name]=ok and result or false
    if not ok then warn("[Nocturne image] "..name..": "..tostring(result)) end
    return ok and result or nil
end
local Faces = {}
local function loadFonts()
    if Faces.Attempted then return end
    Faces.Attempted=true
    local asset=getcustomasset or getsynasset
    if type(asset)~="function" or type(writefile)~="function" then
        warn("[Nocturne] Custom Tahoma requires getcustomasset and writefile; using fallback font") return
    end
    local sources={
        Regular="https://raw.githubusercontent.com/aap27781-commits/hhhh/main/fs-tahoma-8px%281%29.ttf",
        Bold="https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/TAHOMA-8PT-BOLD-WINDOWS-XP.TTF",
    }
    for name,url in pairs(sources) do
        local ok,result=pcall(function()
            local path="Nocturne_TahomaXP_"..name
            if type(isfile)~="function" or not isfile(path..".ttf") then
                local bytes=game:HttpGet(url)
                assert(#bytes>100 and (bytes:sub(1,4)==string.char(0,1,0,0) or bytes:sub(1,4)=="OTTO"),"Invalid font download")
                writefile(path..".ttf",bytes)
            end
            writefile(path..".json",Http:JSONEncode({name="Nocturne Tahoma "..name,faces={{name="Regular",weight=400,style="normal",assetId=asset(path..".ttf")}}}))
            return Font.new(asset(path..".json"),Enum.FontWeight.Regular,Enum.FontStyle.Normal)
        end)
        if ok then Faces[name]=result else warn("[Nocturne font "..name.."] "..tostring(result)) end
    end
end

local function make(class, props, parent)
    local object = Instance.new(class)
    for key, value in pairs(props or {}) do if key~="Bold" and key~="Decoration" then object[key] = value end end
    if (class=="TextLabel" or class=="TextButton" or class=="TextBox") and not (props and props.Decoration) then
        object.TextSize=12
        local face=Faces[props and props.Bold and "Bold" or "Regular"]
        if face then object.FontFace=face else object.Font=props and props.Bold and Enum.Font.ArialBold or Enum.Font.Arial end
    end
    object.Parent = parent
    return object
end
local function texture(parent,name,props)
    local source=imageAsset(name)
    if not source then return nil end
    local settings={Image=source,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,Active=false}
    for k,v in pairs(props or {}) do settings[k]=v end
    return make("ImageLabel",settings,parent)
end
local function frame(parent, props)
    local defaults = { BackgroundColor3 = C.Panel, BorderSizePixel = 0 }
    for k,v in pairs(props or {}) do defaults[k] = v end
    return make("Frame", defaults, parent)
end
local function label(parent, text, props)
    local defaults = {
        BackgroundTransparency = 1, BorderSizePixel = 0, Text = text,
        Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.Text,
        TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1,0,0,20),
    }
    for k,v in pairs(props or {}) do defaults[k] = v end
    return make("TextLabel", defaults, parent)
end
local function button(parent, text, props)
    local defaults = {
        BackgroundColor3 = C.Field, BorderSizePixel = 0, AutoButtonColor = false,
        Text = text, Font = Enum.Font.Code, TextSize = 12, TextColor3 = C.Text,
        Size = UDim2.new(1,0,0,22),
    }
    for k,v in pairs(props or {}) do defaults[k] = v end
    return make("TextButton", defaults, parent)
end
local function stroke(object, color)
    return make("UIStroke", { Color = color or C.Border, Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, object)
end
local function padding(object, n)
    make("UIPadding", {PaddingLeft=UDim.new(0,n), PaddingRight=UDim.new(0,n),
        PaddingTop=UDim.new(0,n), PaddingBottom=UDim.new(0,n)}, object)
end
local function list(object, gap)
    return make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap or 4) }, object)
end
local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function keycode(name)
    if type(name) ~= "string" then return nil end
    local ok, value = pcall(function() return Enum.KeyCode[name] end)
    if ok and value ~= Enum.KeyCode.Unknown then return value end
    return nil
end
local function primary(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end
function Window:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end
function Window:_call(callback, ...)
    if type(callback) ~= "function" or self.Destroyed then return end
    local args = table.pack(...)
    task.spawn(function()
        if self.Destroyed then return end
        local ok, err = pcall(callback, table.unpack(args, 1, args.n))
        if not ok then warn("[Nocturne callback] " .. tostring(err)) end
    end)
end
function Window:_accent(object, property)
    self.Accents[object] = property
    object[property] = self.Accent
end
function Window:SetAccent(color)
    assert(typeof(color) == "Color3", "SetAccent expects Color3")
    self.Accent = color
    for object, property in pairs(self.Accents) do
        if object.Parent then object[property] = color end
    end
end
function Window:SetStatus(text)
    self.Status.Text = tostring(text)
end
function Window:SetVisible(visible)
    self.Main.Visible = visible == true
    if self.Picker then self.Picker.Visible=false end
    self.Tooltip.Visible = false
    if not visible then
        self.Drag = nil
        self:_cancelCapture()
    end
end
function Window:Toggle() self:SetVisible(not self.Main.Visible) end
function Window:_cancelCapture()
    if self.Capture then self.Capture.Refresh() end
    self.Capture = nil
end
function Window:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for _, connection in ipairs(self.Connections) do connection:Disconnect() end
    table.clear(self.Connections)
    self.Gui:Destroy()
    if self.Environment and self.Environment[self.RegistryKey] == self then
        self.Environment[self.RegistryKey] = nil
    end
end
function Window:_dragStart(input, update)
    if not primary(input) then return end
    self.Drag = { Input = input, Update = update }
    update(input.Position)
end
function Window:_tip(target, text)
    if not text then return end
    local info=label(target,"i",{Size=UDim2.fromOffset(11,11),Position=UDim2.new(1,-12,0.5,-5),TextXAlignment=Enum.TextXAlignment.Center,TextColor3=C.Muted})
    make("UICorner",{CornerRadius=UDim.new(1,0)},info) stroke(info,C.Muted)
    self:_connect(target.MouseEnter, function()
        self.Tooltip.Text = tostring(text)
        self.Tooltip.Visible = true
    end)
    self:_connect(target.MouseLeave, function() self.Tooltip.Visible = false end)
end
function Window:_register(control, opts)
    if opts.Flag then
        assert(type(opts.Flag) == "string" and not self.Controls[opts.Flag], "Duplicate/invalid Flag: " .. tostring(opts.Flag))
        self.Controls[opts.Flag] = control
    end
    return control
end

function Library:CreateWindow(opts)
    opts = opts or {}
    loadFonts()
    local player = Players.LocalPlayer
    assert(player, "Nocturne must run on the client")
    local self = setmetatable({
        Connections = {}, Accents = {}, Controls = {}, Tabs = {}, Keybinds = {},
        Accent = opts.Accent or C.Accent, ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
        Width = math.clamp(opts.Width or 540, 420, 1400), Height = math.clamp(opts.Height or 620, 320, 1000),
        RegistryKey = "__NocturneUI_" .. (opts.Id or "Default"), Destroyed = false,
    }, Window)
    local env = _G
    if type(getgenv) == "function" then
        local ok, result = pcall(getgenv)
        if ok and type(result) == "table" then env = result end
    end
    local previous = env[self.RegistryKey]
    if type(previous) == "table" and type(previous.Destroy) == "function" then previous:Destroy() end
    local gui = make("ScreenGui", {
        Name = "NocturneUI", ResetOnSpawn = false, DisplayOrder = 10000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = false,
    })
    self.Gui = gui
    local parents = {}
    if opts.Parent then table.insert(parents, opts.Parent) end
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then table.insert(parents, result) end
    end
    table.insert(parents, game:GetService("CoreGui"))
    table.insert(parents, player:WaitForChild("PlayerGui"))
    local mounted = false
    for _, parent in ipairs(parents) do
        local ok = pcall(function() gui.Parent = parent end)
        if ok then mounted = true break end
    end
    assert(mounted, "Nocturne: no writable GUI parent")
    self.Environment = env
    pcall(function() env[self.RegistryKey] = self end)
    local root = frame(gui, { Size=UDim2.fromScale(1,1), BackgroundTransparency=1 })
    self.Root = root
    local main = frame(root, { Size=UDim2.fromOffset(self.Width,self.Height), BackgroundColor3=C.Outer })
    self.Main = main
    stroke(main, Color3.fromRGB(85,85,85))
    local inner = frame(main, {Position=UDim2.fromOffset(3,3), Size=UDim2.new(1,-6,1,-6)})
    stroke(inner, Color3.fromRGB(7,7,7))
    local scale = make("UIScale", {Scale=1}, main)
    self.Scale = scale
    local topLine = frame(main, {Position=UDim2.fromOffset(5,5), Size=UDim2.new(1,-10,0,1)})
    self:_accent(topLine, "BackgroundColor3")
    local dragBar = button(main, "", {Position=UDim2.fromOffset(5,6), Size=UDim2.new(1,-10,0,9), BackgroundTransparency=1})
    self:_tip(dragBar, "Drag to move the window")
    self.TabBar = frame(main, {Position=UDim2.fromOffset(16,15), Size=UDim2.new(1,-32,0,27), BackgroundTransparency=1})
    local surface = frame(main, {Position=UDim2.fromOffset(16,52), Size=UDim2.new(1,-32,1,-96), BackgroundColor3=Color3.fromRGB(16,16,16), ClipsDescendants=true})
    stroke(surface)
    local dots = {}
    for i=1,110 do dots[i] = string.rep(". ",100) end
    label(surface, table.concat(dots,"\n"), {Size=UDim2.fromOffset(1200,1400), TextSize=9,
        Decoration=true,TextColor3=Color3.fromRGB(51,51,51), TextYAlignment=Enum.TextYAlignment.Top})
    self.Surface = surface
    local footer = frame(main, {Position=UDim2.new(0,16,1,-35),Size=UDim2.new(1,-32,0,28),BackgroundTransparency=1})
    local badge = label(footer, "N", {Size=UDim2.fromOffset(24,24), BackgroundTransparency=0,
        BackgroundColor3=C.Field, TextXAlignment=Enum.TextXAlignment.Center,TextSize=18})
    stroke(badge)
    self:_accent(badge,"TextColor3")
    label(footer, opts.Title or "nocturne / interface", {Position=UDim2.fromOffset(32,-2),Size=UDim2.new(1,-70,0,16),TextSize=12})
    self.Status = label(footer, opts.Subtitle or "ready", {Position=UDim2.fromOffset(32,12),Size=UDim2.new(1,-70,0,14),TextSize=11,TextColor3=C.Muted})
    local grip = button(main, "/", {Position=UDim2.new(1,-21,1,-22), Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,TextColor3=C.Muted})
    texture(grip,"resize.png",{ImageColor3=C.Muted})
    self.Tooltip = label(root,"", {Visible=false,BackgroundTransparency=0,BackgroundColor3=C.Field,
        Size=UDim2.fromOffset(260,58), TextWrapped=true,TextSize=12,ZIndex=100})
    padding(self.Tooltip,8)
    stroke(self.Tooltip)
    -- A small persistent toggle also allows touch-only users to reopen the UI.
    local launcher = button(root,"N",{Position=UDim2.fromOffset(8,8),Size=UDim2.fromOffset(28,28),ZIndex=20})
    self:_accent(launcher,"TextColor3")
    stroke(launcher)
    self:_tip(launcher,"Show / hide Nocturne")
    self:_connect(launcher.Activated,function() self:Toggle() end)
    local function fit(center)
        local size = root.AbsoluteSize
        if size.X < 1 or size.Y < 1 then return end
        scale.Scale = math.min(1, (size.X-16)/self.Width, (size.Y-16)/self.Height)
        local w,h = self.Width*scale.Scale,self.Height*scale.Scale
        local x,y = main.Position.X.Offset,main.Position.Y.Offset
        if center then x,y = (size.X-w)/2,(size.Y-h)/2 end
        main.Position = UDim2.fromOffset(math.clamp(x,0,math.max(0,size.X-w)),math.clamp(y,0,math.max(0,size.Y-h)))
    end
    self:_connect(root:GetPropertyChangedSignal("AbsoluteSize"),function() fit(false) end)
    self:_connect(dragBar.InputBegan,function(input)
        if not primary(input) then return end
        local start, origin = input.Position, main.Position
        self:_dragStart(input,function(point)
            main.Position = UDim2.fromOffset(origin.X.Offset+point.X-start.X,origin.Y.Offset+point.Y-start.Y)
            fit(false)
        end)
    end)
    self:_connect(grip.InputBegan,function(input)
        if not primary(input) then return end
        local start,w,h,s = input.Position,self.Width,self.Height,scale.Scale
        self:_dragStart(input,function(point)
            self.Width = math.clamp(w+(point.X-start.X)/s,420,1400)
            self.Height = math.clamp(h+(point.Y-start.Y)/s,320,1000)
            main.Size = UDim2.fromOffset(self.Width,self.Height)
            fit(false)
        end)
    end)
    self:_connect(UIS.InputChanged,function(input)
        local drag = self.Drag
        if drag and ((drag.Input.UserInputType == Enum.UserInputType.Touch and input == drag.Input)
            or (drag.Input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)) then
            drag.Update(input.Position)
        end
        if self.Tooltip.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
            local point = Vector2.new(input.Position.X,input.Position.Y)-root.AbsolutePosition
            local size = root.AbsoluteSize
            self.Tooltip.Position = UDim2.fromOffset(math.clamp(point.X+14,0,math.max(0,size.X-260)),math.clamp(point.Y+18,0,math.max(0,size.Y-58)))
        end
    end)
    self:_connect(UIS.InputEnded,function(input)
        if self.Drag and (input == self.Drag.Input or (self.Drag.Input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseButton1)) then self.Drag=nil end
        for _,bind in ipairs(self.Keybinds) do
            if bind.Mode == "Hold" and bind.Active and input.KeyCode == bind.Value then
                bind.Active=false self:_call(bind.Callback,false,bind.Value)
            end
        end
    end)
    self:_connect(UIS.WindowFocusReleased,function()
        self.Drag=nil
        self:_cancelCapture()
        for _,bind in ipairs(self.Keybinds) do
            if bind.Mode == "Hold" and bind.Active then bind.Active=false self:_call(bind.Callback,false,bind.Value) end
        end
    end)
    self:_connect(UIS.InputBegan,function(input, processed)
        if self.Capture then
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local control = self.Capture
            self.Capture = nil
            if input.KeyCode == Enum.KeyCode.Escape then control.Refresh()
            elseif input.KeyCode == Enum.KeyCode.Backspace then control:Set(nil)
            else control:Set(input.KeyCode) end
            return
        end
        if processed or UIS:GetFocusedTextBox() then return end
        if input.KeyCode == self.ToggleKey then self:Toggle() return end
        for _,bind in ipairs(self.Keybinds) do
            if input.KeyCode == bind.Value then
                if bind.Mode == "Toggle" then bind.Active=not bind.Active
                elseif bind.Mode == "Hold" then bind.Active=true end
                self:_call(bind.Callback,bind.Mode == "Press" or bind.Active,bind.Value)
            end
        end
    end)
    task.defer(function() if not self.Destroyed then fit(true) end end)
    return self
end

function Window:AddTab(name)
    local tab = setmetatable({Window=self,Name=name,Sections={}},Tab)
    tab.Button = button(self.TabBar,name,{Bold=true,BackgroundTransparency=1,TextSize=12})
    tab.Line = frame(tab.Button,{Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),BackgroundColor3=C.Muted})
    tab.Page = frame(self.Surface,{Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,1,-24),BackgroundTransparency=1,Visible=false})
    tab.Columns = {}
    for i=1,2 do
        local column = make("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new((i-1)*0.5,(i-1)*6,0,0),Size=UDim2.new(0.5,-6,1,0),
            CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=2,ScrollBarImageColor3=C.Muted,
            ClipsDescendants=true},tab.Page)
        padding(column,2)
        list(column,12)
        tab.Columns[i] = column
    end
    table.insert(self.Tabs,tab)
    for i,t in ipairs(self.Tabs) do
        t.Button.Position=UDim2.new((i-1)/#self.Tabs,3,0,0)
        t.Button.Size=UDim2.new(1/#self.Tabs,-6,1,0)
    end
    self:_connect(tab.Button.Activated,function() tab:Select() end)
    if #self.Tabs == 1 then tab:Select() end
    return tab
end
function Tab:Select()
    if self.Window.Picker then self.Window.Picker.Visible=false end
    self.Window.Tooltip.Visible = false
    self.Window:_cancelCapture()
    for _,tab in ipairs(self.Window.Tabs) do
        local active = tab == self
        tab.Page.Visible = active
        tab.Button.TextColor3 = active and C.Text or C.Muted
        if active then self.Window:_accent(tab.Line,"BackgroundColor3")
        else self.Window.Accents[tab.Line]=nil tab.Line.BackgroundColor3=C.Muted end
    end
    self.Window.SelectedTab = self
end
function Tab:AddSection(name, side, minHeight)
    local column = (side == "Right" or side == 2) and 2 or 1
    local panel = frame(self.Columns[column],{Size=UDim2.new(1,-3,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=#self.Sections+1})
    stroke(panel)
    if minHeight then make("UISizeConstraint",{MinSize=Vector2.new(0,minHeight)},panel) end
    local title = label(panel," "..name.." ",{Bold=true,Position=UDim2.fromOffset(7,-1),Size=UDim2.fromOffset(0,16),
        AutomaticSize=Enum.AutomaticSize.X,BackgroundTransparency=0,BackgroundColor3=C.Panel,TextSize=12,ZIndex=2})
    local content = frame(panel,{Position=UDim2.fromOffset(10,22),Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    list(content,4)
    make("UIPadding",{PaddingBottom=UDim.new(0,11)},content)
    local section = setmetatable({Window=self.Window,Frame=panel,Content=content,Title=title,Count=0},Section)
    table.insert(self.Sections,section)
    return section
end
function Section:SetTitle(text) self.Title.Text=" "..tostring(text).." " end
function Section:SetVisible(value) self.Frame.Visible=value==true end
function Section:_row(height)
    self.Count=self.Count+1
    return frame(self.Content,{Size=UDim2.new(1,0,0,height or 22),BackgroundTransparency=1,LayoutOrder=self.Count})
end
function Section:AddLabel(text)
    local row=self:_row(32)
    local item=label(row,text,{Size=UDim2.fromScale(1,1),TextWrapped=true,TextSize=11,TextColor3=C.Muted})
    return {Set=function(_,value) item.Text=tostring(value) end,Frame=row}
end
function Section:AddButton(opts)
    local row=self:_row(24)
    local item=button(row,opts.Text or "button")
    local edge=stroke(item)
    self.Window:_connect(item.MouseEnter,function() edge.Color=self.Window.Accent end)
    self.Window:_connect(item.MouseLeave,function() edge.Color=C.Border end)
    self.Window:_connect(item.Activated,function() self.Window:_call(opts.Callback) end)
    self.Window:_tip(item,opts.Tooltip)
    return {Frame=row,SetText=function(_,value) item.Text=tostring(value) end}
end
function Section:AddToggle(opts)
    local win,row=self.Window,self:_row(16)
    local hit=button(row,"",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
    local box=frame(hit,{Position=UDim2.fromOffset(0,4),Size=UDim2.fromOffset(8,8),BackgroundColor3=C.Field})
    stroke(box)
    local fill=frame(box,{Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2)})
    win:_accent(fill,"BackgroundColor3")
    make("UIGradient",{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(100,100,100)),Rotation=90},fill)
    local text=label(hit,opts.Text or "toggle",{Position=UDim2.fromOffset(17,0),Size=UDim2.new(1,-17,1,0),TextSize=11})
    local section=self
    local control={Kind="Toggle",Value=false,Frame=row,Accessories=0}
    function control:AddColorPicker(options)
        options=table.clone(options or {})
        self.Accessories=self.Accessories+1
        options.Row=row options.Slot=self.Accessories options.Text=options.Text or opts.Text
        hit.Size=UDim2.new(1,-self.Accessories*25-8,1,0)
        return section:AddColorPicker(options)
    end
    function control:Validate(value) return type(value)=="boolean" end
    function control:Set(value,silent)
        assert(self:Validate(value),"Toggle expects boolean")
        local changed=self.Value~=value
        self.Value=value fill.Visible=value text.TextColor3=value and C.Text or C.Muted
        if changed and not silent then win:_call(opts.Callback,value) end
    end
    function control:Get() return self.Value end
    control:Set(opts.Default==true,true)
    win:_connect(hit.Activated,function() control:Set(not control.Value) end)
    win:_tip(hit,opts.Tooltip)
    return win:_register(control,opts)
end
function Section:AddSlider(opts)
    local win,row=self.Window,self:_row(36)
    local min,max,step=opts.Min or 0,opts.Max or 100,opts.Step or 1
    assert(finite(min) and finite(max) and max>min and finite(step) and step>0,"Invalid slider range")
    label(row,opts.Text or "slider",{TextSize=11,Size=UDim2.new(1,0,0,16)})
    local hit=button(row,"",{Position=UDim2.fromOffset(12,16),Size=UDim2.new(1,-24,0,22),BackgroundTransparency=1})
    local track=frame(hit,{Position=UDim2.fromOffset(0,7),Size=UDim2.new(1,0,0,5),BackgroundColor3=C.Field})
    stroke(track)
    local fill=frame(track,{Size=UDim2.fromScale(0,1)})
    win:_accent(fill,"BackgroundColor3")
    make("UIGradient",{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(105,105,105)),Rotation=90},fill)
    local valueLabel=label(hit,"",{Bold=true,Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center,TextSize=11,ZIndex=2,TextStrokeTransparency=0.4})
    local less=button(row,"-",{Position=UDim2.fromOffset(0,16),Size=UDim2.fromOffset(11,22),BackgroundTransparency=1,TextColor3=C.Muted})
    local more=button(row,"+",{Position=UDim2.new(1,-11,0,16),Size=UDim2.fromOffset(11,22),BackgroundTransparency=1,TextColor3=C.Muted})
    local edit=make("TextBox",{Visible=false,Size=UDim2.new(1,0,0,22),Position=UDim2.fromOffset(0,16),BackgroundColor3=C.Field,BorderSizePixel=0,Text="",TextColor3=C.Text,ClearTextOnFocus=false,Bold=true,ZIndex=6},row)
    stroke(edit)
    local valueButton=button(hit,"",{BackgroundTransparency=1,Size=UDim2.fromOffset(52,22),ZIndex=4})
    local control={Kind="Slider",Value=min,Frame=row}
    local errorGeneration=0
    local function invalid()
        errorGeneration=errorGeneration+1
        local generation=errorGeneration
        task.spawn(function()
            for i=1,2 do
                if win.Destroyed or generation~=errorGeneration then return end
                valueLabel.TextColor3=Color3.fromRGB(255,75,75)
                task.wait(0.13)
                if win.Destroyed or generation~=errorGeneration then return end
                valueLabel.TextColor3=C.Text
                task.wait(0.13)
            end
        end)
    end
    function control:Validate(value) return finite(value) end
    function control:Set(value,silent)
        assert(self:Validate(value),"Slider expects finite number")
        value=math.clamp(value,min,max)
        if value~=max then value=math.clamp(min+math.floor((value-min)/step+0.5)*step,min,max) end
        value=tonumber(string.format("%.8f",value))
        local changed=self.Value~=value
        self.Value=value fill.Size=UDim2.fromScale((value-min)/(max-min),1)
        valueLabel.Text=opts.Format and opts.Format(value) or (tostring(value)..(opts.Suffix or ""))
        valueLabel.AnchorPoint=Vector2.new(0.5,0)
        valueLabel.Size=UDim2.fromOffset(52,22)
        local fraction=(value-min)/(max-min)
        valueLabel.Position=UDim2.new(fraction,0,0,0)
        valueButton.AnchorPoint=Vector2.new(0.5,0)
        valueButton.Position=valueLabel.Position
        if changed and not silent then win:_call(opts.Callback,value) end
    end
    function control:Get() return self.Value end
    control:Set(opts.Default or min,true)
    win:_connect(valueButton.Activated,function()
        win.Drag=nil edit.Text=tostring(control.Value) edit.Visible=true edit:CaptureFocus()
    end)
    win:_connect(edit.FocusLost,function()
        local number=tonumber(edit.Text)
        edit.Visible=false
        if not finite(number) then invalid() return end
        control:Set(number)
    end)
    win:_connect(hit.InputBegan,function(input)
        win:_dragStart(input,function(point)
            control:Set(min+math.clamp((point.X-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)*(max-min))
        end)
    end)
    win:_connect(less.Activated,function() control:Set(control.Value-step) end)
    win:_connect(more.Activated,function() control:Set(control.Value+step) end)
    win:_tip(hit,opts.Tooltip)
    return win:_register(control,opts)
end
function Section:AddDropdown(opts)
    local win,row=self.Window,self:_row(43)
    local values={}
    for _,value in ipairs(opts.Values or {}) do
        assert(type(value)=="string" and not table.find(values,value),"Dropdown values must be unique strings")
        table.insert(values,value)
    end
    assert(#values>0,"Dropdown requires Values")
    label(row,opts.Text or "select",{TextSize=11,Size=UDim2.new(1,0,0,16)})
    local selected=button(row,"",{Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,0,0,21),TextXAlignment=Enum.TextXAlignment.Left,TextSize=11})
    padding(selected,5) stroke(selected)
    label(selected,"=",{Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=C.Muted})
    local menu=make("ScrollingFrame",{Visible=false,Position=UDim2.fromOffset(0,43),Size=UDim2.new(1,0,0,math.min(6,#values)*23),BackgroundColor3=C.Field,
        BorderSizePixel=0,CanvasSize=UDim2.fromOffset(0,#values*23),ScrollBarThickness=2,ScrollBarImageColor3=C.Muted,ScrollingDirection=Enum.ScrollingDirection.Y},row)
    stroke(menu) list(menu,0)
    menu.Parent=win.Root menu.ZIndex=75
    local control={Kind="Dropdown",Value=nil,Frame=row,Values=values}
    local choices={}
    local function open(value)
        if value then
            if win.Picker then win.Picker.Visible=false end
            win.Picker=menu
            local p=selected.AbsolutePosition-win.Root.AbsolutePosition
            local height=math.min(6,#values)*23
            menu.Size=UDim2.fromOffset(selected.AbsoluteSize.X,height)
            menu.Position=UDim2.fromOffset(math.clamp(p.X,0,math.max(0,win.Root.AbsoluteSize.X-selected.AbsoluteSize.X)),math.clamp(p.Y+selected.AbsoluteSize.Y+2,0,math.max(0,win.Root.AbsoluteSize.Y-height)))
        end
        menu.Visible=value
    end
    function control:Validate(value) return type(value)=="string" and table.find(values,value)~=nil end
    function control:Set(value,silent)
        assert(self:Validate(value),"Unknown dropdown value: "..tostring(value))
        local changed=self.Value~=value
        self.Value=value selected.Text=value
        for name,item in pairs(choices) do
            if name==value then win:_accent(item,"TextColor3")
            else win.Accents[item]=nil item.TextColor3=C.Muted end
        end
        open(false)
        if changed and not silent then win:_call(opts.Callback,value) end
    end
    function control:Get() return self.Value end
    for i,value in ipairs(values) do
        local item=button(menu,value,{Size=UDim2.new(1,-3,0,23),TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=i,TextSize=11})
        padding(item,5) choices[value]=item
        win:_connect(item.Activated,function() control:Set(value) end)
    end
    control:Set(opts.Default or values[1],true)
    win:_connect(selected.Activated,function() open(not menu.Visible) end)
    win:_connect(UIS.InputBegan,function(input)
        if not menu.Visible then return end
        if input.KeyCode==Enum.KeyCode.Escape then open(false) return end
        if primary(input) then
            local function inside(obj)
                local p,z=obj.AbsolutePosition,obj.AbsoluteSize
                return input.Position.X>=p.X and input.Position.Y>=p.Y and input.Position.X<=p.X+z.X and input.Position.Y<=p.Y+z.Y
            end
            if not inside(menu) and not inside(selected) then open(false) end
        end
    end)
    win:_tip(selected,opts.Tooltip)
    return win:_register(control,opts)
end
function Section:AddTextbox(opts)
    local win,row=self.Window,self:_row(43)
    label(row,opts.Text or "text",{TextSize=11,Size=UDim2.new(1,0,0,16)})
    local input=make("TextBox",{Position=UDim2.fromOffset(0,18),Size=UDim2.new(1,0,0,21),BackgroundColor3=C.Field,BorderSizePixel=0,
        Text="",PlaceholderText=opts.Placeholder or "...",PlaceholderColor3=C.Muted,TextColor3=C.Text,Font=Enum.Font.Code,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false},row)
    padding(input,4) stroke(input)
    local control={Kind="Textbox",Value="",Frame=row}
    function control:Validate(value) return type(value)=="string" end
    function control:Set(value,silent)
        assert(self:Validate(value),"Textbox expects string")
        -- MaxLength counts Unicode codepoints, preserving UTF-8 text.
        local count=utf8.len(value)
        assert(count,"Textbox expects valid UTF-8")
        local limit=opts.MaxLength or 256
        if count>limit then value=string.sub(value,1,utf8.offset(value,limit+1)-1) end
        local changed=self.Value~=value
        self.Value=value input.Text=value
        if changed and not silent then win:_call(opts.Callback,value) end
    end
    function control:Get() return self.Value end
    control:Set(opts.Default or "",true)
    win:_connect(input.FocusLost,function() control:Set(input.Text) end)
    win:_tip(input,opts.Tooltip)
    return win:_register(control,opts)
end
function Section:AddKeybind(opts)
    local win,row=self.Window,self:_row(24)
    label(row,opts.Text or "keybind",{Size=UDim2.new(0.55,0,1,0),TextSize=11})
    local bindButton=button(row,"",{Position=UDim2.fromScale(0.55,0),Size=UDim2.new(0.45,0,0,22),TextSize=11})
    stroke(bindButton)
    local control={Kind="Keybind",Value=nil,Mode=opts.Mode or "Press",Active=false,Callback=opts.Callback,Frame=row}
    assert(control.Mode=="Press" or control.Mode=="Toggle" or control.Mode=="Hold","Invalid keybind Mode")
    function control:Validate(value)
        return value==nil or (typeof(value)=="EnumItem" and value.EnumType==Enum.KeyCode and value~=Enum.KeyCode.Unknown)
    end
    function control.Refresh() bindButton.Text=control.Value and control.Value.Name or "none" end
    function control:Set(value,silent)
        if type(value)=="string" then assert(keycode(value),"Invalid key name") value=keycode(value) end
        assert(self:Validate(value),"Keybind expects Enum.KeyCode or nil")
        local wasActive=self.Active
        self.Active=false self.Value=value self.Refresh()
        if not silent then
            if wasActive then win:_call(self.Callback,false,value) end
            win:_call(opts.Changed,value)
        end
    end
    function control:Get() return self.Value end
    control:Set(opts.Default,true)
    win:_connect(bindButton.Activated,function()
        win:_cancelCapture() win.Capture=control bindButton.Text="..."
    end)
    win:_tip(bindButton,opts.Tooltip or (control.Mode.." | click to bind; Esc: cancel; Backspace: clear"))
    table.insert(win.Keybinds,control)
    return win:_register(control,opts)
end
function Section:AddColorPicker(opts)
    local win,row=self.Window,opts.Row or self:_row(20)
    local hit=button(row,"",{Size=opts.Row and UDim2.fromOffset(23,16) or UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=3})
    if opts.Row then hit.Position=UDim2.new(1,-25*(opts.Slot or 1),0,0)
    else label(hit,opts.Text or "color",{Size=UDim2.new(1,-36,1,0)}) end
    local swatch=frame(hit,{Position=UDim2.new(1,-20,0,5),Size=UDim2.fromOffset(18,8)})
    stroke(swatch)
    make("UIGradient",{Rotation=90,Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(100,100,100))},swatch)
    local popup=frame(win.Root,{Visible=false,Size=UDim2.fromOffset(224,260),BackgroundColor3=C.Field,ZIndex=80})
    stroke(popup,Color3.fromRGB(70,70,70))
    label(popup,opts.Text or "color",{Size=UDim2.new(1,0,0,20),TextXAlignment=Enum.TextXAlignment.Center,Bold=true})
    local sv=button(popup,"",{Position=UDim2.fromOffset(10,26),Size=UDim2.fromOffset(150,150),BackgroundColor3=Color3.new(1,1,1)})
    local horizontal=make("UIGradient",{},sv)
    local shade=frame(sv,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),Active=false,ZIndex=2})
    make("UIGradient",{Rotation=90,Transparency=NumberSequence.new(1,0)},shade)
    local cursor=frame(sv,{Size=UDim2.fromOffset(4,4),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.new(1,1,1),ZIndex=4,Active=false})
    stroke(cursor,Color3.new(0,0,0))
    local hue=button(popup,"",{Position=UDim2.fromOffset(168,26),Size=UDim2.fromOffset(14,150),BackgroundColor3=Color3.new(1,1,1)})
    local stops={}
    for i=0,6 do table.insert(stops,ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1))) end
    local hueGradient=make("UIGradient",{Rotation=90,Color=ColorSequence.new(stops)},hue)
    stroke(hue,Color3.fromRGB(65,65,65))
    local hueMark=frame(hue,{Size=UDim2.new(1,2,0,2),Position=UDim2.fromOffset(-1,0),BackgroundColor3=Color3.new(1,1,1),ZIndex=3})
    stroke(hueMark,Color3.new(0,0,0))
    local alpha=button(popup,"",{Position=UDim2.fromOffset(10,184),Size=UDim2.fromOffset(150,14)})
    for y=0,1 do for x=0,24 do
        frame(alpha,{Position=UDim2.fromOffset(x*6,y*7),Size=UDim2.fromOffset(6,7),BackgroundColor3=(x+y)%2==0 and Color3.fromRGB(150,150,150) or Color3.fromRGB(95,95,95)})
    end end
    stroke(alpha,Color3.fromRGB(65,65,65))
    local alphaColor=frame(alpha,{Size=UDim2.fromScale(1,1),ZIndex=2})
    make("UIGradient",{Transparency=NumberSequence.new(1,0)},alphaColor)
    local alphaMark=frame(alpha,{Size=UDim2.fromOffset(2,14),BackgroundColor3=C.Text,ZIndex=3})
    local preview=frame(popup,{Position=UDim2.fromOffset(168,184),Size=UDim2.fromOffset(46,14)})
    local hex=make("TextBox",{Position=UDim2.fromOffset(10,206),Size=UDim2.fromOffset(204,20),BackgroundColor3=C.Field,BorderSizePixel=0,
        Text="",TextColor3=C.Text,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left},popup)
    padding(hex,4) stroke(hex)
    local save=button(popup,"save to gallery",{Position=UDim2.fromOffset(10,234),Size=UDim2.fromOffset(204,18),TextColor3=C.Muted})
    stroke(save)
    local control={Kind="ColorPicker",Value=Color3.new(1,1,1),Alpha=math.clamp(opts.Alpha or 1,0,1),Frame=row}
    local h,s,v=0,0,1
    local rgba=false
    local formatButton=button(popup,"Aa",{Position=UDim2.fromOffset(190,206),Size=UDim2.fromOffset(24,20),TextColor3=C.Muted,ZIndex=3})
    hex.Size=UDim2.fromOffset(180,20)
    local function paint()
        local color=control.Value
        swatch.BackgroundColor3=color preview.BackgroundColor3=color alphaColor.BackgroundColor3=color
        swatch.BackgroundTransparency=1-control.Alpha preview.BackgroundTransparency=1-control.Alpha
        horizontal.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromHSV(h,1,1))
        sv.BackgroundColor3=Color3.new(1,1,1)
        cursor.Position=UDim2.fromScale(s,1-v)
        hueMark.Position=UDim2.new(0,-1,h,-1)
        alphaMark.Position=UDim2.new(control.Alpha,-1,0,0)
        hex.Text=rgba and string.format("%d, %d, %d, %d",math.floor(color.R*255+0.5),math.floor(color.G*255+0.5),math.floor(color.B*255+0.5),math.floor(control.Alpha*255+0.5)) or ("#"..color:ToHex()..string.format("%02X",math.floor(control.Alpha*255+0.5)))
    end
    win:_connect(formatButton.Activated,function() rgba=not rgba paint() end)
    function control:Validate(value) return typeof(value)=="Color3" end
    function control:Set(value,silent)
        assert(self:Validate(value),"ColorPicker expects Color3")
        local changed=self.Value~=value
        self.Value=value h,s,v=value:ToHSV() paint()
        if changed and not silent then win:_call(opts.Callback,value,self.Alpha) end
    end
    function control:SetAlpha(value,silent)
        assert(finite(value),"Alpha expects a finite number")
        value=math.clamp(value,0,1)
        local changed=self.Alpha~=value self.Alpha=value paint()
        if changed and not silent then win:_call(opts.Callback,self.Value,value) end
    end
    function control:Get() return self.Value end
    function control:GetAlpha() return self.Alpha end
    function control.Notify() win:_call(opts.Callback,control.Value,control.Alpha) end
    local function update()
        local color=Color3.fromHSV(h,s,v)
        local changed=control.Value~=color control.Value=color paint()
        if changed then win:_call(opts.Callback,color,control.Alpha) end
    end
    win:_connect(sv.InputBegan,function(input) win:_dragStart(input,function(p)
        s=math.clamp((p.X-sv.AbsolutePosition.X)/sv.AbsoluteSize.X,0,1)
        v=1-math.clamp((p.Y-sv.AbsolutePosition.Y)/sv.AbsoluteSize.Y,0,1) update()
    end) end)
    win:_connect(hue.InputBegan,function(input) win:_dragStart(input,function(p)
        h=math.clamp((p.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y,0,1) update()
    end) end)
    win:_connect(alpha.InputBegan,function(input) win:_dragStart(input,function(p)
        control:SetAlpha((p.X-alpha.AbsolutePosition.X)/alpha.AbsoluteSize.X)
    end) end)
    win:_connect(hex.FocusLost,function()
        local text=hex.Text:gsub("#",""):gsub("%s","")
        local r,g,b,a=text:match("^(%d+),(%d+),(%d+),(%d+)$")
        if r then
            r,g,b,a=tonumber(r),tonumber(g),tonumber(b),tonumber(a)
            if r<=255 and g<=255 and b<=255 and a<=255 then
                control.Alpha=a/255 control:Set(Color3.fromRGB(r,g,b),true)
                win:_call(opts.Callback,control.Value,control.Alpha) return
            end
        end
        if (#text==6 or #text==8) and text:match("^%x+$") then
            control.Alpha=#text==8 and tonumber(text:sub(7,8),16)/255 or control.Alpha
            control:Set(Color3.fromRGB(tonumber(text:sub(1,2),16),tonumber(text:sub(3,4),16),tonumber(text:sub(5,6),16)),true)
            win:_call(opts.Callback,control.Value,control.Alpha)
        else paint() end
    end)
    local gallery={}
    win.Gallery=win.Gallery or {}
    local initial={}
    for i=1,10 do
        local item=button(popup,"",{Position=UDim2.fromOffset(190,26+(i-1)*15),Size=UDim2.fromOffset(24,11),BackgroundColor3=initial[i] or C.Field})
        stroke(item)
        gallery[i]={Button=item,Color=initial[i],Alpha=1}
        win:_connect(item.Activated,function()
            local entry=win.Gallery[i] or gallery[i]
            if entry.Color then control.Alpha=entry.Alpha control:Set(entry.Color,true) win:_call(opts.Callback,control.Value,control.Alpha) end
        end)
    end
    local nextSlot=1
    win:_connect(save.Activated,function()
        local entry=gallery[nextSlot] entry.Color=control.Value entry.Alpha=control.Alpha
        entry.Button.BackgroundColor3=entry.Color
        win.Gallery[nextSlot]={Color=entry.Color,Alpha=entry.Alpha}
        nextSlot=nextSlot%10+1
    end)
    local function inside(point,obj)
        local p,z=obj.AbsolutePosition,obj.AbsoluteSize
        return point.X>=p.X and point.Y>=p.Y and point.X<=p.X+z.X and point.Y<=p.Y+z.Y
    end
    win:_connect(UIS.InputBegan,function(input)
        if popup.Visible and ((primary(input) and not inside(input.Position,popup) and not inside(input.Position,hit)) or input.KeyCode==Enum.KeyCode.Escape) then popup.Visible=false end
    end)
    win:_connect(hit.Activated,function()
        local show=not popup.Visible
        if win.Picker then win.Picker.Visible=false end
        win.Picker=popup
        local p=hit.AbsolutePosition-win.Root.AbsolutePosition local size=win.Root.AbsoluteSize
        popup.Position=UDim2.fromOffset(math.clamp(p.X+hit.AbsoluteSize.X+8,0,math.max(0,size.X-224)),math.clamp(p.Y,0,math.max(0,size.Y-260)))
        for i,entry in ipairs(gallery) do
            local saved=win.Gallery[i]
            entry.Button.BackgroundColor3=saved and saved.Color or C.Field
        end
        popup.Visible=show
    end)
    control:Set(opts.Default or C.Accent,true)
    return win:_register(control,opts)
end

function Window:GetValues()
    local values={}
    for flag,control in pairs(self.Controls) do values[flag]=control:Get() end
    return values
end
function Window:ExportConfig()
    local values={}
    for flag,control in pairs(self.Controls) do
        local value=control:Get()
        if control.Kind=="ColorPicker" then value={value.R,value.G,value.B}
        elseif control.Kind=="Keybind" then value=value and value.Name or false end
        values[flag]={Kind=control.Kind,Value=value,Alpha=control.Alpha}
    end
    return Http:JSONEncode({Version=1,Values=values})
end
function Window:ImportConfig(json, silent)
    local ok,data=pcall(function() return Http:JSONDecode(json) end)
    if not ok or type(data)~="table" or data.Version~=1 or type(data.Values)~="table" then return false,"Invalid Nocturne config" end
    local pending={}
    for flag,entry in pairs(data.Values) do
        local control=self.Controls[flag]
        if control then
            if type(entry)~="table" or entry.Kind~=control.Kind then return false,"Wrong type: "..flag end
            local value=entry.Value
            if control.Kind=="ColorPicker" and entry.Alpha~=nil and (not finite(entry.Alpha) or entry.Alpha<0 or entry.Alpha>1) then return false,"Invalid alpha: "..flag end
            if control.Kind=="ColorPicker" then
                if type(value)~="table" or #value~=3 then return false,"Invalid color: "..flag end
                for _,channel in ipairs(value) do if not finite(channel) or channel<0 or channel>1 then return false,"Invalid color: "..flag end end
                value=Color3.new(value[1],value[2],value[3])
            elseif control.Kind=="Keybind" then
                if value==false then value=nil
                else value=keycode(value) if not value then return false,"Invalid key: "..flag end end
            end
            if not control:Validate(value) then return false,"Invalid value: "..flag end
            if control.Kind=="Textbox" and not utf8.len(value) then return false,"Invalid UTF-8: "..flag end
            table.insert(pending,{Control=control,Value=value,Alpha=entry.Alpha})
        end
    end
    for _,change in ipairs(pending) do
        if change.Control.Kind=="ColorPicker" then change.Control.Alpha=change.Alpha or 1 end
        local old=change.Control.Value
        change.Control:Set(change.Value,silent~=false)
        if change.Control.Kind=="ColorPicker" and silent==false and old==change.Value and change.Alpha~=nil then
            if change.Control.Notify then change.Control.Notify() end
        end
    end
    return true
end
local function configPath(name)
    assert(type(name)=="string" and #name>0 and #name<=64 and name:match("^[%w_-]+$"),"Use a config name with letters, numbers, _ or -")
    return "Nocturne_"..name..".json"
end
function Window:SaveConfig(name)
    if type(writefile)~="function" then return false,"Executor does not provide writefile" end
    return pcall(function() writefile(configPath(name),self:ExportConfig()) end)
end
function Window:LoadConfig(name, silent)
    if type(readfile)~="function" then return false,"Executor does not provide readfile" end
    local ok,result=pcall(function() return readfile(configPath(name)) end)
    if not ok then return false,tostring(result) end
    return self:ImportConfig(result,silent)
end
function Tab:AddSubTab(name, icon)
    if not self.SubBar then
        self.SubTabs={}
        self.SubBar=frame(self.Page,{Size=UDim2.new(1,0,0,56)}) stroke(self.SubBar)
        for _,column in ipairs(self.Columns) do column.Visible=false end
    end
    local sub=setmetatable({Window=self.Window,Name=name,Sections={},Columns={}},Tab)
    sub.Page=frame(self.Page,{Position=UDim2.fromOffset(0,70),Size=UDim2.new(1,0,1,-70),BackgroundTransparency=1,Visible=false})
    sub.Button=button(self.SubBar,name,{BackgroundTransparency=1})
    if not icon then
        sub.Button.Text=""
        local glyph=frame(sub.Button,{Size=UDim2.fromOffset(24,24),Position=UDim2.new(0.5,-12,0,6),BackgroundTransparency=1})
        local function line(x1,y1,x2,y2)
            local dx,dy=x2-x1,y2-y1
            frame(glyph,{Position=UDim2.fromOffset((x1+x2)/2,(y1+y2)/2),AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),1.5),Rotation=math.deg(math.atan2(dy,dx)),BackgroundColor3=C.Muted})
        end
        local function oval(x,y,w,h)
            local f=frame(glyph,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundTransparency=1})
            make("UICorner",{CornerRadius=UDim.new(1,0)},f) stroke(f,C.Muted)
        end
        if name=="animals" then
            oval(7,11,10,10) oval(2,7,4,5) oval(6,1,4,6) oval(13,1,4,6) oval(18,7,4,5)
        elseif name=="world" then
            oval(2,2,20,20) oval(8,2,8,20) line(2,12,22,12) line(5,6,19,6) line(5,18,19,18)
        elseif name=="local" then
            line(1,12,6,6) line(6,6,18,6) line(18,6,23,12) line(23,12,18,18) line(18,18,6,18) line(6,18,1,12) oval(8,8,8,8)
        else
            oval(4,2,8,8) oval(14,3,6,6) line(1,21,2,16) line(2,16,7,12) line(7,12,12,13) line(12,13,16,18) line(16,18,16,21) line(17,12,22,16) line(22,16,23,21)
        end
        label(sub.Button,name,{Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,18),TextXAlignment=Enum.TextXAlignment.Center})
    end
    if icon then
        make("ImageLabel",{Image=icon,BackgroundTransparency=1,Size=UDim2.fromOffset(22,22),Position=UDim2.new(0.5,-11,0,7),ImageColor3=C.Muted},sub.Button)
        sub.Button.Text=""
        label(sub.Button,name,{Position=UDim2.new(0,0,1,-20),Size=UDim2.new(1,0,0,18),TextXAlignment=Enum.TextXAlignment.Center})
    end
    sub.Line=frame(sub.Button,{Position=UDim2.new(0.5,-12,1,-5),Size=UDim2.fromOffset(24,1)})
    self.Window:_accent(sub.Line,"BackgroundColor3")
    for i=1,2 do
        local col=make("ScrollingFrame",{Position=UDim2.new((i-1)*0.5,(i-1)*6,0,0),Size=UDim2.new(0.5,-6,1,0),
            BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollBarThickness=2,ScrollBarImageColor3=C.Muted,ScrollingDirection=Enum.ScrollingDirection.Y},sub.Page)
        padding(col,2) list(col,12) sub.Columns[i]=col
    end
    local owner=self
    function sub:Select()
        if self.Window.Picker then self.Window.Picker.Visible=false end
        self.Window:_cancelCapture()
        for _,other in ipairs(owner.SubTabs) do
            other.Page.Visible=other==self other.Line.Visible=other==self
            other.Button.TextColor3=other==self and C.Text or C.Muted
        end
        owner.SelectedSubTab=self
    end
    table.insert(self.SubTabs,sub)
    for i,item in ipairs(self.SubTabs) do
        item.Button.Position=UDim2.new((i-1)/#self.SubTabs,0,0,0)
        item.Button.Size=UDim2.new(1/#self.SubTabs,0,1,0)
    end
    self.Window:_connect(sub.Button.Activated,function() sub:Select() end)
    if #self.SubTabs==1 then sub:Select() end
    return sub
end
function Section:AddListbox(opts)
    local win=self.Window
    local values=table.clone(opts.Values or {})
    assert(#values>0,"Listbox requires Values")
    local row=self:_row(opts.Height or 240)
    local scroll=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundColor3=C.Field,BorderSizePixel=0,
        CanvasSize=UDim2.fromOffset(0,#values*18),ScrollBarThickness=2,ScrollBarImageColor3=C.Muted,ScrollingDirection=Enum.ScrollingDirection.Y},row)
    stroke(scroll) list(scroll,0)
    local control={Kind="Listbox",Frame=row,Value=nil}
    local items={}
    function control:Validate(value) return type(value)=="string" and table.find(values,value)~=nil end
    function control:Get() return self.Value end
    function control:Set(value,silent)
        assert(self:Validate(value),"Unknown listbox value")
        local changed=self.Value~=value self.Value=value
        for name,item in pairs(items) do
            item.Button.BackgroundColor3=name==value and Color3.fromRGB(35,35,35) or C.Field
            item.Line.Visible=name==value item.Button.TextColor3=name==value and C.Text or C.Muted
        end
        if changed and not silent then win:_call(opts.Callback,value) end
    end
    for i,value in ipairs(values) do
        assert(type(value)=="string" and not items[value],"Listbox values must be unique strings")
        local item=button(scroll,value,{Size=UDim2.new(1,-4,0,18),LayoutOrder=i,TextXAlignment=Enum.TextXAlignment.Left,Bold=true})
        local line=frame(item,{Size=UDim2.fromOffset(2,18)}) win:_accent(line,"BackgroundColor3")
        make("UIPadding",{PaddingLeft=UDim.new(0,5)},item)
        frame(item,{Position=UDim2.new(1,-8,0,4),Size=UDim2.fromOffset(3,10),BackgroundColor3=opts.StatusColor or Color3.fromRGB(157,101,108)})
        items[value]={Button=item,Line=line}
        win:_connect(item.Activated,function() control:Set(value) end)
    end
    control:Set(opts.Default or values[1],true)
    return win:_register(control,opts)
end

return Library
