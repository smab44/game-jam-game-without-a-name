
function _init()
    --player pos variables--
    p={
    x=30,
    y=70,
    }

    --enemy pos variables--
    e={
    x=70,
    y=70,
    }

    ---attack timer and state---
    player_state = "idle"
    --attack_timer = 0

    --animation--
    valid_frames={0,2,4,6,8,10,12,14}
    frame = 1
    speed = .3
    first_frame = 1
    last_frame = 11 --last frame can go higher than the actual last frame for more delay/impact on the last frame--

    --enemy animation--
    e_valid_frames={32,34,36,38,40,42,44}
    e_frame = 1
    e_speed = .3
    e_first_frame = 1
    e_last_frame = 7

end



function _update60()
    player_attack()

    ---attack timer an state---
    --if attack_timer > 0 then
        --attack_timer -= 1
    --else
        --player_state = "idle"
    --end

    ---animation---
    if player_state == "attacking" then
        if frame < last_frame - speed then --chosing a frame number from valid_frames{}--
            frame += speed
        else    
            frame = first_frame
            player_state = "idle"
        end
    elseif player_state == "idle" then
        frame = first_frame
    end

    ---enemy_animation---
    if player_state == "attacking" then
        if e_frame < e_last_frame - e_speed then --chosing a frame number from valid_frames{}--
            e_frame += e_speed
        else    
            e_frame = e_first_frame
            --player_state = "idle"
        end
    elseif player_state == "idle" then
        e_frame = e_first_frame
    end




end

function _draw()
	cls()
	spr(valid_frames[flr(frame)], p.x, p.y, 2, 2)
    spr(e_valid_frames[flr(e_frame)], e.x, e.y, 2, 2)

	print(player_state)
    print(frame)
end



function player_attack()
	if btn(4) then
		player_state = "attacking"
--        attack_timer = 30
	end
    if btn(5) then
		player_state = "parry"
--        attack_timer = 30
	end
end

