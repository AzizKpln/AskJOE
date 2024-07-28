#!/bin/bash
# A bash script for installing AskJOE automaticly and properly
# AskJoe Project: https://github.com/securityjoes/AskJOE
# Author: securityjoes
# contributor: AzizKpln
# Contact: Aziz Kaplan <aziz.kaplan@threatmonit.io>

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)
#!/bin/bash

# Banner function to display on CLI using figlet
print_banner() {
    echo "${BLUE}"
    figlet AskJOE
    echo "============================================================="
    echo ""
    echo "Author      : securityjoes"
    echo "Contributor : AzizKpln"
    echo "Created on  : 2024-07-28"
    echo ""
    echo "Description : Setting up AskJOE"
    echo "============================================================="
}
echo "${RESET}"
if [ "$EUID" -ne 0 ]; then
  echo "${RED}[-]Please be root and re-run this script.${RESET}"
  exit 1
fi

install_if_not_installed() {
  PACKAGE=$1
  if dpkg -l | grep -q "$PACKAGE"; then
    echo "${GREEN}[+]$PACKAGE is installed."
  else
    echo "${YELLOW}[!] $PACKAGE is not installed. Installing..."
    apt install -y $PACKAGE
    if [ $? -eq 0 ]; then
      echo "${GREEN}[+] $PACKAGE installed successfully."
    else
      echo "${RED}[-] Error while installing $PACKAGE!"
      exit 1
    fi
  fi
}
apt update && apt install figlet -y && clear
print_banner
echo "${BLUE}[+]Checking for necessery packages please wait."
sleep 1
install_if_not_installed "unzip"
sleep 1
install_if_not_installed "git"
sleep 1
install_if_not_installed "python3"
sleep 1
install_if_not_installed "python3-pip"
sleep 1
install_if_not_installed "openjdk-17-jdk"
sleep 1
install_if_not_installed "python3-dev"
sleep 1
install_if_not_installed "default-jdk"
sleep 1
install_if_not_installed "wget"
sleep 1

GHIDRATHON_URL="https://github.com/mandiant/Ghidrathon/releases/download/v4.0.0/Ghidrathon-v4.0.0.zip"
ZIP_FILE="Ghidrathon-v4.0.0.zip"
EXTRACT_DIR="Ghidrathon-v4.0.0"


echo ""
echo "${BLUE}Installing Ghidrathon Please Wait:"
echo -n "${YELLOW}Installing ["
wget -q $GHIDRATHON_URL -O $ZIP_FILE &>null &
WGET_PID=$!
while kill -0 $WGET_PID 2> /dev/null; do
    echo -n "."
    sleep 0.5
done
wait $WGET_PID
if [ $? -eq 0 ]; then
    echo "]"
    echo -n "${GREEN}[✔]Done!"
else
    echo "]"
    echo -n "${RED}[-]Error while installing Ghidrathon!"
    exit 1
fi

unzip $ZIP_FILE -d $EXTRACT_DIR &> null
rm $ZIP_FILE
echo ""
echo -n "${BLUE}Installing JEP Please Wait:"
echo ""
git clone https://github.com/ninia/jep.git &>null &
echo -n "${YELLOW}Installing ["
JEPPID=$!
while kill -0 $JEPPID 2> /dev/null; do
	echo -n "${YELLOW}.${RESET}"
	sleep 1
done
echo "${YELLOW}]${RESET}"
cd jep || { echo "${RED}Error while changing directory into JEP${RESET}"; exit 1; }

ls /usr/lib/jvm &>null
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
echo -n "${YELLOW}Installing [${RESET}"

python3 -m pip install jep==4.2.0 --break-system-packages &>null &
PIP_PID=$!
while kill -0 $PIP_PID 2> /dev/null; do
    echo -n "${YELLOW}.${RESET}"
    sleep 1
done
echo "${YELLOW}]${RESET}"
wait $PIP_PID
if [ $? -eq 0 ]; then
    echo -e "${YELLOW}${RESET}${GREEN}[✔]Done!${RESET}"
else
    echo -e "${YELLOW}]{RESET}${RED}[-]Error while installing JEP!${RESET}"
    exit 1
fi
echo "${BLUE}Setting up Ghidration Please Wait:"
echo "${BLUE}Looking for Ghidra directory within the system:"
echo -n "${YELLOW}Searching 'ghidra_scripts' [${RESET}"
target_subdir="Ghidra/Features/Python/ghidra_scripts"
result=""
if command -v locate &> /dev/null; then
    result=$(locate "$target_subdir" &)
else
    result=$(find / -type d -path "*/$target_subdir" 2>/dev/null &)
fi
SearchGhidra=$!
while kill -0 $SearchGhidra 2> /dev/null; do
        echo -n "${YELLOW}.${RESET}"
        sleep 1
done
echo "${YELLOW}]${RESET}"
if [ -n "$result" ]; then
    echo -e "${YELLOW}${RESET}${GREEN}[✔]Done!${RESET}"
    echo "${GREEN}[+]Found: $result"
else
    echo "[-]Could not found! Please make sure that you have Ghidra installed withing the system!"
    exit 1
fi
cd ../Ghidrathon-v4.0.0
echo "${BLUE}Configuring Ghidration Please Wait:"
python3 ghidrathon_configure.py $result &>null
echo -e "${YELLOW}${RESET}${GREEN}[✔]Done!${RESET}"
cd ../

clear && print_banner
echo -e "${BLUE}Please enter your OpenAI API Key:"
read -p ">> " NEW_API_KEY


FILENAME="AskJOE/openai_utils.py"
FILENAME2="AskJOE/config.ini"
cp $FILENAME ${FILENAME}.bak
sed -i "s/OpenAI(api_key=\"HERE_API\")/OpenAI(api_key=\"$NEW_API_KEY\")/" $FILENAME
cp $FILENAME2 ${FILENAME}.bak
sed -i "s/OPEN_AI = HERE_API/OPEN_AI = $NEW_API_KEY/" $FILENAME2


cp -r AskJOE/ AskJOE.py JOES.png $result
echo ""
echo -e "${BLUE}[+]Installation Process is done! Please now start Ghidra, install Ghidrathon extension as mentioned in Readme.MD..${RESET}"
