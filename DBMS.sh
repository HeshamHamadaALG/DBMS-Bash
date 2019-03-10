#!/bin/bash


#############################
## Display DataBase Function

export databaseName
function displayDB {
echo "";
if [[ -s data/databases.meta ]]
then echo "----------------------"
echo "| List Of DataBases  |"
echo "----------------------"
cat data/databases.meta ;
else 
echo "---------------------"
echo "| No DataBase Found |"
echo "---------------------"
fi
}

#############################
## Create DataBase Function

function createDB {
echo ""
echo "==> PLZ, Write Your DataBase Name = ";
read databaseName ;
## validate user input 

val="$(echo $databaseName | head -c 1)" ;

if [[ $val == [0-9] ]]
then echo "WARNING !! , You can't start database name with Number"; createDB;
elif [[ $databaseName =~ [^[:alnum:]]+ ]]
then echo "WARNING !! , there is ( Special Char ) in database name"; createDB;
elif [[ $databaseName =~ [[:space:]] ]]
then echo "WARNING !! , There is ( space ) in your database name"; createDB;
elif [ -z ${databaseName} ]
then echo "WARNING !! , Empty database name"; createDB;

else

if [ -d data/$databaseName ] 
then echo "DataBase Already Exist ";
sleep 1 ;
echo "Plz, Choose Another Name For Your DataBase";
else
clear;
echo "Please Wait ...";
mkdir data/$databaseName ;
touch data/$databaseName/$databaseName.meta ;
echo -e $databaseName >> data/databases.meta ;
sleep 1 ;
echo "DataBase $databaseName Created Successfully" ;
return 0 ;
fi

fi
}


#############################
## Delete DataBase Function

function deleteDB {
clear;
echo "==> PLZ, Write DataBase Name you wish to delete = ";
read databaseName ;
if [ ! -d data/$databaseName ] 
then echo "No DataBase Found ";
sleep 1 ;
echo "Plz, Make Sure from DataBase Name";
else
clear;
echo "";
echo "Are you sure you want to delete database ( $databaseName ) : " ;
echo "Enter [ Y ] to delete Or [ N ] to cancel" ;
read answer ;

if [[ $answer == [yY] ]]
then echo "Please Wait ...";
rm -r data/$databaseName ;
sed -i "/$databaseName/d" data/databases.meta
sleep 1 ;
echo "DataBase $databaseName Deleted Successfully" ;
return 0 ;
elif [[ $answer == [nN] ]]
then echo "Cancel DataBase Deletion ..."
sleep 1 ;
main;
else 
echo "No Valid Answer"
sleep 1 ;
deleteDB;
fi 
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
clear;
displayDB;
echo "";
echo "";
echo "Plz , Press Enter to back to menu";
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
echo "==> Plz , Enter DataBase Name : ";
read databaseName ;

if [ -d data/$databaseName ] 
then clear ; 
echo "";
echo "==> You are in database [ $databaseName ] .";
echo "";

select chMenu in "Create Table" "Choose table" "Delete Table" "Back"
do
case $chMenu in 
"Create Table")
clear;
createTable;
;;
"Choose table")
echo "you choose choose Table";
chooseTableMenu
;;
"Delete Table")
deleteTable;
;;
"Back")
chooseMenu ;
;;
*)
echo "Please Choose From the List";
;;
esac
done

else 
echo "No DataBase Found .."
echo "Make Sure you Enter name of database ."
sleep 1.5 ;
chooseMenu;
fi 
}

#####################
## create table function

function createTable {
echo "";
echo "==> Create Table in database [ $databaseName ] .";
echo "";

echo "==> PLZ, Write Your Table Name = ";
read tableName ;

## validate user input 

valt="$(echo $tableName | head -c 1)" ;

if [[ $valt == [0-9] ]]
then echo "WARNING !! , You can't start Table name with Number"; dbMenu;
elif [[ $tableName =~ [^[:alnum:]]+ ]]
then echo "WARNING !! , there is ( Special Char ) in Table name"; dbMenu;
elif [[ $tableName =~ [[:space:]] ]]
then echo "WARNING !! , There is ( space ) in your Table name"; dbMenu;
elif [ -z ${tableName} ]
then echo "WARNING !! , Empty Table name"; dbMenu;

else

if [ -e data/$databaseName/$tableName ] 
then echo "Table with this name Already Exist ";
sleep 1 ;
echo "Plz, Choose Another Name For Your DataBase";
sleep 1 ;
createTable;
else
clear;
echo "Please Wait ...";
sleep 1 ;
touch data/$databaseName/$tableName ;
echo "Table [ $tableName ] Created Successfully" ;
sleep 1 ;
clear;
creatColumn;
fi

fi
}

##########################
## create column Function

function creatColumn {

    unset 'ptype' ;

##### Create Columns #######

	echo " You Are in database name $databaseName";
	echo "";
	echo "==> Plz , Enter No. Of columns you wish in table $tableName : ";
	read colNum ;
	if [[ $colNum == [0-9] ]] && [[ $colNum != [0] ]]   ## Validate number of colmuns 
	then echo "";
		echo "Plz wait while processing your data ...";
		sleep 1 ;

	##### create primary Key #######

		clear;
		local invalid=1
		until (( invalid == 0 ))
		do
			echo "";
			echo "=====> Enter Name of Primary Key for table $tableName : ";
			read pKey;

			## ++++ Validate pKey 
			valp="$(echo $pKey | head -c 1)" ;
			if [[ $valp == [0-9] ]]
			then echo "WARNING !! , You can't start Column name with Number"; sleep 1 ; echo "Plz Write a valid name ";
			elif [[ $pKey =~ [^[:alnum:]]+ ]]
			then echo "WARNING !! , there is ( Special Char ) in Column name"; sleep 1 ; echo "Plz Write a valid name ";
			elif [[ $pKey =~ [[:space:]] ]]
			then echo "WARNING !! , There is ( space ) in your Column name"; sleep 1 ; echo "Plz Write a valid name ";
			elif [ -z ${pKey} ]
			then echo "WARNING !! , Empty Column name"; sleep 1 ; echo "Plz Write a valid name ";
			else invalid=0
			fi
		done
		echo "";
		echo "=====> Enter Type of Primary Key for table $tableName : ";
		echo "";
		select choice in "Integer" "String"
					do
						case $choice in
							"Integer" )
								ptype="int" ;
								echo "";
								echo "Plz wait while processing your data ...";
								sleep 1 ;
								creatOtherColumns ;
								break;
							;;
							"String" )
								ptype="char" ;
								echo "";
								echo "Plz wait while processing your data ...";
								sleep 1 ;
								creatOtherColumns;
								break;
							;;
								* )
									echo "Invalid input, Please try Again!" ;
									;;
							esac
					done
	else 
	echo "Plz enter a valid number of columns ";
	echo "redirecting you to column numbers .... "
	sleep 2 ;
	creatColumn;
	fi     ## End Of Validation number of colmuns 

}

############################
############################

function creatOtherColumns {
    unset 'typ' ;

##### create Columns #######
local colSchema=';'
for i in $(seq 2 $colNum)
do 
	local invalid=1
	until (( invalid == 0 ))
	do
		clear;
		echo "";
		echo "=====> Enter Name Column for table $tableName  no $i : ";
		read col[i];

		## ++++ Validate col 
		valp="$(echo ${col[i]} | head -c 1)" ;

		if [[ ${valp[i]} == [0-9] ]]
		then echo "WARNING !! , You can't start Column name with Number"; sleep 1 ; 
		elif [[ ${col[i]} =~ [^[:alnum:]]+ ]]
		then echo "WARNING !! , there is ( Special Char ) in Column name"; sleep 1 ; 
		elif [[ ${col[i]} =~ [[:space:]] ]]
		then echo "WARNING !! , There is ( space ) in your Column name"; sleep 1 ; 
		elif [ -z ${col[i]} ]
		then echo "WARNING !! , Empty Column name"; sleep 1 ; 
		elif [[ ${col[i]} == $pKey ]]
		then echo "WARNING !! , The Name Already taken for [ Primary Key ]"; sleep 1 ;
		else invalid=0
		fi
	done
	echo "";
	echo "=====> Enter Type Column for table [$tableName] column name [${col[i]}] no [$i] : ";
	echo "";
	select choice in "Integer" "String"
				do
					case $choice in
						"Integer" )
							typ[i]="int" ;
							break;;
						"String" )
							typ[i]="char";
							break;;
							* )
								echo "Invalid input, Please try Again!" ;
								;;
						esac
				done
				colSchema="$colSchema${col[i]}":"${typ[i]};"
done 
if (( $colNum > 1 ))
then
	colSchema=${colSchema::-1}
else colSchema=''
fi
echo -e $tableName";"$pKey":"$ptype":p"$colSch ema >> data/$databaseName/$databaseName.meta ;   ## Printing Table 
clear;
echo "";
echo "Your Table [$tableName] created Successfully in DataBase [$databaseName] with ' $colNum ' Columns , and your primary Key is [ $pKey ]"
echo "";
echo "Plz wait while redirecting you to main page ..."
sleep 2 ;
main;
}

#############################
## Delete Table Function

function deleteTable {
clear;
echo "==> PLZ, Write Table Name you wish to delete = ";
read tableDel ;
if [ ! -e data/$databaseName/$tableDel ] 
then echo "No Table Found ";
sleep 1 ;
echo "Plz, Make Sure from Table Name";
else
clear;
echo "";
echo "Are you sure you want to delete Table ( $tableDel ) from DataBase ( $databaseName ) : " ;
echo "Enter [ Y ] to delete Or [ N ] to cancel" ;
read ans ;

if [[ $ans == [yY] ]]
then echo "Please Wait ...";
rm -r data/$databaseName/$tableDel ;
sed -i "/$tableDel/d" data/$databaseName/$databaseName.meta
sleep 1 ;
echo "Table [ $tableDel ] Deleted Successfully from DataBase [ $data ]" ;
echo "plz waith while redirecting you to the menu ..."
sleep 2 ;
chooseMenu;
elif [[ $ans == [nN] ]]
then echo "Cancel Table Deletion ..."
sleep 1 ;
chooseMenu;
else 
echo "No Valid Answer"
sleep 1 ;
chooseMenu;
fi 
fi
}

function intialization () 
{
	if [[ ! -d data ]]
	then 
		mkdir data ;
	fi
	if [[ ! -f data/databases.meta ]]
	then
		touch data/databases.meta
	fi
}

#####################
## Main Menu function

function main {
clear;
intialization
echo "#################################################";
echo "#                                               #";
echo "#          Welcome , to ITI OS DBMS             #";
echo "#                                               #";
echo "#################################################";
echo "";
echo "==>  Please, write No. of your choice <==";
echo "";
select menu in "Create DB" "Choose DB" "Delete DB" "Exit"
do
case $menu in 
"Create DB")
clear;
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

# ## Start Main Function 
# export -f dbMenu
# main ;
