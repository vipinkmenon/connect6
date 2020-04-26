puts "---------------------------------------------------"
puts "Simulation Start Time:"
set sysTime [clock seconds]
puts "---------------------------------------------------"

# Set up the work library   
if {[file exists work]} {               
} else {
   vlib work
   vmap work work
   puts "Successfully created work directory"
}   

#These are the files frequently modified, so compile every time
vlog -incr -work work -L mtiAvm -L mtiOvm -L mtiUPF +define+SIM {../src/rtl/verilog/connect6.v}
vlog -incr -work work -L mtiAvm -L mtiOvm -L mtiUPF {../src/rtl/verilog/threat_detector.v}
vlog -incr -work work -L mtiAvm -L mtiOvm -L mtiUPF {../src/rtl/verilog/master_sm.v}
vlog -incr -work work -L mtiAvm -L mtiOvm -L mtiUPF {../src/rtl/verilog/shadow_board.v}
vlog -incr -work work -L mtiAvm -L mtiOvm -L mtiUPF {../src/rtl/verilog/board_values.v}
vlog -incr -work work -L mtiAvm -L mtiOvm -L mtiUPF {../src/tb/verilog/monitor.v}
	
vsim -novopt -t ns connect6 monitor
#do wave.do
force -freeze sim:/connect6/i_clk 1 0, 0 {50000 ps} -r {100 ns} ;
force -freeze sim:/connect6/i_rst 1 0;
run 200 ns;
force -freeze sim:/connect6/i_rst 0 0;
run 200 ns

set counter 0
set my_color 0
set enemy_color 0
set w .connect6
catch {destroy $w}
toplevel $w
wm title $w "Connect6"
wm iconname $w "Connect6"
scrollbar $w.s
set frameSize 700
frame $w.frame -width $frameSize -height $frameSize -relief sunken -bg [$w.s cget -troughcolor]
pack $w.frame -side top -pady 1c -padx 1c
destroy $w.s
label $w.colour -text "Select FPGA colour "
radiobutton $w.rdb_b -text "Black" -variable my_color -value 2 -command "Place"
radiobutton $w.rdb_w -text "White" -variable my_color -value 1 -command "Place"
$w.rdb_w select
place $w.colour -relx 0.2 -rely 0 -relwidth 0.25 -relheight 0.05
place $w.rdb_b -relx 0.45 -rely 0 -relwidth 0.25 -relheight 0.05
place $w.rdb_w -relx 0.70 -rely 0 -relwidth 0.25 -relheight 0.05

proc Place {} {

global counter;
global my_color;
global enemy_color;
global w;

if {$my_color == 1} {
   set counter 1
} else {
   set counter 0
}

if {$my_color == 1} {
    set enemy_color 2
	force -freeze sim:/connect6/msm/i_uart_data_avail 1 0;
	force -freeze sim:/connect6/msm/i_uart_rd_data 8'd87 0;
	run 200 ns;
	force -freeze sim:/connect6/msm/i_uart_data_avail 0 0  ;
	run 200 ns;
} else {
    set enemy_color 1
	force -freeze sim:/connect6/msm/i_uart_data_avail 1 0 ;
	force -freeze sim:/connect6/msm/i_uart_rd_data 8'd68 0;
	run 200 ns ;
	force -freeze sim:/connect6/msm/i_uart_data_avail 0 0;
	run 200 ns 
	run 1 ms; 
}

set ypos 0
for {set i 0} {$i < 20} {set i [expr {$i+1}]} {
    set xpos 0
    for {set j 0} {$j < 20} {set j [expr {$j+1}]} {
	    set num [expr {$i*20+$j}]
		if {$xpos == 0} {
		    label $w.frame.$num -text "$i"
		    place $w.frame.$num -relx $xpos -rely $ypos -relwidth 0.05 -relheight 0.05
		} elseif {$ypos == 0} {
            label $w.frame.$num -text "$j"		
			place $w.frame.$num -relx $xpos -rely $ypos -relwidth 0.05 -relheight 0.05
		} else {
	        button $w.frame.$num -relief raised -highlightthickness 0 -command "push_button $i $j $w $enemy_color 0"
            place $w.frame.$num -relx $xpos -rely $ypos -relwidth 0.05 -relheight 0.05		
		}
		set xpos [expr {$xpos + 0.05}]
	}
	set ypos [expr {$ypos + 0.05}]
}  
    destroy $w.colour
    destroy $w.rdb_b
    destroy $w.rdb_w
    main;
}

proc push_button {i j w color player} {
    global my_color;
	set xpos [expr {$j*0.05}]
	set ypos [expr {$i*0.05}]
	set num [expr {$i*20+$j}]
	if {$color == 1} {
	    image create photo image$num -file [file join white-stone.gif]
	} else {
	    image create photo image$num -file [file join black-stone.gif]
	}	
	destroy $w.frame.$num
	label $w.frame.$num -image image$num -bd 1 -relief sunken
	place $w.frame.$num -relx $xpos -rely $ypos -relwidth 0.05 -relheight 0.05
	#destroy image$i
    global counter
	#puts " counter:$counter"
    if {$player == 0} {                  #i am playing
	    puts stderr "You placed at row     :         $i";
		puts stderr "You placed at column  :         $j";
        force -freeze sim:/connect6/msm/i_uart_data_avail 1 0
        force -freeze sim:/connect6/msm/i_uart_rd_data 8'd[expr (48 + ($i/10))] 0;
        run 300 ns;
        force -freeze sim:/connect6/msm/i_uart_rd_data 8'd[expr (48 + ($i%10))] 0;
        run 200 ns;
        force -freeze sim:/connect6/msm/i_uart_rd_data 8'd[expr (48 + ($j/10))] 0;
        run 200 ns;
        force -freeze sim:/connect6/msm/i_uart_rd_data 8'd[expr (48 + ($j%10))] 0;
        run 200 ns;
        force -freeze sim:/connect6/msm/i_uart_data_avail 0 0 ;
        run 300 ns;
		run 8 ms;
		incr counter
		if {[expr {$counter % 2}] == 0} {
		    if {$counter != 0} {
		    #puts "calling fpga 1"
		    fpga_place_2
			}
		}		
    }	
}	

proc fpga_place_1 {} {
    global my_color
	global w	
	set fptr [open fpga_out r]
    set row [gets $fptr]
	#puts $row;
	set col [gets $fptr]
	#puts $col;
	close $fptr
	push_button $row $col $w $my_color 1
}


proc fpga_place_2 {} {
    global my_color
	global w	
	set fptr [open fpga_out r]
    set row [gets $fptr]
	#puts $row;
	set col [gets $fptr]
	#puts $col;
	push_button $row $col $w $my_color 1
	set row [gets $fptr]
	#puts $row;
	set col [gets $fptr]
	#puts $col;
	push_button $row $col $w $my_color 1
	close $fptr
	if { [string match 1 [exa /connect6/td/o_succ_possible]] } {
	    puts "\n\n\nFPGA has won"
	    quit -sim;
    }
}

proc main {} {
    global my_color;
    if {$my_color == 2} {
	    fpga_place_1; 
	}
}

.main clear;


	