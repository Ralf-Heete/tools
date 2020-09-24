# Autor: R. Heete
# Auftraggeber: K. Heppner
# Datum: 18.09.2020

# Script erstellt im AD unter der angegebenen OU neue domänenlokale Verteilergruppen
# Quelle ist eine CSV-Datei, die sich im gleichen Verzeichnis wie dieses Script selbst befindet.
# Die CSV-Datei wird aus den jeweiligen Google-Sheets exportiert, z.B. "G Suite Groups and Shared Drives - Arneburg - AD GROUPS"
# Benutzt werden die Felder "ad group_name", "group_mail_address" und "Description"




$USRDOM  =$ENV:USERDOMAIN

$PATH="OU=blah, OU=blubb, DC=$USRDOM" #oder so ähnlich
$CSV='.\G Suite Groups and Shared Drives - Arneburg - AD GROUPS.csv'



Import-Csv -Path $CSV -Delimiter ','| %{
    if($_.realized -eq 'false' -and $_.mark -eq 'g'){  

        $OBJ=[pscustomobject]@{
                 Name=$_.'ad group_name'
                 samAccountName=$_.'ad group_name' #Anführungszeichen wegen Leerzeichen in den Spaltenköpfen
                 Mail=$_.'group_mail_address'
                 GroupScope='domainlocal'
                 GroupCategory='Distribution'
                 Description=$_.Description
                
               }
        #$obj
        $OBJ|New-ADGroup -Path $PATH -PassThru -ea stop
     }
}

