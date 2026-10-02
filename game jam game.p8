pico-8 cartridge // http://www.pico-8.com
version 43
__lua__

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
    force =12.16
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
    player_hp =7

    win =false


    sfx_played =false
    enemy_sfx_played_1 =false
    enemy_sfx_played_2 =false

    score =0

    --debug--
    middle = 64
    debug =false
    
    cemera_offset =100
    score =0

    game="play"

end


function _update60()


    between = (p.x + e.x) / 2 + 8 - 64
    c.x = between+cemera_offset

    if game == "play" then
        player_attack()

        --levels--



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

            valid_frames={64,66,68,70,72,74,76,78}
            if frame < parry_last_frame - speed then --chosing a frame number from valid_frames{}--
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
        else
            e_frame = e_first_frame
        end

        if enemy_state =="attacked" then
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

                if enemy_sfx_played_1 ==false then
                    sfx(03)
                    enemy_sfx_played_1 =true
                end
            else
                warning_timer =30
                warning_trigerred = 2

                enemy_is_attacking =true

                if enemy_sfx_played_2 ==false then
                    sfx(03)
                    enemy_sfx_played_2 =true
                end
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

                if enemy_sfx_played_1 ==false then
                    sfx(03)
                    enemy_sfx_played_1 =true
                end
            else
                warning_timer =30
                warning_trigerred = 1

                enemy_is_attacking =true

                if enemy_sfx_played_2 ==false then
                    sfx(03)
                    enemy_sfx_played_2 =true
                end

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
                score +=2
                sfx(02)
            end
        end


        --win statment--
        if player_hp <=0 then
            game ="lose"
        end
    end
end






function _draw()

    if game =="play" then
        cls()
        map()
        camera(c.x,c.y)
        spr(valid_frames[flr(frame)], p.x+cemera_offset, p.y, 2, 2, flip_e)
        spr(e_valid_frames[flr(e_frame)], e.x+cemera_offset, e.y, 2, 2, flip_e)

        print("player hp: " ..player_hp,c.x+64-(48/2),20)
        if score ==0 then
            print("score: " ..score,c.x+64-(32/2),28) --8
        elseif score >=1 then
            print("score: " ..score .."00",c.x+64-(40/2),28)
        elseif score >=10 then
            print("score: " ..score .."00",c.x+64-(44/2),28) 
        elseif score >=100 then
            print("score: " ..score .."00",c.x+64-(48/2),28)
        elseif score >=1000 then
            print("score: " ..score .."00",c.x+64-(52/2),28)
            print("get a fucking life",c.x+64-(72/2),36)
        elseif score >=10000 then
            print("score: " ..score .."00",c.x+64-(56/2),28)
        end
    elseif game =="lose" then
        cls()
        print("game over",c.x+64-(36/2),64-4)
        print("score: "..score,c.x+64-(36/2),64+4+8)

    end

    if debug == true then
        print("player state:" ..player_state ,between+cemera_offset,0)
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

        if win == true then
            print("u win")
        end
        
        spr(96,-1,0)
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

    enemy_sfx_played_1 =false
    enemy_sfx_played_2 =false
end

function reset_enemy_to_the_right()
    e.x =32

    e_is_attacking =false
    parried =false

    enemy_state = "idle"
    flip_e = false
    force =default_force
    
    warning_trigerred =1

    enemy_sfx_played_1 =false
    enemy_sfx_played_2 =false
end
-->8


__gfx__
00000cccccc00000000000cccccc0000000000cccccc0000000000cccccc00000000cccccc0000000000cccccc0000000000cccccc0000000000cccccc000000
0000cccccccc000000000cccccccc00000000cccccccc00000000cccccccc000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000
0000cccccccc000000000cccccccc00000000cccccccc00000000cccccccc000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000
0000cccccccc000000000cccccccc00000000cccccccc00000000cccccccc000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000
0000cccccccc000050000cccccccc00050000cccccccc00000000cccccccc000000cccccccc05550000cccccccc00555000cccccccc00555000cccccccc00555
0000cccccccc000055500cccccccc00055500cccccccc00050000cccccccc000000ccccccc555555000cccccccc55555000cccccccc55555000cccccccc55555
00000cccccc00000555500cccccc0000555500cccccc0000555000cccccc000000005555555555550000cccccc5555550000cccccc5555550000cccccc555555
000000ccccc000005555c00ccccc00005555c00ccccc00005555500ccccc0cc0000055555555555500000ccccc5cc55500000ccccc5cc55500000ccccc5cc555
0000cccccccc00000555cccccccccc000555cccccccccc0005555cccccccccc0000c555555555555000cccccccccc550000cccccccccc550000cccccccccc550
000cccccccccc0000ccccccccccccc000ccccccccccccc0000055ccccccccc0000ccc5555555500000cccccccccc500000cccccccccc500000cccccccccc5000
00cccccccccccc000cccccccccccc0000cccccccccccc000000cccccccccc0000ccccccc55c000000cccccccccc000000cccccccccc000000cccccccccc00000
00ccccccccccccc0000ccccccccccc00000ccccccccccc00000ccccccccccc000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc0000
0cccccccccccccc000cccccccccccc0000cccccccccccc0000cccccccccccc00ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000
0cccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc0ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000
0cccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc0ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000
00cccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc000ccccccc000000000ccccccc000000000ccccccc000000000ccccccc00000000
00000333330000000000003333300000000000333330000000000033333000000000003333300000000000333330000000000033333000000000033333000000
00003333333000000000033333330000000003333333000000000333333300000000033333330000000003333333000000000333333300000000333333300000
00003333333300000000033333333000000003333333300000000333333330000000033333333000000003333333300000000333333330000000333333330000
00003333333300000000033333333000000003333333300000000333333330000000033333333000000003333333300000000333333330000000333333330000
00003333333300000000033333333000000003333333300000000333333330000000033333333000000003333333300000000333333330000000333333330000
00003333333300000000033333333000000003333333300000000333333330000000033333333000000003333333300000000333333330000000333333330000
00000353533000000000003533330000000000353333000000000035333300000000003533330000000000353333000000000035333300000000033333300000
00003355533300000003355555333000000335555533300000033555553330000003355555333000000335555533300000033555553330000000333333330000
00033335553330000055555555333300005555555533330000555555553333000055555555333300005555555533330000555555553333000003333333333000
00333035355333005555530533333330555553053333333055555305333333305555530533333330555553053333333055555305333333300033303333333000
00333033330333505503300333303330550330033330333055033003333033305503300333303330550330033330333055033003333033300333003333033300
00033333330335550000003333303330000000333330333000000033333033300000003333303330000000333330333000000033333033300033033333033300
00000333033000050000003330330000000000333033000000000033303300000000003330330000000000333033000000000033303300000000033303300000
00333333033333000000333330333300000033333033330000003333303333000000333330333300000033333033330000003333303333000033333303333300
03333333033333300003333330333330000333333033333000033333303333300003333330333330000333333033333000033333303333300333333303333330
00333330003333000000333300033330000033330003333000003333000333300000333300033330000033330003333000003333000333300033333000333300
0000cccccc0000000000cccccc0000000000cccccc0000000000cccccc0000000000cccccc0000000000cccccc0000000000cccccc0000000000cccccc000000
000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000
000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000
000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000000cccccccc00000
000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0
000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0000cccccccc00cc0
0000cccccc000cc00000cccccc000cc00000cccccc000cc00000cccccc000cc00000cccccc000cc00000cccccc000cc00000cccccc000cc00000cccccc000cc0
00000ccccc00ccc000000ccccc00ccc000000ccccc00ccc000000ccccc00ccc000000ccccc00ccc000000ccccc00ccc000000ccccc00ccc000000ccccc00ccc0
000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0
00cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc00
0cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc0000cccccccccccc000
0ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc00
cccccccccccccc00cccccccccccccc00cccccccccccccc00cccccccccccccc00cccccccccccccc00cccccccccccccc00cccccccccccccc00cccccccccccccc00
ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000ccccccccccccc000
ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000ccccccccccc00000
0cccc0000ccc00000cccc0000ccc00000cccc0000ccc00000cccc0000ccc00000cccc0000ccc00000cccc0000ccc00000cccc0000ccc00000cccc0000ccc0000
bb000000000000007777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000007777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6263626362636263626362636263626362636263626362636263626362636263626362636263000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7273727372737273727372737273727372737273727372737273727372737273727372737273000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001000000d0430000000000000000d0430000000000000000d0430000000000000000d0430000000000000000d0430000000000000000d0430000000000000000d0430000000000000000d043000000000000000
00020000282322c2303023030240332502930028300283002d30000000000000000024600000002b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000a3300a3320b3301132013322143000b3000b3020c4020c4000d502195001750214500135000d502005000f50012500175001850000500005000050015500115000f5000d5000c500005000050000500
000300001a5501a5521b5401d140261220f500105001350215502005000d502195001750214500135000d502005000f50012500175001850000500005000050015500115000f5000d5000c500005000050000500
00100000001000b1020b1000c1000d1020f100101001310215102001000d102191001710214100131000d102001001710014100121001110000100001000010015100111000f1000d1000c1001c1000010000100
00100000000000a700070000a000090000d0000d000100000a000144000a000090000d0000c7000e7000a000137000d000037000a000090000d00013400154000a0000d0000a000090000d0000d0001c4000a000
000200001f27222260222602a2502d2702234022340223302520000000000000000024600000002b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 40414244
03 40434445
02 41424344

