package connect4

/*********************************************************************
				Connect Four
		This is a simple two player game of connect 4,
		where it functions how the game is known to function.
		The game adds green and purple cursors to select 
		a slot to drop a token in. Green is for the yellow
		player and purple is for the red player.

**********************************************************************/


import time "core:time"
import fmt  "core:fmt"
import rl   "vendor:raylib"


//0, 0 is top right corner
slots:[7][7]i8
game_over : bool
move: b8

open: int

store_slot: i8//stores a slot when the cursor moves over it

slot_x: i8//current selected slot


drop_flag := false
play: i8//player who is playing//player who is waiting
wait: i8
StructA :: struct {
	foo : int,
	}
StructB :: struct {
	foo : int,
	}
Window :: struct { 
    name:          cstring,
    width:         i32, 
    height:        i32,
    fps:           i32,
    control_flags: rl.ConfigFlags,
}

Game :: struct {
    tick_rate: time.Duration,
    last_tick: time.Time,
    pause:     bool,
    colors:    []rl.Color,
    width:     i32,
    height:    i32,
}

World :: struct {
    width:   i32,
    height:  i32,
    alive:   []u8,
}

Cell :: struct { 
    width:  f32,
    height: f32,
}

User_Input :: struct {
    left_pressed:   bool,
    right_pressed:  bool,	
    drop:         	bool,
    enter:  		bool,
}





 //draws slots on the board based on what token, if there is not a token, or if there is a cursor 

draw_slots :: #force_inline proc(world: ^World, cell:Cell) {
	
    x, y, ix, iy : i32
    for y = 2; y < world.height - 7; y += 2 {
        for x = 2; x < world.width - 7; x +=  2{
           
		  
            color := rl.BLACK//default, if slot unfilled
			if(slots[ix][iy]==3){//player 1 select
				color = rl.GREEN
				}
			if(slots[ix][iy]==4){//player 2 select
				color = rl.PURPLE
				}
			if(slots[ix][iy] == 1){//yellow and red are taken by users
				color = rl.YELLOW
				}
			if(slots[ix][iy] == 2){
				color = rl.RED
				}

            rect := rl.Rectangle{
                x      = f32(x) * cell.width *4,
                y      = f32(y) * cell.height *4,
                width  = cell.width *4,
                height = cell.height *4,
            }
            rl.DrawRectangleRec(rect, color)
			if(ix < 6){
				ix += 1
			}
        }
		ix= 0
		if(iy < 6){
			iy += 1
		}
    }
}



check_win :: proc(slot_x : int, slot_y: int) -> ( win : bool){//check win condition here
	//only have to check around slots[slot_x][open] if surrounding is equal
	//directions: down, l, r, l/up, r/up, l/down, r/down
	//check down
	i : i8
	streak : int
	if(slot_y < 4){//higher values cant give a win and will break code
		for i in 0..3{//simplest way to write a for loop in odin
			if streak == i{//if streak not broken
				if slots[slot_x][slot_y + i] == play{
				streak+=1
				}
				else{//if empty or other player
				streak = 0//break streak to reset for next check and to stop the for
				}
			}
		}
		if(streak == 4){
		return true
		}				
	}
	if slot_x < 4{//left
		for i in 0..3{
			if streak == i{
				if slots[slot_x + i][slot_y] == play{
					streak+=1
				}
				else{//if empty or other player
					streak = 0
				}
			
		
			}
		}
		if(streak == 4){
		return true
		}
		if slot_y < 4{//left/down
			for i in 0..3{
			if streak == i{
				if slots[slot_x + i][slot_y + i] == play{
					streak+=1
					}
					else{//if empty or other player
						streak = 0
					}
			
		
				}
			}
			if(streak == 4){
				return true
			}
		}
		if slot_y > 2{//left/up
			for i in 0..3{
			if streak == i{
				if slots[slot_x + i][slot_y - i] == play{
					streak+=1
					}
					else{//if empty or other player
						streak = 0
					}
			
		
				}
			}
			if(streak == 4){
				return true
			}
		}
		
		
	}
	
	if slot_x > 2{//right
	for i in 0..3{
		if streak == i{
			if (slots[slot_x - i][slot_y] == play){
				streak+=1
				}
			else{//if empty or other player
				streak = 0
			}
			
		
			}
		}
		if(streak == 4){
		return true
		}
		
		if slot_y < 4{//right/down
			for i in 0..3{
			if streak == i{
				if slots[slot_x - i][slot_y + i] == play{
					streak+=1
					}
					else{//if empty or other player
						streak = 0
					}
			
		
				}
			}
			if(streak == 4){
				return true
			}
		}
		if slot_y > 2{//right/up
			for i in 0..3{
			if streak == i{
				if slots[slot_x - i][slot_y - i] == play{
					streak+=1
					}
					else{//if empty or other player
						streak = 0
					}
			
		
				}
			}
			if(streak == 4){
				return true
			}
		}
		
		
	
	}
	return false
}
turn :: proc(user_input: ^User_Input, window: Window, world: World) {
//checks user input, doubles to restart after game over
	if !game_over{
	select := play + 2
 	if(user_input.left_pressed && slot_x >0){
		if(open != 0){
		slots[slot_x][0] = store_slot//return to last value
		}
		open = 8
		slot_x-=1
		store_slot = slots[slot_x][0]//store for when mouse changes
		slots[slot_x][0] = select
		
	}
	
	if (user_input.right_pressed && slot_x < 6){
		if(open !=0){
			
			slots[slot_x][0] = store_slot//return to last value
		}
		open = 8
		slot_x+=1
		store_slot = slots[slot_x][0]//store for when mouse changes
		slots[slot_x][0] = select
		
	}
	drop_flag = false
	
	i: int
	if (user_input.drop && store_slot != 1 && store_slot != 2){
		if(slots[slot_x][0] != 1 && slots[slot_x][0] != 2){
		
			drop_flag = true
			for i = 0; i < 7; i+= 1{
				if (slots[slot_x][i] == 0 || slots[slot_x][i] > 2){
					open = i
				
					}
				}
			if(open!= 8){
				slots[slot_x][open] = play 
				if(open != 0){
					slots[slot_x][0] = store_slot
					}
					store_slot = 0//reset
					
					temp: int = int(slot_x)
					game_over = check_win(temp, open)
					if(!game_over){//only swap if game still going
						play, wait = wait, play//swap in odin
					}
				
				}
			}
		}
		}
		if game_over && user_input.enter{
			//reset values here
			play, wait = 1, 2//reset to original values
			slot_x = 0
			x, y : int
			for x = 0; x < 7; x+=1{
				for y = 0; y<7; y += 1{
					slots[x][y] = 0//reset all slots
					}
				}
			
			game_over = false//restart game
			}
    user_input^ = User_Input{//reset user input after each frame input check
        left_pressed	      = rl.IsKeyPressed(.LEFT),
        right_pressed  		  = rl.IsKeyPressed(.RIGHT),
        drop		          = rl.IsKeyPressed(.SPACE),
		enter				  = rl.IsKeyPressed(.ENTER),
	}
}

main :: proc() {
    window := Window{"Connect Four", 1024, 1024, 60, rl.ConfigFlags{ .WINDOW_RESIZABLE }}
	a: uint = 3
	b : int = 3
	c: uint = a + 3

    game := Game{
        tick_rate = 300 * time.Millisecond,
        last_tick = time.now(),
        pause     = true,
        colors    = []rl.Color{ rl.YELLOW, rl.RED },
        width     = 64,
        height    = 64,
    }

    world      := World{game.width, game.height, make([]u8, game.width * game.height)}


    cell := Cell{
        width  = f32(window.width)  / f32(world.width),
        height = f32(window.height) / f32(world.width),
    }

    user_input : User_Input
    
    rl.InitWindow(window.width, window.height, window.name)
    rl.SetWindowState( window.control_flags )
    rl.SetTargetFPS(window.fps)
	
	 play = 1//player 1 playing, player 2 waiting
	 wait = 2//these will swap when each player takes a turn
    // Infinite game loop. Breaks on pressing <Esc>
    for !rl.WindowShouldClose() {
        // all the values in game used to be separate variables and were
        // moved into a single Game struct. `using game` is a quick fix
        // to get the program back to running. Comment this line to see
        // where the variables were used and updated.
        using game

        // If the user resized the window, we adjust the cell size to keep drawing over the entire window.
        if rl.IsWindowResized() {
            window.width  = rl.GetScreenWidth()
            window.height = rl.GetScreenHeight()

            cell.width  = f32(window.width)  / f32(world.width)
            cell.height = f32(window.height) / f32(world.width)
        }

        // Create and edit board based on input
		  rl.BeginDrawing()//draw the board
			rl.ClearBackground(rl.DARKBLUE)
			if !game_over{//if game continues draw slots
				draw_slots(&world, cell)
            }
			else{//if game ended draw win screen
			//print win screen
			winner : cstring
				if play == 1{
					winner = "Yellow wins!"
				}
				if play == 2{
					winner = " Red wins!"
				}
				rl.DrawText(winner, rl.GetScreenWidth()/2 - rl.MeasureText(text, 18)/2, rl.GetScreenHeight()/2 - 100, 40, game.colors[play-1])
				text : : "Press Enter to play again."
				rl.DrawText(text, rl.GetScreenWidth()/2 - rl.MeasureText(text, 20)/2, rl.GetScreenHeight()/2 - 50, 20, rl.GRAY)
			}
        rl.EndDrawing()
		turn(&user_input, window, world);//check input
		
        }
    }
