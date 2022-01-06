Import-Module ActiveDirectory

$ObjectTypeGUID = @{}

$GetADObjectParameter=@{
    SearchBase=(Get-ADRootDSE).SchemaNamingContext
    LDAPFilter='(SchemaIDGUID=*)'
    Properties=@("Name", "SchemaIDGUID")
}

$SchGUID=Get-ADObject @GetADObjectParameter
    Foreach ($SchemaItem in $SchGUID){
    $ObjectTypeGUID.Add([GUID]$SchemaItem.SchemaIDGUID,$SchemaItem.Name)
}

$ADObjExtPar=@{
    SearchBase="CN=Extended-Rights,$((Get-ADRootDSE).ConfigurationNamingContext)"
    LDAPFilter='(ObjectClass=ControlAccessRight)'
    Properties=@("Name", "RightsGUID")
}

$SchExtGUID=Get-ADObject @ADObjExtPar
    ForEach($SchExtItem in $SchExtGUID){
    try{
      $ObjectTypeGUID.Add([GUID]$SchExtItem.RightsGUID,$SchExtItem.Name)
    }catch{
      #write-Host "$($SchExtItem.RightsGUID):($ObjectTypeGUID[[GUID]$SchExtItem.RightsGUID]):$($SchExtItem.Name)"
    }
}   

function translateExtGUID{
   param(
     [Parameter(Mandatory=$true)]
     [Guid]$Guid
   )
   $ObjectType=$ObjectTypeGUID[$Guid]
   if(-not $ObjectType){
             $Guid.ToString()
   }else{
     $ObjectType
   }
}
function F_OU{ 
   param(
      [Parameter(Mandatory=$true)]
      $OC,
      [Parameter(ValueFromPipeline=$true)]
      $I
   )
   Begin{}
   Process{
     if(-not $OC -or $I.ObjectClass -in $OC ){
        #Write-Host "$($I.ObjectClass):$($I.distinguishedName)" 
        $I 
     }
   }
   end{}
}


function Analyze-ActiveDirectoryACLs{
param(
  [Parameter(Mandatory=$true)]
  [string]$Path,
  [Parameter(Mandatory=$false)]
  [string]$ObectClass='organizationalUnit',
  [switch]$all
)
   if($all){
     $ObectClass=''
   }

  $O=[pscustomobject]@{
     ObjectClass=$ObectClass.Split(',')
     Path=$Path
     ObjectByIdrefs=@{}
     AccessByObject=@{}  
  }
  

   Get-ChildItem -Path 'AD:DC=AHS,DC=local' -Recurse |F_OU -OC $O.ObjectClass|%{
      $P=$_
      $ACL=Get-Acl -Path "AD:$($P.distinguishedName)"
      $OACL=New-Object System.Collections.ArrayList
      $AccessObject=[pscustomobject]@{
         Object=$P.distinguishedName
         ACL=$ACL
         OACL=$OACL
      }
      $O.AccessByObject[$P.distinguishedName]=$AccessObject

      $ACL.Access |?{ -not $_.IsInherited} |%{
         $IDR=$_.IdentityReference.Value
         if(-not $IDR){
            Write-Host "$($_):$($P)"
         }else{
           $A=$O.ObjectByIdrefs[$IDR]
           if(-not $A){ 
              $A=New-Object System.Collections.ArrayList
              $O.ObjectByIdrefs[$IDR]=$A    
           }
           $DESC=[pscustomobject]@{
                   Object=$P.distinguishedName
                   IdentityReference=$IDR
                   AccessControlType=$_.AccessControlType                 
                   ActiveDirectoryRights=$_.ActiveDirectoryRights
                   ObjectType=translateExtGUID $_.ObjectType # $ObjectTypeGUID[$_.ObjectType]
                   InheritedObjectType=translateExtGUID $_.InheritedObjectType # $ObjectTypeGUID[$_.InheritedObjectType]
                   
                   IsInherited=$_.IsInherited             
                   Rule=$_
           }
           
                         
           $n=$A.Add($DESC)
           $n=$OACL.Add($DESC)
        }
      }
   }
   $O
}
