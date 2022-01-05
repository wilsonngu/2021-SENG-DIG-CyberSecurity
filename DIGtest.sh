#Wilson Nguyen SENG 460 Script V00896922
#your website is www.xyzincorporated.com and they registered www.xyzincorporate.com and are hosting fake login pages designed to steal your employee credentials 
#you need to gather necessary information to report to the following abuse departments: domain registrar, web hosting provider, DNS hosting provider, network provider#


#1. build a shell script that takes a domain as input and gathers as much information about it as possible using commands like WHOIS and dig

#2. test the script to ensure that it works across a variety of domains and presents the information in a meaningful way

#whoisis the most important command to be run

#3.leverage linux, vi, network tools, shell scripting, sed/awk, cut, grep, as necessary

#4 you will be required to provide a copy of the script and sample output for the following domains:cnn.com?yahoo.ca?uvic.ca

#Domain registrar = whois -> Registry domain ID, Registrar WHOIS server, Registrar URL and the 'Registrar:'

#Webhosting provider -> "REGISTRANT name" INFO

#DNS hosting provider THE NAME SERVERS ->whois gets the netnames = DNS OR nslookup gives the DNS running servers, if you do a who is on these DNS servers you can get all the NET info, if NSlookup gives no "authoritative answers" it iteslf is a DNS!

#network provider info -> whois of the NETNAME IPs



#EMAIL CONDITION

#Asses Case conditions, 1 = email, 2 = URL/DOMAIN, 3 = IP
cc=0

while true; do
   read -r -p "Enter a DOMAIN,URL,EMAIL,IP: " VAR
   #VAR="98.137.11.163"
   #TEST1 98.137.11.163
   #TEST2 bob@yahoo.com
   #TEST3 yahoo.com
   #TEST4 www.yahoo.com
   echo -e "\nChecking Input '"$VAR"'.... \n"
   if [[ "$VAR" =~ .*"@".* ]]; then
      #EMAIL verified
      echo -e "This is an Email\n"
      VAR=$(echo $VAR | awk '{split($1,arr,"@"); print arr[2]}')
      echo -e "new address '"$VAR"' \n"
      #Asses number of IPs
      returnval=$(getent hosts $VAR | awk '{ print $1 }')
      echo -e "You entered '"$VAR"', The following IP(DNS) of name servers are...: \n$returnval"
      numip=0
      numip=$(echo "${returnval}" | tr -d '[:graph:] ' |wc -c)
      echo  $returnval > ip.txt
      echo -e "number of IP Domains are is $numip \n"     
      cc=1
      break
   #it is either a Domain,IP, or URL
   else
      echo -e "This is not an Email, it is either a URL/DOMAIN/IP \n" 
      #CHECK FOR HTTP HEADER & / to REMOVE or www.
      VAR=$(echo "${VAR}" | sed 's/^http\(\|s\):\/\///g' | sed 's/[/]//g'| sed 's/^www.//g')
      #CHECK IF IT IS AN IP ADDRESS, NOT A URL
      if [[ $VAR =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "This is an IP\n"
        cc=3
      else
        echo -e "This is a URL\n" 
        cc=2  
      fi
      returnval=$(getent hosts $VAR | awk '{ print $1 }')
      echo -e "You entered '"$VAR"', The following IP (DNS) of name servers are...: \n$returnval"
      numip=0
      #numip=$(echo "${returnval}" | awk -F"{ }" '{print NF}')
      numip=$(echo "${returnval}" | tr -d '[:graph:] ' |wc -c)
      echo  $returnval > ip.txt
      echo -e "number of IP Hosts are is $numip \n"    
      break
   fi
done



#now with the IP file we can parse each # of IP domain checking each whois lookup


#get Domain REGISTRAR INFO
# Host is PARCED, we can retrieve the Domain info/IPs/Registrar
if [[ "$cc" -eq 1 ]]; then
  echo -e "-------------------------------Registrar INFO-----------------------------------------------" 
  whois $VAR > whoisinfo.txt
  sed -n -e 1,11p  whoisinfo.txt
  echo -e "\n ----------------Nameservers for this Website -----------------------\n" 
  whois $VAR | grep 'Name Server:' | awk '{print $3}'
  echo -e "\n ----------------Web/DNS Hosting & Network Providor Information for this Website -----------------------\n" 
  ip1=$(awk '{print $1}' ip.txt)
  whois $ip1 > netinformation.txt 
  sed '/^#/d' netinformation.txt
  echo -e "\n Notes: Web/DNS Hosting provider is the from this display Organization\n" 
  echo -e "\n NetRange block is Network information, OrgName block is WEB/DNS provider information, OrgTechHandle+left block = Abuse department contact information" 
  echo -e "\n ----------------Simple Breakdown -----------------------\n" 
  echo "The WEB/DNS hoster is"
  grep 'Organization:' netinformation.txt 
  echo -e "\nThe WEB/DNS hoster IP is"
  grep 'NetRange:' netinformation.txt 
elif [[ "$cc" -eq 2 ]]; then
  #This is DOMAIN/URL input
  echo -e "-------------------------------Registrar INFO-----------------------------------------------" 
  whois $VAR > whoisinfo.txt
  sed -n -e 1,11p  whoisinfo.txt
  echo -e "\n ----------------Nameservers for this Website -----------------------\n" 
  whois $VAR | grep 'Name Server:' | awk '{print $3}'
  echo -e "\n ----------------Web/DNS Hosting & Network Providor Information for this Website -----------------------\n" 
  ip1=$(awk '{print $1}' ip.txt)
  whois $ip1 > netinformation.txt 
  sed '/^#/d;/^%/d' netinformation.txt 
  echo -e "\n Notes: Web/DNS Hosting provider is the from this display Organization\n" 
  echo -e "\n NetRange/netname block is Network information, OrgName/person block is WEB/DNS provider information, OrgTechHandle+left block = Abuse department contact information" 
  echo -e "\n ----------------Simple Breakdown -----------------------\n" 
  echo "The WEB/DNS hoster is"
  grep 'Organization:\|org-name' netinformation.txt 
  echo -e "\nThe WEB/DNS hoster IP is"
  grep 'NetRange:\|inet6num' netinformation.txt 
elif [[ "$cc" -eq 3 ]]; then
  #This is an IP
  echo "filler IP $VAR"  
  echo -e "-------------------------------Registrar INFO-----------------------------------------------" 
  #need to get host name of IP
  echo -e "\nHost name address from IP\n" 
  host $VAR

  echo -e "\n ----------------Web/DNS Hosting & Network Providor Information for this Website -----------------------\n" 
  ip1=$(awk '{print $1}' ip.txt)
  whois $ip1 > netinformation.txt 
  sed '/^#/d' netinformation.txt 
  echo -e "\n Notes: Web/DNS Hosting provider is the from this display Organization\n" 
  echo -e "\n NetRange block is Network information, OrgName block is WEB/DNS provider information, OrgTechHandle+left block = Abuse department contact information" 
  echo -e "\n ----------------Simple Breakdown -----------------------\n" 
  echo "The WEB/DNS hoster is"
  grep 'Organization:' netinformation.txt 
  echo -e "\nThe WEB/DNS hoster IP is"
  grep 'NetRange:' netinformation.txt 
else
  echo "invalid input"
fi
      
      
      
#Debug stuff
#echo -e "\nThe case conditions is $cc ."



echo "Done!"