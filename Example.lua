local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/popannonnn-art/daswa/main/Nocturne.lua"))()
local Window=Library:CreateWindow({Id="Demo",Title="nocturne / interface",Subtitle="video edition",Width=530,Height=620})
local function report(value) Window:SetStatus("preview / "..tostring(value)) end
local Assistance=Window:AddTab("assistance")
local Visuals=Window:AddTab("visuals")
local Misc=Window:AddTab("miscellaneous")
local function toggle(section,text,flag,color)
    local item=section:AddToggle({Text=text,Flag=flag,Callback=report})
    if color then item:AddColorPicker({Default=color,Flag=flag.."Color",Callback=report}) end
    return item
end
local Models=Assistance:AddSection("players models","Left",246)
toggle(Models,"visible model","visible",Color3.fromRGB(62,88,249))
Models:AddDropdown({Text="material",Values={"3d","2d","flat"},Flag="material",Tooltip="Preview material",Callback=report})
Models:AddSlider({Text="intensity",Min=0,Max=100,Default=7,Suffix="%",Flag="intensity",Callback=report})
toggle(Models,"occluded model","occluded",Color3.fromRGB(176,60,225))
Models:AddDropdown({Text="material",Values={"2d","3d","flat"},Flag="secondaryMaterial",Callback=report})
Models:AddSlider({Text="intensity",Min=0,Max=100,Default=7,Suffix="%",Flag="secondaryIntensity",Callback=report})
local function world(section,prefix)
    toggle(section,"time of day",prefix.."time")
    section:AddSlider({Text="hour",Min=0,Max=24,Default=12,Step=0.5,Flag=prefix.."hour",Format=function(v) return string.format("%02d:%02d",math.floor(v),math.floor(v%1*60)) end,Callback=report})
    toggle(section,"bright night",prefix.."night")
    section:AddSlider({Text="brightness",Min=0,Max=300,Default=150,Suffix="%",Flag=prefix.."brightness",Callback=report})
    toggle(section,"stars",prefix.."stars")
    section:AddSlider({Text="star size",Min=0,Max=500,Default=300,Suffix="%",Flag=prefix.."starSize",Callback=report})
    section:AddSlider({Text="star brightness",Min=0,Max=500,Default=300,Suffix="%",Flag=prefix.."starBrightness",Callback=report})
    toggle(section,"day sky",prefix.."daySky",Color3.fromRGB(83,66,170))
    toggle(section,"night sky",prefix.."nightSky",Color3.fromRGB(48,175,125))
end
world(Assistance:AddSection("world modulation","Left"),"main")
local Master=Assistance:AddSection("players master","Right",144)
toggle(Master,"master","master")
Master:AddSlider({Text="max distance",Min=0,Max=1000,Default=200,Suffix="m",Flag="distance",Callback=report})
local General=Assistance:AddSection("general","Right",190)
General:AddDropdown({Text="bounding box",Values={"2d","3d","cornered"},Flag="boxStyle",Callback=report})
for _,name in ipairs({"name","distance","skeleton","held item"}) do toggle(General,name,"general"..name,Color3.new(1,1,1)) end
local Extra=Assistance:AddSection("extra","Right",140)
local extra=toggle(Extra,"checkbox","extra",Color3.new(1,1,1))
extra:AddColorPicker({Text="secondary",Default=Color3.new(1,1,1),Flag="extraColor2"})
Extra:AddKeybind({Text="toggle key",Default=Enum.KeyCode.G,Mode="Toggle",Flag="extraKey",Callback=report})
for _,name in ipairs({"characters","animals"}) do
    local sub=Visuals:AddSubTab(name)
    local left=sub:AddSection(name.." preview","Left",270)
    toggle(left,"enabled",name.."Enabled",Color3.new(1,1,1))
    left:AddDropdown({Text="bounding box",Values={"2d","3d","cornered"},Flag=name.."Box",Callback=report})
    left:AddSlider({Text="max distance",Min=0,Max=1000,Default=200,Suffix="m",Flag=name.."Distance",Callback=report})
    local right=sub:AddSection(name.." extra","Right",420)
    toggle(right,"health bar",name.."Health")
    toggle(right,"name",name.."Name",Color3.new(1,1,1))
end
local World=Visuals:AddSubTab("world")
local Category=World:AddSection("categories","Left")
local worldMaster=World:AddSection("containers master","Right",120)
toggle(worldMaster,"master","worldMaster")
worldMaster:AddSlider({Text="max distance",Min=0,Max=1000,Default=200,Suffix="m",Flag="worldDistance",Callback=report})
world(World:AddSection("world modulation","Left",430),"world")
local WG=World:AddSection("general","Right",160)
WG:AddDropdown({Text="bounding box",Values={"2d","3d","cornered"},Flag="worldBox",Callback=report})
toggle(WG,"name","worldName") toggle(WG,"distance","worldDistanceLabel")
local health=toggle(WG,"health bar","worldHealth",Color3.fromRGB(178,100,100))
health:AddColorPicker({Text="full health",Default=Color3.fromRGB(100,178,120),Flag="worldHealthFull"})
local groups={}
local names={containers={"crate","military crate","elite crate","barrel","oil barrel","supply drop","locked crate","stash","tool cupboard"},
    resources={"stone ore","metal ore","sulfur ore","tree","hemp","mushroom","corn","pumpkin","wood pile"},
    items={"weapons","ammunition","medical","attire","tools","components","explosives","food","blueprints"}}
for _,category in ipairs({"containers","resources","items"}) do
    local section=World:AddSection(category,"Right",250) groups[category]=section
    for i,name in ipairs(names[category]) do toggle(section,name,category..name,Color3.fromHSV(i/12,0.5,0.65)) end
    section:SetVisible(category=="containers")
end
Category:AddListbox({Values={"containers","resources","items"},Height=54,StatusColor=Color3.fromRGB(95,150,100),Flag="category",Callback=function(value)
    for name,section in pairs(groups) do section:SetVisible(name==value) end
    worldMaster:SetTitle(value.." master")
end})
local Local=Visuals:AddSubTab("local")
local Skins=Local:AddSection("skin changer","Left",435)
toggle(Skins,"enabled","skins")
local Detail=Local:AddSection("rock","Right",435)
toggle(Detail,"override","override")
Detail:AddDropdown({Text="skin",Values={"default","army","black","red","blue"},Flag="skin",Callback=report})
Skins:AddListbox({Values={"rock","stone hatchet","hatchet","salvaged axe","pickaxe","stone pickaxe","salvaged icepick","hammer","salvaged hammer","torch","jackhammer","chainsaw","hoodie","pants","boots","t-shirt","longsleeve t-shirt","shirt","tank top","shorts","jacket"},Height=365,Flag="skinItem",Callback=function(value) Detail:SetTitle(value) end})
local Settings=Misc:AddSection("interface","Left")
Settings:AddColorPicker({Text="accent",Default=Window.Accent,Flag="accent",Callback=function(c) Window:SetAccent(c) end})
Settings:AddLabel("Right Shift: show / hide")
Settings:AddButton({Text="unload",Callback=function() Window:Destroy() end})
local Config=Misc:AddSection("configuration","Right")
Config:AddButton({Text="save default",Callback=function() local ok,err=Window:SaveConfig("default") report(ok and "saved" or err) end})
Config:AddButton({Text="load default",Callback=function() local ok,err=Window:LoadConfig("default",false) report(ok and "loaded" or err) end})
Config:AddLabel("UI demonstration.\nConnect your own callbacks.")
Assistance:Select()
return Window
