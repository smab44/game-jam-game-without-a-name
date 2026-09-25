
function _init()
    --player pos variables--
    p={
    x=50,
    y=50,
    }

    --attack timer and state--
    player_state = "idle"
    attack_timer = 0

    --animation--
    valid_frames={0,2,4,6,8,10,12}
    frame = 1
    speed = .3

end



function _update60()
    player_attack()

    --attack timer an state--
--    if attack_timer > 0 then
--        attack_timer -= 1
--    else
--        player_state = "idle"
--    end

    --animation--
    if player_state == "attacking" then
        if frame < 12-speed then --chosing a frame number from valid_frames{}--
            frame +=speed
        else    
            frame = 1
            player_state = "idle"
        end
    elseif player_state == "idle" then
        frame = 1
    end



end

function _draw()
	cls()
	spr(valid_frames[flr(frame)], p.x, p.y, 2, 2)
	--print(player_state)
    print(frame)
end



function player_attack()
	if btn(4) then
		player_state = "attacking"
        attack_timer = 30
	end
end

