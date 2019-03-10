#!/bin/bash

# source ./DBMS.sh
array_contains () {
    local seeking="$1"   # Save first argument in a variable
    shift            # Shift all arguments to the left (original $1 gets lost)
    local array=("$@") # Rebuild the array with rest of arguments 
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    echo $in
}

function chooseTableMenu ()
{
    echo "Choose Table"
    local tables=($( awk 'BEGIN {FS = ";"} { print $1 }' ./data/$databaseName/$databaseName.meta ))
    table=''
    select item in ${tables[@]} "Back"
    do
         res=$(array_contains "$item" "${tables[@]}" )
         if [[ $item == 'Back' ]]
         then
            chooseMenu
         else 
            if (( $res == 1 ))
            then
                echo "You Select Table: " $item
                tableMenu $item
                break
            else
                echo "No Matching Table"
            fi
        fi
    done
}

printBorder () {
 str=$1
 num=$2
 v=$(printf "%-${num}s" "$str")
 echo "${v// /=}"
}
function printTableHeader () {
    local table=$1
    local cols=($( awk 'BEGIN {FS = ";"} { if( "'"$table"'" == $1 ) for (i=2; i<=NF; i++) print $i }' ./data/$databaseName/$databaseName.meta | awk 'BEGIN {FS = ":"} { print $1 }' ))
    local len=${#cols[@]}
    local header=''
    for (( i=0; i<$len; i++ ))
    do
        header="$header ------- "${cols[$i]}" "
    done
    echo $header
    printBorder "=" ${#header}
}

function displayTable () {
    local table=$1
    local i=0;
    local rows
    while read -r line
    do
        rows[$i]=$line
        echo ${rows[$i]}
        (( i++ ))
    done < ./data/$databaseName/$table
    len=${#rows[@]}
    printTableHeader $1
    for (( i=0; i< $len; i++ ))
    do
        echo $(echo  ${rows[$i]} | ( awk 'BEGIN {FS = ";" } { for ( i = 1;i <= NF;i++ ) { print "-------",$i } } ' ) )
    done
}

function checkUniquePK () 
{
    local primaryKey=$1
    (( primaryKey++ ))
    local table=$2
    local value=$3
    return $(awk 'BEGIN {FS = ";" ; f=1 } { if( $"'"$primaryKey"'" == "'"$value"'" ) f=0 }  END { print f ;} ' ./data/$databaseName/$table)
}

function insertIntoTable () {
    local table=$1
    local cols=($( awk 'BEGIN {FS = ";"} { if( "'"$table"'" == $1 ) for (i=2; i<=NF; i++) print $i }' ./data/$databaseName/$databaseName.meta ))
    local primaryKey=-1
    local dataTypes
    local colName
    local typeset i=0
    for item in ${cols[@]}
    do
        local col=($(echo $item | ( awk 'BEGIN {FS = ":" } { for (i=1; i<=NF; i++) print $i } ' ) ))
        if (( ${#col[@]} == 3))
        then
            primaryKey=$i
        fi
        colName[$i]=${col[0]}
        dataType[$i]=${col[1]}
        (( i++ ))
    done
    declare -A newRow
    for (( i=0; i<${#colName[@]}; i++ ))
    do
        isvalid=0
        until (( $isvalid ))
        do 
            read -p "Enter ${colName[$i]} : " input
            if [ ${dataType[$i]} == "int" ]
            then
                if [[ $input =~ ^-?[0-9]+$ ]]
                then
                    isvalid=1
                    newRow[$i]=$input
                else
                    echo "Invalid Input"
                fi
                #check Uniqueness of ID
                if (( primaryKey == $i ))
                then 
                    checkUniquePK $primaryKey $table $input
                    if [[ $? == 0 ]]
                    then
                        isvalid=0
                        echo "ID Already Exist"
                    fi
                fi
            fi
            if [ ${dataType[$i]} == "char" ]
            then
                if [[ -n $input ]]
                then
                    isvalid=1
                    input=${input//;/,}
                    newRow[$i]=$input
                else
                    echo "Invalid Input"
                fi
                #check Uniqueness of ID
                if (( primaryKey == $i ))
                then 
                    checkUniquePK $primaryKey $table $input
                    if [[ $? == 0 ]]
                    then
                        isvalid=0
                        echo "ID Already Exist"
                    fi
                fi
            fi
        done
    done
    # echo ${colName[@]} 
    # echo ${dataType[@]} 
    # echo $primaryKey 
    # echo new row ${newRow[@]}
    # echo length of new row ${#newRow[@]}  
    local len=${#newRow[@]}   
    local newRowFormated=''
    for (( i=0; i<$len; i++))
    do 
        # echo ${newRow[$i]}
        newRowFormated="$newRowFormated${newRow[$i]}"
        if (( i < $len-1 ))
        then
            newRowFormated="$newRowFormated;"
        fi
    done
    # newRowFormated="$newRowFormated"
    # local newRowFormated=$(echo ${newRow[@]}  | ( awk 'BEGIN {FS = " "; OFS="-" } { str=""; for (i=1; i<NF; i++) str=str $i ";" ; str= str $NF '\n'; print str; } ' ) )
    # echo $newRowFormated
    echo -e $newRowFormated >> data/$databaseName/$table ;
    sleep 1
    echo "Insertion Done Successfully"
    # echo ${newRow[@]} 
    # echo 
}

function deleteFromTable () 
{
    local table=$1 
    local cols=($( awk 'BEGIN {FS = ";"} { if( "'"$table"'" == $1 ) for (i=2; i<=NF; i++) print $i }' ./data/$databaseName/$databaseName.meta ))
    local primaryKey=-1
    local dataTypes
    local colName
    local typeset i=0
    for item in ${cols[@]}
    do
        local col=($(echo $item | ( awk 'BEGIN {FS = ":" } { for (i=1; i<=NF; i++) print $i } ' ) ))
        if (( ${#col[@]} == 3))
        then
            primaryKey=$i
        fi
        colName[$i]=${col[0]}
        dataType[$i]=${col[1]}
        (( i++ ))
    done
    isvalid=0
    until (( $isvalid ))
    do 
        read -p "Enter Id You Want to Delete : " input
        if [ ${dataType[$primaryKey]} == "int" ]
        then
            if [[ $input =~ ^-?[0-9]+$ ]]
            then
                isvalid=1
                newRow[$i]=$input
            else
                echo "Invalid Input"
            fi
        fi
        if [ ${dataType[$primaryKey]} == "char" ]
        then
                if [[ -n $input ]]
                then
                    checkUniquePK $primaryKey $table $input
                    if [[ $? == 0 ]]
                    then
                    isvalid=1
                    input=${input//;/,}
                    primaryKeyValue=$input
                    else
                        echo "ID Not Found"
                    fi
                else
                    echo "Invalid Input"
                fi
        fi
    done
    (( primaryKey++ ))                         
    deleteRowLine=$(awk 'BEGIN {FS = ";" ; f=1 } { if( $"'"$primaryKey"'" == "'"$input"'" ) { f=0; print NR; }  }  END { if(f==1) print -1 ;} ' ./data/$databaseName/$table)
    if (( deleteRowLine == -1 ))
    then
        echo "No Row Affected"
    else 
        sed -i $deleteRowLine'd' ./data/$databaseName/$table
        sleep 1
        echo "Deletion Done Successfully"
    fi 
}

function updateFromTable ()
{
    table=$1
    local table=$1 
    local cols=($( awk 'BEGIN {FS = ";"} { if( "'"$table"'" == $1 ) for (i=2; i<=NF; i++) print $i }' ./data/$databaseName/$databaseName.meta ))
    local primaryKey=-1
    local dataTypes
    local colName
    local typeset i=0
    for item in ${cols[@]}
    do
        local col=($(echo $item | ( awk 'BEGIN {FS = ":" } { for (i=1; i<=NF; i++) print $i } ' ) ))
        if (( ${#col[@]} == 3))
        then
            primaryKey=$i
        fi
        colName[$i]=${col[0]}
        dataType[$i]=${col[1]}
        (( i++ ))
    done
    isvalid=0
    until (( $isvalid ))
    do 
        read -p "Enter Id You Want to Update : " input
        if [ ${dataType[$primaryKey]} == "int" ]
        then
            if [[ $input =~ ^-?[0-9]+$ ]]
            then
                checkUniquePK $primaryKey $table $input
                if [[ $? == 0 ]]
                then
                    isvalid=1
                    primaryKeyValue=$input
                else
                    echo "ID Not Found"
                fi
            else
                echo "Invalid Input"
            fi
        fi
        if [ ${dataType[$primaryKey]} == "char" ]
        then
                if [[ -n $input ]]
                then
                    checkUniquePK $primaryKey $table $input
                    if [[ $? == 0 ]]
                    then
                    isvalid=1
                    input=${input//;/,}
                    primaryKeyValue=$input
                    else
                        echo "ID Not Found"
                    fi
                else
                    echo "Invalid Input"
                fi
        fi
    done
    declare -A newRow
    for (( i=0; i<${#colName[@]}; i++ ))
    do
        isvalid=0
        until (( $isvalid ))
        do 

            if (( primaryKey != $i ))
            then 
                read -p "Enter ${colName[$i]} : " input
            fi
            if [ ${dataType[$i]} == "int" ]
            then
                if [[ $input =~ ^-?[0-9]+$ ]]
                then
                    isvalid=1
                    newRow[$i]=$input
                else
                    echo "Invalid Input"
                fi
            #check Uniqueness of ID
            fi
            if [ ${dataType[$i]} == "char" ]
            then
                if [[ -n $input ]]
                then
                    isvalid=1
                    input=${input//;/,}
                    newRow[$i]=$input
                else
                    echo "Invalid Input"
                fi
            fi
        done
    done
    local len=${#newRow[@]}   
    local newRowFormated=''
    for (( i=0; i<$len; i++))
    do 
        newRowFormated="$newRowFormated${newRow[$i]}"
        if (( i < $len-1 ))
        then
            newRowFormated="$newRowFormated;"
        fi
    done
    (( primaryKey++ ))
    local updatedLine=$(awk 'BEGIN {FS = ";" ; f=1 } { if( $"'"$primaryKey"'" == "'"$primaryKeyValue"'" ) { f=0; print NR; }  }  END { if(f==1) print -1 ;} ' ./data/$databaseName/$table )
    # sed -i "$updatedLine""s/.*/$newRowFormated/" ./data/$databaseName/$table
    sed -i "$updatedLine""s/.*/$(echo $newRowFormated | sed -e 's/[\/&]/\\&/g')/" ./data/$databaseName/$table
    sleep 1
    echo "Row Updated Successfully"
}  

function selectFromTable ()
{
    # printTableHeader $1
    local table=$1
    local table=$1 
    local cols=($( awk 'BEGIN {FS = ";"} { if( "'"$table"'" == $1 ) for (i=2; i<=NF; i++) print $i }' ./data/$databaseName/$databaseName.meta ))
    local primaryKey=-2
    local dataTypes
    local colName
    local typeset i=0
    for item in ${cols[@]}
    do
        local col=($(echo $item | ( awk 'BEGIN {FS = ":" } { for (i=1; i<=NF; i++) print $i } ' ) ))
        if (( ${#col[@]} == 3))
        then
            primaryKey=$i
        fi
        colName[$i]=${col[0]}
        dataType[$i]=${col[1]}
        (( i++ ))
    done
    local isvalid=0
    local input
    until (( $isvalid ))
        do 
        read -p "Enter ${colName[$primaryKey]} : " input
        if [ ${dataType[$primaryKey]} == "int" ]
        then
            if [[ $input =~ ^-?[0-9]+$ ]]
            then
                isvalid=1
            else
                echo "Invalid Input"
            fi
        #check Uniqueness of ID
        fi
        if [ ${dataType[$primaryKey]} == "char" ]
        then
            if [[ -n $input ]]
            then
                isvalid=1
                input=${input//;/,}
            else
                echo "Invalid Input"
            fi
        fi
    done
    (( primaryKey++ ))
    # echo primaryKey $primaryKey
    # echo input $input
    local rowNo=$( awk 'BEGIN {FS = ";" ; f=1;} {  if( $"'"$primaryKey"'" == "'"$input"'" ) {f=0; print NR; } } END {  if(f==1) print -1; }' ./data/$databaseName/$table )
    local row=$(sed -n $rowNo'p' ./data/$databaseName/$table)
    # echo rowNo $rowNo
    if (( rowNo > 0))
    then
        printTableHeader $table
        echo $(echo  $row | ( awk 'BEGIN {FS = ";" } { for ( i = 1;i <= NF;i++ ) { print "-------",$i } } ' ) )
    else 
        echo "No Row Found"
    fi
}
function tableOperationMenu ()
{
    select item in 'Display' 'Insert' 'Delete' 'Update' 'Select Row' 'Back' 'Quit'
    do
        echo $item
        break
    done
}

function tableMenu ()
{
    while true; do
    option=$(tableOperationMenu)
    case $option in
    'Display' )
        displayTable $1 
        ;;
    'Insert' )
        insertIntoTable $1 
        ;;
    'Delete' )
        deleteFromTable $1 
        ;;
    'Update' )
        updateFromTable $1 
        ;;            
    'Select Row' ) 
        selectFromTable $1
        ;;
    'Back' )
        chooseTableMenu
        ;;
    'Quit' )
        exit
        ;;
    * ) echo "not Matching"
    esac
done
}

# echo $databaseName
# deleteFromTable table1
#  insertIntoTable table1
# selectFromTable table2
# chooseTableMenu 
# tableMenu table1
# echo $res
# insertIntoTable table2