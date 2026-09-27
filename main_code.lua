
    --if attack_timer > 0 then
        --attack_timer -= 1
    --else
        --e_frame = 3
        --attack_timer = rnd(max) + min
    --end

function _init()

    debug = true

    --player pos variables--
    p={
    x=17,
    y=70,
    }

    --enemy pos variables--
    e={
    x=80,
    y=70,
    }

    ---attack timer and state---
    player_state = "idle"
    enemy_state = "idle"

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


    --timer--
    attack_timer = 60
    now_bariar = 0
    bariar = 6

end


function _update60()
    player_attack()



    ---attack timer---
    if attack_timer > 0 then
        attack_timer -= 1


    else --happens every ~frame--

        if rnd(100) < 21 then --1/4--  --every ~frame there will be a 1/4 chance of the enemy attacking--
            enemy_state = "attacking"
            attack_timer = 60 + rnd(120)

        elseif now_bariar == bariar or now_bariar > bariar then --if the bariar crossed--
            enemy_state = "attacking"
            attack_timer = 60 + rnd(120)
            now_bariar = 0

        else --3/4--  --every ~frame there will be a 3/4 chance that nothing happens, for example: poring water on a rock!--
            attack_timer = 60
            now_bariar +=1 --adds 1 to bariar--

        end

    end




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
    if enemy_state == "attacking" then
        if e_frame < e_last_frame - e_speed then --chosing a frame number from valid_frames{}--
            e_frame += e_speed
        else    
            e_frame = e_first_frame
            enemy_state = "idle"
        end
    elseif enemy_state == "idle" then
        e_frame = e_first_frame
    end

end

function _draw()
	cls()
	spr(valid_frames[flr(frame)], p.x, p.y, 2, 2)
    spr(e_valid_frames[flr(e_frame)], e.x, e.y, 2, 2)

    if debug == true then
        print("player state:" ..player_state)
        print("player frame:" ..frame)
        print("enemy state:" ..enemy_state)
        print("attack_timer:" ..attack_timer)
    end
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







---attack timer an state---
    --if attack_timer > 0 then
        --attack_timer -= 1
    --else
        --player_state = "idle"
    --end



    --1 sec: 60
    --2 sec: 120
    --3 sec: 180
    --4 sec: 240
    --5 sec: 300
    --6 sec: 360
    --7 sec: 420
    --8 sec: 480
    --9 sec: 540