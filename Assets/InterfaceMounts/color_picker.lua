return function(Interface, GUI_ENGINE)
    local InputService = game:GetService("UserInputService");

    local function Vector2(x, y) 
        return __Vector2(Floor(x), Floor(y));
    end; 

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
    
    Colorpicker.Elements.PickerBackground = Interface.PipeObjectThemeData("Secondary", GUI_ENGINE.Graphics:Create("Square", {
        Size = Vector2(170, 150);
        Position = Position; 
        Filled = true;
        Transparency = 1;
        Visible = false;
        ZIndex = 9999;
    }));
    
    Colorpicker.Elements.PickerBackgroundOutline = Interface.PipeObjectThemeData("Border", GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.PickerBackground; 
        Size = Colorpicker.Elements.PickerBackground.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Transparency = 1;
        Visible = true;
        ZIndex = 9999;
    }));
    
    Colorpicker.Elements.PickerHexDisplay = Interface.PipeObjectThemeData("Primary", GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.PickerBackground; 
        Size = Vector2(Colorpicker.Elements.PickerBackground.Size.X - 10, 20);
        Position = Vector2(5, 5); 
        Filled = true;
        Transparency = 1;
        Visible = true;
        ZIndex = 999999;
    }));
    
    Colorpicker.Elements.PickerHexDisplayOutline = Interface.PipeObjectThemeData("Border", GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.PickerHexDisplay; 
        Size = Colorpicker.Elements.PickerHexDisplay.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Transparency = 1;
        Visible = true;
        ZIndex = 999999;
    }));
    
    Colorpicker.Elements.ColorDisplay = GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.PickerHexDisplay; 
        Size = Vector2(10, 10);
        Position = Vector2(Colorpicker.Elements.PickerHexDisplay.Size.X - 15, Colorpicker.Elements.PickerHexDisplay.Size.Y / 2 - 5); 
        Filled = true;
        Transparency = 1;
        Visible = true;
        ZIndex = 9999999;
    });
    
    Colorpicker.Elements.ColorDisplayOutline = Interface.PipeObjectThemeData("Border", GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.ColorDisplay; 
        Size = Colorpicker.Elements.ColorDisplay.Size;
        Position = Vector2(0, 0); 
        Thickness = 2;
        Visible = true;
        ZIndex = 9999999;
    }));
    
    Colorpicker.Elements.ColorText = Interface.PipeObjectThemeData("Font", GUI_ENGINE.Graphics:Create("Text", {
        Parent = Colorpicker.Elements.PickerHexDisplay; 
        Size = 17;
        Position = Vector2(0, 0); 
        Visible = true;
        ZIndex = 9999999;
    }));
    
    Colorpicker.Elements.SaturationFrame = GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.PickerBackground; 
        Size = Colorpicker.Elements.PickerBackground.Size - Vector2(35, Colorpicker.Elements.PickerHexDisplay.Size.Y + 15);
        Position = Vector2(6, Colorpicker.Elements.PickerHexDisplay.Size.Y + 10); 
        Color = Colof3.fromRGB(255, 0, 0);
        Filled = true; 
        Visible = true;
        ZIndex = 99999;
    });
    
    Colorpicker.Elements.SaturationFrameOutline = Interface.PipeObjectThemeData("Border", GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.SaturationFrame; 
        Size = Colorpicker.Elements.SaturationFrame.Size;
        Position = Vector2(0, 0); 
        Thickness = 1;
        Visible = true;
        ZIndex = 999999;
    }));
    
    Colorpicker.Elements.SaturationImage = GUI_ENGINE.Graphics:Create("Image", {
        Parent = Colorpicker.Elements.SaturationFrame; 
        Size = Colorpicker.Elements.SaturationFrame.Size;
        Position = Vector2(0, 0); 
        Data = Interface.Images.Saturation;
        Visible = true;
        ZIndex = 999999;
    });
    
    Colorpicker.Elements.SaturationCursor = GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.SaturationImage;
        Color = Colof3.fromRGB(255, 255, 255);
        Position = Vector2(0, 0);
        Size = Vector2(5, 5); 
        Thickness = 1; 
        ZIndex = 999999;
        Visible = true;
    });
    
    Colorpicker.Elements.HueImage = GUI_ENGINE.Graphics:Create("Image", {
        Parent = Colorpicker.Elements.PickerBackground; 
        Size = Vector2(10, Colorpicker.Elements.SaturationFrame.Size.Y); 
        Position = Vector2(Colorpicker.Elements.SaturationFrame.Position.X + Colorpicker.Elements.SaturationFrame.Size.X + 2, Colorpicker.Elements.SaturationFrame.Position.Y);
        Data = Interface.Images.Hue;
        Visible = true; 
        ZIndex = 999999;
    });
    
    Colorpicker.Elements.HueCursor = GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.HueImage;
        Color = Colof3.fromRGB(255, 255, 255);
        Position = Vector2(0, 0);
        Size = Vector2(10, 2); 
        Filled = true;
        ZIndex = 99999999;
        Visible = true;
    });
    
    Colorpicker.Elements.Alpha = GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.PickerBackground; 
        Color = Colof3.fromRGB(255, 0, 0);
        Size = Vector2(10, Colorpicker.Elements.SaturationFrame.Size.Y); 
        Filled = true;
        Transparency = 1;
        Position = Vector2(Colorpicker.Elements.HueImage.Position.X + Colorpicker.Elements.HueImage.Size.X + 3, Colorpicker.Elements.HueImage.Position.Y);
        Visible = true; 
        ZIndex = 999999;
    });
    
    Colorpicker.Elements.AlphaImage = GUI_ENGINE.Graphics:Create("Image", {
        Parent = Colorpicker.Elements.Alpha; 
        Size = Colorpicker.Elements.Alpha.Size;
        Position = Vector2(0, 0);
        Data = Interface.Images.Alpha;
        Visible = true; 
        ZIndex = 9999999;
    });
    
    Colorpicker.Elements.AlphaCursor = GUI_ENGINE.Graphics:Create("Square", {
        Parent = Colorpicker.Elements.AlphaImage;
        Color = Colof3.fromRGB(0, 0, 0);
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

    return Colorpicker;
end; 
