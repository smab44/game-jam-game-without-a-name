
function _init()
	make_player()
	player_state = "idle"
    attack_timer = 0
end

function _update60()
	player_attack()

    if attack_timer > 0 then
        attack_timer -= 1
    elseif attack_timer == 0 then
        player_state = "idle"
    else
        player_state = "idle"
    end

end

function _draw()
	cls()
	spr(1, p.x, p.y, 2, 2)
	print(player_state)
end



function make_player()
	p={}
	p.x =50
	p.y =50
end

function player_attack()
	if btn(4) then
		player_state = "attacking"
        attack_timer = 30
	end
end

