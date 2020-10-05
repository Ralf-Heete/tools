function GetUserIdrefs($file) {


  #Info Struktur 

  $INFO=[psobject]@{
        ID=(New-Guid).guid                                                 #Eindeutige Id
        FILE=$file                                                         #File Entry
        Owner=$ACL.Owner                                                   #Owner
        FileSystemRights=@{}                                               #Liste der in ACLs ausgeübten Berechtigungen, Bool
        Users=@{}                                                          #Liste der Benutzer mit ausgeübten Berechtigungen
        OldACL=Get-Acl $file.FullName                                      #Alte ACL
        ACL=New-Object System.Security.AccessControl.DirectorySecurity     #Neu zu erstellende ACL
        #Groups=[System.Collections.ArrayList]@()                           
        Modified=$false
        
  }

  #write-host $INFO

  $Files[$file.FullName]=$INFO

 

  $Info.OldACL.Access | %{
     $idref=$_.IdentityReference.Value.split('\\')
     if( $idref[0] -eq $USRDOM){
       try{
          $O=Get-ADUser $idref[1]
          if($O.ObjectClass -eq 'user'){
            # write-host 1
             #AD based IDREF to User
             if($Info.Users.ContainsKey($idref[1])){
               $UAM=$Info.Users[$idref[1]]
                               
             }else{
               #Write-Host -ForegroundColor Green 2
               $UAM=@{}
               $Info.Users[$idref[1]]=$UAM
             }

             $UAM[$_.FileSystemRights]=$true

             $Info.Modified=$true
             

          }else{
             throw
          }
       }catch{
          try{
            $INFO.ACL.AddAccessRule($_)
          }catch{
            write-host -ForegroundColor Magenta ('$INFO.ACL.AddAccessRule($_)',$idref[0],$idref[1])
          }
       }
    
     }else{
        $INFO.ACL.AddAccessRule($_)
        
     }      
  }
  if($Info.Modified){
    $INFO
  }
}
   
   
function AdjustAclIdref($Path){

 Get-ChildItem . | %{
     GetUserIdrefs $_
    
  }

}


#Aufruf im aktuellen Verzeichnis
#$LIStinfo =AdjustAclIdref .


