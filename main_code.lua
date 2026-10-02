
function _init()

    --player pos variables--
    p={
        x=0-8,
        y=80,
    }
    --42
    --enemy pos variables--
    e={
        x=32,
        y=80,
    }

    --cemera pos variables--
    c={
        x=0,
        y=0,
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

    --animation--
    parry_valid_frames={0,2,4,6,8,10,12,14}
    parry_frame = 1
    parry_speed = .3
    parry_first_frame = 1
    parry_last_frame = 11 --last frame can go higher than the actual last frame for more delay/impact on the last frame--

    --enemy animation--
    e_valid_frames={32,34,36,38,40,42,44}
    e_frame = 1
    e_speed = .3
    e_first_frame = 1
    e_last_frame = 7


    --timer--
    attack_timer = 60
    now_bariar = 0
    bariar = 4


    --cemera--
    between =0


    --enemy attack movement and easing--
    force =12.5
    default_force =force
    flip_e =false
    warning_timer =30
    warning_trigerred = 1

    --attack and parry--
    enemy_is_attacking =false
    parried =false
    enemy_parried_coldown = 140
    enemy_parried_coldown_default = enemy_parried_coldown

    player_can_attack =true
    enemy_x_after_parry =10

    attack_coldown =30
    default_attack_coldown =attack_coldown

    parry_coldown =0
    default_parry_coldown =100

    enemy_hp =10
    player_hp =5

    win =false


    sfx_played =false

    --debug--
    middle = 64
    debug =false
    

end


function _update60()
    player_attack()


    between = (p.x + e.x) / 2 + 8 - 64
    c.x = between


    ---attack timer---
    if enemy_state =="idle" then
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
    end


    ---animation---
    if player_state == "attacking" then

        valid_frames={0,2,4,6,8,10,12,14}
        if frame < last_frame - speed then --chosing a frame number from valid_frames{}--
            frame += speed
        else
            frame = first_frame
            player_state = "idle"
        end
    elseif player_state == "parry" then

        valid_frames={64,66,68}
        if frame < last_frame - speed then --chosing a frame number from valid_frames{}--
            frame += speed
        else
            frame = first_frame
            player_state = "idle"
        end
    elseif player_state == "idle" then
        valid_frames={0,2,4,6,8,10,12,14}
        frame = first_frame
    end


    ---enemy_animation---
    if enemy_state == "attacking" then
        if e_frame < e_last_frame - e_speed then --chosing a frame number from valid_frames{}--
            e_frame += e_speed
        else    
            e_frame = e_first_frame
            --enemy_state = "idle"
        end
    elseif enemy_state == "idle" then
        e_frame = e_first_frame
    end


    ---parry coldown---
    if parry_coldown >=0 then
        parry_coldown -=1
    end


    ---enemy easing movement--- --no explanation for u f u--

    if enemy_state == "attacking" and flip_e == false then

        --warningtimer--
        if warning_timer > 0 and warning_trigerred == 1 then
            warning_timer -=1
        else
            warning_timer =30
            warning_trigerred = 2

            enemy_is_attacking =true

            --easing--
            e.x -=force
            force-=1
            if e.x == -48 or e.x < -48 then
                player_hp-=1

                reset_enemy_to_the_left()
                
            end
        end

    elseif enemy_state == "attacking" and flip_e == true then

        --warningtimer--
        if warning_timer > 0 and warning_trigerred == 2 then
            warning_timer -=1
        else
            warning_timer =30
            warning_trigerred = 1

            enemy_is_attacking =true

            --easing--
            e.x +=force
            force-=1
            if e.x == 32 or e.x > 32 then
                player_hp-=1

                reset_enemy_to_the_right()
                
            end
        end
    end

    ---parry---  ---checks if u can parry da enemy---
    if player_state =="parry" and enemy_is_attacking ==true then
        if warning_trigerred ==2 and e.x > -8 then
            parried =true
            enemy_state = "attacked"
            e.x =enemy_x_after_parry
            if sfx_played ==false then
                sfx(01)
                sfx_played =true
            end
        elseif warning_trigerred ==1 and e.x < -8 then
            parried =true
            enemy_state = "attacked"
            e.x =enemy_x_after_parry*-1-16
            if sfx_played ==false then
                sfx(01)
                sfx_played =true
            end
        end

    end


    ---coldown for the parried enemy---
    if enemy_parried_coldown > 0 and parried ==true then
        enemy_parried_coldown -=1

    elseif parried ==true and warning_trigerred ==2 and enemy_parried_coldown >=0 then --if da enemy went left--

        reset_enemy_to_the_left()
        enemy_parried_coldown =enemy_parried_coldown_default
        sfx_played =false

    elseif parried ==true and warning_trigerred ==1 and enemy_parried_coldown >=0 then --if da enemy went right--

        reset_enemy_to_the_right()
        enemy_parried_coldown =enemy_parried_coldown_default
        sfx_played =false

    end


    --attacking parried enemy--
    if parried == true and player_state == "attacking" then
        if attack_coldown >=0 then
            attack_coldown -=1
        else
            attack_coldown =default_attack_coldown
            enemy_hp -=1
        end
    end


    --win statment--
    if enemy_hp ==0 then
        win =true
    end

end






function _draw()
	cls()
    camera(c.x,c.y)
	spr(valid_frames[flr(frame)], p.x, p.y, 2, 2, flip_e)
    spr(e_valid_frames[flr(e_frame)], e.x, e.y, 2, 2, flip_e)
    print(player_hp)

    if debug == true then
        print("player state:" ..player_state ,between,0)
        print("player frame:" ..frame)
        --print("player x:" ..p.x)
        print("---------")
        print("enemy state:" ..enemy_state)
        print("attack_timer:" ..attack_timer)
        print("enemy x:" ..e.x )
        --print("enemy x flr:" ..flr(e.x) )
        --print("force:" ..force )
        print("---------")
        print(e.x)
        print(e.x+16)
        print("---------")
        print("is parried: " ..(parried and 'true' or 'false'))
        print("parried coldown: " ..enemy_parried_coldown)
        print("warning trigerred: " ..warning_trigerred)
        
        spr(96,-1,0)
    end
    
    if win == true then
        print("u win")
    end
end



function player_attack()
	if btn(4) then
		player_state = "attacking"
	end
    if btn(5) and parry_coldown <=0 then
		player_state = "parry"
        parry_coldown =default_parry_coldown
	end
end

function reset_enemy_to_the_left()
    e.x =-48

    e_is_attacking =false
    parried =false

    enemy_state = "idle"
    flip_e = true
    force =default_force

    warning_trigerred =2
end

function reset_enemy_to_the_right()
    e.x =32

    e_is_attacking =false
    parried =false

    enemy_state = "idle"
    flip_e = false
    force =default_force
    
    warning_trigerred =1
end