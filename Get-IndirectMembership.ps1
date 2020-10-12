function Get-IndirectMembership($object,$hierarchy=''){

  if(-not $object.ObjectClass){
    $object=Get-ADObject -filter "name -eq '$object'"
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
     [psobject]@{
        Hierarchy=$hierarchy
        ObjectClass=$_.ObjectClass
        Name=$_.name
        DistinguishedName=$_.DistinguishedName     
     }
  }  
}
