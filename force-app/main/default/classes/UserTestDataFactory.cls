@isTest
public class UserTestDataFactory {
    
    public static User createUserRecord(String profileName,String roleName,List<String>Permissionset_Names){
        System.debug('called getProfile method');
        //querying profiles with profile name given
        User testUser = new User();
        Profile Userprofile = [SELECT Id, Name FROM Profile WHERE Name =:profileName LIMIT 1];
        System.debug(Userprofile.Id);
        
        //check if the list is empty or not then create a user
        if(Userprofile.Id==Null){
            System.debug('there is no profile with  name : '+profileName);
            
        }else{
            
            testUser.FirstName = 'testUser';
            testUser.LastName = profileName;
            testUser.Email = 'test@test.com';
            testUser.Username = 'test1122334444@test.com';
            testUser.ProfileId = Userprofile.Id;
            testUser.Alias = 'tcode1';
            testUser.CommunityNickname = 'test12'; 
            testUser.LocaleSidKey = 'en_US';
            testUser.TimeZoneSidKey = 'GMT';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.EmailEncodingKey = 'UTF-8';
            UserTestDataFactory.insertUserRecord(testUser);     
        }
        
        if(roleName!=Null){
            UserTestDataFactory.assignUserRole(testUser,roleName);
        }
        if(Permissionset_Names[0] != 'No permission set'){
            UserTestDataFactory.assignPermissionSet(testUser,Permissionset_Names); 
        }
        return testUser;
    }
    
    
    
    public static User assignUserRole(User insertedTestUser,String roleName){
        System.debug('called assign user role method');    
        //get userRole associated with a profile
        List<User> luserRoleForProfile= [SELECT UserRole.Name,UserRole.Id 
                                         FROM User WHERE ProfileId =:insertedTestUser.ProfileId AND UserRole.Name =:roleName];
        
        if(luserRoleForProfile.isEmpty()){
            System.debug('there is no combination of user role : '+roleName+' with this profile');
        }
        else{
            insertedTestUser.UserRoleId = luserRoleForProfile[0].UserRole.Id;
        }  
        System.debug(insertedTestUser.userRoleId);
        return UserTestDataFactory.updateUserRole(insertedTestUser); 
    }
    
    
    public static void assignPermissionSet(User updatedTestUser,List<String> Permissionset_Names){
        System.debug('called assignPermissionSet method');
        System.debug(updatedTestUser.Id);
        List<PermissionSetAssignment> lpermissionSetAssignments = new List<PermissionSetAssignment>();
        Map<String,Id> mPermissionSet = new Map<String,Id>();
        //query permission set for a particular profile and for a userRole 
        List<PermissionSetAssignment> permissionsetForRole = [SELECT PermissionSet.Name,PermissionSetId 
                                                              FROM PermissionSetAssignment 
                                                              WHERE Assignee.ProfileId=:updatedTestUser.profileId
                                                              AND Assignee.UserRole.Id =:updatedTestUser.UserRoleId];
        System.debug(permissionsetForRole);
        if(permissionsetForRole.isEmpty()){
            System.debug('there is no combination of permissionSet with profile : '+updatedTestUser.Profile.Name+' with role : '+updatedTestUser.UserRole.Name);
        }
        else{
            for(PermissionSetAssignment permiRec : permissionsetForRole){
                mPermissionSet.put(permiRec.PermissionSet.Name, permiRec.PermissionSetId);
            }
        }
        
        for(String permiName: Permissionset_Names){
            if(!mPermissionSet.keySet().contains(permiName)){
                System.debug('cannot assign this permissionSet : '+permiName+' for this user');
            }
            else{
                
                PermissionSetAssignment assignmentRec = new PermissionSetAssignment();
                assignmentRec.AssigneeId = updatedTestUser.Id;
                assignmentRec.PermissionSetId = mPermissionSet.get(permiName);
                lpermissionSetAssignments.add(assignmentRec);
            }
        }
        if(!lpermissionSetAssignments.isEmpty())
            UserTestDataFactory.insertPermAssignment(lpermissionSetAssignments);
    }
    
    
    //insert created user
    public static User insertUserRecord(User testUser){
        System.debug('called insertUserRecord method');
        insert testUser;
        return testUser;
        //insert userRole
    }
    //method to update user
    public static User updateUserRole(User userToAssignRole){
        update userToAssignRole;
        return userToAssignRole;
    }
    
    //method to insert permissionSetAssignments
    public static void insertPermAssignment(List<PermissionSetAssignment> lpermissionSetAssignments){
        System.debug('called insertPermAssignment method');
        insert lpermissionSetAssignments;
    }
    
    
    
}