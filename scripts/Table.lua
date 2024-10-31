function table.find(haystack, needle)
    for index, value in ipairs(haystack) do 
        if value==needle then return index end 
    end 
end 

return table 