if not init then
   init = true
   headertext = 'HUB HUB'
   LastInput = ""
   Tick = 0
   
   -- Obejcts 
   Mouse = nil
   Screen = nil
   Items = {}
   ItemIndexAsync = 1
   SelectedItemIndex = nil
   CurrentImage = nil
   MaxItems = 20
   InfoColumnWidthPadding = 87
   ItemsCount = 0
   CurrentPage = nil
   TotalPages = nil
   

    -- Functions
    function Ternary(condition,x,y) if condition then return x else return y end end
    function ToVec4(a,b,c,d) return {x = a, y = b, z = c, r = d} end
    function ToColor(w,x,y,z) return {r = w, g = x, b = y, o = z} end
    
    function Split(s, delimiter)
        result = {};
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match);
        end
        return result;
    end
    
    function DisplayText(layer, fnt, text, x, y, alignH, alignV, color)
        setNextFillColor(layer, color.r, color.g, color.b, color.o)
        setNextTextAlign(layer, alignH, alignV)
        --logMessage(text..'|'..x)
        addText(layer, fnt, text, x, y)
    end
    
    function DisplayBox(layer, x, y, w, h, fill, shadow, blur, round, stroke, strokeWidth)
        if stroke ~= nil then setNextStrokeColor(layer, stroke.r, stroke.g, stroke.b, stroke.o) end
        if strokeWidth ~= nil then setNextStrokeWidth(layer, strokeWidth) end
        if shadow ~= nil then setNextShadow(layer, blur, shadow.r, shadow.g, shadow.b, shadow.o) end
        if fill ~= nil then setNextFillColor(layer, fill.r, fill.g, fill.b, fill.o) end
        if round ~= nil then addBoxRounded(layer, x, y, w, h, round) else addBox(layer, x, y, w, h) end
    end
    
    function NewItem(i)
        t = {}
        t.Id = i[2]
        t.Quantity = i[3]
        t.Name = i[4]
        t.Icon = i[5]
        t.Description = i[6]
        t.Type = i[7]
        t.UnitMass = i[8]
        t.UnitVolume = i[9]
        t.Tier = i[10]
        return t
    end
    
    function AddItem(i) 
        table.insert(Items, 1, i)
        
        if Items[MaxItems+1] ~= nil then
           table.remove(Items, MaxItems+1)
        end
    end
    
    function GetMouse()
        local mx, my = getCursor()
        Mouse = {x = mx, y = my, Down = getCursorDown(), Release = getCursorReleased()}
    end
    
    function GetScreen()
        local s = {}
        local x, y = getResolution()
        s.Width = x
        s.Height = y
        s.HalfWidth = math.floor(x/2)
        s.HalfHeight = math.floor(y/2)
        s.ThirdWidth = math.floor(x/3)
        s.ThirdHeight = math.floor(y/3)
        s.HeaderWidth = 1050
        s.HeaderHeight = 52
        s.InfoWidth = math.floor(math.floor(x*0.38)*0.62)
        s.InfoHeight = y
        s.HalfInfoWidth = math.floor(math.floor(math.floor(x*0.38)*0.62)/2)
        s.HalfInfoHeight = math.floor(y/2)
        s.ContentWidth = x - math.floor(math.floor(x*0.38)*0.62)
        s.ContentHeight = y
        s.HalfContentWidth = math.floor((x - math.floor(math.floor(x*0.38)*0.62))/2)
        s.HalfContentHeight = math.floor(y/2)
        Screen = s
    end
    
    function CreateButton(i, layer, font, name, x, tx, y, mx, my, r, tc)
        local click = false
        local btnHeight = 25
        if r and mx > x and mx < x + tx and my > y and my < y + btnHeight then click = true end
        
        if tc == nil then
           tc = ToColor(0.8, 0.8, 0.8, 1)
        end
        
        if click then
           SelectedItemIndex = Ternary(ItemsCount < i, nil, i)
        end
        
        DisplayBox(layer, x, y, tx, btnHeight, Ternary(SelectedItemIndex == i,ToColor(0.15, 0.15, 0.15, 1),ToColor(0.25, 0.25, 0.25, 1)), Ternary(SelectedItemIndex == i,ToColor(0.8, 0.8, 0.8, 1),ToColor(0, 0, 0, 1)), 2, nil, nil, nil)
        DisplayText(layer, font, name, x + 5, y + (btnHeight/2), AlignH_Left, AlignV_Middle, Ternary(SelectedItemIndex == i, ToColor(0.8, 0.8, 0.2, 1), tc))
        return click
    end
    
    function HandleInput()
        local inputstring = getInput()
        
        local input = nil
        if (inputstring ~= "" and LastInput ~= inputstring) then 
           input = Split(inputstring, "~")
        end
        
        if input ~= nil then
           ProcessInput(input)
        end
        ItemsCount = tablelength(Items)
        
        LastInput = inputstring
    end
    
    function ProcessInput(i) 
        if i[1] == 'I' then 
           AddItem(NewItem(i))
        elseif i[1] == 'P' then
           AddPagination(i)
        end 
    end
    
    function AddPagination(i)
       TotalPages = i[2]
       CurrentPage = i[3]
    end
    
    function DisplayTextArea(layer, text, x, y, width, maxlength, font, alignH, alignV)
        local length = text:len()
        
        if alignH == nil then alignH = AlignH_Left end
        if alignV == nil then alignV = AlignV_Middle end
        
        for i = 1, math.ceil(length/maxlength)+1, 1 do
           local startindex = (i-1)*maxlength + 1
           local endindex = i*maxlength
           local subtext = string.sub(text, startindex, Ternary(endindex <= length, endindex, length))
           DisplayText(layer, font, subtext, x, y + (20*i), alignH, alignV, ToColor(.8, .8, .8, 1))
        end
    end
    
    function tablelength(T)
      local count = 0
      for _ in pairs(T) do count = count + 1 end
      return count
    end
    
    function BuildPagination(layer,font,x,y)
       local xoffset = 115
       local yoffset = 0
       local xspace = 25
       local yspace = 12
       local leftclick = false
       local rightclick = false
        
       if CurrentPage ~= nil then
            
          if Mouse.Release and Mouse.x > (x - xoffset) and Mouse.x < (x - xoffset) + xspace and Mouse.y > y - yspace and Mouse.y < y + yspace then leftclick = true end
          if Mouse.Release and Mouse.x < (x + xoffset) and Mouse.x > (x + xoffset) - xspace and Mouse.y > y - yspace and Mouse.y < y + yspace then rightclick = true end
            
          if leftclick then
             setOutput('PREVPAGE')   
          end
            
          if rightclick then
             setOutput('NEXTPAGE')
          end
            
          DisplayText(layer, font, " Page "..CurrentPage.." of "..TotalPages, x, y, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
          setNextFillColor(layer, 0.8, 0.8, 0.2, 1)
          addTriangle(layer, (x - xoffset), (y + yoffset), (x - xoffset) + xspace, (y + yoffset) - yspace, (x - xoffset) + xspace, (y + yoffset) + yspace)
          setNextFillColor(layer, 0.8, 0.8, 0.2, 1)
          addTriangle(layer, (x + xoffset), (y + yoffset), (x + xoffset) - xspace, (y + yoffset) - yspace, (x + xoffset) - xspace, (y + yoffset) + yspace)
       end
    end
    
    function DisplayItemsGrid(layer, font)
       local idx = 0
       local x = Screen.InfoWidth + 50
       local y = 50
       local totali = math.floor(ItemsCount/5) 
        
       for i = 1, 3,1 do
          for j = 1, 5, 1 do
             idx = idx + 1
             if Items[idx] ~= nil then
                 CurrentImage = loadImage(Items[idx].Icon)
                 addImage(layer, CurrentImage, (x + (150 * (j-1))), ((i) * 175)-70, 80, 80)
                 DisplayTextArea(layer, Items[idx].Name, x + 30 +(150 * (j-1)), (i) * 175, 0, 22, font, AlignH_Center)
                 --logMessage('I['..i..']'..'|J['..j..']')
             end
          end
       end
    end
    
    -- These only need called on init
    GetScreen()
end

-- Layers
local forelayer = createLayer()
local panellayer = createLayer()
local backlayer = createLayer()
local headerfont = loadFont("RefrigeratorDeluxe", 30)
local subheaderfont = loadFont("FiraMono-Bold", 25)
local font = loadFont("FiraMono-Bold", 12)
local subfont = loadFont("FiraMono-Bold", 10)

-- Player Actions
Tick = Tick + 1
GetMouse()
HandleInput()
BuildPagination(backlayer,font,Screen.HalfInfoWidth,Screen.Height - 15)

for k,v in ipairs(Items) do
    local selected = CreateButton(k, backlayer, font, v.Name, 0, Screen.InfoWidth, Screen.HeaderHeight+(25*(k-1)), Mouse.x, Mouse.y, Mouse.Release)
    
    if k == ItemsCount and SelectedItemIndex ~= nil then
       CreateButton(ItemsCount+1, backlayer, font, "BACK", 0, Screen.InfoWidth, Screen.HeaderHeight+(25*(k)), Mouse.x, Mouse.y, Mouse.Release, ToColor(0.8, 0.8, 0.2, 0.8))
    end
end
 
-- Show Item Info
if SelectedItemIndex ~= nil then
    local i = Items[SelectedItemIndex]
    
    -- Header, Description, and Image
    CurrentImage = loadImage(i.Icon)
    DisplayText(forelayer, subheaderfont, i.Name, Screen.InfoWidth+10, Screen.HeaderHeight + 45, AlignH_Left, AlignV_Middle, ToColor(.8, .8, .2, 1))
    addImage(forelayer, CurrentImage, Screen.Width - 250, Screen.HeaderHeight + 25, 250, 250)
    DisplayTextArea(forelayer, i.Description, Screen.InfoWidth+10, Screen.HeaderHeight + 55, nil, 65, font)
    
    -- Quantity
    DisplayText(forelayer, subheaderfont, "Quantity", Screen.InfoWidth+InfoColumnWidthPadding, Screen.HalfHeight - 70, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
    DisplayText(forelayer, subheaderfont, i.Quantity, Screen.InfoWidth+InfoColumnWidthPadding, Screen.HalfHeight - 30, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .8, 1))
    
    -- Tier
    DisplayText(forelayer, subheaderfont, "Tier", Screen.HalfContentWidth+Screen.InfoWidth, Screen.HalfHeight - 70, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
    DisplayText(forelayer, subheaderfont, i.Tier, Screen.HalfContentWidth+Screen.InfoWidth , Screen.HalfHeight - 30, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .8, 1))

    -- Mass
    DisplayText(forelayer, subheaderfont, "Mass", Screen.InfoWidth+InfoColumnWidthPadding, Screen.HalfHeight+10, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
    DisplayText(forelayer, subheaderfont, i.UnitMass, Screen.InfoWidth+InfoColumnWidthPadding, Screen.HalfHeight+50, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .8, 1))
    
    -- Volume
    DisplayText(forelayer, subheaderfont, "Volume", Screen.HalfContentWidth+Screen.InfoWidth, Screen.HalfHeight+10, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
    DisplayText(forelayer, subheaderfont, i.UnitVolume, Screen.HalfContentWidth+Screen.InfoWidth , Screen.HalfHeight+50, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .8, 1))

    -- Stack Mass
    DisplayText(forelayer, subheaderfont, "Stack Mass", Screen.InfoWidth+InfoColumnWidthPadding, Screen.HalfHeight+90, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
    DisplayText(forelayer, subheaderfont, i.UnitMass*i.Quantity, Screen.InfoWidth+InfoColumnWidthPadding, Screen.HalfHeight+130, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .8, 1))
    
    -- Stack Volume
    DisplayText(forelayer, subheaderfont, "Stack Volume", Screen.HalfContentWidth+Screen.InfoWidth, Screen.HalfHeight+90, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .2, 1))
    DisplayText(forelayer, subheaderfont, i.UnitVolume*i.Quantity, Screen.HalfContentWidth+Screen.InfoWidth , Screen.HalfHeight+130, AlignH_Center, AlignV_Middle, ToColor(.8, .8, .8, 1))
else
   if ItemsCount > 0 then
      DisplayItemsGrid(forelayer, subfont)
   end
end

-- Header and Info
DisplayBox(panellayer, 0, 0, Screen.InfoWidth, Screen.InfoHeight, ToColor(.3, .3, .3, 1), ToColor(0, 0, 0, 1), 15, nil, nil, nil)
DisplayBox(backlayer, 0, 0, Screen.HeaderWidth,  Screen.HeaderHeight, ToColor(1, 1, 0.2, 1), ToColor(0, 0, 0, 1), 25, nil, nil, nil)
DisplayText(backlayer, headerfont, headertext, Screen.HalfWidth, 30, AlignH_Center, AlignV_Middle, ToColor(.1, .1, .1, 1))
setBackgroundColor(.1, .1, .1)

requestAnimationFrame(2)
