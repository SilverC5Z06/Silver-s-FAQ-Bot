function table.find(haystack, needle)
    for index, value in ipairs(haystack) do 
        if value==needle then return index end 
    end 
end 


Logger:Log(0, "Recieved scripts/Util/Table.lua      : OK", {Text = "MODULES", Color = Logger.Colors.BrightBlue})

return table 