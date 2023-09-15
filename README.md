
# China Lake Interface Documentation 

## Setup 
```
local ChinaLake = loadstring("http://")();
local Menu = ChinaLake.new{ Title  =  "ChinaLake" };
```

## Categories, Sub-Categories and Sections
```
--@ Options { Title = <string> }
local Category = Menu:Category{ Title = "Example" }
local SubCategory = Category:SubCategory{ Title = "Example" }

--@ Side ["Left", "Right"]
--@ Height <int> 
--@ Options { 
	{Title = <string> } 
}
local Section = MenuOptions:Section("Left", 400, { 
	{Title = "One"};
	{Title = "Two"};
	{Title = "Wow"};
});
```

## Toggles
```
--@ Section Parent
--@ Options { 
	Title = <string>, 
	InheritanceLock = { 
		Toggle = <ParentToggle> 
		Lock = <bool>
	} 
}
local Toggle = ChinaLake:Toggle(Section.One, {
	Title = "Toggle Demo"; 
});

--// Example InheritanceLock
local Parent = ChinaLake:Toggle(Section.One, {
	Title = "Inheritance Lock";
});

local Child = ChinaLake:Toggle(Section.One, {
	Title = "Child Lock";
	InheritanceLock = {
		Toggle = Parent; 
		Lock = false; 
	};
});
```

##
