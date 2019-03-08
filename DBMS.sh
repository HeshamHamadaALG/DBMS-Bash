#!/bin/bash
 
#############################
## Create DataBase Function

function createDB {
clear;
echo "==> PLZ, Write Your DataBase Name = ";
read databaseName ;
if [ -d $databaseName ] 
then echo "DataBase Already Exist ";
sleep 1 ;
echo "Plz, Choose Another Name For Your DataBase";
else
clear;
echo "Please Wait ...";
mkdir $databaseName ;
sleep 1 ;
echo "DataBase Created Successfully" ;
return 0 ;
fi
}


#############################
## Delete DataBase Function

function deleteDB {
clear;
echo "==> PLZ, Write DataBase Name you wish to delete = ";
read databaseName ;
if [ ! -d $databaseName ] 
then echo "No DataBase Found ";
sleep 1 ;
echo "Plz, Make Sure from DataBase Name";
else
clear;
echo "Please Wait ...";
rm -r $databaseName ;
sleep 1 ;
echo "DataBase $databaseName Deleted Successfully" ;
return 0 ;
fi
}


############################
## All Menu Functions ##
############################


########################## 
## Choose DB Menu function

function chooseMenu {
clear;
echo "";
echo "==> You are in Choose DB Menu <==";
echo "";
select chMenu in "Write Database Name" "Display DataBases" "Back"
do
case $chMenu in 
"Write Database Name")
echo "Database Name ?";
dbMenu;
;;
"Display DataBases")
echo "you choose Display DataBases";
;;
"Back")
main;
;;
*)
echo "Please Choose From the List";
;;
esac
done
}

###########################
#### Database Menu function

function dbMenu {
clear;
echo "";
echo "==> You are in Choose DB Menu <==";
echo "";
select chMenu in "Create Table" "Choose table" "Delete Table" "Back"
do
case $chMenu in 
"Create Table")
echo "you choose Create Table";
;;
"Choose table")
echo "you choose choose Table";
;;
"Delete Table")
echo "you choose Delete Table";
;;
"Back")
chooseMenu ;
;;
*)
echo "Please Choose From the List";
;;
esac
done
}

#####################
## Main Menu function

function main {
clear;
echo "#################################################";
echo "##         Welcome , to ITI OS DBMS            ##";
echo "#################################################";
echo "";
echo "==>  Please, write No. of your choice <==";
echo "";
select menu in "Create DB" "Choose DB" "Delete DB" "Exit"
do
case $menu in 
"Create DB")
createDB;
echo "Please Wait , Redirecting you to main menu"
sleep 2 ;
main ;
;;
"Choose DB")
chooseMenu;
;;
"Delete DB")
deleteDB;
echo "Please Wait , Redirecting you to main menu"
sleep 2 ;
main ;
;;
"Exit")
clear ;
echo "We Hope To See You Again !!";
exit 0;
;;
*)
echo "Please Choose From the List";
;;
esac
done
}

## Start Main Function 
main ;