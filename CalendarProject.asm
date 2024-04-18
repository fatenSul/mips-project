# WORKED BY:
# ANAN ZEIN 1193078
# FATEN SULTAN 1202750

.data
    calendar: .space 1000       # Assume 1000 bytes for the calendar (adjust as needed)
    appointments: .space 1000   # Assume 1000 bytes for appointments (adjust as needed)
    buffer:         .space  1024           # Buffer to store the read data
    fileWords:      .space 1024
    inputPrompt:    .asciiz "Enter data to write to the file: "
    dayPrompt:      .asciiz "Enter a day to retrieve data: "
    dayPrompt_set_of_days:      .asciiz "Enter a day to retrieve data or zero (0) to go back to the menu: "
    filename:       .asciiz "C:\\Users\\ananz\\OneDrive\\Desktop\\Computer Architecture\\testfinal.txt"
    exitKeyword:    .asciiz "exit"
    newline:        .asciiz "\n"
    searchCharL:     .asciiz "L"
    label_lectures: .asciiz "Total Lecture Hours: "
    TOTAL_LECTURE:  .DOUBLE 0
    number_ofLectures: .DOUBLE 0
    searchCharM:     .asciiz "M"
    label_meetings: .asciiz "Total Meeting Hours: "
    TOTAL_MEETING:  .DOUBLE 0
    number_ofMeetings: .DOUBLE 0
    searchCharO:     .asciiz "O"
    label_office: .asciiz "Total Office Hours: "
    Ratio:	  .asciiz "Ratio between Total Lecture And Office Hour is "
    searchCharLT:     .asciiz "L"
    label_lecturesT: .asciiz "Total Lecture Hours: "
    average_lecturesT: .asciiz "Average Lecture Hours: "
    TOTAL_OFFICE:  .DOUBLE 0
    number_ofOffice: .DOUBLE 0
    average_lectures: .DOUBLE 0
    Promptday:      .asciiz "Enter a Day: "
    prompthour: .asciiz "Enter an hour (08-17): "
    result_reserved: .asciiz "The Hour Is Reserved and The Type Is: "
    result_available: .asciiz "The Hour Is Available and Not Reserved.\n"
    promptchar:     .asciiz "Enter a character (L, M, O): "
    inputChar: .space 1    # Variable to store the user input character
    
    
    prompt_adding: .asciiz "Enter Start hour (08-17): "
    prompt2_adding: .asciiz "Enter End hour (08-17): "
    result_conflict_adding: .asciiz "There is a conflict. Please enter the input again.\n"
    result_available_adding: .asciiz "The hour is available.\n"
    result_str_adding:     .space 2048  # Allocate enough space for the result

    string2_adding: .asciiz  "-"
    string3_adding: .asciiz  " ,"
    new_line: .asciiz "\n"
    prompt3_adding:         .asciiz "Enter a character: "
    input_buffer_adding:   .space  2      # Buffer to store the input (including null terminator)
    buffer_adding:         .space  1024           # Buffer to store the read data
    inputPrompt_adding:    .asciiz "Enter data to write to the file: "
    dayPrompt_adding:      .asciiz "Enter a Day: "
    output_filename: .asciiz "C:\\Users\\user\\Desktop\\mips\\test6.txt"

    
    

    # Data sections for menus
    main_menu: .asciiz "Month Calendar\nPlease Choose an Option to Do:\n1- View the Calendar\n2- View Statistics\n3- Add a New Appointment\n4- Delete An Appointment\n"
    view_calendar_menu_str: .asciiz "Please Choose What Do You Want to Do:\n1- View the Calendar Per Day\n2- View the Calendar Per Set of Days\n3- View the Calendar For a Given Slot In a Given Day\n4- Back to the Main Menu\n"
    view_statistics_menu_str: .asciiz "Please Choose What Do You Want to Do:\n1- Total Number of Lectures (In Hours)\n2- Total Number of Meetings (In Hours)\n3- Total Number of Office Hours (In Hours)\n4- The Average Lectures Per Day\n5- Ratio Between Lectures Hours Reserved and Office Hours Reserved\n6- Back to the Main Menu\n"
    

.text
main:
    # Display main menu
    li $v0, 4
    la $a0, main_menu
    syscall

    # Get user choice
    li $v0, 5
    syscall
    move $t0, $v0  # Save user choice in $t0

    # Process user choice
    beq $t0, 1, view_calendar
    beq $t0, 2, view_statistics
    beq $t0, 3, add_appointment
    beq $t0, 4, delete_appointment

view_calendar:
    view_calendar_menu:
    # Display sub-menu for viewing the calendar
    li $v0, 4
    la $a0, view_calendar_menu_str
    syscall

    # Get user choice for viewing the calendar
    li $v0, 5
    syscall
    move $t1, $v0  # Save user choice in $t1

    # Process user choice for viewing the calendar
    beq $t1, 1, view_calendar_per_day
    beq $t1, 2, view_calendar_per_set_of_days
    beq $t1, 3, view_calendar_for_given_slot
    beq $t1, 4, main  # Back to the main menu
    # Add more branches for other options in the sub-menu

view_calendar_per_day:
   retrieve_data:
    # Prompt the user to enter a day
    li $v0, 4             # syscall code for print string = 4
    la $a0, dayPrompt     # load address of the day prompt
    syscall

    # Read user input for the day
    li $v0, 8             # syscall code for read string = 8
    la $a0, buffer        # buffer to store the user input
    li $a1, 256           # maximum number of characters to read
    syscall

    # Convert the entered string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t0, $zero       # initialize $t0 to 0 (to store the result)

convert_loop:
    lb $t1, 0($a0)        # Load the byte at the current position in the string
    beqz $t1, conversion_done  # If it's null (end of string), exit the loop

    # Check if the character is a digit
    blt $t1, 48, conversion_done   # If ASCII value is less than '0', exit the loop
    bgt $t1, 57, conversion_done   # If ASCII value is greater than '9', exit the loop

    # Convert ASCII to integer
    sub $t1, $t1, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t0, $t0, 10      # Multiply current result by base 10
    add $t0, $t0, $t1      # Add the current digit

    addi $a0, $a0, 1       # Move to the next character in the string
    j convert_loop         # Repeat the loop

conversion_done:
    move $t0, $t0         # Move the result to $t0

    # Open file for reading
    li $v0, 13            # open_file syscall code = 13
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s1, $v0         # save the file descriptor in $s1

    # Read lines from the file until the specified day is found
read_day_loop:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s1         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 256           # number of bytes to read
    syscall

    # Check if read was successful
    bgtz $v0, check_day   # branch if read successful

    # If read failed, exit the loop
    j end_read_day_loop

check_day:
    beq $t0, $zero, end_read_day_loop  # If $t0 is 0 (end of file), exit the loop

    # Convert the read string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t1, $zero       # initialize $t1 to 0 (to store the result)

convert_read_loop:
    lb $t2, 0($a1)        # Load the byte at the current position in the string
    beqz $t2, print_data_day   # If it's null (end of string), print the data

    # Check if the character is a digit
    blt $t2, 48, print_data_day   # If ASCII value is less than '0', print the data
    bgt $t2, 57, print_data_day   # If ASCII value is greater than '9', print the data

    # Convert ASCII to integer
    sub $t2, $t2, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t1, $t1, 10      # Multiply current result by base 10
    add $t1, $t1, $t2      # Add the current digit

    addi $a1, $a1, 1       # Move to the next character in the string
    j convert_read_loop   # Repeat the loop

print_data_day:
    # Check if the entered day matches the read day
    beq $t0, $t1, print_data   # If the days match, print the data

    # Repeat the loop until the end of file
    j read_day_loop

print_data:
    # Print the read data to the console
    li $v0, 4             # syscall code for print_str
    la $a0, buffer        # load buffer address
    syscall

    # Repeat the loop until the end of file
    j read_day_loop

end_read_day_loop:
    # Close the file
    li $v0, 16            # system call for close file
    move $a0, $s1         # file descriptor
    syscall
    
    # Jump back to the calendar menu
    j view_calendar

##########################################################################################################################

view_calendar_per_set_of_days:
retrieve_data_loop_set_of_days:
    # Prompt the user to enter a day
    li $v0, 4             # syscall code for print string = 4
    la $a0, dayPrompt_set_of_days     # load address of the day prompt
    syscall

    # Read user input for the day
    li $v0, 8             # syscall code for read string = 8
    la $a0, buffer        # buffer to store the user input
    li $a1, 256           # maximum number of characters to read
    syscall

    # Convert the entered string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t0, $zero       # initialize $t0 to 0 (to store the result)

convert_loop_set_of_days:
    lb $t1, 0($a0)        # Load the byte at the current position in the string
    beqz $t1, conversion_done_set_of_days  # If it's null (end of string), exit the loop

    # Check if the character is a digit
    blt $t1, 48, conversion_done_set_of_days   # If ASCII value is less than '0', exit the loop
    bgt $t1, 57, conversion_done_set_of_days  # If ASCII value is greater than '9', exit the loop

    # Convert ASCII to integer
    sub $t1, $t1, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t0, $t0, 10      # Multiply current result by base 10
    add $t0, $t0, $t1      # Add the current digit

    addi $a0, $a0, 1       # Move to the next character in the string
    j convert_loop_set_of_days         # Repeat the loop

conversion_done_set_of_days:
    move $t0, $t0         # Move the result to $t0
    
    # Check if the entered day is 0 to go back to the view calendar menu
    beqz $t0, view_calendar_menu   # If the entered day is 0, go back to view_calendar_menu

    # Open file for reading
    li $v0, 13            # open_file syscall code = 13
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s1, $v0         # save the file descriptor in $s1

    # Read lines from the file until the specified day is found
    read_day_loop_set_of_days:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s1         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 256           # number of bytes to read
    syscall

    # Check if read was successful
    bgtz $v0, check_day_set_of_days   # branch if read successful

    # If read failed, exit the loop
    j end_read_day_loop_set_of_days

check_day_set_of_days:
    beq $t0, $zero, end_read_day_loop_set_of_days  # If $t0 is 0 (end of file), exit the loop

    # Convert the read string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t1, $zero       # initialize $t1 to 0 (to store the result)

convert_read_loop_set_of_days:
    lb $t2, 0($a1)        # Load the byte at the current position in the string
    beqz $t2, print_data_day_set_of_days   # If it's null (end of string), print the data

    # Check if the character is a digit
    blt $t2, 48, print_data_day_set_of_days   # If ASCII value is less than '0', print the data
    bgt $t2, 57, print_data_day_set_of_days   # If ASCII value is greater than '9', print the data

    # Convert ASCII to integer
    sub $t2, $t2, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t1, $t1, 10      # Multiply current result by base 10
    add $t1, $t1, $t2      # Add the current digit

    addi $a1, $a1, 1       # Move to the next character in the string
    j convert_read_loop_set_of_days   # Repeat the loop

print_data_day_set_of_days:
    # Check if the entered day matches the read day
    beq $t0, $t1, print_data_set_of_days   # If the days match, print the data

    # Repeat the loop until the end of file
    j read_day_loop_set_of_days

print_data_set_of_days:
    
    # Print the read data to the console
    li $v0, 4             # syscall code for print_str
    la $a0, buffer        # load buffer address
    syscall

    # Repeat the loop until the end of file
    j read_day_loop_set_of_days


end_read_day_loop_set_of_days:
    # Close the file
    li $v0, 16            # system call for close file
    move $a0, $s1         # file descriptor
    syscall

    # Repeat the loop to get more input
    j retrieve_data_loop_set_of_days
    
        
##########################################################################################################################

view_calendar_for_given_slot:
    get_day:
    # Prompt the user to enter a day
    li $v0, 4             # syscall code for print string = 4
    la $a0, Promptday    # load address of the day prompt
    syscall

    # Read user input for the day
    li $v0, 8             # syscall code for read string = 8
    la $a0, buffer        # buffer to store the user input
    li $a1, 256           # maximum number of characters to read
    syscall

    # Convert the entered string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t0, $zero       # initialize $t0 to 0 (to store the result)

convert_loop_view:
    lb $t1, 0($a0)        # Load the byte at the current position in the string
    beqz $t1, conversion_done_view # If it's null (end of string), exit the loop

    # Check if the character is a digit
    blt $t1, 48, conversion_done_view  # If ASCII value is less than '0', exit the loop
    bgt $t1, 57, conversion_done_view  # If ASCII value is greater than '9', exit the loop

    # Convert ASCII to integer
    sub $t1, $t1, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t0, $t0, 10      # Multiply current result by base 10
    add $t0, $t0, $t1      # Add the current digit

    addi $a0, $a0, 1       # Move to the next character in the string
    j convert_loop_view         # Repeat the loop

conversion_done_view:
    move $t0, $t0         # Move the result to $t0

    # Open file for reading
    li $v0, 13            # open_file syscall code = 13
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s1, $v0         # save the file descriptor in $s1

    # Read lines from the file until the specified day is found
read_day_loop_view:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s1         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 256           # number of bytes to read
    syscall

    # Check if read was successful
    bgtz $v0, check_day_view   # branch if read successful

check_day_view:
   
    # Convert the read string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t1, $zero       # initialize $t1 to 0 (to store the result)

convert_read_loop_view:
    lb $t2, 0($a1)        # Load the byte at the current position in the string
    beqz $t2, print_data_day_view   # If it's null (end of string), print the data

    # Check if the character is a digit
    blt $t2, 48, print_data_day_view   # If ASCII value is less than '0', print the data
    bgt $t2, 57, print_data_day_view   # If ASCII value is greater than '9', print the data

    # Convert ASCII to integer
    sub $t2, $t2, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t1, $t1, 10      # Multiply current result by base 10
    add $t1, $t1, $t2      # Add the current digit

    addi $a1, $a1, 1       # Move to the next character in the string
    j convert_read_loop_view   # Repeat the loop

print_data_day_view:
    # Check if the entered day matches the read day
    beq $t0, $t1, print_data_view   # If the days match, print the data

    # Repeat the loop until the end of file
    j read_day_loop_view

print_data_view:
    # Print the read data to the console
    li $v0, 4             # syscall code for print_str
    la $a0, buffer        # load buffer address
    syscall

    # Display prompt for the hour
    li $v0, 4
    la $a0, prompthour
    syscall

    # Get user input for the hour
    li $v0, 5
    syscall
    move $t0, $v0  # $t0 contains the user input hour
    

    # Call a function to check for reserveds for the hour
    jal check_reserved_view

    # Exit program
    li $v0, 10
    syscall

# Function to check for reserveds
check_reserved_view:
    # Initialize variables
     la $a1, buffer  # Load the string address into $a1


 appointment_loop_view:
 
            lb $t1, 0($a1)  # Load the current character
            beqz $t1, exit  # Exit the loop if end of string

            # Check for the start of a line (index indication)
            beq $t1, ':', loop_view
            addi $a1, $a1, 1   # Move to the next character
            j appointment_loop_view
    # Loop through the string
   loop_view:
  	   addi $a1, $a1, 1
  nested_loop_view:
      addi $a1, $a1, 1
       lb $t3, 0($a1)  # Load a character from the string
       beq $t3 ,'O' ,letter2_view 
        beq $t3 ,'L' ,letter_view
        beq $t3 ,'M' ,letter_view
        # Read the hour from the string
        beqz $t3, end_loop_view  # If the character is null, end the loop
        sub $t3, $t3, 48  # Convert ASCII to integer
       #-------------------------
        bnez $t3,not_zero_view
        addi $a1 , $a1 , 1
        lb $t3, 0($a1)
        subi $t3, $t3, 48  
         beq $t3 , $t0 , equal_view        
        blt $t3, $t0, next_appointment_view  # If the hour is less than the user input, check the next appointment

        # Check for reserved
     check_view:
        lb $t4, -2($a1)  # Load the character before the found appointment hour
        beq $t4, 45, reserved_view # If the character is "-", there is a reserved
        j end_loop_view  # If the character is not "-", the hour is available

    # Check the next appointment
    next_appointment_view:
        addi $a1, $a1, 1  # Skip the space and move to the next character
        j nested_loop_view
        
    letter_view:
       addi $a1, $a1, 2
       j nested_loop_view
       
     letter2_view:
       addi $a1, $a1, 3
       j nested_loop_view
    

    # Handle reserveds
    reserved_view:
    	# move two steps to reach the character
	lb $t4, 2($a1)
	
	# Check if the loaded byte is 'O'
	li $t5, 'O'        # ASCII value of 'O'
	beq $t4, $t5, is_O  # Branch to is_O if $t4 is equal to 'O'
	
        li $v0, 4
        la $a0, result_reserved # print result resreved
        syscall
        
        # Print the character reached
	li $v0, 11         # System call code for printing a character
	move $a0, $t4      # Load the byte to be printed into $a0
	syscall            # Make the system call
	
	# Print newline
    	li $v0, 4             # syscall code for print_str
    	la $a0, newline
    	syscall
       
        j view_calendar
        
        # fuction to add H to the O to be printed OH
        is_O:
        # Print 'O'
        li $v0, 4
        la $a0, result_reserved
        syscall

	li $v0, 11         # System call code for printing a character
	move $a0, $t4      # Load the byte 'O' to be printed
	syscall  
        
	# Print 'H' beside 'O'
	li $v0, 11         # System call code for printing a character
	li $a0, 'H'        # Load 'H' to be printed
	syscall            # Make the system call
	
	# Print newline
    	li $v0, 4             # syscall code for print_str
    	la $a0, newline
    	syscall

        j view_calendar
        
     reserved_for_equal_view:
        # Load the byte from memory
	lb $t4, 5($a1) # move five steps to reach the character
	
	# Check if the loaded byte is 'O'
	li $t5, 'O'        # ASCII value of 'O'
	beq $t4, $t5, is_O  # Branch to is_O if $t4 is equal to 'O'
	
        li $v0, 4
        la $a0, result_reserved
        syscall
        # Print the char
	li $v0, 11         # System call code for printing a character
	move $a0, $t4      # Load the byte to be printed into $a0
	syscall            # Make the system call
	
	# Print newline
    	li $v0, 4             # syscall code for print_str
    	la $a0, newline
    	syscall
        
        j view_calendar
        
 
    not_zero_view:
	addi $a1 , $a1 , 1
	lb $t3, 0($a1)
	subi $t3, $t3, 48   
	addi $t3, $t3 , 10
	beq $t3 , $t0 , equal_view 
	blt $t3, $t0, next_appointment_view
	j check_view

    # End of loop
    end_loop_view:
        li $v0, 4
        la $a0, result_available
        syscall

    # Exit the function
    exit:
        jr $ra
        
        
       equal_view:
    lb $t4, 1($a1)  # Load the character before the found appointment hour
    beq $t4, 45, reserved_for_equal_view # If the character is "-", there is a conflict
    j next_appointment_view
    
    

##########################################################################################################################

view_statistics:
    view_statistics_menu:
    
    # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall
    
    # Display sub-menu for viewing statistics
    li $v0, 4
    la $a0, view_statistics_menu_str
    syscall

    # Get user choice for viewing statistics
    li $v0, 5
    syscall
    move $t2, $v0  # Save user choice in $t2

    # Process user choice for viewing statistics
    beq $t2, 1, total_lectures
    beq $t2, 2, total_meetings
    beq $t2, 3, total_office_hours
    beq $t2, 4, average_lectures_per_day
    beq $t2, 5, lectures_office_hours_ratio
    beq $t2, 6, main  # Back to the main menu
    # Add more branches for other options in the sub-menu

##########################################################################################################################

total_lectures:
li $t5, 0
    li $t8, 0
    li $t9, 0
    

    # Open file for reading
    li $v0, 13            # syscall code for open_file
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s0, $v0         # save the file descriptor in $s0

read_loop:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s0         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 1024          # number of bytes to read
    syscall

    # Check if read was successful
    beqz $v0, close_file  # exit if end of file

    # Check if 'L' is present in the line
    la $a0, buffer        # load buffer address
    la $a1, searchCharL    # load searchChar address
    jal contains_char

   
    j read_loop



close_file:

    # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

    # Print label for lecture hours
    li $v0, 4             # syscall code for print_str
    la $a0, label_lectures
    syscall

    # Print the total lecture hours
    move $a0, $t8
    li $v0, 1             # syscall code for print_int
    syscall
    
      # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall
    
    mtc1 $t8, $f8          # Move integer from $t0 to floating-point register $f0
    mtc1 $t9, $f9 
    div.s $f9,$f8 , $f9 
    li $v0, 2
    
    # Close the file
    li $v0, 16            # syscall code for close file
    move $a0, $s0         # file descriptor
    syscall
    
    # Jump back to the statistics menu
    j view_statistics_menu

# Function to check if a character is present in a string
contains_char:
    lb $t0, 0($a0)        # Load the first character from the string

contains_loop:
    beqz $t0, char_not_found  # Exit loop if end of string
    beq $t0, 10, char_not_found # Exit loop if newline character is encountered

    # Compare the current character with the search character
    lb $t1, 0($a1)        # Load the search character
    bne $t0, $t1, next_char2
    
    beq $t0, $t1,  check_hours
    # If characters match, set $v0 to 1 and return
    

next_char2:
    addi $a0, $a0, 1      # Move to the next character in the string
    lb $t0, 0($a0)        # Load the next character
    j contains_loop

char_not_found:
    # If the character is not found, set $v0 to 0
    li $v0, 0
    jr $ra


 check_hours:
        # Move to the first character of the hours
        subi $a0, $a0, 6

        # Load the first and second characters of the hours
        lb $t1, 0($a0)        # Load the ASCII character from memory into $t1
        li $t7, '0'           # Load the ASCII value of '0' into register $t7
        sub $t1, $t1, $t7     # Subtract the ASCII value of '0' from the loaded character
        bnez $t1,not_zero
        addi $a0 , $a0 , 1
        lb $t3, 0($a0)
        sub $t3, $t3, $t7 
        
          #*****next number*****  
      next_num: 
         addi $a0 , $a0 , 2
        lb $t4, 0($a0)
        sub $t4, $t4, $t7   
         bnez $t4,not_zero2
        addi $a0 , $a0 , 1
        lb $t4, 0($a0)
        sub $t4, $t4, $t7 
        
        
	not_zero:
		addi $a0 , $a0 , 1
		lb $t3, 0($a0)
		sub $t3, $t3, $t7   
		addi $t3, $t3 , 10
		j next_num
		
	
	not_zero2:
		addi $a0 , $a0 , 1
		lb $t4, 0($a0)
		sub $t4, $t4, $t7   
		addi $t4, $t4 , 10

process_lecture:
        # Calculate lecture hours by subtracting the first hour from the second hour
        sub $t5, $t4, $t3

        # Accumulate the result in $t0
        add $t8, $t8, $t5
        li $v0, 1
    	jr $ra
    	
##########################################################################################################################

total_meetings:
li $t5, 0
    li $t8, 0
    li $t9, 0
    

    # Open file for reading
    li $v0, 13            # syscall code for open_file
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s0, $v0         # save the file descriptor in $s0

read_loopM:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s0         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 1024          # number of bytes to read
    syscall

    # Check if read was successful
    beqz $v0, close_fileM  # exit if end of file

    # Check if 'M' is present in the line
    la $a0, buffer        # load buffer address
    la $a1, searchCharM    # load searchChar address
    jal contains_charM
    j read_loopM

close_fileM:

    # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

    # Print label for lecture hours
    li $v0, 4             # syscall code for print_str
    la $a0, label_meetings
    syscall

    # Print the total meeting hours
    move $a0, $t8
    li $v0, 1             # syscall code for print_int
    syscall
    
      # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall
    
    # Close the file
    li $v0, 16            # syscall code for close file
    move $a0, $s0         # file descriptor
    syscall

    # Jump back to the statistics menu
    j view_statistics_menu

# Function to check if a character is present in a string
contains_charM:
    lb $t0, 0($a0)        # Load the first character from the string

contains_loopM:
    beqz $t0, char_not_foundM  # Exit loop if end of string
    beq $t0, 10, char_not_foundM # Exit loop if newline character is encountered

    # Compare the current character with the search character
    lb $t1, 0($a1)        # Load the search character
    bne $t0, $t1, next_char2M
    
    beq $t0, $t1,  check_hoursM
    # If characters match, set $v0 to 1 and return
    

next_char2M:
    addi $a0, $a0, 1      # Move to the next character in the string
    lb $t0, 0($a0)        # Load the next character
    j contains_loopM

char_not_foundM:
    # If the character is not found, set $v0 to 0
    li $v0, 0
    jr $ra


 check_hoursM:
        # Move to the first character of the hours
        subi $a0, $a0, 6

        # Load the first and second characters of the hours
        lb $t1, 0($a0)        # Load the ASCII character from memory into $t1
        li $t7, '0'           # Load the ASCII value of '0' into register $t7
        sub $t1, $t1, $t7     # Subtract the ASCII value of '0' from the loaded character
        bnez $t1,not_zeroM
        addi $a0 , $a0 , 1
        lb $t3, 0($a0)
        sub $t3, $t3, $t7 
        
          #*****next number*****  
      next_numM: 
         addi $a0 , $a0 , 2
        lb $t4, 0($a0)
        sub $t4, $t4, $t7   
         bnez $t4,not_zero2M
        addi $a0 , $a0 , 1
        lb $t4, 0($a0)
        sub $t4, $t4, $t7 
        
        
	not_zeroM:
		addi $a0 , $a0 , 1
		lb $t3, 0($a0)
		sub $t3, $t3, $t7   
		addi $t3, $t3 , 10
		j next_numM
		
	
	not_zero2M:
		addi $a0 , $a0 , 1
		lb $t4, 0($a0)
		sub $t4, $t4, $t7   
		addi $t4, $t4 , 10


process_meeting:
        # Calculate meeting hours by subtracting the first hour from the second hour
        sub $t5, $t4, $t3

        # Accumulate the result in $t0
        add $t8, $t8, $t5
        li $v0, 1
    	jr $ra   

##########################################################################################################################

total_office_hours:
    li $t5, 0
    li $t8, 0
    li $t9, 0
    

    # Open file for reading
    li $v0, 13            # syscall code for open_file
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s0, $v0         # save the file descriptor in $s0

read_loopO:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s0         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 1024          # number of bytes to read
    syscall

    # Check if read was successful
    beqz $v0, close_fileO  # exit if end of file

    # Check if 'O' is present in the line
    la $a0, buffer        # load buffer address
    la $a1, searchCharO    # load searchChar address
    jal contains_charO
    j read_loopO

close_fileO:

    # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

    # Print label for offiec hours
    li $v0, 4             # syscall code for print_str
    la $a0, label_office
    syscall

    # Print the total office hours
    mfc1  $t8 , $f3
    move $a0, $t8
    li $v0, 1             # syscall code for print_int
    syscall
    
      # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

    # Close the file
    li $v0, 16            # syscall code for close file
    move $a0, $s0         # file descriptor
    syscall
    
    # Jump back to the statistics menu
    j view_statistics_menu

# Function to check if a character is present in a string
contains_charO:
    lb $t0, 0($a0)        # Load the first character from the string

contains_loopO:
    beqz $t0, char_not_foundO  # Exit loop if end of string
    beq $t0, 10, char_not_foundO # Exit loop if newline character is encountered

    # Compare the current character with the search character
    lb $t1, 0($a1)        # Load the search character
    bne $t0, $t1, next_char2O
    
    beq $t0, $t1,  check_hoursO
    # If characters match, set $v0 to 1 and return
    

next_char2O:
    addi $a0, $a0, 1      # Move to the next character in the string
    lb $t0, 0($a0)        # Load the next character
    j contains_loopO

char_not_foundO:
    # If the character is not found, set $v0 to 0
    li $v0, 0
    jr $ra


 check_hoursO:
        # Move to the first character of the hours
        subi $a0, $a0, 6

        # Load the first and second characters of the hours
        lb $t1, 0($a0)        # Load the ASCII character from memory into $t1
        li $t7, '0'           # Load the ASCII value of '0' into register $t7
        sub $t1, $t1, $t7     # Subtract the ASCII value of '0' from the loaded character
        bnez $t1,not_zeroO
        addi $a0 , $a0 , 1
        lb $t3, 0($a0)
        sub $t3, $t3, $t7 
        
          #*****next number*****  
      next_numO: 
         addi $a0 , $a0 , 2
        lb $t4, 0($a0)
        sub $t4, $t4, $t7   
         bnez $t4,not_zero2O
        addi $a0 , $a0 , 1
        lb $t4, 0($a0)
        sub $t4, $t4, $t7 
        
        
	not_zeroO:
		addi $a0 , $a0 , 1
		lb $t3, 0($a0)
		sub $t3, $t3, $t7   
		addi $t3, $t3 , 10
		j next_numO
		
	
	not_zero2O:
		addi $a0 , $a0 , 1
		lb $t4, 0($a0)
		sub $t4, $t4, $t7   
		addi $t4, $t4 , 10


process_officeO:
        # Calculate officehours by subtracting the first hour from the second hour
        sub $t5, $t4, $t3

        # Accumulate the result in $t0
        add $t8, $t8, $t5
        li $v0, 1
    	jr $ra    

##########################################################################################################################

average_lectures_per_day:
       li $t5, 0
    li $t8, 0
    li $t9, 0
    

    # Open file for reading
    li $v0, 13            # syscall code for open_file
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s0, $v0         # save the file descriptor in $s0

read_loopT:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s0         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 1024          # number of bytes to read
    syscall

    # Check if read was successful
    beqz $v0, close_fileT  # exit if end of file

    # Check if 'L' is present in the line
    la $a0, buffer        # load buffer address
    la $a1, searchCharLT    # load searchChar address
    jal contains_charT

    # Print the line if 'L' is found
    bnez $v0, printT

    j read_loopT

printT:
  
    # Print the line
    li $v0, 4             # syscall code for print_str
    la $a0, buffer        # load buffer address
    syscall

    # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

    j read_loopT

close_fileT:
    # Print label for lecture hours
    li $v0, 4             # syscall code for print_str
    la $a0, label_lecturesT
    syscall

    # Print the total lecture hours
    move $a0, $t8
    li $v0, 1             # syscall code for print_int
    syscall
    
      # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall
    
     move $a0, $t9
    li $v0, 1             # syscall code for print_int
    syscall

 # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

#calculate the average hours 
 li $v0, 4             # syscall code for print_str
    la $a0, average_lecturesT
    syscall
    
    div $t9 , $t8 , $t9 
     move $a0, $t9
    li $v0, 1             # syscall code for print_int
    syscall

    # Close the file
    li $v0, 16            # syscall code for close file
    move $a0, $s0         # file descriptor
    syscall

    # Jump back to the statistics menu
    j view_statistics_menu

# Function to check if a character is present in a string
contains_charT:
    lb $t0, 0($a0)        # Load the first character from the string

contains_loopT:
    beqz $t0, char_not_foundT  # Exit loop if end of string
    beq $t0, 10, char_not_foundT # Exit loop if newline character is encountered

    # Compare the current character with the search character
    lb $t1, 0($a1)        # Load the search character
    bne $t0, $t1, next_char2T
    
    beq $t0, $t1,  check_hoursT
    # If characters match, set $v0 to 1 and return
    

next_char2T:
    addi $a0, $a0, 1      # Move to the next character in the string
    lb $t0, 0($a0)        # Load the next character
    j contains_loopT

char_not_foundT:
    # If the character is not found, set $v0 to 0
    li $v0, 0
    jr $ra


 check_hoursT:
        # Move to the first character of the hours
        subi $a0, $a0, 6

        # Load the first and second characters of the hours
        lb $t1, 0($a0)        # Load the ASCII character from memory into $t1
        li $t7, '0'           # Load the ASCII value of '0' into register $t7
        sub $t1, $t1, $t7     # Subtract the ASCII value of '0' from the loaded character
        bnez $t1,not_zeroT
        addi $a0 , $a0 , 1
        lb $t3, 0($a0)
        sub $t3, $t3, $t7 
        
          #*****next number*****  
      next_numT: 
         addi $a0 , $a0 , 2
        lb $t4, 0($a0)
        sub $t4, $t4, $t7   
         bnez $t4,not_zero2T
        addi $a0 , $a0 , 1
        lb $t4, 0($a0)
        sub $t4, $t4, $t7 
        
        
	not_zeroT:
		addi $a0 , $a0 , 1
		lb $t3, 0($a0)
		sub $t3, $t3, $t7   
		addi $t3, $t3 , 10
		j next_numT
		
	
	not_zero2T:
		addi $a0 , $a0 , 1
		lb $t4, 0($a0)
		sub $t4, $t4, $t7   
		addi $t4, $t4 , 10


process_lectureT:
        # Calculate lecture hours by subtracting the first hour from the second hour
        sub $t5, $t4, $t3

        # Accumulate the result in $t0
            addi $t9 , $t9 , 1
        add $t8, $t8, $t5
        li $v0, 1
    	jr $ra
#############################################################################################################
lectures_office_hours_ratio:
    li $v0, 4             # syscall code for print_str
    la $a0, Ratio        # load buffer address
    syscall
    
    
   div.s $f6,$f8 ,$f3 
    li $v0, 2
    # Jump back to the statistics menu
    j view_statistics_menu
    

#############################################################################################################
add_appointment:

retrieve_data_adding:
    # Prompt the user to enter a day
    li $v0, 4             # syscall code for print string = 4
    la $a0, dayPrompt_adding    # load address of the day prompt
    syscall

    # Read user input for the day
    li $v0, 8             # syscall code for read string = 8
    la $a0, buffer_adding        # buffer to store the user input
    li $a1, 256           # maximum number of characters to read
    syscall

    # Convert the entered string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t0, $zero       # initialize $t0 to 0 (to store the result)

convert_loop_adding:
    lb $t1, 0($a0)        # Load the byte at the current position in the string
    beqz $t1, conversion_done_adding  # If it's null (end of string), exit_addingthe loop

    # Check if the character is a digit
    blt $t1, 48, conversion_done_adding   # If ASCII value is less than '0', exit_addingthe loop
    bgt $t1, 57, conversion_done_adding   # If ASCII value is greater than '9', exit_addingthe loop

    # Convert ASCII to integer
    sub $t1, $t1, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t0, $t0, 10      # Multiply current result by base 10
    add $t0, $t0, $t1      # Add the current digit

    addi $a0, $a0, 1       # Move to the next character in the string
    j convert_loop_adding         # Repeat the loop

conversion_done_adding:
    move $t0, $t0         # Move the result to $t0

    # Open file for reading
    li $v0, 13            # open_file syscall code = 13
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s1, $v0         # save the file descriptor in $s1

    # Read lines from the file until the specified day is found
read_day_loop_adding:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s1         # file descriptor
    la $a1, buffer_adding        # buffer to read into
    li $a2, 256           # number of bytes to read
    syscall

    # Check if read was successful
    bgtz $v0, check_day_adding   # branch if read successful



check_day_adding: 
    beq $t0, $zero, Start_adding  # If $t0 is 0 (end of file), exit_addingthe loop

    # Convert the read string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t1, $zero       # initialize $t1 to 0 (to store the result)

convert_read_loop_adding:
    lb $t2, 0($a1)        # Load the byte at the current position in the string
    beqz $t2, print_data_day_adding   # If it's null (end of string), print the data

    # Check if the character is a digit
    blt $t2, 48, print_data_day_adding   # If ASCII value is less than '0', print the data
    bgt $t2, 57, print_data_day_adding   # If ASCII value is greater than '9', print the data

    # Convert ASCII to integer
    sub $t2, $t2, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t1, $t1, 10      # Multiply current result by base 10
    add $t1, $t1, $t2      # Add the current digit

    addi $a1, $a1, 1       # Move to the next character in the string
    j convert_read_loop_adding   # Repeat the loop

print_data_day_adding:
    # Check if the entered day matches the read day
    beq $t0, $t1, print_data_adding   # If the days match, print the data

    # Repeat the loop until the end of file
    j read_day_loop_adding

print_data_adding:
    # Print the read data to the console
    li $v0, 4             # syscall code for print_str
    la $a0, buffer_adding        # load buffer address
    syscall


Start_adding:
    la $a2, result_str_adding
    la $t9, string2_adding
    la $s2, string3_adding
    # Display prompt for the first hour
    li $v0, 4
    la $a0, prompt_adding
    syscall

    # Get user input for the first hour
    li $v0, 5
    syscall
    move $t0, $v0  # $t0 contains the user input hour
    move $a3 , $v0
    

    # Call a function to check for conflicts for the first hour
    jal check_conflict_adding

    # If there is a conflict, ask the user to enter the input again
    beq $v0, 1, main
    
     li $v0, 4
    la $a0, new_line
    syscall
    

    # Display prompt for the second hour
    li $v0, 4
    la $a0, prompt2_adding
    syscall

    # Get user input for the second hour
    li $v0, 5
    syscall
    move $t0, $v0  # $t0 contains the user input hour
    move $s1, $v0  # $t0 contains the user input hour
    # Call the check_conflict function again for the second hour
 jal check_conflict2_adding
    
    # If there is a conflict, ask the user to enter the input again
    beq $v0, 1, main

    # Exit program
    li $v0, 10
    syscall

# Function to check for conflicts
check_conflict_adding:
    # Initialize variables
     la $a1, buffer_adding # Load the string address into $a1

 appointment_loop_adding:
            lb $t3, 0($a1)  # Load the current character
             sb $t3, 0($a2)
            beqz $t3, exit_adding # Exit the loop if end of string

            # Check for the start of a line (index indication)
            beq $t3, ':', loop_adding
            addiu $a1, $a1, 1   # Move to the next character
             addiu $a2, $a2, 1
            j appointment_loop_adding
    # Loop through the string
    
   loop_adding:
  	   addiu $a1, $a1, 1
  	   addiu $a2, $a2, 1
           lb $t3, 0($a1)
           sb $t3, 0($a2)
  nested_loop_adding:
       addiu $a1, $a1, 1
       addiu $a2, $a2, 1
       lb $t3, 0($a1)  # Load a character from the string
       sb $t3, 0($a2)
       beq $t3 ,'O' ,letter2_adding 
        beq $t3 ,'L' ,letter_adding
        beq $t3 ,'M' ,letter_adding
        # Read the hour from the string
        beqz $t3, end_loop_adding  # If the character is null, end the loop
        sub $t3, $t3, 48  # Convert ASCII to integer
       #-------------------------
        bnez $t3,not_zero_adding
        addiu $a1 , $a1 , 1
        addiu $a2, $a2, 1
         lb $t3, 0($a1)
        sb $t3, 0($a2)
        subi $t3, $t3, 48  
         beq $t3 , $t0 , equal_adding        
        blt $t3, $t0, next_appointment_adding  # If the hour is less than the user input, check the next appointment

        # Check for conflict
     check_adding:
        lb $t4, -2($a1)  # Load the character before the found appointment hour
        beq $t4, 45, conflict_adding  # If the character is "-", there is a conflict
       j end_loop_adding    # If the character is not "-", the hour is available

    # Check the next appointment
    next_appointment_adding:
        addiu $a1, $a1, 1  # Skip the space and move to the next character
        addiu $a2, $a2, 1
        lb $t3, 0($a1)
        sb $t3, 0($a2)
        j nested_loop_adding
        
    letter_adding:
       addiu $a1, $a1, 1
       addiu $a2, $a2, 1
        lb $t3, 0($a1)
        sb $t3, 0($a2)
         addiu $a1, $a1, 1
       addiu $a2, $a2, 1
        lb $t3, 0($a1)
        sb $t3, 0($a2)
       j nested_loop_adding
       
     letter2_adding:
       addiu $a1, $a1, 1
       addiu $a2, $a2, 1
        lb $t3, 0($a1)
        sb $t3, 0($a2)
       addiu $a1, $a1, 1
       addiu $a2, $a2, 1
        lb $t3, 0($a1)
        sb $t3, 0($a2)
        addiu $a1, $a1, 1
       addiu $a2, $a2, 1
        lb $t3, 0($a1)
        sb $t3, 0($a2)
       j nested_loop_adding


    # Handle conflicts
    conflict_adding:
        li $v0, 4
        la $a0, result_conflict_adding
        syscall
        li $v0, 1
        li $a0, 1
        syscall  # Prompt for user input (you may need to adjust this depending on your environment)
        j exit_adding
        
        
    not_zero_adding:
	addiu $a1 , $a1 , 1
	addiu $a2 , $a2 , 1
	lb $t3, 0($a1)
	sb $t3, 0($a2)
	subi $t3, $t3, 48   
	addi $t3, $t3 , 10
	beq $t3 , $t0 , equal_adding 
	blt $t3, $t0, next_appointment_adding
	j check_adding

    # End of loop
     end_loop_adding:
     subiu $a1 , $a1 , 1
     subiu $a2 , $a2 , 1
      subiu $a2 , $a2 , 1
    li $t6 ,10
	bge  $t0 ,$t6 , greater_than10_adding 
      addiu $a2 , $a2 , 1
     addiu $t0, $t0, 48 
     sb $t0, 0($a2)
     addiu $a2 , $a2 , 1
     lb $t3, 0($t9)
     sb $t3, 0($a2)
        
     li $v0, 4
     la $a0, result_available_adding
     syscall
     
     li $v0, 4
     la $a0, result_str_adding
     syscall
       
     jr $ra
    # Exit the function
    exit_adding:
        jr $ra        
        
       equal_adding:
    lb $t4, 1($a1)  # Load the character before the found appointment hour
    beq $t4, 45, conflict_adding  # If the character is "-", there is a conflict
    
        addiu $a1 , $a1 , 1
	addiu $a2 , $a2 , 1
	lb $t3, 0($a1)
	sb $t3, 0($a2)
	
	addiu $a1 , $a1 , 1
	addiu $a2 , $a2 , 1
	lb $t3, 0($a1)
	sb $t3, 0($a2)
	
	addiu $a1 , $a1 , 1
	addiu $a2 , $a2 , 1
	lb $t3, 0($a1)
	sb $t3, 0($a2)
	
	addiu $a1 , $a1 , 1
	addiu $a2 , $a2 , 1
	lb $t3, 0($a1)
	sb $t3, 0($a2)
	
	li $t6 ,10
	bge  $t0 ,$t6 , greater_than10_adding 
	addiu $t0, $t0, 48 
      addiu $a2 , $a2 , 1
      sb $t0, 0($a2)
       addiu $a2 , $a2 , 1
       lb $t3, 0($t9)
       sb $t3, 0($a2)
       
       
        move $a0, $t0
     li $v0, 1        # Print string service
        syscall
        
       li $v0, 4        # Print string service
        la $a0, result_available_adding
        syscall 
 
	   
	li $v0, 4        # Print string service
        la $a0, result_str_adding
        syscall 
     jr $ra  
     
     
     
     greater_than10_adding:
     addiu $a2 , $a2 , 1
     subi $t0 , $t0 , 10
     addiu $t0, $t0, 48 
     li $t5 , 1 
    addiu $t5, $t5, 48
    sb $t5, 0($a2)
    addiu $a2 , $a2 , 1
    sb $t0, 0($a2)
    addiu $a2 , $a2 , 1
    lb $t3, 0($t9)
    sb $t3, 0($a2)
     
        
       li $v0, 4        # Print string service
        la $a0, result_available_adding
        syscall 
 
	   
	li $v0, 4        # Print string service
        la $a0, result_str_adding
        syscall 
        
        
     jr $ra  
    

    
    
       ####################################################################
        ###############################################################
        ##################################################################
        
   
   check_conflict2_adding:
      la $a3, buffer_adding # Load the string address into $a1


 appointment_loop2_adding:
 
            lb $t3, 0($a3)  # Load the current character
            beqz $t3, exit_adding # Exit the loop if end of string

            # Check for the start of a line (index indication)
            beq $t3, ':', loop2_adding
            addi $a3, $a3, 1   # Move to the next character
            j appointment_loop2_adding
    # Loop through the string
   loop2_adding:
  	   addi $a3, $a3, 1
  nested_loop2_adding:
      addi $a3, $a3, 1
       lb $t3, 0($a3)  # Load a character from the string
       beq $t3 ,'O' ,letter21_adding 
        beq $t3 ,'L' ,letter1_adding
        beq $t3 ,'M' ,letter1_adding
        # Read the hour from the string
        beqz $t3, end_loop2_adding  # If the character is null, end the loop
        sub $t3, $t3, 48  # Convert ASCII to integer
       #-------------------------
        bnez $t3,not_zero2_adding
        addi $a3 , $a3 , 1
        lb $t3, 0($a3)
        subi $t3, $t3, 48         
        blt $t3, $t0, next_appointment2_adding  # If the hour is less than the user input, check the next appointment
	beq $t3, $t0 , equalEnd_adding
        # Check for conflict
     check2_adding:
        lb $t4, -2($a3)  # Load the character before the found appointment hour
        beq $t4, 45, conflict2_adding  # If the character is "-", there is a conflict
        j end_loop2_adding  # If the character is not "-", the hour is available

    # Check the next appointment
    next_appointment2_adding:
        addi $a3, $a3, 1  # Skip the space and move to the next character
        j nested_loop2_adding
        
    letter1_adding:
       addi $a3, $a3, 2
       j nested_loop2_adding
       
     letter21_adding:
       addi $a3, $a3, 3
       j nested_loop2_adding

    # Handle conflicts
    conflict2_adding:
        li $v0, 4
        la $a0, result_conflict_adding
        syscall
        li $v0, 1
        li $a0, 1
        syscall  # Prompt for user input (you may need to adjust this depending on your environment)
        j exit_adding
        
        
    not_zero2_adding:
	addiu $a3 , $a3 , 1
	lb $t3, 0($a3)
	subi $t3, $t3, 48   
	addi $t3, $t3 , 10
	blt $t3, $t0, next_appointment2_adding
	beq $t3, $t0 , equalEnd_adding
	j check2_adding

    # End of loop
    end_loop2_adding:  
     bge  $t0 ,10 , greater_than10.2_adding
     addiu $a2 , $a2 , 1 
     addiu $t0, $t0, 48 
     sb $t0, 0($a2)
      addiu $a2 , $a2 , 1
        
     li $v0, 4
     la $a0, result_available_adding
     syscall
      
         li $v0, 4            # System call for print_str
         la $a0, prompt3_adding       # Load the address of the prompt string
        syscall
        li      $v0, 8            # System call for read_str
        la      $a0, input_buffer_adding # Load the address of the buffer
        li      $a3, 2            # Specify the buffer size
        syscall
     
        lb $a0, input_buffer_adding # Load the entered character from the buffer
	sb $a0 , 0($a2)
         addiu $a2, $a2, 1
         
           lb $a0, 0($s2)
           sb $a0, 0($a2)
           addiu $a2, $a2, 1 
           
             lb $a0, 1($s2)
           sb $a0, 0($a2)
           addiu $a2, $a2, 1 
        j  copy_original_adding
      j  copy_original_adding
    
  greater_than10.2_adding:
     addiu $a2 , $a2 , 1
     subi $t0 , $t0 , 10
     addiu $t0, $t0, 48 
     li $t5 , 1 
    addiu $t5, $t5, 48
    sb $t5, 0($a2)
    addiu $a2 , $a2 , 1
    sb $t0, 0($a2)
    addiu $a2 , $a2 , 1
    
   
       li $v0, 4        # Print string service
        la $a0, result_available_adding
        syscall 
        
         li $v0, 4            # System call for print_str
         la $a0, prompt3_adding       # Load the address of the prompt string
        syscall

        li      $v0, 8            # System call for read_str
        la      $a0, input_buffer_adding # Load the address of the buffer
        li      $a3, 2            # Specify the buffer size
        syscall
     
        lb $a0, input_buffer_adding # Load the entered character from the buffer
	sb $a0 , 0($a2)
         addiu $a2, $a2, 1
         
           lb $a0, 0($s2)
           sb $a0, 0($a2)
           addiu $a2, $a2, 1 
           
             lb $a0, 1($s2)
           sb $a0, 0($a2)
           addiu $a2, $a2, 1 
        j  copy_original_adding


    # Exit the function
    exit2:
        jr $ra
        
     
    equalEnd_adding:
     lb $t4, -2($a3)  # Load the character before the found appointment hour
     beq $t4, 45, conflict2_adding
     bge  $t0 ,10 , greater_than10.2_adding 
     addiu $t0, $t0, 48 
     sb $t0, 0($a2)
     
     addiu $a2 , $a2 , 1
     lb $t3, 0($t9)
     sb $t3, 0($a2)
        
     li $v0, 4
     la $a0, result_available_adding
     syscall
     
     li $v0, 4
     la $a0, result_str_adding
     syscall
       
     jr $ra

          la $a0, new_line
     li $v0, 4        # Print string service
        syscall  
        
     la $a0, result_str_adding
     li $v0, 4        # Print string service
        syscall
        
        
       
          #------------------------------------------------------------------
    #------------------------------------------------------------------
    #------------------------------------------------------------------
    #------------------------------------------------------------------
      copy_original_adding:

        # Copy character from the original string to result
        lb $t3, 0($a1)   # Load character from original string
        beqz $t3, end_insertion_adding
        sb $t3, 0($a2)
        addiu $a1, $a1, 1  # Move to the next character in the original string
        addiu $a2, $a2, 1  # Move to the next position in the result string
        j  copy_original_adding
     
 

    end_insertion_adding:
    
# Close the file
li $v0, 16            # syscall code for close file
move $a0, $s2         # file descriptor
syscall
      
        li $v0, 4        # Print string service
        la $a0, result_str_adding
        syscall
        
        
        
# Open file for writing
li $v0, 13            # open_file syscall code = 13
la $a0, output_filename      # get the file name
li $a1, 1             # open for writing (1)
li $a2, 0             # file permission (ignored for writing)
syscall
move $s2, $v0         # save the file descriptor in $s2

# Print data to the file
li $v0, 15            # syscall code for write file
move $a0, $s2         # file descriptor
la $a1, result_str_adding    # buffer containing the data to write
li $a2, 2048          # number of bytes to write
syscall

# Close the file
li $v0, 16            # syscall code for close file
move $a0, $s2         # file descriptor
syscall


j view_calendar

#############################################################################################################

delete_appointment:

get_daydelete:
    # Prompt the user to enter a day
    li $v0, 4             # syscall code for print string = 4
    la $a0, Promptday     # load address of the day prompt
    syscall

    # Read user input for the day
    li $v0, 8             # syscall code for read string = 8
    la $a0, buffer        # buffer to store the user input
    li $a1, 256           # maximum number of characters to read
    syscall

    # Convert the entered string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t0, $zero       # initialize $t0 to 0 (to store the result)

convert_loop_delete:
    lb $t1, 0($a0)        # Load the byte at the current position in the string
    beqz $t1, conversion_done_delete  # If it's null (end of string), exit the loop

    # Check if the character is a digit
    blt $t1, 48, conversion_done_delete   # If ASCII value is less than '0', exit the loop
    bgt $t1, 57, conversion_done_delete   # If ASCII value is greater than '9', exit the loop

    # Convert ASCII to integer
    sub $t1, $t1, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t0, $t0, 10      # Multiply current result by base 10
    add $t0, $t0, $t1      # Add the current digit

    addi $a0, $a0, 1       # Move to the next character in the string
    j convert_loop_delete         # Repeat the loop

conversion_done_delete:
    move $t0, $t0         # Move the result to $t0

    # Open file for reading
    li $v0, 13            # open_file syscall code = 13
    la $a0, filename      # get the file name
    li $a1, 0             # open for reading
    syscall
    move $s1, $v0         # save the file descriptor in $s1

    # Read lines from the file until the specified day is found
read_day_loop_delete:
    # Read from file
    li $v0, 14            # syscall code for read file
    move $a0, $s1         # file descriptor
    la $a1, buffer        # buffer to read into
    li $a2, 256           # number of bytes to read
    syscall

    # Check if read was successful
    bgtz $v0, check_day_delete   # branch if read successful

check_day_delete:
    # Convert the read string to an integer
    li $v0, 0             # syscall code for read integer = 0
    move $t1, $zero       # initialize $t1 to 0 (to store the result)

convert_read_loop_delete:
    lb $t2, 0($a1)        # Load the byte at the current position in the string
    beqz $t2, print_data_day_delete   # If it's null (end of string), print the data

    # Check if the character is a digit
    blt $t2, 48, print_data_day_delete   # If ASCII value is less than '0', print the data
    bgt $t2, 57, print_data_day_delete   # If ASCII value is greater than '9', print the data

    # Convert ASCII to integer
    sub $t2, $t2, 48       # Convert ASCII to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul $t1, $t1, 10      # Multiply current result by base 10
    add $t1, $t1, $t2      # Add the current digit

    addi $a1, $a1, 1       # Move to the next character in the string
    j convert_read_loop_delete   # Repeat the loop

print_data_day_delete:
    # Check if the entered day matches the read day
    beq $t0, $t1, print_data_delete   # If the days match, print the data

    # Repeat the loop until the end of file
    j read_day_loop_delete

print_data_delete:
    # Print the read data to the console
    li $v0, 4             # syscall code for print_str
    la $a0, buffer        # load buffer address
    syscall

  # Prompt user to enter a character
  li $v0, 4     # System call for print_str
  la $a0, promptchar   # Load the address of the prompt string
  syscall

  # Read user input character
  li $v0, 12     # System call for read_char
  syscall
  sb $v0, inputChar # Store the input character in inputChar

  # Load the string into a register
  la $a0, buffer

  # Load the input character into a register
  lb $t0, inputChar

  # Load the length of the input string
  li $t1, 256

  # Initialize index
  li $t2, 0

  # Loop through the string
  loop_delete:
    # Check if we reached the end of the string
    beq $t2, $t1, end_delete

    # Load the current character from the string
    lb $t3, 0($a0)

    # Compare the current character with the input character
    beq $t3, $t0, replace_delete

    # Store the current character in the buffer
    sb $t3, buffer($t2)

    # Move to the next character in the string and buffer
    addi $a0, $a0, 1
    addi $t2, $t2, 1

    # Continue the loop
    j loop_delete

  replace_delete:
    # Replace the 7 bits before the matched character with whitespace
    li $t4, 7
    sub $t2, $t2, $t4 # Move back 7 positions

    replace_loop:
      # Check if we replaced 6 bits
      beqz $t4, continue_loop

      # Store whitespace in the buffer
      li $t3, 32
      sb $t3, buffer($t2)

      # Move to the next position
      addi $t2, $t2, 1
      subi $t4, $t4, 1

      # Continue the loop
      j replace_loop

    continue_loop:
    # Continue storing the remaining bits after replacement
    nop

    # Move to the next character in the string and buffer
    addi $a0, $a0, 1

    # Continue the loop
    j loop_delete

  end_delete:
    # Null-terminate the buffer
    sb $zero, buffer($t2)
    
    # Print newline
    li $v0, 4             # syscall code for print_str
    la $a0, newline
    syscall

    # Print the modified string
    li $v0, 4
    la $a0, buffer
    syscall
    j main
