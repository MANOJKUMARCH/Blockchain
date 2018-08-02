pragma solidity ^0.4.24;

contract Portaluser{
    
    uint totalUsers;
    uint totalJobseekers;
    uint totalRecruiters;
    
    struct user{
        string name;
        Role role;
        uint experience;
        string expertise;
        uint salary;
        uint nopc; //nopc stands for number of past companies
        bytes32 userAddress;
    }
    
    user userDetails;
    user[] jobseekerDetails;
    user[] recruiterDetails;
    
    enum Role{Jobseeker,Recruiter}
    
    function userRegister(string _name,Role _role,uint _experience, string _expertise, uint _salary, uint _nopc) public returns(string){
        uint count;
        if(uint(_role) == 0){
            count = totalJobseekers;
            totalJobseekers += 1;
        }else{
            count = totalRecruiters;
            totalRecruiters += 1;
        }
        userDetails.name = _name;
        userDetails.role = _role;
        userDetails.experience = _experience;
        userDetails.expertise = _expertise;
        userDetails.salary = _salary;
        userDetails.nopc = _nopc;
        userDetails.userAddress = keccak256(msg.sender);
        totalUsers += 1;
        if(uint(_role) == 0){
            jobseekerDetails.push(userDetails);
        }else{
            recruiterDetails.push(userDetails);
        }
        return("Successfully registered");
        
    }
    
    function verifyJobseekerDetails(bytes32 _uAd) public view 
                            returns(string _name,Role _role,uint _experience, string _expertise, uint _salary, uint _nopc,bytes32 _userAddress){
        uint i;
        for (i=0;i<totalJobseekers;i++){
            if(jobseekerDetails[i].userAddress == _uAd) break;
        }
        return(
            jobseekerDetails[i].name,
            jobseekerDetails[i].role,
            jobseekerDetails[i].experience,
            jobseekerDetails[i].expertise,
            jobseekerDetails[i].salary,
            jobseekerDetails[i].nopc,
            jobseekerDetails[i].userAddress
            );
    }
    
    function searchJobseeker(string _expertise) public view returns(bytes32[]){
        uint i;
        uint j = 0;
        bytes32[] jbs;
        for (i=0;i<totalJobseekers;i++){
            if(keccak256(jobseekerDetails[i].expertise) == keccak256(_expertise)) {
            jbs[j] = jobseekerDetails[i].userAddress;
            j += 1;
            }
        }
        jbs.length = j;
        return(jbs);
    }
}