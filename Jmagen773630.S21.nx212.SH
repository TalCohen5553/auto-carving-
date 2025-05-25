#!/bin/bash 
#subject of the project - Automate HDD and Memory Analysis
#S21 , cyber security , John Bryce 77630
#This sctipt was written using co-pilot. thank u co-pilot :)

#1.1 Check the current user; exit if not ‘root’.

#if it is not root i'm gonna make it root - why exit if i can fix it :)
#when i tried to run the script and i wasnt root it automaticly exit the script. co-pilot helped me understand about the $0 and $@ - and there's purpose on my script
#sudo bash- giving the current user priviliges like root 
# sudo bash "$0" "$@" - running the script again with the already written parameters.
# exit 0 - stops the original running of the script- when i wasnt root 

function check_root ()
{
	if [ $(whoami) == 'root' ]
	then 
        	echo "You are Root, you may proceed :)"
	else
        	echo "You are NOT Root, Making you now ... "
		sudo bash "$0" "$@"
        	exit 0  
	fi
}
check_root

echo
#1.2 Allow the user to specify the filename; check if the file exists.

# -e cheaking both directory or files, for if i wanna check both  
function check_if_file_exist ()
{
	read -p "Which of the files would you like to check if it exist? " file_name
	if [ -e "$file_name" ]
	then
        	echo
		echo "This file exists."
	else
        	echo "This filename does not exists. please try again"
        	exit 1  
	fi
}

check_if_file_exist

#1.5 Data should be saved into a directory.
# I chose to change the order of the assigment a bit, because i wanted to have a file ready  to save info and tools
function create_folder ()
{
	if [ -d "info_about_$file_name" ] 
	then 
		echo "You already have a file name 'info about $file_name' "
		sleep 1 
		echo "saving all the data to an exsisting file name 'info about $file_name' "
	else
        	echo "saving all the data in a new file name 'info about $file_name' "
		mkdir "info_about_$file_name" 
	fi
}
create_folder

#1.3 Create a function to install the forensics tools if missing.
#because i dont know the type of a file this script will use i'll install a lot of tools 
#!/bin/bash
echo
sleep 1 
function tools_installation ()
{
	tools=("bulk_extractor" "binwalk" "foremost" "strings")
	echo "Checking if the tool is installed..."
		for tool in "${tools[@]}"
		do
    			if command -v "$tool" > /dev/null 2>&1
			then
        			echo "   ✅ $tool is already installed"
    			else
        			echo "   ❌ $tool is not installed. Installing $tool..."
        			sudo apt-get install -y "$tool" > /dev/null 2>&1
        			if command -v "$tool" > /dev/null 2>&1 
				then
            				echo "✅ $tool was successfully installed."
        			else
            				echo "❌ Failed to install $tool. Please check for issues."
        			fi
   	 		fi	
		sleep 1 
		done
        echo "🎉 Process completed for all tools"
 }
tools_installation
sleep 1 
echo
#1.4 Use different carvers to automatically extract data.
function running_tools ()
{
	cp "$file_name" "./info_about_$file_name" 
	cd "info_about_$file_name"
	echo "Extracting data automatically-please wait, it might take some time "
	sleep 1
		if [ -d != bulk ]
		then
			echo "  [1] initiating bulk_exstractor, loading... "
			bulk_extractor -o bulk "$file_name" > /dev/null 2>&1 
			echo "    -> bulk_extracror finished"
		else
			echo "you already have a directory containing bulk for '$file_name"
		fi
	sleep 1
		if [ -f "$file_name" ]
		then
    			echo "  [2] initiating foremost, loading..."
    			foremost "$file_name" -o foremost  > /dev/null 2>&1
		else
    			echo "Error: File '$file_name' does not exist."
		fi
		cd foremost
		find . -type f -empty -delete # deleted all the empty files
		cd ..
		echo "    -> foremost finished"
	sleep 1	
		if [ -d != binwalk ] 
		then
			echo "  [3] initiating binwalk, loading..."
			binwalk -e "$file_name" > /dev/null 2>&1
			echo "    -> binwalk finished"
		else
			echo "you already have a directory containing binwalk info for '$file_name' " 
		fi
	sleep 1 
		if [ ! -d strings ] 
		then
			echo "  [4] initiating strings, loading..."
			mkdir strings
			cp "$file_name" "./strings"
			cd strings
			strings "$file_name" > strings.all.info
			echo "    -> strings finished"
		else
			echo "you already have a directory containing strings info for '$file_name' "
		fi

}
running_tools
echo
#1.7 Check for human-readable (exe files, passwords, usernames, etc.).
#becaue strings is a heavy command i canot use it several times , so co-pilot offerd for me  to grep it 
function strings
{ 
	echo "Extracting strings about files, passwords, usernames and emails from '$file_name' "
	cat strings.all.info | grep 'files' > strings.files
	cat strings.all.info | grep 'password' -i > strings.passwords
	cat strings.all.info | grep 'username' -i > strings.usernames
	cat strings.all.info | grep '@' > strings.emails
    	echo "strings saved for files, passwords, usernames and emails"
	
    while true
	 do
        	read -p "Would you like to search for a diffrent strings? (y/n): " response
        	if [[ "$response" == "y" ]]
		then
           		read -p "What other parameters should the strings look for? " search_me
            		if [[ -n "$search_me" ]]
			then
                		grep "$search_me" strings.all.info > "strings.$search_me"
                		echo "Done. A file named 'strings.$search_me' has been created."
            		else
                		echo "Error: No valid search parameter was provided."
            		fi
        	elif [[ "$response" == "n" ]]
		then
            		echo "OK moving on with the script"
            	break
        	else
            		echo "Invalid input. Please enter 'y' or 'n'."
        	fi
    done
	sudo rm -f "$file_name"
}	
strings
echo

#1.6 Attempt to extract network traffic; if found, display to the user the location and size>
#network traffic bulk_extractor dose, and i already run it the last question 
function pcap 
{
        cd .. 
        if [ -d 'bulk' ] 
        then 
                cd bulk
		if [ -f 'packets.pcap' ]

then 
                        echo "found a pcap file to investigate"
                        sleep 1 
                        echo "saved in info_about_$file_name/bulk"
                        echo "Size:$(ls -lh | grep packets.pcap | awk '{print $5}')"
                else 
                        echo "no network file was found during this investigation"
                fi
        else
                echo "there is no such file named bulk - please cheak again"
        fi
 
}
pcap
echo
#2. Memory Analysis with Volatility
cd ..
function install_vol
{
	if [ ! -d vol ]
        then    
		mkdir vol
		cd vol
		echo "you do not have volatility installed"
		echo "installing volatility ... please wait a monent"
		sudo wget -nc http://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_lin64_standalone.zip > /dev/null 2>&1
		unzip -j -o volatility_2.6_lin64_standalone.zip
		mv volatility_2.6_lin64_standalone vol
		sudo chmod -R 777 vol
                echo "✅ vol was successfully installed."
        else
                echo "vol is already installed"
         fi
}
install_vol
echo
#2.1 Check if the file can be analyzed in Volatility; if yes, run Volatility.
#2.2 Find the memory profile and save it into a variable
function can_analyze
{ 
	cd ..
        cp "$file_name" "./vol"
        cd vol
	echo "running volatility now, please wait..." 
        if ./vol -f "$file_name" imageinfo 2>/dev/null
	 then
                PROFILE=$(./vol -f "$file_name" imageinfo 2>/dev/null | grep -i 'Suggested Profile(s)' | cut -d ':' -f2 | awk -F',' '{print $1}' | tr -d ' ')
                if [ -n "$PROFILE" ]
                then
                        echo "Detected profile: $PROFILE, saving it as a variable"
                        sleep 0.5
                        echo "This file can be analyzed with Volatility."
		else
                echo "Error: Could not determine the profile. Please check the file."
                fi
        else
                echo "Error! This file cannot be analyzed with Volatility. Please check the file"
        fi
}
can_analyze
echo
#2.3 Display the running processes.
if [ ! -d "vol_output_$file_name" ]
then
        mkdir "vol_output_$file_name"
fi
function display_process
{
        echo "Displaying running processes..."
        ./vol -f "$file_name" --profile="$PROFILE" pslist | tee "vol_output_$file_name/running_processes.txt"
	echo "for your convienance, also saving it to a file inside 'vol_output_$file_name' directory"
}
display_process
echo
#2.4 Display network connections.
function display_network
{
        echo "Displaying network conecctions..."
	./vol -f "$file_name" --profile="$PROFILE" connections | tee "vol_output_$file_name/network_connection.txt"
        echo "for your convienance, also saving it to a file inside 'vol_output_$file_name' directory"
}
display_network
echo
#2.5 Attempt to extract registry information.
function registry
{
echo "Extracting registry information..."
        ./vol -f "$file_name" --profile="$PROFILE" hivelist | tee "vol_output_$file_name/registry_hives.txt"
        ./vol -f "$file_name" --profile="$PROFILE" printkey --key "Software\\Microsoft\\Windows\\CurrentVersion\\Run" | tee -a "vol_output_$file_name/registry_hives.txt"
        echo "for your convienance, also saving it to a file inside 'vol_output_$file_name' directory"
}
registry
echo

#3. Results
#3.1 Display general statistics (time of analysis, number of found files, etc>
#3.2 Save all the results into a report (name, files extracted, etc.)
function display_statistics 
{
        cd ..
	cd ..
        echo "Displaying general statistics..."
        ANALYSIS_TIME=$(date)
        FILE_COUNT=$(ls -1 "info_about_$file_name" | wc -l)
	echo "  Time of analysis: $ANALYSIS_TIME" | tee "info_about_$file_name/general_statistics.txt"
        echo "  Number of found files: $FILE_COUNT" | tee -a "info_about_$file_name/general_statistics.txt"
}
echo
display_statistics
#3.3 Zip the extracted files and the report file.

function zip 
{
	echo "for your convience, zipping the directory and report file."
	echo "it may take a while"
	sudo zip -r zip_$file_name info_about_$file_name  
	sleep 2
}
zip
echo 
echo "end of the script. thank you for choosing to work with us, have a lovely day :) "

