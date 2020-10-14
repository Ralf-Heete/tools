#Listet die direkten und indirekten Mitglieder einer Gruppe auf sofern es sich um Benutzer handelt
function Get-IndirectMembership($object,$hierarchy=''){

  if(-not $object.ObjectClass){
    if($object -like 'CN=*'){
      $object=Get-ADObject -filter "DistinguishedName -eq '$object'"
    }else{
      $object=Get-ADObject -filter "name -eq '$object'"
    }
  }
  
  if(-not $hierarchy){
    $hierarchy=$object.name
  }else{
    $hierarchy="$($hierarchy):$($object.name)"
  }
  
  
   
  if($object.ObjectClass -eq 'group'){
    (Get-ADGroup -Identity $object -Properties member).member |Get-ADObject |% {
       Get-IndirectMembership $_ $hierarchy
    }
  }else{
     if($_.ObjectClass -eq 'user'){
       #nur Userobjekte ausgeben
       $o=$_|Get-ADUser 
       [pscustomobject]@{
          Hierarchy=$hierarchy
          Enabled=$o.Enabled
          ObjectClass=$o.ObjectClass
          Name=$o.name
          DistinguishedName=$o.DistinguishedName   
       }  
     }else{
       [pscustomobject]@{
          Hierarchy=$hierarchy
          Enabled=$true
          ObjectClass=$_.ObjectClass
          Name=$_.name
          DistinguishedName=$_.DistinguishedName   
        }
       #write-host -ForegroundColor red "$($_.ObjectClass),$($_.Name)"     
     }
  }  
}
