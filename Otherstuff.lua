-- cool number formatting from JackMac XD
("1.2653e600")
  :gsub("(%d)%.(%d+)e+(%d+)", function(w, f, e) return w .. f .. ("0"):rep(e - #f) end)
  :gsub("(%d)%.(%d+)e%-(%d+)", function(w, f, e) return "0." .. ("0"):rep(e - 1) .. w .. f end)
  :gsub("(%.[^0]+)0+$", "%1")

  
function num_tostring(n)
    if n >= 1e11 or n <= 1e-11 then
        return ("%.4e"):format(n)
    else 
        return (("%.10f"):format(n):gsub("%.0+%f[^%d]", ""):gsub("(%.%d-)0+%f[^%d]", "%1")) 
    end
end