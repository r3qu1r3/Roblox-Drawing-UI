-- setfpscap(240); uncomment if you want this 

local HttpService = game:GetService("HttpService");
local InputService = game:GetService("UserInputService");

local Sleep = task.wait; 
local Vector3, __Vector2 = Vector3.new, Vector2.new;
local HSV, Color3, Draw, Color3New = Color3.fromHSV, Color3.fromRGB, Drawing.new, Color3.new;
local Insert, Remove = table.insert, table.remove;
local Max, Floor, Ceil, Abs, Clamp = math.max, math.floor, math.ceil, math.abs, math.clamp;
local Sub, GSub, Format = string.sub, string.gsub, string.format;
local KeyNames = { One = "1"; Two = "2"; Three = "3"; Four = "4"; Five = "5"; Six = "6"; Seven = "7"; Eight = "8"; Nine = "9"; Zero = "0"; Minus = "-"; Period = "." };
local Camera = workspace.CurrentCamera;
local ClampDecimal = function(n, d) local M = 10 ^ d; return Floor(n * M + 0.5) / M; end;
local TextboundsCalculator = Draw("Text");

local function GetStackLine()
    return debug.getinfo(2, "Sl").currentline;
end; 

local function Vector2(x, y) 
    return __Vector2(Floor(x), Floor(y));
end; 

local function CalculateTextBounds(t, f, s)
    TextboundsCalculator.Text = t; 
    TextboundsCalculator.Size = s; 
    TextboundsCalculator.Font = f; 
    return TextboundsCalculator.TextBounds;
end; 

local function CubicBezier(p0, p1, p2, p3, t)
    local mt = 1 - t
    local mt2 = mt * mt
    local mt3 = mt2 * mt
    local t2 = t * t
    local t3 = t2 * t

    local x = mt3 * p0.x + 3 * mt2 * t * p1.x + 3 * mt * t2 * p2.x + t3 * p3.x
    local y = mt3 * p0.y + 3 * mt2 * t * p1.y + 3 * mt * t2 * p2.y + t3 * p3.y

    return Vector2(x, y);
end

local GuiEngine = loadstring(game:HttpGet("https://raw.githubusercontent.com/1e20/ChinaLake/main/Assets/Lua/GuiEngine.lua"))();
local ProjectionEngine = loadstring(game:HttpGet("https://raw.githubusercontent.com/1e20/ChinaLake/main/Assets/Lua/3DMath.lua"))();

if (not isfolder("Interwebz")) then 
    makefolder("Interwebz"); 
    makefolder("Interwebz/Configs");
end;

local Interface = {
    TransparencyRenderCache = { };
    Windows = { }; 
    ThemeCache = { };
    FrameCache = { };
    Flags = { };
    AllowAnimatedHints = true;
    ConnectionBin = GuiEngine.Bin();
};

Interface.Theme = {
    Button = Color3(67, 48, 104);
    Primary = Color3(47, 32, 74);
    Primary2 = Color3(29, 19, 53);
    Secondary = Color3(36, 24, 59);
    Accent = Color3(243, 91, 59);
    Font = Color3(255, 255, 255);
    Border = Color3(81, 64, 115);
};

Interface.Images = {
    Checkmark = crypt.base64.decode("iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAAAdUlEQVR4nO2TQQ6AIAwE+wo0flGea0RfM4bAgQMSIuViuklvdGC3RcRk6hWwArtMhAeSvDZ8AY4Mv4DN4DIUS9yEOLTOgYbW2VqzbzUyAs8AV1i/S+tq21K7BO1VrEQRPsfS6UT/ExVOzlw6L39x4qbATf/QA+J3Itr5qTUAAAAAAElFTkSuQmCC");
    Saturation = game:HttpGet("https://raw.githubusercontent.com/1e20/ChinaLake/main/Assets/Images/saturation.png");
    Hue = game:HttpGet("https://raw.githubusercontent.com/1e20/ChinaLake/main/Assets/Images/hue.png");
    Alpha = game:HttpGet("https://raw.githubusercontent.com/1e20/ChinaLake/main/Assets/Images/alpha.png");
}; 

function Interface.PipeObjectThemeData(ThemeProperty, Object)
    if (not Interface.Theme[ThemeProperty]) then return; end; 
    Interface.ThemeCache[Object] = ThemeProperty; 
    Object.Color = Interface.Theme[ThemeProperty];
    return Object;
end; 

function Interface.ReloadTheme()
    for c, k in next, Interface.ThemeCache do 
        c.Color = Interface.Theme[k];
    end; 
end; 

function Interface.Unload()
    Interface.ConnectionBin:Clear();
    GuiEngine.Collection:Clear();

    for c, k in next, Interface.Windows do 
        k:Destroy();
    end;

    table.clear(Interface);
end; 

function Interface:SetFlag(Name, Flag)
    self.Flags[Name] = Flag;
end; 

function Interface:Timestamp(File, Content)
    local Timestamp = os.date("[%Y-%m-%d %H:%M:%S]");
    Content = Timestamp .. " L " .. Content .. "\n";

    if (not isfile(File)) then 
        writefile(File, Content);
        return;
    end; 

    appendfile(File, Content);
end;

local NotificationContainer = GuiEngine.Graphics:Create("Square", {
    Visible = true;
    Transparency = 0;
    Filled = true; 
    Size = Camera.ViewportSize;
});

local NotificationLayout = GuiEngine.List(NotificationContainer); 
NotificationLayout.IgnoreUnFilled = true;
NotificationLayout.FillDirection = Enum.FillDirection.Vertical; 
NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Top;
NotificationLayout.Padding = 5;


local ElementSize = 25; 
local ElementPadding = 5; 
local ElementInitialPadding = 10; 

function Interface.new(InterfaceOptions)
    local Menu = { 
        Enabled = true;   
        Elements = { };
        Categories = { };
    }; 

    --#region Main Elements
    Menu.Elements.Background = Interface.PipeObjectThemeData("Primary", GuiEngine.Graphics:Create("Square", {
        Size = Vector2(700, 650);
        Position = Vector2(300, 300);
        Filled = true; 
        Visible = true; 
    }));

    table.insert(Interface.Windows, Menu.Elements.Background);

    Menu.Elements.ContentFrame = Interface.PipeObjectThemeData("Primary2", GuiEngine.Graphics:Create("Square", {
        Parent = Menu.Elements.Background;
        Size = Vector2(Menu.Elements.Background.Size.X - 20, Menu.Elements.Background.Size.Y - 40);
        Position = Vector2(10, 30);
        Filled = true; 
        Visible = true; 
    }));

    Menu.Elements.CategoryHolder = GuiEngine.Graphics:Create("Square", {
        Parent = Menu.Elements.ContentFrame; 
        Size = Vector2(Menu.Elements.ContentFrame.Size.X, 35);
        Filled = true;
        Position = Vector2(0, 0);
        Transparency = 1;
        Visible = true;
    });


    local CategoryLayout = GuiEngine.List(Menu.Elements.CategoryHolder); 
    CategoryLayout.FillDirection = Enum.FillDirection.Horizontal; 
    CategoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; 
    CategoryLayout.VerticalAlignment = Enum.VerticalAlignment.Top;
    CategoryLayout.Padding = 0;


    Menu.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Menu.Elements.Background;
        Position = Vector2(10, 7);
        Size = 17;
        Font = 1;
        Text = (InterfaceOptions.Title or "INTERWEBZ - (DRAWING GuiEngine)");
        Visible = true; 
    }));

    Menu.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Menu.Elements.Background;
        Size = Menu.Elements.Background.Size;
        Position = Vector2(0, 0);
        Thickness = 1;
        Visible = true; 
    }));

    Menu.Elements.ContentFrameOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Menu.Elements.ContentFrame;
        Size = Menu.Elements.ContentFrame.Size;
        Position = Vector2(0, 0);
        Thickness = 1;
        Visible = true; 
    }));

    do 
        local LastClick = nil 
        Menu.Elements.Background.Mouse1Down:Connect(function()
            local Mouse = InputService:GetMouseLocation();
            LastClick = Vector2(Mouse.X, Mouse.Y)
            
            while (InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do 
                Mouse = InputService:GetMouseLocation();   
                local Offset = LastClick - Mouse;
                LastClick = Mouse;
     
                Menu.Elements.Background.Position = Vector2(Menu.Elements.Background.Position.X - Offset.X, Menu.Elements.Background.Position.Y - Offset.Y);
                Sleep();
            end;
            
        end)
    end; 
    --#endregion

    function Menu:SetCategory(Category)
        if (Category.Enabled) then return end;
        for i, c in next, self.Categories do 
            c.Enabled = (c == Category);
            c.Elements.Background:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Color = ((c.Enabled and Interface.Theme.Primary) or (Interface.Theme.Secondary))}):Play();
            c.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = (c.Enabled and 1) or 0.5}):Play();

            for a, b in next, c.SubCategories do 
                b.Elements.Background.Visible = c.Enabled;
                b.Content.Visible = (b.Enabled and c.Enabled);
            end; 

            Interface.ThemeCache[c.Elements.Background] = (c.Enabled and "Primary") or "Secondary";
        end; 
    end; 

    function Menu:Category(CategoryOptions)
        local Category = { 
            Enabled = false; 
            Elements = { };
            SubCategories = { };
        };

        table.insert(Menu.Categories, Category);
 
        --#region Category Elements
        Category.Elements.Background = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
            Parent = Menu.Elements.CategoryHolder; 
            Position = Vector2(0, 0); 
            Filled = true;
            Visible = true; 
        }));

        Category.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
            Parent = Category.Elements.Background;  
            Position = Vector2(0, 0);
            Thickness = 1; 
            Visible = true; 
        }));

        Category.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
            Parent = Category.Elements.Background;  
            Position = Vector2(0, 0);
            Transparency = 0.5;
            Text = (CategoryOptions.Title or "Demo Category");
            Font = 1;
            Size = 17;
            Visible = true; 
        }));

        Category.Elements.SubCategoryHolder = GuiEngine.Graphics:Create("Square", {
            Parent = Menu.Elements.ContentFrame; 
            Size = Vector2(Menu.Elements.ContentFrame.Size.X, 35);
            Position = Vector2(0, Menu.Elements.CategoryHolder.Size.Y);
            Filled = true;
            Transparency = 0;
            Visible = true;
        });

        local SubCategoryLayout = GuiEngine.List(Category.Elements.SubCategoryHolder); 
        SubCategoryLayout.FillDirection = Enum.FillDirection.Horizontal; 
        SubCategoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; 
        SubCategoryLayout.VerticalAlignment = Enum.VerticalAlignment.Top;
        SubCategoryLayout.IgnoreUnfilled = true;
        SubCategoryLayout.Padding = 0;
        --#endregion

        --#region Category Connections
        Category.Elements.Background.MouseEnter:Connect(function()
            Category.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 1}):Play();
        end);

        Category.Elements.Background.MouseLeave:Connect(function()
            if (not Category.Enabled) then 
                Category.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 0.5}):Play();
            end;
        end);

        Category.Elements.Background.Mouse1Click:Connect(function()
            Menu:SetCategory(Category);
        end);
        --#endregion

        --Resize Categories 
        do 
            local Width = math.floor(Menu.Elements.CategoryHolder.Size.X / #Menu.Categories)
            local TotalSize = Menu.Elements.CategoryHolder.Size.X - (Width * #Menu.Categories)

            for i, c in next, Menu.Categories do
                c.Elements.Background.Size = Vector2(Width + (i == #Menu.Categories and TotalSize or 0), Menu.Elements.CategoryHolder.Size.Y);
                c.Elements.BackgroundOutline.Size = c.Elements.Background.Size;
                c.Elements.Title.Position = Vector2((c.Elements.Background.Size.X - c.Elements.Title.TextBounds.X) / 2, (c.Elements.Background.Size.Y - c.Elements.Title.TextBounds.Y) / 2);
            end

            CategoryLayout:Update();
        end; 

        function Category:SetSubCategory(SubCategory)
            --if (SubCategory.Enabled) then return end;
            for i, c in next, self.SubCategories do 
                c.Enabled = (c == SubCategory);
                c.Content.Visible = c.Enabled;
                c.Elements.Background:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Color = ((c.Enabled and Interface.Theme.Primary) or (Interface.Theme.Secondary))}):Play();
                c.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = (c.Enabled and 1) or 0.5}):Play();
                Interface.ThemeCache[c.Elements.Background] = (c.Enabled and "Primary") or "Secondary";
            end; 
        end; 

        function Category:SubCategory(SubCategoryOptions)
            local SubCategory = {
                Enabled = false;  
                Elements = { };
            };

            --#region Elements
            SubCategory.Content = GuiEngine.Graphics:Create("Square", {
                Parent = Menu.Elements.ContentFrame; 
                Size = Vector2(Menu.Elements.ContentFrame.Size.X, Menu.Elements.ContentFrame.Size.Y - (Menu.Elements.CategoryHolder.Size.Y * 2));
                Position = Vector2(0, (Menu.Elements.CategoryHolder.Size.Y * 2));
                Filled = true; 
                Transparency = 0;
                Visible = false;
            });

            SubCategory.Left = GuiEngine.Graphics:Create("Square", {
                Parent = SubCategory.Content; 
                Size = Vector2((Menu.Elements.ContentFrame.Size.X - 30) / 2, Menu.Elements.ContentFrame.Size.Y - (Menu.Elements.CategoryHolder.Size.Y * 2) - 20);
                Position = Vector2(10, 10); 
                Filled = true;
                Transparency = 0;
                Visible = true;
            });

            SubCategory.Right = GuiEngine.Graphics:Create("Square", {
                Parent = SubCategory.Content; 
                Size = Vector2((Menu.Elements.ContentFrame.Size.X - 30) / 2, Menu.Elements.ContentFrame.Size.Y - (Menu.Elements.CategoryHolder.Size.Y * 2) - 20);
                Position = Vector2(SubCategory.Left.Position.X + SubCategory.Left.Size.X + 10, 10); 
                Filled = true;
                Transparency = 0;
                Visible = true;
            });
            --#endregion

            table.insert(self.SubCategories, SubCategory);

            --#region SubCategory Elements
            SubCategory.Elements.Background = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
                Parent = Category.Elements.SubCategoryHolder; 
                Position = Vector2(0, 0); 
                Filled = true;
                Visible = false; 
            }));

            SubCategory.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
                Parent = SubCategory.Elements.Background;  
                Position = Vector2(0, 0);
                Thickness = 1; 
                Visible = true; 
            }));

            SubCategory.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
                Parent = SubCategory.Elements.Background;  
                Position = Vector2(0, 0);
                Transparency = 0.5;
                Text = (SubCategoryOptions.Title or "Demo SubCategory");
                Font = 1;
                Size = 17;
                Visible = true; 
            }));

            local LeftLayout = GuiEngine.List(SubCategory.Left); 
            LeftLayout.FillDirection = Enum.FillDirection.Vertical; 
            LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Top; 
            LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
            LeftLayout.Padding = 5;

            local RightLayout = GuiEngine.List(SubCategory.Right); 
            RightLayout.FillDirection = Enum.FillDirection.Vertical; 
            RightLayout.VerticalAlignment = Enum.VerticalAlignment.Top; 
            RightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
            RightLayout.Padding = 5;
            --#endregion

            --#region SubCategory Connections
            SubCategory.Elements.Background.MouseEnter:Connect(function()
                SubCategory.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 1}):Play();
            end);
    
            SubCategory.Elements.Background.MouseLeave:Connect(function()
                if (not SubCategory.Enabled) then 
                    SubCategory.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 0.5}):Play();
                end;
            end);
    
            SubCategory.Elements.Background.Mouse1Click:Connect(function()
                Category:SetSubCategory(SubCategory);
            end);
            --#endregion

            --Resize SubCategories 
            do 
                local Width = math.floor(Category.Elements.SubCategoryHolder.Size.X / #Category.SubCategories)
                local TotalSize = Category.Elements.SubCategoryHolder.Size.X - (Width * #Category.SubCategories)

                for i, c in next, Category.SubCategories do
                    c.Elements.Background.Size = Vector2(Width + (i == #Category.SubCategories and TotalSize or 0), Category.Elements.SubCategoryHolder.Size.Y);
                    c.Elements.BackgroundOutline.Size = c.Elements.Background.Size;
                    c.Elements.Title.Position = Vector2((c.Elements.Background.Size.X - c.Elements.Title.TextBounds.X) / 2, (c.Elements.Background.Size.Y - c.Elements.Title.TextBounds.Y) / 2);
                end

                SubCategoryLayout:Update();
            end; 

            ---Section 
            ---@param Side (Left, Right);
            ---@param Height (int);
            ---@param Sections ({Title});
            function SubCategory:Section(Side, Height, Sections)
                local Section = {
                    Sections = { };
                    SectionDict = { };
                    Elements = { };
                };

                Height = math.floor((Height + (ElementSize / 2)) / ElementSize) * ElementSize - ElementInitialPadding; 

                Section.Elements.ContentHolder = GuiEngine.Graphics:Create("Square", {
                    Parent = self[Side]; 
                    Position = Vector2(0, 0);
                    Size = Vector2(self[Side].Size.X, Height + 40);
                    Transparency = 0;
                    Filled = true;
                    Visible = true;
                });

                Section.Elements.TabHolder = GuiEngine.Graphics:Create("Square", {
                    Parent = Section.Elements.ContentHolder; 
                    Position = Vector2(0, 0);
                    Size = Vector2(self[Side].Size.X, 25);
                    Transparency = 0;
                    Filled = true;
                    Visible = true;
                });

                local SectionTabLayout = GuiEngine.List(Section.Elements.TabHolder);
                SectionTabLayout.FillDirection = Enum.FillDirection.Horizontal; 
                SectionTabLayout.VerticalAlignment = Enum.VerticalAlignment.Top; 
                SectionTabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
                SectionTabLayout.Padding = 0;

                function Section:SetSection(Section)
                    for i, c in next, self.Sections do 
                        c.Enabled = (c == Section);
                        c.Content.Visible = c.Enabled;
                        c.Elements.Blender.Visible = c.Enabled;
                        c.Elements.Blender.__AbsoluteVisiblity = c.Enabled;
                        c.Content.__AbsoluteVisiblity = c.Enabled;
                        c.Elements.Background:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Color = ((c.Enabled and Interface.Theme.Primary) or (Interface.Theme.Secondary))}):Play();
                        c.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = (c.Enabled and 1) or 0.5}):Play();
                        Interface.ThemeCache[c.Elements.Background] = (c.Enabled and "Primary") or "Secondary";
                    end; 
                end; 

                for i, s in next, Sections do 
                    local __Section = { 
                        Enabled = false; 
                        Elements = { };
                        Items = { };
                        CachedItems = { };
                        ElementSize = ElementSize;
                        ScrollIndex = 1;
                    };

                    __Section.MaxDisplay = math.floor((Height - ((Height / ElementSize) * ElementPadding)- ElementInitialPadding) / ElementSize);
                    
                    --#region Elements
                    __Section.Elements.Background = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
                        Parent = Section.Elements.TabHolder; 
                        Position = Vector2(0, 0);
                        Filled = true;   
                        Visible = true;
                    }));

                    __Section.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
                        Parent = __Section.Elements.Background; 
                        Position = Vector2(0, 0);
                        Thickness = 1;   
                        Visible = true;
                    }));

                    __Section.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
                        Parent = __Section.Elements.Background; 
                        Position = Vector2(0, 0);
                        Text = (s.Title or "Peter"); 
                        Size = 16; 
                        Font = 1; 
                        Transparency = 0.5;
                        Visible = true;
                    }));

                    __Section.Content = Interface.PipeObjectThemeData("Primary", GuiEngine.Graphics:Create("Square", {
                        Parent = Section.Elements.ContentHolder; 
                        Position = Vector2(0, 25);
                        Size = Vector2(self[Side].Size.X, Height + 5);
                        Transparency = 1;
                        Filled = true;
                        Visible = false;
                    }));

                    __Section.Elements.ContentOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
                        Parent = __Section.Content;
                        Position = Vector2(0, 0); 
                        Size = __Section.Content.Size; 
                        Thickness = 1; 
                        Visible = true; 
                    }));

                    __Section.Elements.Blender = Interface.PipeObjectThemeData("Primary", GuiEngine.Graphics:Create("Square", {
                        Parent = __Section.Elements.Background; 
                        Position = Vector2(0, 0);
                        Filled = true; 
                        Thickness = 1;
                        Visible = false;
                    }));

                    __Section.Elements.Layout = GuiEngine.List(__Section.Content); 
                    __Section.Elements.Layout.IgnoreUnFilled = true;
                    __Section.Elements.Layout.FillDirection = Enum.FillDirection.Vertical; 
                    __Section.Elements.Layout.VerticalAlignment = Enum.VerticalAlignment.Top; 
                    __Section.Elements.Layout.InitialPadding = ElementInitialPadding;
                    __Section.Elements.Layout.Padding = ElementPadding;
                    __Section.Elements.Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    --#endregion

                    --#region Section Connections 
                    __Section.Elements.Background.MouseEnter:Connect(function()
                        __Section.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 1}):Play();
                    end);
            
                    __Section.Elements.Background.MouseLeave:Connect(function()
                        if (not __Section.Enabled) then 
                            __Section.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = 0.5}):Play();
                        end;
                    end);
            
                    __Section.Elements.Background.Mouse1Click:Connect(function()
                        Section:SetSection(__Section);
                    end);
                    --#endregion

                    __Section.Elements.ScrollBar = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
                        Parent = __Section.Content;
                        Position = Vector2(0, 0); 
                        Size = Vector2(5, 0); 
                        Filled = true;
                        Visible = false; 
                    }));

                    __Section.Elements.ScrollBar.__Properties.IgnoreList = true;

                    function __Section:Scroll(Z, DontAdd)
                        if ((#__Section.Items <= __Section.MaxDisplay)) then return end;
                        if (not DontAdd) then self.ScrollIndex = self.ScrollIndex + (Z > 0 and -1 or 1); end;
                        if (self.ScrollIndex < 1) then self.ScrollIndex = 1 elseif (self.ScrollIndex > #self.Items - self.MaxDisplay) then self.ScrollIndex = #self.Items - self.MaxDisplay end;
                        
                        local index = 0;
                        for i = 1, #self.Items do 
                            local Child = self.Items[i];

                            if (i < self.ScrollIndex) or (index > self.MaxDisplay) then 
                                Child.Visible = false;
                                Child.__AbsoluteVisiblity = false;
                                Child.__Properties.IgnoreList = true; 
                            else 
                                if (Child.__Properties.IgnoreScroll) then continue end;
                                index = index + 1;
                                if (index == 1) then FirstChild = Child; end;
                                Child.Visible = (Child.__Parent.Visible); 
                                Child.__AbsoluteVisiblity = true;
                                Child.__Properties.IgnoreList = false;
                            end; 
                        end; 

                        local ScrollbarHeight = self.Elements.ScrollBar.Size.Y;
                        local Offset = 5;
                        local ScrollbarPosition = ((self.ScrollIndex) / (#__Section.Items - __Section.MaxDisplay + 1)) * (__Section.Content.Size.Y - ScrollbarHeight - (2 * Offset)) + Offset;
                        self.Elements.ScrollBar:Tween(TweenInfo.new(0.08, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                            Position = Vector2(__Section.Content.Size.X - 10, ScrollbarPosition);
                        }):Play();

                        __Section.Elements.Layout:Update();
                    end; 

                    __Section.Content.ChildAdded:Connect(function(Child)
                        __Section.Items[#__Section.Items + 1] = Child;
                        __Section.Elements.ScrollBar.Visible = (#__Section.Items > __Section.MaxDisplay);
                        __Section.Elements.ScrollBar.__AbsoluteVisiblity = (#__Section.Items > __Section.MaxDisplay);
                        __Section.Elements.ScrollBar.Size = Vector2(5, ((__Section.MaxDisplay / #__Section.Items) * __Section.Content.Size.Y));
                        __Section:Scroll(0, true);
                    end);

                    Interface.ConnectionBin:Add(InputService.InputChanged:Connect(function(Input)
                        if (not GuiEngine.IsMouseOnObject(__Section.Content) or not __Section.Content.Visible) then return end;
                        if (Input.UserInputType == Enum.UserInputType.MouseWheel) then 
                            __Section:Scroll(Input.Position.Z);
                        end; 
                    end));

                    Section.SectionDict[s.Title] = __Section;
                    table.insert(Section.Sections, __Section);
                end; 

                Section:SetSection(Section.Sections[1]);

                --Resize Tabs
                do 
                    local Width = math.floor(Section.Elements.TabHolder.Size.X / #Sections)
                    local TotalSize = (Section.Elements.TabHolder.Size.X - (Width * #Sections))

                    for i, c in next, Section.Sections do
                        c.Elements.Background.Size = Vector2(Width + (i == #Sections and TotalSize or 0), Section.Elements.TabHolder.Size.Y);
                        c.Elements.Blender.Size =  Vector2(c.Elements.Background.Size.X - 2, 2);
                        c.Elements.Blender.Position = Vector2(1, c.Elements.Background.Size.Y - 1);
                        c.Elements.BackgroundOutline.Size = c.Elements.Background.Size;
                        c.Elements.Title.Position = Vector2((c.Elements.Background.Size.X - c.Elements.Title.TextBounds.X) / 2, (c.Elements.Background.Size.Y - c.Elements.Title.TextBounds.Y) / 2);
                    end

                    SectionTabLayout:Update();
                end; 

                setmetatable(Section, {
                    __index = function(self, index)
                        if (self.SectionDict[index]) then 
                            return self.SectionDict[index]; 
                        end; 
                    end; 
                });

                return Section;
            end; 

            if (#self.SubCategories == 1) then 
                Category:SetSubCategory(SubCategory);
            end; 
            return SubCategory;
        end; 

        return Category; 
    end; 

    local ShutteringWindow = false;
    function Menu:Toggle(Value)
        if (ShutteringWindow) then return end;
        Menu.Enabled = (Value ~= nil and Value) or not Menu.Enabled;
        GuiEngine.Graphics.ProcessInput = Menu.Enabled; 

        if (Menu.Enabled) then Menu.Elements.Background.Visible = Menu.Enabled; end;

        ShutteringWindow = true;
        for c, k in next, GuiEngine.Graphics.__RenderCache do 
            if (not k.Visible and k.Transparency > 0) then continue end;

            if (not Menu.Enabled) then
                Interface.TransparencyRenderCache[k] = k.Transparency;
                k:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { Transparency = 0 }):Play();
            else 
                k:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In), { Transparency = Interface.TransparencyRenderCache[k] }):Play();
            end
        end; 

        Sleep(0.3);

        Menu.Elements.Background.Visible = Menu.Enabled;
        ShutteringWindow = false;
    end; 

    return Menu; 
end; 

--@ Graph Class
local Graph = { };
Graph.__index = Graph;

function Graph:Normalise(Coordinate)
    return Vector2(1 / self.x * Coordinate.x * self.Elements.Background.Size.x, 1 / self.y * math.abs(self.y - Coordinate.y) * self.Elements.Background.Size.y);
end; 

function Graph:Denormalise(GuiPosition)
    local x = (GuiPosition.x / self.Elements.Background.Size.x) * self.x;
    local y = self.y - (GuiPosition.y / self.Elements.Background.Size.y) * self.y;

    return Vector2(x, y);
end

function Graph:Clear()
    for _, p in pairs(self.Points) do 
        p.Elements.Background:Destroy();
        p.Elements.Connector:Destroy();
    end;
    
    table.clear(self.Points);
end; 

function Graph:AnchorPoint(Coordinate, Coloroverride)
    local Point = {
        Coordinate = Coordinate; 
        Elements = { };
    };

    Point.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Visible = true;
        Color = Coloroverride or Color3(255, 255, 255);
        Parent = self.Elements.Background;
        Size = Vector2(5, 5); 
        Filled = true;
        ZIndex = 9999999;
        Position = self:Normalise(Coordinate) - Vector2(2.5, 2.5);
    });

    Interface.ConnectionBin:Add(Point.Elements.Background.Mouse1Down:Connect(function()
        local Delta = InputService:GetMouseLocation(); 

        while (InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do 
            local Mouse = InputService:GetMouseLocation(); 
            local Offset = (Mouse - Delta); 
            Delta = Mouse;

            local NewPosition = Point.Elements.Background.Position + Offset;
            local X, Y = self.Elements.Background.Size.x, self.Elements.Background.Size.y;

            NewPosition = Vector2(
                Clamp(NewPosition.x, 0, X - (NewPosition.x > (X / 2) and 5 or 0)),
                Clamp(NewPosition.y, 0, Y - (NewPosition.y > (Y / 2) and 5 or 0))
            );

            Point.Elements.Background.Position = NewPosition;
            self:UpdatePlots();
            task.wait();
        end;

    end));

    Insert(self.AnchorPoints, Point);
    return Point;
end;

function Graph:Plot(Coordinate, Coloroverride)
    local Point = {
        Coordinate = Coordinate; 
        Elements = { };
    };

    Point.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Visible = true;
        Parent = self.Elements.Background;
        Color = Coloroverride or Color3(255, 255, 255);
        Size = Vector2(3, 3); 
        Filled = true;
        ZIndex = 9999999;
        Position = self:Normalise(Coordinate) - Vector2(1.5, 1.5);
    });

    Insert(self.Points, Point);
    return Point;
end;

function Graph:Formulate(v)
    if (not self.Formula) then return v; end;
    local Data = { };

    for c, k in pairs(self.AnchorPoints) do 
        table.insert(Data, self:Denormalise(k.Elements.Background.Position));
    end; 

    table.insert(Data, v);

    return self.Formula(unpack(Data));
end;

function Graph:UpdatePlots()
    local Step = 1 / #self.Points;
    for i = 1, #self.Points do 
        self.Points[i].Elements.Background.Position = self:Normalise(self:Formulate(i * Step));
    end; 
end;

--@ ColorPicker Class
local Colorpicker = { Elements = { } };

function Colorpicker.Color3ToHex(color)
    return Format("%02X%02X%02X", math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255));
end;

function Colorpicker.Mount(ColorpickerData, Position)
    Colorpicker.Current = ColorpickerData; 
    Colorpicker.Color = ColorpickerData.Value;
    Colorpicker.Elements.PickerBackground.Visible = true; 
    Colorpicker.Elements.PickerBackground.Position = Position; 
    ColorpickerData:Set(ColorpickerData.Value);
    return Colorpicker.Elements.PickerBackground;
end;

Colorpicker.Elements.PickerBackground = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
    Size = Vector2(170, 150);
    Position = Position; 
    Filled = true;
    Transparency = 1;
    Visible = false;
    ZIndex = 9999;
}));

Colorpicker.Elements.PickerBackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.PickerBackground; 
    Size = Colorpicker.Elements.PickerBackground.Size;
    Position = Vector2(0, 0); 
    Thickness = 1;
    Transparency = 1;
    Visible = true;
    ZIndex = 9999;
}));

Colorpicker.Elements.PickerHexDisplay = Interface.PipeObjectThemeData("Primary", GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.PickerBackground; 
    Size = Vector2(Colorpicker.Elements.PickerBackground.Size.X - 10, 20);
    Position = Vector2(5, 5); 
    Filled = true;
    Transparency = 1;
    Visible = true;
    ZIndex = 999999;
}));

Colorpicker.Elements.PickerHexDisplayOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.PickerHexDisplay; 
    Size = Colorpicker.Elements.PickerHexDisplay.Size;
    Position = Vector2(0, 0); 
    Thickness = 1;
    Transparency = 1;
    Visible = true;
    ZIndex = 999999;
}));

Colorpicker.Elements.ColorDisplay = GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.PickerHexDisplay; 
    Size = Vector2(10, 10);
    Position = Vector2(Colorpicker.Elements.PickerHexDisplay.Size.X - 15, Colorpicker.Elements.PickerHexDisplay.Size.Y / 2 - 5); 
    Filled = true;
    Transparency = 1;
    Visible = true;
    ZIndex = 9999999;
});

Colorpicker.Elements.ColorDisplayOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.ColorDisplay; 
    Size = Colorpicker.Elements.ColorDisplay.Size;
    Position = Vector2(0, 0); 
    Thickness = 2;
    Visible = true;
    ZIndex = 9999999;
}));

Colorpicker.Elements.ColorText = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
    Parent = Colorpicker.Elements.PickerHexDisplay; 
    Size = 17;
    Position = Vector2(0, 0); 
    Visible = true;
    ZIndex = 9999999;
}));

Colorpicker.Elements.SaturationFrame = GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.PickerBackground; 
    Size = Colorpicker.Elements.PickerBackground.Size - Vector2(35, Colorpicker.Elements.PickerHexDisplay.Size.Y + 15);
    Position = Vector2(6, Colorpicker.Elements.PickerHexDisplay.Size.Y + 10); 
    Color = Color3(255, 0, 0);
    Filled = true; 
    Visible = true;
    ZIndex = 99999;
});

Colorpicker.Elements.SaturationFrameOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.SaturationFrame; 
    Size = Colorpicker.Elements.SaturationFrame.Size;
    Position = Vector2(0, 0); 
    Thickness = 1;
    Visible = true;
    ZIndex = 999999;
}));

Colorpicker.Elements.SaturationImage = GuiEngine.Graphics:Create("Image", {
    Parent = Colorpicker.Elements.SaturationFrame; 
    Size = Colorpicker.Elements.SaturationFrame.Size;
    Position = Vector2(0, 0); 
    Data = Interface.Images.Saturation;
    Visible = true;
    ZIndex = 999999;
});

Colorpicker.Elements.SaturationCursor = GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.SaturationImage;
    Color = Color3(255, 255, 255);
    Position = Vector2(0, 0);
    Size = Vector2(5, 5); 
    Thickness = 1; 
    ZIndex = 999999;
    Visible = true;
});

Colorpicker.Elements.HueImage = GuiEngine.Graphics:Create("Image", {
    Parent = Colorpicker.Elements.PickerBackground; 
    Size = Vector2(10, Colorpicker.Elements.SaturationFrame.Size.Y); 
    Position = Vector2(Colorpicker.Elements.SaturationFrame.Position.X + Colorpicker.Elements.SaturationFrame.Size.X + 2, Colorpicker.Elements.SaturationFrame.Position.Y);
    Data = Interface.Images.Hue;
    Visible = true; 
    ZIndex = 999999;
});

Colorpicker.Elements.HueCursor = GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.HueImage;
    Color = Color3(255, 255, 255);
    Position = Vector2(0, 0);
    Size = Vector2(10, 2); 
    Filled = true;
    ZIndex = 99999999;
    Visible = true;
});

Colorpicker.Elements.Alpha = GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.PickerBackground; 
    Color = Color3(255, 0, 0);
    Size = Vector2(10, Colorpicker.Elements.SaturationFrame.Size.Y); 
    Filled = true;
    Transparency = 1;
    Position = Vector2(Colorpicker.Elements.HueImage.Position.X + Colorpicker.Elements.HueImage.Size.X + 3, Colorpicker.Elements.HueImage.Position.Y);
    Visible = true; 
    ZIndex = 999999;
});

Colorpicker.Elements.AlphaImage = GuiEngine.Graphics:Create("Image", {
    Parent = Colorpicker.Elements.Alpha; 
    Size = Colorpicker.Elements.Alpha.Size;
    Position = Vector2(0, 0);
    Data = Interface.Images.Alpha;
    Visible = true; 
    ZIndex = 9999999;
});

Colorpicker.Elements.AlphaCursor = GuiEngine.Graphics:Create("Square", {
    Parent = Colorpicker.Elements.AlphaImage;
    Color = Color3(0, 0, 0);
    Position = Vector2(0, 0);
    Size = Vector2(10, 2); 
    Filled = true; 
    ZIndex = 9999999;
    Visible = true;
});

Colorpicker.Elements.SaturationImage.Mouse1Down:Connect(function()
    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do Sleep()
        local Mouse = InputService:GetMouseLocation();
        local X = Mouse.X - Colorpicker.Elements.SaturationImage.__AbsolutePosition.X - Colorpicker.Elements.SaturationCursor.Size.X / 2; 
        local Y = Mouse.Y - Colorpicker.Elements.SaturationImage.__AbsolutePosition.Y - Colorpicker.Elements.SaturationCursor.Size.Y / 2; 
        local Offset = Colorpicker.Elements.SaturationCursor.Size.X; 
        
        X = math.clamp(X, 0, Colorpicker.Elements.SaturationImage.Size.X - Offset);
        Y = math.clamp(Y, 0, Colorpicker.Elements.SaturationImage.Size.Y - Offset);
        
        Colorpicker.Elements.SaturationCursor.Position = Vector2(X, Y);

        Colorpicker.Saturation = math.clamp((X - Offset / 2) / (Colorpicker.Elements.SaturationImage.Size.X - Offset), 0, 1);
        Colorpicker.Brightness = 1 - math.clamp((Y - Offset / 2) / (Colorpicker.Elements.SaturationImage.Size.Y - Offset), 0, 1);
        
        Colorpicker.Color = HSV(Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Brightness);
        Colorpicker.Current:Set(Colorpicker.Color, Colorpicker.Transparency);
    end;
end);

Colorpicker.Elements.HueImage.Mouse1Down:Connect(function()
    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do Sleep()
        local Mouse = InputService:GetMouseLocation();
        local Y = Mouse.Y - Colorpicker.Elements.HueImage.__AbsolutePosition.Y - Colorpicker.Elements.HueCursor.Size.Y / 2; 
        local Offset = Colorpicker.Elements.HueCursor.Size.X; 
        
        Y = math.clamp(Y, 0, Colorpicker.Elements.HueImage.Size.Y - Offset);
        Colorpicker.Elements.HueCursor.Position = Vector2(Colorpicker.Elements.HueImage.Size.X / 2 - Colorpicker.Elements.HueCursor.Size.X / 2, Y);
        Colorpicker.Hue = 1 - math.clamp(1 - ((Mouse.y - Colorpicker.Elements.HueImage.__AbsolutePosition.Y) / Colorpicker.Elements.HueImage.Size.Y), 0, 1);

        Colorpicker.Color = HSV(Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Brightness);
        Colorpicker.Current:Set(Colorpicker.Color, Colorpicker.Transparency);
    end
end);

Colorpicker.Elements.AlphaImage.Mouse1Down:Connect(function()
    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do Sleep()
        local Mouse = InputService:GetMouseLocation();
        local Y = Mouse.Y - Colorpicker.Elements.AlphaImage.__AbsolutePosition.Y - Colorpicker.Elements.AlphaCursor.Size.Y / 2; 
        local Offset = Colorpicker.Elements.AlphaCursor.Size.X; 

        Y = math.clamp(Y, 0, Colorpicker.Elements.AlphaImage.Size.Y);
        Colorpicker.Elements.AlphaCursor.Position = Vector2(Colorpicker.Elements.AlphaImage.Size.X / 2 - Colorpicker.Elements.AlphaCursor.Size.X / 2, Y);

        Colorpicker.Transparency = Y / (Colorpicker.Elements.AlphaImage.Size.Y) * 1;
        Colorpicker.Current:Set(Colorpicker.Color, Colorpicker.Transparency);
    end; 
end);    

--// Interface Functions 
function Interface:CreateSaveString(SaveOptions)
    local Save = { };

    for Flag, FlagValue in next, self.Flags do 
        local NewFlag = { 
            Flag = Flag;
            Type = typeof(FlagValue.Value);  
        }; 

        if (NewFlag.Type == "number" or NewFlag.Type == "string") then 
            NewFlag.Value = FlagValue.Value; 
        elseif (NewFlag.Type == "boolean") then 
            NewFlag.Value = FlagValue.Value;
        elseif (NewFlag.Type == "Color3") then 
            NewFlag.Value = HttpService:JSONEncode({R=FlagValue.Value.R, G=FlagValue.Value.G, B=FlagValue.Value.B, A=FlagValue.Transparency});
        elseif (NewFlag.Type == "EnumItem") then
            NewFlag.Value = FlagValue.Value.Name;
        elseif (FlagValue.Type == "table") then 

        end; 

        Insert(Save, NewFlag);        
    end; 

    Save = HttpService:JSONEncode(Save);
    return Save; 
end; 

function Interface:SetSave(String)
    local Save = HttpService:JSONDecode(String); 

    for i, SavedFlag in next, Save do 
        RealFlag = self.Flags[SavedFlag.Flag]; 
        if (not RealFlag) then continue; end;

        if (SavedFlag.Type == "number"or SavedFlag.Type == "string") then 
            RealFlag:Set(SavedFlag.Value); 
        elseif (SavedFlag.Type == "boolean" and RealFlag.Value ~= SavedFlag.Value) then 
            RealFlag:Set(SavedFlag.Value);
        elseif (SavedFlag.Type == "Color3") then 
            local Value = HttpService:JSONDecode(SavedFlag.Value);
            RealFlag:Set(Color3(Value.R*255, Value.G*255, Value.B*255), Value.A)
        elseif (SavedFlag.Type == "EnumItem") then 
            RealFlag:Set(Enum.KeyCode[SavedFlag.Value] or Enum.UserInputType[SavedFlag.Value]);
        end; 
    end; 

    return true; 
end; 


--// Elements
function Interface:Graph(Parent, GraphOptions)
    GraphOptions = GraphOptions or { };
    
    local NewGraph = { 
        PointGrid = { };
        Points = { };
        Formula = GraphOptions.Formula or nil;
        AnchorPoints = { };
        x = GraphOptions.x or 500; 
        y = GraphOptions.y or 500;
        Lines = { };
        Elements = { };
    }; 

    setmetatable(NewGraph, Graph);

    NewGraph.Elements.Background = Interface.PipeObjectThemeData("Primary2", GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2((Parent.Content.Size.X-2) - 30, (GraphOptions.Height or 400));
        ListOffset = Vector2(15, 0);
        Filled = true;
        Visible = true;
    }));

    NewGraph.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = NewGraph.Elements.Background; 
        Size = NewGraph.Elements.Background.Size;
        Filled = false;
        Thickness = 1;
        Visible = true;
    }));

    local GraphSize = GraphOptions.GraphSize or {10, 10};
    local Step = { math.ceil(NewGraph.Elements.Background.Size.x / GraphSize[1]), math.ceil(NewGraph.Elements.Background.Size.y / GraphSize[2]) };

    for y = Step[2], NewGraph.Elements.Background.Size.y, Step[2] do 
        for x = Step[1], NewGraph.Elements.Background.Size.x, Step[1] do  
            NewGraph.PointGrid[x] = y;
        end;
    end; 

    if (not GraphOptions.NoGraphLines) then 
        for y = Step[2], NewGraph.Elements.Background.Size.y, Step[2] do 
            Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Line", {
                Parent = NewGraph.Elements.Background;
                From = Vector2(1, y);
                To = Vector2(NewGraph.Elements.Background.Size.x - 2, y);
                Transparency = 0.5;
                Thickness = 1;
                Visible = true;
            }));
        end;
    
        for x = Step[1], NewGraph.Elements.Background.Size.x, Step[1] do 
            Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Line", {
                Parent = NewGraph.Elements.Background;
                From = Vector2(x, 1);
                To = Vector2(x, NewGraph.Elements.Background.Size.y - 2);
                Transparency = 0.5;
                Thickness = 1;
                Visible = true;
            }));
        end;
    end; 
    
    NewGraph.Elements.XLabel = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = NewGraph.Elements.Background;  
        Size = 14;
        Text = NewGraph.x;
        Position = Vector2(5, 5);
        Font = 1;
        Transparency = 0.3;
        Visible = true;
    }));

    NewGraph.Elements.YLabel = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = NewGraph.Elements.Background;  
        Size = 14;
        Text = NewGraph.y;
        Font = 1;
        Transparency = 0.3;
        Visible = true;
    }));

    NewGraph.Elements.YLabel.Position = NewGraph.Elements.Background.Size - Vector2(NewGraph.Elements.YLabel.TextBounds.x + 5, NewGraph.Elements.YLabel.TextBounds.y + 5);

    Interface.ConnectionBin:Add(NewGraph.Elements.Background.MouseEnter:Connect(function()
        NewGraph.Elements.XLabel:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = .9 }):Play();
        NewGraph.Elements.YLabel:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = .9 }):Play();
    end));

    Interface.ConnectionBin:Add(NewGraph.Elements.Background.MouseLeave:Connect(function()
        NewGraph.Elements.XLabel:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 0.2 }):Play();
        NewGraph.Elements.YLabel:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 0.2 }):Play();
    end));

    return NewGraph;
end;

function Interface:Colorpicker(Parent, ColorpickerOptions, OverrideDontCreateBackground)
    local NewColorpicker = { 
        Value = (ColorpickerOptions.Value or Color3(255, 255, 255));
        Callback = ColorpickerOptions.Callback or function() end;
        Call = GuiEngine.Signal();
        Elements = { };
        Transparency = ColorpickerOptions.Transparency or 0;
    };

    if (ColorpickerOptions.Flag) then self:SetFlag(ColorpickerOptions.Flag, NewColorpicker) end;

    if (not OverrideDontCreateBackground) then 
        NewColorpicker.Elements.Background = GuiEngine.Graphics:Create("Square", {
            Parent = Parent.Content or Parent; 
            Size = Vector2(Parent.Content.Size.X / 2, ElementSize);
            Position = Vector2(0, 0); 
            Filled = true;
            Transparency = 0;
            Visible = true;
        });
    else 
        NewColorpicker.Elements.Background = Parent;
    end; 

    NewColorpicker.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = NewColorpicker.Elements.Background;
        Size = 17;
        Position = Vector2(20, 0);
        Font = 1;
        Text = (ColorpickerOptions.Title or "");
        Visible = true;
    }));

    NewColorpicker.Elements.ColorShower = GuiEngine.Graphics:Create("Square", {
        Parent = NewColorpicker.Elements.Background; 
        Size = Vector2(14, 14);
        Color = NewColorpicker.Value;
        Position = Vector2(15, NewColorpicker.Elements.Background.Size.Y / 2 - 7); 
        Filled = true;
        Transparency = 1 - NewColorpicker.Transparency;
        Visible = true;
    });

    NewColorpicker.Elements.ColorShowerOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = NewColorpicker.Elements.ColorShower; 
        Size = NewColorpicker.Elements.ColorShower.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Visible = true;
    }));

    NewColorpicker.Elements.Title.Position = Vector2(NewColorpicker.Elements.ColorShower.Position.X + NewColorpicker.Elements.ColorShower.Size.X + 10, (NewColorpicker.Elements.Background.Size.Y/2 - NewColorpicker.Elements.Title.TextBounds.Y / 2)); 

    NewColorpicker.Elements.ColorShower.Mouse1Click:Connect(function()
        NewColorpicker.LoadedPicker = Colorpicker.Mount(NewColorpicker, InputService:GetMouseLocation());
    end);

    Interface.ConnectionBin:Add(InputService.InputBegan:Connect(function(Input)
        if (not NewColorpicker.LoadedPicker or NewColorpicker.LoadedPicker.__Destroyed) then return end;
        
        if (Input.UserInputType == Enum.UserInputType.MouseButton1) and not GuiEngine.IsMouseOnObject(NewColorpicker.LoadedPicker) then 
            NewColorpicker.LoadedPicker.Visible = false;
        end; 
    end));

    function NewColorpicker:Set(Color, Transparency)
        NewColorpicker.Value = Color;
        NewColorpicker.Transparency = Transparency or NewColorpicker.Transparency;
        NewColorpicker.Call:Fire(Color, NewColorpicker.Transparency); 
        NewColorpicker.Callback(Color, NewColorpicker.Transparency);
        NewColorpicker.Elements.ColorShower.Color = Color;
        NewColorpicker.Elements.ColorShower.Transparency = 1 - NewColorpicker.Transparency;
        Colorpicker.Elements.ColorDisplay.Color = Color;
        Colorpicker.Elements.Alpha.Color = Color;
        Colorpicker.Elements.SaturationFrame.Color = Color;
        Colorpicker.Elements.ColorDisplay.Transparency = 1 - NewColorpicker.Transparency;
        Colorpicker.Elements.ColorText.Text = Colorpicker.Color3ToHex(NewColorpicker.Value);
        Colorpicker.Elements.ColorText.Position = Vector2(10, Colorpicker.Elements.PickerHexDisplay.Size.Y / 2 - Colorpicker.Elements.ColorText.TextBounds.Y / 2);
    end; 
    
    return NewColorpicker;
end;
 
function Interface:Button(Parent, Buttons)
    local Button = {
        Buttons = { };
        Elements = { };
    };

    local ButtonSize = ((Parent.Content.Size.X - 30) - ((#Buttons - 1) * 10)) / #Buttons;

    Button.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2(Parent.Content.Size.X, ElementSize);
        Position = Vector2(0, 0); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    local ButtonList = GuiEngine.List(Button.Elements.Background); 
    ButtonList.FillDirection = Enum.FillDirection.Horizontal;
    ButtonList.Padding = 10; 

    for i, b in pairs(Buttons) do 
        local NewButton = { 
            Elements = { };
            Callback = b.Callback or function() end; 
            Call = GuiEngine.Signal();
        };

        NewButton.Elements.Button = Interface.PipeObjectThemeData("Button", GuiEngine.Graphics:Create("Square", {
            Parent = Button.Elements.Background; 
            Size = Vector2(ButtonSize, ElementSize);
            ListOffset = Vector2(15, 0);
            Filled = true; 
            Visible = true;
        }));

        NewButton.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
            Parent = NewButton.Elements.Button; 
            Size = 17; 
            Text = b.Title or "Button";
            Transparency = 0.5;
            Visible = true; 
        }));

        NewButton.Elements.Title.Position = (NewButton.Elements.Button.Size - NewButton.Elements.Title.TextBounds) / 2;

        NewButton.Elements.Button.Mouse1Click:Connect(function()
            NewButton.Callback();
            NewButton.Call:Fire();
        end);

        NewButton.Elements.Button.MouseEnter:Connect(function()
            NewButton.Elements.Title:Tween(TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                Transparency = 1; 
            }):Play();
        end);

        NewButton.Elements.Button.MouseLeave:Connect(function()
            NewButton.Elements.Title:Tween(TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                Transparency = 0.5; 
            }):Play();
        end);

        Insert(Button.Buttons, NewButton);
    end; 

    return Button;
end; 

function Interface:Notification(NotificationOptions)
    NotificationOptions = NotificationOptions or { };
    NotificationContainer.Size = Camera.ViewportSize; 

    local Notification = { 
        Time = NotificationOptions.Time or 5; 
        Title = NotificationOptions.Title or "Notification";
        Text = NotificationOptions.Text or "Hello World!";
    };

    local Background = Interface.PipeObjectThemeData("Primary", GuiEngine.Graphics:Create("Square", {
        Parent = NotificationContainer;
        Visible = true;
        ListOffset = Vector2(5, 0);
        Filled = true;
    }));

    local TimeLine = Interface.PipeObjectThemeData("Accent", GuiEngine.Graphics:Create("Square", {
        Visible = true;
        Filled = true; 
        Parent = Background;
    }));

    local BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Visible = true;
        Filled = false;
        Thickness = 1;
        Parent = Background;
    }));

    local Title = Interface.PipeObjectThemeData("Accent", GuiEngine.Graphics:Create("Text", {
        Parent = Background;
        Text = Notification.Title;
        Visible = false;
        Font = 1;
        Transparency = 1;
        Position = Vector2(5, 5);
        Size = 17
    }));

    local Text = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Background;
        Text = Notification.Text;
        Visible = false;
        Font = 1;
        Position = Vector2(5, Title.TextBounds.y + 5);
        Size = 15
    }));

    Background.Size = Vector2(0, (Title.TextBounds.y + Text.TextBounds.y) + 15);
    BackgroundOutline.Size = Background.Size; 
    TimeLine.Position = Vector2(0, Background.Size.y - 2);
    TimeLine.Size = Vector2(0, 2);

    Background:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = Vector2(math.max(Title.TextBounds.x, Text.TextBounds.x) + 10, (Title.TextBounds.y + Text.TextBounds.y) + 15) }):Play();
    local WaitTween = BackgroundOutline:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = Vector2(math.max(Title.TextBounds.x, Text.TextBounds.x) + 10, (Title.TextBounds.y + Text.TextBounds.y) + 15) });
    WaitTween:Play(); 

    WaitTween.Completed:Connect(function()
        Title.Visible = true; 
        Text.Visible = true;
        TimeLine.Size = Vector2(Background.Size.x, 2);

        local ExistTween = TimeLine:Tween(TweenInfo.new(Notification.Time, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = Vector2(0, 2) });
        ExistTween:Play();
    
        ExistTween.Completed:Connect(function()
            Title.Visible = false; 
            Text.Visible = false;
            
            Background:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = Vector2(0, Background.Size.y) }):Play();
            local WaitTween = BackgroundOutline:Tween(TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Size = Vector2(0, Background.Size.y) });
            WaitTween:Play(); 
    
            WaitTween.Completed:Connect(function()
                Background:Destroy();
            end);
        end);
    end);
end;

function Interface:Keybind(Parent, KeybindOptions, OverrideDontCreateBackground)
    local Keybind = {
        Value = KeybindOptions.Value or false; 
        IsReady = false;
        Call = GuiEngine.Signal(); 
        Callback = (KeybindOptions.Callback or function() end);
        Bind = (KeybindOptions.Bind);
        Elements = { };
    };

    if (KeybindOptions.Flag) then self:SetFlag(KeybindOptions.Flag, Keybind) end; 

    if (not OverrideDontCreateBackground) then 
        Keybind.Elements.Background = GuiEngine.Graphics:Create("Square", {
            Parent = Parent.Content; 
            Size = Vector2(Parent.Content.Size.X, ElementSize);
            Position = Vector2(0, 0); 
            Filled = true;
            Transparency = 0;
            Visible = true;
        });
    else 
        Keybind.Elements.Background = Parent;
    end; 

    Keybind.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Keybind.Elements.Background;
        Size = 17;
        Position = Vector2(20, 0);
        Font = 1;
        Text = (KeybindOptions.Title or "");
        Visible = true;
    }));

    Keybind.Elements.Bind = Interface.PipeObjectThemeData("Primary2", GuiEngine.Graphics:Create("Square", {
        Parent = Keybind.Elements.Background; 
        Size = Vector2(25, 17);
        Position = Vector2(15, Keybind.Elements.Background.Size.Y / 2 - (17/2));
        Filled = true; 
        Visible = true;
    }));

    Keybind.Elements.BindOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Keybind.Elements.Bind; 
        Size = Vector2(25, 17);
        Position = Vector2(0, 0);
        Thickness = 1;
        Visible = true;
    }));

    Keybind.Elements.BindTitle  = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Keybind.Elements.Bind;
        Size = 16;
        Position = Vector2(20, 0);
        Font = 1;
        Visible = true;
    }));

    Keybind.Elements.Title.Position = Vector2(Keybind.Elements.Bind.Position.X + Keybind.Elements.Bind.Size.X + 10, (Keybind.Elements.Background.Size.Y/2 - Keybind.Elements.Title.TextBounds.Y/2)); 

    if (not OverrideDontCreateBackground) then 
        Keybind.Elements.Background.Size = Vector2(Keybind.Elements.Bind.Size.X + 10 + Keybind.Elements.Title.TextBounds.X, Keybind.Elements.Background.Size.Y);
    end; 
    
    function Keybind:Set(Bind, NoneText)
        if (type(Bind) == "string") then Bind = Enum.KeyCode[Bind] end;
        Keybind.Bind = Bind; 
        Keybind.Value = Bind;
        Keybind.Elements.BindTitle.Text = (Keybind.Value and Keybind.Value.Name) or (Keybind.Bind and Keybind.Bind.Name) or NoneText;
        Keybind.Elements.Bind.Size = Vector2(Keybind.Elements.BindTitle.TextBounds.X + 10, Keybind.Elements.Bind.Size.Y);

        if (not OverrideDontCreateBackground) then 
            Keybind.Elements.Background.Size = Vector2(Keybind.Elements.Bind.Size.X + 10 + Keybind.Elements.Title.TextBounds.X, Keybind.Elements.Background.Size.Y);
        end;

        Keybind.Elements.BindOutline.Size = Keybind.Elements.Bind.Size;
        Keybind.Elements.BindTitle.Position = Vector2(Keybind.Elements.Bind.Size.X / 2 - Keybind.Elements.BindTitle.TextBounds.X / 2, Keybind.Elements.Bind.Size.Y / 2 - Keybind.Elements.BindTitle.TextBounds.Y / 2);
        Keybind.Elements.Title.Position = Vector2(Keybind.Elements.Bind.Position.X + Keybind.Elements.Bind.Size.X + 10, (Keybind.Elements.Background.Size.Y/2 - Keybind.Elements.Title.TextBounds.Y/2)); 
    end; 

    Interface.ConnectionBin:Add(InputService.InputBegan:Connect(function(Input)
        if (Keybind.IsReady) then 

            if (Input.KeyCode.Name ~= "Unknown") then 
                Keybind:Set(Input.KeyCode); 
            else
                Keybind:Set(Input.UserInputType);
            end; 

            Keybind.IsReady = false;
        else 
            if (Input.KeyCode == Keybind.Value) or (Input.KeyCode == Keybind.Bind) or (Input.UserInputType == Keybind.Bind) then 
                Keybind.Value = not Keybind.Value;
                Keybind.Call:Fire(Keybind.Value); 
                Keybind.Callback(Keybind.Value);
            end; 
        end; 
    end));

    Keybind.Elements.Bind.Mouse1Click:Connect(function()
        Keybind.IsReady = not Keybind.IsReady;

        if (Keybind.IsReady) then 
            Keybind:Set(nil, "...");
        end;
    end);

    Keybind:Set(KeybindOptions.Value, "NONE"); 
    return Keybind;  
end; 

function Interface:Toggle(Parent, ToggleOptions)
    local Toggle = { 
        Value = (ToggleOptions.Value or false);
        InheritanceLock = ToggleOptions.InheritanceLock;
        Callback = ToggleOptions.Callback or function() end;
        Call = GuiEngine.Signal();
        Children = { };
        Elements = { };
    };

    if (ToggleOptions.Flag) then self:SetFlag(ToggleOptions.Flag, Toggle) end;
    if (Toggle.InheritanceLock) then table.insert(Toggle.InheritanceLock.Toggle.Children, Toggle); end;

    Toggle.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2(Parent.Content.Size.X / 2, ElementSize);
        Position = Vector2(0, 0); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    Toggle.Elements.AddOnBackground = GuiEngine.Graphics:Create("Square", {
        Parent = Toggle.Elements.Background; 
        Size = Vector2(Parent.Content.Size.X * 0.3, ElementSize);
        Position = Vector2(Toggle.Elements.Background.Size.X + (Parent.Content.Size.X * 0.3) / 2 - 5, 0); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    Toggle.Elements.Toggle = Interface.PipeObjectThemeData(((Toggle.Value and "Accent")) or "Secondary", GuiEngine.Graphics:Create("Square", {
        Parent = Toggle.Elements.Background; 
        Size = Vector2(17, 17);
        Position = Vector2(15, Toggle.Elements.Background.Size.Y / 2 - (17/2));
        Filled = true; 
        Visible = true;
    }));

    Toggle.Elements.Checkmark = GuiEngine.Graphics:Create("Image", {
        Parent = Toggle.Elements.Toggle; 
        Size = Vector2(17, 17);
        Position = (Toggle.Elements.Toggle.Size / 2 - Toggle.Elements.Toggle.Size / 2);
        Data = Interface.Images.Checkmark;
        Transparency = (Toggle.Value and 1) or 0;
        Visible = true;
    });

    Toggle.Elements.ToggleOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Toggle.Elements.Toggle; 
        Size = Toggle.Elements.Toggle.Size;
        Position = Vector2(0, 0);
        Thickness = 1;
        Visible = true;
    }));

    Toggle.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Toggle.Elements.Background;
        Size = 17;
        Position = Vector2(20, 0);
        Font = 1;
        Text = (ToggleOptions.Title or "Toggle");
        Visible = true;
    }));

    Toggle.Elements.Title.Position = Vector2(Toggle.Elements.Toggle.Position.X + Toggle.Elements.Toggle.Size.X + 10, (Toggle.Elements.Background.Size.Y/2 - Toggle.Elements.Title.TextBounds.Y/2))

    Toggle.Elements.Blackout = GuiEngine.Graphics:Create("Square", {
        Parent = Toggle.Elements.Toggle; 
        Size = Toggle.Elements.Toggle.Size;
        Color = Color3(0, 0, 0);
        Position = Vector2(0, 0);
        Filled = true; 
        Transparency = 0;
        Visible = true;
    });

    local AddOnLayout = GuiEngine.List(Toggle.Elements.AddOnBackground); 
    AddOnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right; 
    AddOnLayout.FillDirection = Enum.FillDirection.Horizontal;
    AddOnLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
    AddOnLayout.Padding = 2;

    function Toggle:Set(Value)
        if (self.InheritanceLock) then
            if (self.InheritanceLock.Toggle.Value and self.InheritanceLock.Lock == self.Value) then
                Toggle.Elements.Blackout:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                    Transparency = (self.InheritanceLock.Toggle.Value and self.InheritanceLock.Lock == self.Value) and 0.3 or 0;
                }):Play();
                return;
            end; 

            Toggle.Elements.Blackout:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                Transparency = (self.InheritanceLock.Toggle.Value and self.InheritanceLock.Lock == Value) and 0.3 or 0;
            }):Play();
        end; 

        Toggle.Value = Value; 
        Toggle.Elements.Toggle:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Color = (Toggle.Value and Interface.Theme.Accent) or Interface.Theme.Secondary}):Play();
        Toggle.Elements.Checkmark:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Transparency = (Toggle.Value and 1) or 0}):Play();
        Toggle.Callback(Value);
        Toggle.Call:Fire(Value);
        Interface.ThemeCache[Toggle.Elements.Toggle] = (Toggle.Value and "Accent") or "Primary";

        for c,k in next, self.Children do 
            k:Set((Value and k.InheritanceLock.Lock) or false);
        end;  
    end; 

    function Toggle:Keybind(IsToggle, KeybindOptions)
        local Bind = Interface:Keybind(Toggle.Elements.AddOnBackground, KeybindOptions, true);
        Bind.Call:Connect(function(Value)
            if (IsToggle) then 
                Toggle:Set(not Toggle.Value);
            end; 
        end);

        Bind.Elements.Bind.Changed:Connect(function(Prop)
            if (Prop == "Size") then 
                AddOnLayout:Update();
            end;
        end);

        AddOnLayout:Update();
        return Bind;
    end; 

    function Toggle:Colorpicker(ColorpickerOptions)
        local Picker = Interface:Colorpicker(Toggle.Elements.AddOnBackground, ColorpickerOptions, true);
        AddOnLayout:Update(); 
        return Picker;
    end; 

    Toggle.Elements.Background.Mouse1Click:Connect(function() Toggle:Set(not Toggle.Value) end);
    Toggle.Elements.Toggle.Mouse1Click:Connect(function() Toggle:Set(not Toggle.Value) end);

    Toggle:Set(Toggle.Value)
    return Toggle;
end;

function Interface:Slider(Parent, SliderOptions)
    local Slider = { 
        Value = (SliderOptions.Value or 1);
        Callback = SliderOptions.Callback or function() end;
        Call = GuiEngine.Signal();
        Data = { 
            Min = (SliderOptions.Min or 0); 
            Max = (SliderOptions.Max or 100); 
            Step = (SliderOptions.Step or 1); 
            Prefix = (SliderOptions.Prefix or "");
        }; 
        Elements = { };
    };

    if (SliderOptions.Flag) then self:SetFlag(SliderOptions.Flag, Slider) end;

    --#region Elements
    Slider.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2(Parent.Content.Size.X - 15, ElementSize);
        Position = Vector2(0, 0); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    Slider.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Slider.Elements.Background; 
        Size = 17; 
        Position = Vector2(15, -3);
        Font = 1; 
        Transparency = 0.7;
        Text = (SliderOptions.Title or "Slider Demo"); 
        Visible = true;
    }));

    Slider.Elements.Empty = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
        Parent = Slider.Elements.Background;
        Size = Vector2(Slider.Elements.Background.Size.X - 20, 10); 
        Position = Vector2(15, 14);
        Filled = true; 
        Visible = true;
    }));

    Slider.Elements.EmptyOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Slider.Elements.Empty;
        Size = Slider.Elements.Empty.Size; 
        Position = Vector2(0, 0);
        Thickness = 1;
        Visible = true;
    }));

    Slider.Elements.Fill = Interface.PipeObjectThemeData("Accent", GuiEngine.Graphics:Create("Square", {
        Parent = Slider.Elements.Empty;
        Size = Slider.Elements.Empty.Size - Vector2(0, 2); 
        Position = Vector2(0, 1);
        Filled = true; 
        Visible = true;
    }));
    
    Slider.Elements.TextValue = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Slider.Elements.Fill; 
        Size = 15; 
        Outline = true;
        Font = 1; 
        Visible = true;
    }));
    --#endregion

    local SliderTween;
    function Slider:Set(Value)
        Value = math.clamp(Value, Slider.Data.Min, Slider.Data.Max);
        Value = ClampDecimal(Value, Slider.Data.Step);
        
        local Suffix = "";
        if (Value < 0) then Suffix = "Neg" end;
        Slider.Value = Value; 
        local fillWidth = math.floor(math.abs(Value - Slider.Data.Min) / math.abs(Slider.Data.Max - Slider.Data.Min) * Slider.Elements.Empty.Size.X)
        Slider.Elements.Fill.Size = Vector2(fillWidth, Slider.Elements.Fill.Size.Y)
        Slider.Elements.TextValue.Text = (Suffix .. Value .. Slider.Data.Prefix);
        Slider.Elements.TextValue.Position = Vector2((Slider.Elements.Fill.Size.X - Slider.Elements.TextValue.TextBounds.X) + 5, 0);

        Slider.Call:Fire(Value); 
        Slider.Callback(Value);
    end; 

    function Slider.Drag()
        while (InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do 
            local Mouse = InputService:GetMouseLocation();
            local X = Mouse.X - Slider.Elements.Empty.__AbsolutePosition.X;

            local Value = (X / Slider.Elements.Empty.Size.X) * (Slider.Data.Max - Slider.Data.Min) + Slider.Data.Min
            Slider:Set(Value)
            Sleep();
        end 
    end; 

    Slider.Elements.Fill.Mouse1Down:Connect(Slider.Drag);
    Slider.Elements.Empty.Mouse1Down:Connect(Slider.Drag);

    Slider.Elements.Background.MouseEnter:Connect(function()
        Slider.Elements.Title:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
            Transparency = 1;
        }):Play();
    end);

    Slider.Elements.Background.MouseLeave:Connect(function()
        Slider.Elements.Title:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
            Transparency = 0.7;
        }):Play();
    end);

    Slider:Set(Slider.Value);
    return Slider;
end; 

function Interface:TextEditor(Parent, Options)
    Options = Options or { }; 
    Options.Text = Options.Text or "Lorem ipsum is placeholder text commonly used in the graphic, print, and publishing industries for previewing layouts and visual mockups.";
    Options.Font = Options.Font or 1; 
    Options.FontSize = Options.FontSize or 14; 

    local Editor = { 
        Memory = { }; 
        Display = { };
        Elements = { };
        IsHovering = false;
        ScrollIndex = 0;
    };

    setmetatable(Editor, TextEditor); 

    --// Parse text data into column 
    local EditorWidth = (Parent.Content.Size.X-2) - 30;
    local TotalSize = CalculateTextBounds(Options.Text, Options.Font, Options.FontSize);
    local TextCharacters = string.split(Options.Text, " ");
    local LastString = "";

    for i, word in pairs(TextCharacters) do 
        local TestString = LastString .. " " .. word;
      
        if (i == #TextCharacters) then 
            Insert(Editor.Memory, TestString);
            continue;
        end; 

        if (CalculateTextBounds(TestString, Options.Font, Options.FontSize).x > EditorWidth) then 
            Insert(Editor.Memory, LastString);
            LastString = word;
            continue; 
        end; 

        LastString = TestString;
    end; 

    Editor.Elements.Background = Interface.PipeObjectThemeData("Primary2", GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Position = Vector2(0, 0);
        Size = Vector2((Parent.Content.Size.X-2) - 30, (Options.Height or 200));
        ListOffset = Vector2(15, 0);
        Filled = true;
        Visible = true;
    }));

    Editor.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Editor.Elements.Background; 
        Size = Editor.Elements.Background.Size;
        Filled = false;
        Visible = true;
    }));

    --// Display Text 
    local LineStep = Editor.Elements.Background.Size.y / 25;
    local Count = 0;

    for i = 0, Editor.Elements.Background.Size.y - 25, 25 do 
        local TextBox = Interface.PipeObjectThemeData("Primary2", GuiEngine.Graphics:Create("Square", {
            Parent = Editor.Elements.Background; 
            Position = Vector2(0, Count * 25);
            Size = Vector2(Editor.Elements.Background.Size.x, 25);
            Filled = true;
            Visible = true;
        }));

        Count = Count + 1;

        local Text = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
            Parent = TextBox; 
            Position = Vector2(5, 0);
            Text = Editor.Memory[Count] or "";
            Font = 1;
            Size = 14;
            Visible = true;
        }));

        table.insert(Editor.Display, Text);

        Text.Position = Vector2(5, (TextBox.Size.y / 2) - (Text.TextBounds.y / 2));
    end; 


    Interface.ConnectionBin:Add(InputService.InputChanged:Connect(function(Input)
        if (not Parent.Content.Visible) then return end;
        
        if (Input.UserInputType == Enum.UserInputType.MouseWheel) then 
            local Z = Input.Position.z; 
            Editor.ScrollIndex = Editor.ScrollIndex + (Z > 0 and -1 or 1);

            local RealIndex = 0;
            for i = Editor.ScrollIndex, Editor.ScrollIndex + LineStep - 1 do 
                RealIndex = RealIndex + 1;

                local Display = Editor.Display[RealIndex]; 
                local Cached = Editor.Memory[i];
                if (not Display) then return end; 

                Display.Text = Cached;
            end; 
        end; 
    end));

    return Editor;
end;

function Interface:Dropdown(Parent, DropdownOptions)
    local Dropdown = { 
        Enabled = false;
        Value = { };
        Options = (DropdownOptions.Options or { });
        Values = { };
        Buttons = { };
        Default = DropdownOptions.Default;
        Callback = DropdownOptions.Callback or function() end;
        Call = GuiEngine.Signal();
        Fill = DropdownOptions.Fill or false;
        Data = { 
            Multi = DropdownOptions.Multi or false;
            MaxDisplay = (DropdownOptions.MaxDisplay or 5);
        }; 
        Elements = { };
    };

    if (DropdownOptions.Flag) then self:SetFlag(DropdownOptions.Flag, Dropdown) end;

    --#region Elements
    Dropdown.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2(Parent.Content.Size.X - 10, ElementSize);
        Position = Vector2(0, 0); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    Dropdown.Elements.Dropdown = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
        Parent = Dropdown.Elements.Background; 
        Size = Vector2((not Dropdown.Fill and math.floor(Parent.Content.Size.X / 2)) or Parent.Content.Size.X - 30, 21);
        Position = Vector2(15, 2); 
        Filled = true;
        Visible = true;
    }));

    Dropdown.Elements.DropdownOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Dropdown.Elements.Dropdown;
        Size = Dropdown.Elements.Dropdown.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Visible = true;
    }));

    Dropdown.Elements.Title = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Dropdown.Elements.Background; 
        Size = 17; 
        Font = 1; 
        Position = Vector2(0, 0);
        Text = (DropdownOptions.Title or "Dropdown Demo"); 
        Visible = true;
    }));
    
    Dropdown.Elements.Holder = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
        Parent = Dropdown.Elements.Dropdown; 
        Size = Vector2(Dropdown.Elements.Dropdown.Size.X, 0);
        Position = Vector2(0, Dropdown.Elements.Dropdown.Size.Y + 1); 
        Filled = true;
        Visible = false;
        ZIndex = 9999999;
    }));

    Dropdown.Elements.HolderOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Dropdown.Elements.Holder;
        Size = Dropdown.Elements.Holder.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Visible = true;
        ZIndex = 9999999;
    }));

    Dropdown.Elements.Title.Position = Vector2(Dropdown.Elements.Dropdown.Position.X + Dropdown.Elements.Dropdown.Size.X + 10, (Dropdown.Elements.Dropdown.Size.Y / 2 - Dropdown.Elements.Title.TextBounds.Y / 2));

    Dropdown.Elements.ValueTitle = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Dropdown.Elements.Dropdown; 
        Size = 17; 
        Font = 1; 
        Position = Vector2(0, 0);
        Visible = true;
        ZIndex = 999999;
    }));

    local DropdownLayout = GuiEngine.List(Dropdown.Elements.Holder); 
    DropdownLayout.IgnoreUnFilled = true;
    DropdownLayout.FillDirection = Enum.FillDirection.Vertical; 
    DropdownLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
    DropdownLayout.VerticalAlignment = Enum.VerticalAlignment.Top;
    DropdownLayout.Padding = 0;

    --#endregion

    function Dropdown.ToggleHolder(Value)
        if (type(Value) == "boolean") then 
            Dropdown.Enabled = Value; 
        else 
            Dropdown.Enabled = not Dropdown.Enabled; 
        end;

        if (Dropdown.Enabled) then 
            Dropdown.Elements.Holder.Visible = Dropdown.Enabled; 
        else 
            for c,k in next, Dropdown.Buttons do 
                k.Elements.Background.Visible = false;
            end; 
        end; 

        local Tween = Dropdown.Elements.Holder:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = Vector2(Dropdown.Elements.Holder.Size.X, (Dropdown.Enabled and 20 * Dropdown.Data.MaxDisplay or 0))});
        Dropdown.Elements.HolderOutline:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Size = Vector2(Dropdown.Elements.Holder.Size.X, (Dropdown.Enabled and 20 * Dropdown.Data.MaxDisplay or 0) + 1)}):Play();
        Tween:Play(); Tween.Completed:Wait();

        Dropdown.Elements.Holder.Visible = Dropdown.Enabled;
        Dropdown.Elements.Holder.__AbsoluteVisiblity = Dropdown.Enabled;
        DropdownLayout:Update();
    end; 

    function Dropdown:Set(Value)
        if (not Value) then return end;

        if (not self.Data.Multi) then 
            table.clear(self.Value);
            table.insert(self.Value, Value);
            Dropdown.Elements.ValueTitle.Text = Value;
        else 
            if (not self.Value[Value]) then
                Dropdown.Elements.ValueTitle.Text = GSub(Dropdown.Elements.ValueTitle.Text, Value .. ", ", "");
                Dropdown.Elements.ValueTitle.Text = GSub(Dropdown.Elements.ValueTitle.Text, (Value .. " "), "")
            else
                Dropdown.Elements.ValueTitle.Text = Dropdown.Elements.ValueTitle.Text .. (Value .. ", ");
            end
        end; 

        Dropdown.Elements.ValueTitle.Position = Vector2(10, Dropdown.Elements.Dropdown.Size.Y / 2 - Dropdown.Elements.ValueTitle.TextBounds.Y / 2);
    end; 

    function Dropdown:NewOption(k)
        if (self.Buttons[(Dropdown.Data.Multi and c) or k]) then return end; 

        local Button = {
            Enabled = (k == Dropdown.Default);
            Elements = { };
            Value = (Dropdown.Data.Multi and c) or k;
        };

        if (Dropdown.Data.Multi) then Button.Enabled = k end;

        Button.Elements.Background = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
            Parent = Dropdown.Elements.Holder; 
            Size = Vector2(Dropdown.Elements.Holder.Size.X - 2, 20); 
            Position = Vector2(0, 0); 
            Visible = true;
            Filled = true;
            ZIndex = 9999999;
        }));

        Button.Elements.Title = Interface.PipeObjectThemeData((Button.Enabled and "Accent") or "Font", GuiEngine.Graphics:Create("Text", {
            Parent = Button.Elements.Background; 
            Size = 17; 
            Text = (Dropdown.Data.Multi and c) or k;
            Visible = true;
            Font = 1;
            ZIndex = 99999999;
        }));

        Button.Elements.Title.Position = Vector2(5, (Button.Elements.Background.Size.Y - Button.Elements.Title.TextBounds.Y) / 2);

        function Button:Set(Value)
            Button.Enabled = Value;
            Button.Elements.Title:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
                Color = (Button.Enabled and Interface.Theme.Accent) or Interface.Theme.Font;
            }):Play();
            Interface.ThemeCache[Button.Elements.Title] = (Button.Enabled and "Accent") or "Font";
        end; 

        Button.Elements.Background.Mouse1Click:Connect(function()
            for c, k in next, Dropdown.Buttons do 
                if (Dropdown.Data.Multi) then 
                    if (k == Button) then 
                        k:Set(not Button.Enabled);
                        Dropdown.Value[Button.Value] = Button.Enabled;
                        Dropdown:Set(Button.Value);
                    end; 
                else
                    k:Set(k == Button);
                    if (k == Button) then 
                        Dropdown:Set(Button.Value);
                    end; 
                end; 
            end; 
        end);

        Button.Elements.Background.MouseEnter:Connect(function()
            Button.Elements.Background.Color = Interface.Theme.Primary;
        end);

        Button.Elements.Background.MouseLeave:Connect(function()
            Button.Elements.Background.Color = Interface.Theme.Secondary;
        end);

        self.Buttons[(Dropdown.Data.Multi and c) or k] = Button;
    end; 

    function Dropdown:DeleteOption(Name)
        self.Buttons[Name].Elements.Background:Destroy();
    end; 
    
    for c, k in next, Dropdown.Options do 
        Dropdown:NewOption(k);
    end;

    Dropdown.Elements.Dropdown.Mouse1Click:Connect(Dropdown.ToggleHolder);

    Interface.ConnectionBin:Add(InputService.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1) and not (GuiEngine.IsMouseOnObject(Dropdown.Elements.Holder) or GuiEngine.IsMouseOnObject(Dropdown.Elements.Dropdown)) then 
            Dropdown.ToggleHolder(false);
        end; 
    end));

    if (Dropdown.Data.Multi) then 
        for c, k in next, Dropdown.Options do 
            Dropdown.Value[c] = k;
            Dropdown:Set(c);
        end; 
    else 
        Dropdown:Set(Dropdown.Default);
    end; 

    return Dropdown;
end; 

function Interface:Textbox(Parent, TextboxOptions)
    local Textbox = {
        Value = (TextboxOptions.Value or ""); 
        Placeholder = (TextboxOptions.Placeholder or '"Text..."');
        Call = GuiEngine.Signal();
        Callback = TextboxOptions.Callback or function() end;
        Typing = false;
        Elements = { };
    };

    Textbox.Elements.Background = GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2(Parent.Content.Size.X / 1.5, ElementSize);
        Position = Vector2(0, 0); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    Textbox.Elements.Textbox = Interface.PipeObjectThemeData("Secondary", GuiEngine.Graphics:Create("Square", {
        Parent = Textbox.Elements.Background; 
        Size = Vector2(Parent.Content.Size.X - 30, ElementSize);
        Position = Vector2(15, 0); 
        Filled = true;
        Transparency = 1;
        Visible = true;
    }));

    Textbox.Elements.TextboxOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Textbox.Elements.Textbox; 
        Size = Textbox.Elements.Textbox.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Visible = true;
    }));

    Textbox.Elements.ValueText = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Textbox.Elements.Textbox;
        Size = 17;
        Position = Vector2(10, 0);
        Font = 1;
        Text = Textbox.Placeholder;
        Visible = true;
    }));

    Textbox.Elements.Blinker = GuiEngine.Graphics:Create("Square", {
        Parent = Textbox.Elements.Textbox; 
        Size = Vector2(1, Textbox.Elements.Textbox.Size.Y - 6);
        Color = Color3(255, 255, 255);
        Position = Vector2(0, 3); 
        Filled = true;
        Transparency = 0;
        Visible = true;
    });

    Textbox.Elements.ValueText.Position = Vector2(10, Textbox.Elements.Textbox.Size.Y / 2 - Textbox.Elements.ValueText.TextBounds.Y / 2);

    function Textbox:Reset()
        Textbox.Call:Fire(Textbox.Elements.ValueText.Text);
        Textbox.Callback(Textbox.Elements.ValueText.Text);
        Textbox.Value = Textbox.Elements.ValueText.Text;
        Textbox.Typing = false;
        Textbox.Elements.ValueText.Text = Textbox.Placeholder; 
        Textbox.Elements.ValueText.Transparency = 0.5;
        Textbox.Elements.Blinker.Transparency = 0;
    end; 

    Interface.ConnectionBin:Add(InputService.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 and not Textbox.Elements.Textbox.__MouseEntered and Textbox.Typing) then 
            Textbox:Reset();
        end; 

        if (#Input.KeyCode.Name == 1 and Textbox.Typing) then 
            Textbox.Elements.ValueText.Text = Textbox.Elements.ValueText.Text .. (InputService:IsKeyDown(Enum.KeyCode.LeftShift) and Input.KeyCode.Name or Input.KeyCode.Name:lower()); 
        elseif (Input.KeyCode.Name == "Space") then 
            Textbox.Elements.ValueText.Text = Textbox.Elements.ValueText.Text .. " "; 
        elseif (Input.KeyCode.Name == "Backspace") then 
            Textbox.Elements.ValueText.Text = Textbox.Elements.ValueText.Text:sub(1, -2);
        elseif (Input.KeyCode.Name == "Return") then 
            Textbox:Reset();
        end; 
    end));   

    Textbox.Elements.Textbox.Mouse1Click:Connect(function()
        Textbox.Typing = true; 
        Textbox.Elements.ValueText.Transparency = 1;
        Textbox.Elements.ValueText.Text = "";
        coroutine.wrap(function()
            local LastBlink = tick();
            while Textbox.Typing do Sleep();
                if (not Textbox.Typing) then continue end; 
                if (tick() - LastBlink > 0.3) then LastBlink = tick(); Textbox.Elements.Blinker.Transparency = (Textbox.Elements.Blinker.Transparency == 1 and 0 or 1); end; 
                Textbox.Elements.Blinker.Position = Vector2(Textbox.Elements.ValueText.Position.X + Textbox.Elements.ValueText.TextBounds.X + 2, Textbox.Elements.Blinker.Position.Y);
            end; 
        end)()
    end);

    Textbox:Reset();
    return Textbox;
end; 

function Interface:Viewport(Parent, ViewportOptions)
    local Viewport = { 
        ViewCamera = ProjectionEngine.Camera.new({0, 0}, 60);
        IdleRotate = ViewportOptions.IdleRotate or false;
        RenderCallback = ViewportOptions.RenderCallback or function() end;
        Objects = { ProjectionEngine.Object.new(); };
        RenderVerticies = false;
        Elements = { };
    }; 

    Viewport.Elements.Background = Interface.PipeObjectThemeData("Primary2", GuiEngine.Graphics:Create("Square", {
        Parent = Parent.Content; 
        Size = Vector2((Parent.Content.Size.X-2) - 30, (ViewportOptions.Height or 400));
        ListOffset = Vector2(15, 0);
        Filled = true;
        Visible = true;
    }));

    Viewport.Elements.BackgroundOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Viewport.Elements.Background; 
        Size = Viewport.Elements.Background.Size;
        Filled = false;
        Thickness = 1;
        Visible = true;
    }));

    Viewport.Elements.VerticiesToggle = Interface.PipeObjectThemeData("Primary", GuiEngine.Graphics:Create("Square", {
        Parent = Viewport.Elements.Background; 
        Size = Vector2(14, 14);
        Position = Vector2(10, 10);
        Transparency = 0.5;
        Filled = true;
        Visible = true;
    }));

    Viewport.Elements.VerticiesToggleLabel = Interface.PipeObjectThemeData("Font", GuiEngine.Graphics:Create("Text", {
        Parent = Viewport.Elements.VerticiesToggle;
        Size = 13;
        Transparency = 0.5;
        Text = "V";
        Visible = true;
    }));

    Viewport.Elements.VerticiesToggleLabel.Position = Vector2(Viewport.Elements.VerticiesToggle.Size.x / 2 - Viewport.Elements.VerticiesToggleLabel.TextBounds.x / 2, Viewport.Elements.VerticiesToggle.Size.y / 2 - Viewport.Elements.VerticiesToggleLabel.TextBounds.y / 2);

    Viewport.Elements.VerticiesToggleOutline = Interface.PipeObjectThemeData("Border", GuiEngine.Graphics:Create("Square", {
        Parent = Viewport.Elements.VerticiesToggle; 
        Size = Viewport.Elements.VerticiesToggle.Size;
        Transparency = 0.5;
        Thickness = 1;
        Visible = true;
    }));

    local VerticiesColorpicker = Interface:Colorpicker(Viewport.Elements.Background, { Value = Color3(255, 150, 0) }, true);
    VerticiesColorpicker.Elements.ColorShower.Transparency = 0.5;
    VerticiesColorpicker.Elements.ColorShower.Position = Viewport.Elements.VerticiesToggle.Position + Vector2(0, Viewport.Elements.VerticiesToggle.Size.y + 10);

    local FacesColorpicker = Interface:Colorpicker(Viewport.Elements.Background, { Value = Color3(255, 255, 255); Transparency = 0.7 }, true);
    FacesColorpicker.Elements.ColorShower.Transparency = 0.5;
    FacesColorpicker.Elements.ColorShower.Position = VerticiesColorpicker.Elements.ColorShower.Position + Vector2(0, VerticiesColorpicker.Elements.ColorShower.Size.y + 10);
    
    Viewport.ViewCamera:SetResolution({Viewport.Elements.Background.Size.x, Viewport.Elements.Background.Size.y});
    Viewport.ViewCamera.Position = ProjectionEngine.Vector3(0, 10, -30);

    Interface.ConnectionBin:Add(Viewport.Elements.Background.MouseEnter:Connect(function()
        Viewport.Elements.VerticiesToggle:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 1 }):Play();
        Viewport.Elements.VerticiesToggleLabel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 1 }):Play();
        VerticiesColorpicker.Elements.ColorShower:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 1 }):Play();
        FacesColorpicker.Elements.ColorShower:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 1 }):Play();
    end));

    Interface.ConnectionBin:Add(Viewport.Elements.Background.MouseLeave:Connect(function()
        Viewport.Elements.VerticiesToggle:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 0.5 }):Play();
        Viewport.Elements.VerticiesToggleLabel:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 0.5 }):Play();
        VerticiesColorpicker.Elements.ColorShower:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 0.5 }):Play();
        FacesColorpicker.Elements.ColorShower:Tween(TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Transparency = 0.5 }):Play();
    end));

    Interface.ConnectionBin:Add(InputService.InputBegan:Connect(function(Input)
        if (not GuiEngine.IsMouseOnObject(Viewport.Elements.Background) or not Viewport.Elements.Background.Visible or GuiEngine.IsMouseOnHigherZIndexThan(Viewport.Elements.Background)) then return end;

        if (Input.UserInputType == Enum.UserInputType.MouseButton1) then 
            local Delta = InputService:GetMouseLocation(); 
            local LastInputTime = tick();

            while (InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do 
                local Mouse = InputService:GetMouseLocation(); 
                local Offset = (Mouse - Delta) / 5; 
                Delta = Mouse;

                local DeltaTime = tick() - LastInputTime;
                LastInputTime = tick();
            
                Viewport.ViewCamera.Yaw = Viewport.ViewCamera.Yaw + (-Offset.x * DeltaTime);
                Viewport.ViewCamera.Pitch = Viewport.ViewCamera.Pitch + Offset.y * DeltaTime;
                task.wait();
            end;
        end; 
    end));

    Interface.ConnectionBin:Add(Viewport.Elements.VerticiesToggle.Mouse1Click:Connect(function()
        Viewport.RenderVerticies = not Viewport.RenderVerticies;
        Viewport.Elements.VerticiesToggle:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
            Color = (Viewport.RenderVerticies and Interface.Theme.Accent or Interface.Theme.Primary);
        }):Play();
    end));

    Interface.ConnectionBin:Add(InputService.InputChanged:Connect(function(Input)
        if (not GuiEngine.IsMouseOnObject(Viewport.Elements.Background) or not Viewport.Elements.Background.Visible or GuiEngine.IsMouseOnHigherZIndexThan(Viewport.Elements.Background)) then return end;
        if (Input.UserInputType == Enum.UserInputType.MouseWheel) then 
            if (Input.Position.Z > 0) then 
                Viewport.ViewCamera.Position = Viewport.ViewCamera.Position + Viewport.ViewCamera.Forward * 0.5;
            else 
                Viewport.ViewCamera.Position = Viewport.ViewCamera.Position - Viewport.ViewCamera.Forward * 0.5;
            end; 
        end; 
    end));

    local Vertexes, Faces;
    if (ViewportOptions.Data) then 
        Vertexes, Faces = ProjectionEngine.Object.ParseObjectData(ViewportOptions.Data);
    end; 

    for _, Object in pairs(Viewport.Objects) do
        Object.Position = ProjectionEngine.Vector3(0, 5, 0);
        Object.Rotation = ProjectionEngine.Vector3(math.rad(90), 0, 0);
        if (ViewportOptions.Data) then 
            Object.Vertexes = Vertexes; 
            Object.Faces = Faces;
        end;
    end; 

    local LastFrameUpdate = tick();
    local GridSize = 150;
    local GridStep = 10;
    GuiEngine.Graphics.OnPaint:Connect(function() 
        if (not Viewport.Elements.Background.Visible) then return; end;
        local DeltaTime = tick() - LastFrameUpdate; 
        LastFrameUpdate = tick(); 
    
        -- for z = -GridSize, GridSize, GridStep do
        --     local From = Viewport.ViewCamera:WorldToScreenPoint(ProjectionEngine.Vector3(-GridSize, 0, z));
        --     local To = Viewport.ViewCamera:WorldToScreenPoint(ProjectionEngine.Vector3(GridSize, 0, z));
        --     if (not From or not To) then continue; end;

        --     local Min = Vector2(Viewport.Elements.Background.__AbsolutePosition.x, Viewport.Elements.Background.__AbsolutePosition.y);
        --     local Max = Vector2(Viewport.Elements.Background.__AbsolutePosition.x + Viewport.Elements.Background.Size.x, Viewport.Elements.Background.__AbsolutePosition.y + Viewport.Elements.Background.Size.y);
        --     From = Viewport.Elements.Background.__AbsolutePosition + Vector2(From.x, From.y);
        --     To = Viewport.Elements.Background.__AbsolutePosition + Vector2(To.x, To.y);

        --     GuiEngine.Graphics.ImmediateDraw("Line", {
        --         From = Vector2(Clamp(From.x, Min.x, Max.x), Clamp(From.y, Min.y, Max.y));
        --         To = Vector2(Clamp(To.x, Min.x, Max.x), Clamp(To.y, Min.y, Max.y));
        --         Transparency = 0.3; 
        --         Color = Interface.Theme.Border;
        --     });
        -- end;

        for _, Object in pairs(Viewport.Objects) do 
            Object.Rotation = Object.Rotation + ProjectionEngine.Vector3(0, math.rad(20 * DeltaTime), 0);
            local Vertexes, Faces = Object:Project(Viewport.ViewCamera);

            for _, face in pairs(Faces) do
                local polygon = { };

                for _, vertexIndex in pairs(face) do 
                    local Vertex = Vertexes[vertexIndex]; 
                    if (not Vertex) then continue; end; 
                    Vertex = Vertex + Viewport.Elements.Background.__AbsolutePosition;
                    table.insert(polygon, Vertex);
                end;

                GuiEngine.Graphics.ImmediateDrawPolygon(polygon, {
                    Visible = true; 
                    Color = FacesColorpicker.Value;
                    Thickness = 1;
                    Transparency = 1 - FacesColorpicker.Transparency;
                    Filled = true;
                }, {
                    Min = Vector2(Viewport.Elements.Background.__AbsolutePosition.x, Viewport.Elements.Background.__AbsolutePosition.y);
                    Max = Vector2(Viewport.Elements.Background.__AbsolutePosition.x + Viewport.Elements.Background.Size.x, Viewport.Elements.Background.__AbsolutePosition.y + Viewport.Elements.Background.Size.y);
                });
            end;

            if (Viewport.RenderVerticies) then 
                for _, vertex in pairs(Vertexes) do 
                    vertex = vertex + Viewport.Elements.Background.__AbsolutePosition;
                    if (vertex.x < Viewport.Elements.Background.__AbsolutePosition.x or vertex.x > Viewport.Elements.Background.__AbsolutePosition.x + Viewport.Elements.Background.Size.x) then continue end;
                    if (vertex.y < Viewport.Elements.Background.__AbsolutePosition.y or vertex.y > Viewport.Elements.Background.__AbsolutePosition.y + Viewport.Elements.Background.Size.y) then continue end;

                    GuiEngine.Graphics.ImmediateDraw("Square", {
                        Visible = true; 
                        Position = Vector2(vertex.x - 2, vertex.y - 2);
                        Size = Vector2(4, 4); 
                        Transparency = 1 - VerticiesColorpicker.Transparency;
                        Color = VerticiesColorpicker.Value; 
                        Filled = true;
                    });
                end; 
            end;

            Viewport.RenderCallback(Object, Vertexes, Faces);
        end;
    end);

    function Viewport.ImmediateDraw(Class, Properties)
        GuiEngine.Graphics.ImmediateDraw(Class, Properties);
    end; 

    return Viewport; 
end; 

local CursorOutline = Draw("Triangle"); 
CursorOutline.Visible = true;  
CursorOutline.Filled = false; 
CursorOutline.Color = Color3(0, 0, 0)
CursorOutline.Thickness = 2;
CursorOutline.ZIndex = 2000000000;

local Cursor = Draw("Triangle"); 
Cursor.Visible = true; 
Cursor.Color = Color3(255, 255, 255); 
Cursor.Filled = true; 
Cursor.ZIndex = 2000000000;

InputService.InputChanged:Connect(function(Input)
    if (Input.UserInputType == Enum.UserInputType.MouseMovement) then 
        local Mouse = InputService:GetMouseLocation();
        Cursor.PointA = Mouse; 
        Cursor.PointB = Vector2(Mouse.x + 10, Mouse.y + 5); 
        Cursor.PointC = Vector2(Mouse.x, Mouse.y + 10);
        CursorOutline.PointA = Cursor.PointA; 
        CursorOutline.PointB = Cursor.PointB; 
        CursorOutline.PointC = Cursor.PointC;
    end; 
end);






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

Menu:SetCategory(MenuTab);

return Interface;
