server_address = minetest.get_server_info().address
if server_address == "ctf.rubenwardy.com" then
    time = 0
    subtract = 0
    refresh = 0.1
    time_multiplier = 1
    names = {}
    times = {}

    core.register_on_receiving_chat_message(function(message)
        privs = {
            interact = true,
        }

        if string.find(message, "has taken ") and string.find(message, " flag") then
            player = message:sub(13,string.find(message, "has taken ")-26)
            names[#names+1] = player
            times[#times+1] = time
        end
        if string.find(message, "has dropped ") and string.find(message, " flag") then
            player = message:sub(13,string.find(message, "has dropped ")-26)
            removefromlist(player,nil)
        end
        if string.find(message, "has captured ") and string.find(message, " flag") then
            player = message:sub(13,string.find(message, "has captured ")-26)
            removefromlist(player,nil)
        end
        if string.find(message, "Map: ") and string.find(message, " by ") then
            names = {}
            times = {}
            if hud then
                minetest.localplayer:hud_change(hud, "text", "")
            end
        end
    end)

    minetest.register_globalstep(function(dtime)
        time = time + dtime
        if time - subtract > refresh then
            hudpos = {x = 0.5, y = 0.09}
            subtract = subtract + refresh
            screen_message = ""
            for i = 1, #names do
                name = names[i]
                starttime = times[i]
                if starttime and name then
                    remainingtime = format_time((180-(time - starttime))*time_multiplier)
                    if (180-(time - starttime))*time_multiplier > 0 then
                        screen_message = screen_message .. name .. " has " .. remainingtime .. " seconds.\n"
                    else
                        removefromlist(nil,i)
                    end
                end
            end
            
            if screen_message then
                if hud then
                    minetest.localplayer:hud_change(hud, "text", screen_message)
                else
                    hud = minetest.localplayer:hud_add({hud_elem_type = "text", position = hudpos, offset = {x = 0, y = 0}, text = screen_message, alignment = {x = 0, y = 0}, scale = {x = 1, y = 1}, number = 0xFFFFFF})
                end
            end
        end
    end)

    function format_time(seconds)
        local minutes = math.floor(seconds / 60)
        local remaining_seconds = seconds % 60
        return string.format("%02d:%02d", minutes, remaining_seconds)
    end
    function removefromlist(player,i)
        if i then 
            names[i] = nil
            times[i] = nil
            minetest.localplayer:hud_change(hud, "text", screen_message)
        else
            for i = 1, #names do
                if names[i] == player then
                    times[i] = nil
                    names[i] = nil
                end
            end
        end
    end
end
