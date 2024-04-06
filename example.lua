-- Example
local Players = game:GetService("Players");
local Me = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;
local VirtualInputManager = game:GetService("VirtualInputManager");

local Menu = Interface.new{ Title = "ChinaLake" };
local VisualsTab = Menu:Category{Title = "Visuals"};
local MovementTab = Menu:Category{Title = "Movement"};
local NetworkTab = Menu:Category{Title = "Network"};
local MenuTab = Menu:Category{Title = "Menu"};
local ConfigsTab = Menu:Category{Title = "Configs"};

local LagTab = NetworkTab:SubCategory{Title = "Lag"};
local MenuOptions = MenuTab:SubCategory{Title = "Options"};

local VisualsPlayer = VisualsTab:SubCategory{Title = "Player"};
local VisualsWorld = VisualsTab:SubCategory{Title = "World"}
local VisualsOther = VisualsTab:SubCategory{Title = "Other"};
local ConfigsMain = ConfigsTab:SubCategory{Title = "Load/Save"};
local MovementGeneral = MovementTab:SubCategory{Title = "General"};

--@ Menu Settings
local SafetySwitch;
local NoPartCreation = false;
do 
    local MenuColors = MenuOptions:Section("Left", 400, {
        {Title = "Colors"};
    });

    local MenuOther = MenuOptions:Section("Right", 400, {
        {Title = "Misc"};
    });

    for c, k in next, Interface.Theme do 
        Interface:Colorpicker(MenuColors.Colors, { Title = c; Value = k; Flag = "MenuColors/" .. c }).Call:Connect(function(Color)
            Interface.Theme[c] = Color;
            Interface.ReloadTheme();
        end);
    end; 
    
    SafetySwitch = Interface:Toggle(MenuOther.Misc, {Title = "Safety Mode"});
    Interface:Keybind(MenuOther.Misc, { Title = "Menu Toggle"; Flag = "Menu/MenuToggle"; Value = Enum.KeyCode.RightControl; Callback = function() Menu:Toggle() end })
    Interface:Toggle(MenuOther.Misc, { Title = "Animated Hints"; Flag = "Menu/AnimatedHints"; Value = Interface.AllowAnimatedHints }).Call:Connect(function(Bool)
        Interface.AllowAnimatedHints = Bool;
    end);
    Interface:Button(MenuOther.Misc, {{ Title = "Unload"; Callback = Interface.Unload }});

    Interface:TextEditor(MenuOther.Misc, {
        Text = "1 2 3 4 5 6 Hello writing something long and weird so that i can test this text editor haha so quirky a text editor for what thats useless right well kys faggot ass bitch because maybe i just want a text eidtor bum 1 2 3 4 5 6 Hello writing something long and weird so that i can test this text editor haha so quirky a text editor for what thats";
        Font = 3; 
        FontSize = 15;
        Height = 150;
    })
end;

--@ Visuals
do 
    local VisualsSettings = VisualsPlayer:Section("Left", 300, {
        {Title = "Enemy"};
        {Title = "Friendly"};
        {Title = "Local"};
    });

    local SelfChams = Interface:Toggle(VisualsSettings.Local, { Title = "Body Chams"; Flag = "Visuals/Local/ChamsToggle"});
    SelfChams:Colorpicker({ Flag = "Visuals/Local/ChamsColor" }).Call:Connect(function(Color, Alpha)
        local High = Me.Character and Me.Character:FindFirstChild("High");
        if (not High) then return end; 
        High.FillColor = Color; 
        High.FillTransparency = Alpha;
    end);

    for c, k in next, {"Enemy", "Friendly"} do 
        local DynamicBox, CornerBox;
        Interface:Slider(VisualsSettings[k], { Title = "Render Distance"; Prefix = "m"; Flag = "Visuals/" .. k .. "/" .. "RenderDistance"; Min = 10; Max = 1500; Step = 0; Value = 750});
        DynamicBox = Interface:Toggle(VisualsSettings[k], { Title = "Dynamic Box"; Flag = "Visuals/" .. k .. "/" .. "BoxToggle" });
        CornerBox = Interface:Toggle(VisualsSettings[k], { Title = "Corner Box"; Flag = "Visuals/" .. k .. "/" .. "CornerBoxToggle" });
        Interface:Toggle(VisualsSettings[k], { Title = "Health"; Flag = "Visuals/" .. k .. "/" .. "HealthToggle" });
        Interface:Toggle(VisualsSettings[k], { Title = "Nametag"; Flag = "Visuals/" .. k .. "/" .. "NametagToggle" });
        Interface:Toggle(VisualsSettings[k], { Title = "Tracer"; Flag = "Visuals/" .. k .. "/" .. "TracerToggle" });

        DynamicBox.Call:Connect(function(bool) if (bool) then CornerBox:Set(false) end; end);
        CornerBox.Call:Connect(function(bool) if (bool) then DynamicBox:Set(false); end; end);

        Interface:Toggle(VisualsSettings[k], { Title = "Chams"; InheritanceLock = { Toggle = SafetySwitch; Lock = false }; Flag = "Visuals/" .. k .. "/" .. "ChamsToggle" });
    end;
end;

--@ Plot Example
do 
    local GraphTest = VisualsPlayer:Section("Left", 150, {
        {Title = "Drawing Data"};
    });
    
    local ExamplePlot = Interface:Graph(GraphTest["Drawing Data"], {
        Height = 110;
        GraphSize = {10, 5};
        x = 500; 
        y = 500;
        Formula = CubicBezier;
        -- NoGraphLines = true;
    });
    
    for x = 100, 400, 100 do 
        ExamplePlot:AnchorPoint({x = x, y = math.abs(math.sin(math.rad(x)) * 250)}, Color3(0, 255, 0));
    end; 
    
    for x = 10, 200, 10 do 
        ExamplePlot:Plot({x = x, y = math.abs(math.sin(math.rad(x)) * 250)}, Color3(255, 150, 0));
    end; 
    
    ExamplePlot:UpdatePlots();
    
end; 


--@ Visuals Viewport
do
    --@ Preview
    local VisualsPreview = VisualsPlayer:Section("Right", 300, {
        {Title = "Enemy"};
        {Title = "Friendly"};
    });

    for c, k in next, {"Enemy", "Friendly"} do 
        for c, v in next, {"Occluded", "Visible"} do 
            Interface.Flags["Visuals/" .. k .. "/" .. "CornerBoxToggle"]:Colorpicker({ Flag = "Visuals/" .. k .. "/" .. "CornerColor/" .. v });
            Interface.Flags["Visuals/" .. k .. "/" .. "BoxToggle"]:Colorpicker({ Flag = "Visuals/" .. k .. "/" .. "BoxColor/" .. v });
            Interface.Flags["Visuals/" .. k .. "/" .. "HealthToggle"]:Colorpicker({ Flag = "Visuals/" .. k .. "/" .. "HealthColor/" .. v });     
            Interface.Flags["Visuals/" .. k .. "/" .. "NametagToggle"]:Colorpicker({Flag = "Visuals/" .. k .. "/" .. "NametagColor/" .. v });
            Interface.Flags["Visuals/" .. k .. "/" .. "TracerToggle"]:Colorpicker({ Flag = "Visuals/" .. k .. "/" .. "TracerColor/" .. v });
            Interface.Flags["Visuals/" .. k .. "/" .. "ChamsToggle"]:Colorpicker({ Flag = "Visuals/" .. k .. "/" .. "ChamsColor/" .. v });
        end; 

        local EspPreview = Interface:Viewport(VisualsPreview[k], {
            Data = game:HttpGet("https://pastebin.com/raw/CjpzpR7Q");
            Height = 260;
            IdleRotate = true;
            Rotation = Vector3(0, 0, 250);
        });

        EspPreview.RenderCallback = function(Object, Vertexes, Faces)
            local Min, Max = Object:Get2DBoundingBox(EspPreview.ViewCamera, Vertexes, Faces);
            
            if (Interface.Flags["Visuals/" .. k .. "/" .. "BoxToggle"].Value) then 
                EspPreview.ImmediateDraw("Square", {
                    Visible = true; 
                    Filled = false; 
                    Thickness = 1;
                    Color = Interface.Flags["Visuals/" .. k .. "/" .. "BoxColor/" .. "Visible"].Value; 
                    Size = Vector2(Max.x - Min.x, Max.y - Min.y);
                    Position = EspPreview.Elements.Background.__AbsolutePosition + Vector2(Min.x, Min.y);
                });
            end;

            if (Interface.Flags["Visuals/" .. k .. "/" .. "HealthToggle"].Value) then 
                EspPreview.ImmediateDraw("Square", {
                    Visible = true; 
                    Filled = false; 
                    Thickness = 1;
                    Color = Interface.Flags["Visuals/" .. k .. "/" .. "HealthColor/" .. "Visible"].Value; 
                    Size = Vector2(2, Max.y - Min.y);
                    Position = EspPreview.Elements.Background.__AbsolutePosition + Vector2(Min.x - 4, Min.y);
                });
            end;

            if (Interface.Flags["Visuals/" .. k .. "/" .. "TracerToggle"].Value) then 
                EspPreview.ImmediateDraw("Line", {
                    Visible = true; 
                    Thickness = 1;
                    Color = Interface.Flags["Visuals/" .. k .. "/" .. "TracerColor/" .. "Visible"].Value; 
                    From = EspPreview.Elements.Background.__AbsolutePosition + Vector2(EspPreview.Elements.Background.Size.x / 2, EspPreview.Elements.Background.Size.y);
                    To = EspPreview.Elements.Background.__AbsolutePosition + Vector2(Max.x - ((Max.x - Min.x) / 2), Max.y);
                });
            end;
        end;

        Interface.Flags["Visuals/" .. k .. "/" .. "NametagToggle"].Call:Connect(function(Value)  end);
        Interface.Flags["Visuals/" .. k .. "/" .. "TracerToggle"].Call:Connect(function(Value)  end);
    end; 
end;

--@ Configs
do 
    local SelectedName = "";

    local ConfigLeft = ConfigsMain:Section("Left", 400, { {Title = "Configs"} });
    local ConfigRight = ConfigsMain:Section("Right", 400, { {Title = " "} });

    local ConfigName = Interface:Textbox(ConfigLeft.Configs, {Placeholder = "Config Name"});
    local ConfigList;

    Interface:Button(ConfigLeft.Configs, {
        { 
            Title = "New"; 
            Callback = function()
                if (SelectedName == " " or SelectedName == "") then return end;
                ConfigList:NewOption(SelectedName .. ".itwbz");
                local ConfigPath = "Interwebz/Configs/" .. SelectedName .. ".itwbz";  
                writefile(ConfigPath, Interface:CreateSaveString());
                Interface:Notification({Time = 10; Title = "Config"; Text = "Saved config successfully."})
            end;
        };
    });

    ConfigList = Interface:Dropdown(ConfigLeft.Configs, {Fill = true; Title = ""});

    for c, k in next, listfiles("Interwebz/Configs/") do 
        ConfigList:NewOption(k:split("Interwebz/Configs/")[2]);
    end; 

    ConfigName.Call:Connect(function(name)
        if (name == " " or name == "") then return end;
        SelectedName = name;
    end);

    Interface:Button(ConfigRight[" "], {{ 
        Title = "Load Config"; 
        Callback = function()
            if (not ConfigList.Value[1]) then return end;
            local ConfigPath = "Interwebz/Configs/" .. ConfigList.Value[1]; 
            local Save = readfile(ConfigPath); 
            Interface:SetSave(Save);
        end; 
    }});

    Interface:Button(ConfigRight[" "], {{ 
        Title = "Save Config"; 
        Callback = function()
            if (not ConfigList.Value[1]) then return end;
            local Save = Interface:CreateSaveString(); 
            writefile("Interwebz/Configs/" .. ConfigList.Value[1], Save);
        end; 
    }});

    Interface:Button(ConfigRight[" "], {{ 
        Title = "Export to Clipboard"; 
        Callback = function()
            if (not ConfigList.Value[1]) then return end;
            local ConfigPath = "Interwebz/Configs/" .. ConfigList.Value[1]; 
            local Save = readfile(ConfigPath); 
            setclipboard(Save);
        end; 
    }});

    Interface:Button(ConfigRight[" "], {{ 
        Title = "Delete Config"; 
        Callback = function()
            if (not ConfigList.Value[1]) then return end;
            local ConfigPath = "Interwebz/Configs/" .. ConfigList.Value[1]; 
            delfile(ConfigPath);
            ConfigList:DeleteOption(ConfigList.Value[1]);
        end; 
    }});
end;
