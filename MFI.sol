pragma solidity ^0.4.17;

contract MFI{
    uint256 mfiID = 0;
    uint256 fundID = 0;
    uint256 invID = 0;
    uint256 lnID = 0;

    bytes32[] _mfinames;
    mapping(uint256 => fund) _funds;
    mapping(uint256 => mfi) _mfi;

    event mfiEvent(
        uint256 uID,
        address owner,
        bytes32 name,
        uint256 rating,
        bytes32 email,
        uint contactNo
    );

    event fundEvent(
        uint256 uID,
        uint256 mfiID,
        bytes32 name,
        uint256 depositRate,
        uint256 loanRate,
        uint256 startDate,
        uint256 endDate,
        uint256 minInvestment,
        uint256 maxInvestment,
        uint active
    );
    struct mfi{
        uint256 uid;
        address owner;
        bytes32 name;
        uint256 rating;
        bytes32 email;
        uint contactNo;
        uint256[] funds;
    }
    struct fund{
        uint256 uid;
        uint256 mfiid;
        bytes32 name;
        uint256[] details;
        uint active;
        uint256[] investedAmount;
        address[] investedBy;
        uint256[] investedDate;
        uint256[] loanAmount;
        address[] takenBy;
        uint256[] loanDate;
    }
    

    function MFI() public {

    }
    //"MFI12",15,30,20180401,20180730,100,500,"jinijose@gmail.com",8891222515
    //MFI.deployed().then(function(f) {f.mfiSignup('MFI12',15,30,20180401,20180730,100,500,'jinijose@gmail.com',8891222515).then(function(f) {console.log(f)})})
    //MFI.deployed().then(function(f) {f.mfiSignup('MFI12','jinijose@gmail.com',8891222515).then(function(f) {console.log(f.toString())})})
    function mfiSignup(bytes32 name, bytes32 email, uint256 cNo) public returns(bool) {
        require(name != "");
        require(email!="");
        require(cNo>0);
        require(!isExists(_mfinames,name));

        mfiID = mfiID + 1;
        mfi memory m;
        m.uid = mfiID;
        m.owner = msg.sender;
        m.name = name;
        m.rating = 0;
        m.email = email;
        m.contactNo = cNo;

        _mfi[mfiID] = m;
        _mfinames.push(name);
        mfiEvent(mfiID,msg.sender,name,0,email,cNo);

        return true;
    }

    function addFund(uint256 mfiid,bytes32 name, uint256 dRate, uint256 lRate, uint256 sDate, uint256 eDate, uint256 mnInv, uint256 mxInv) public returns(bool) {
        require(name != "");
        require(dRate > 0);
        require(lRate > 0);
        require(sDate > 0);
        require(eDate > 0);
        require(mnInv > 0);
        require(mxInv > 0);
        require(sDate < eDate);
        require(mnInv < mxInv);
        require(dRate < lRate);

        fundID = fundID + 1;
        uint256[] memory r = new uint256[](6);

        r[0] = dRate;
        r[1] = lRate;
        r[2] = sDate;
        r[3] = eDate;
        r[4] = mnInv;
        r[5] = mxInv;

        fund memory f;
        f.uid = fundID;
        f.mfiid = mfiid;
        f.name = name;
        f.details = r;
        f.active = 1;

        _funds[fundID] = f;

        _mfi[mfiid].funds.push(fundID);
        fundEvent(fundID,mfiid,name,dRate,lRate,sDate,eDate,mnInv,mxInv,0);
        return true;
    }
    function invest(uint256 fundid, uint256 value) public payable returns(bool){
        require(fundid > 0);
        //require(value > 0);
        _mfi[_funds[fundid].mfiid].owner.transfer(value);

        _funds[fundid].investedAmount.push(value);
        _funds[fundid].investedBy.push(msg.sender);
        _funds[fundid].investedDate.push(now);
        return true;
    }

    function borrow(uint256 fundid,uint256 value) public returns(bool){
        
        require(value > 0);
        _funds[fundid].loanAmount.push(value);
        _funds[fundid].takenBy.push(msg.sender);
        _funds[fundid].loanDate.push(now);

        return true;
    }
    
    function viewMFI(uint256 id) view public returns(address Owner,bytes32 Name,
    uint256 Rating,bytes32 Email,uint ContactNo,uint256[] FundsList){
        return(
            _mfi[id].owner,
            _mfi[id].name,
            _mfi[id].rating,
            _mfi[id].email,
            _mfi[id].contactNo,
            _mfi[id].funds
        );
    }
    function viewFund(uint256 id) view public returns(bytes32 name,uint256[] rates,uint){
        return(
            _funds[id].name,
            _funds[id].details,
            _funds[id].active
        );
    }
    function viewLoans(uint256 id) view public returns(uint256[],address[],uint256[]){
        return(
            _funds[id].loanAmount,
            _funds[id].takenBy,
            _funds[id].loanDate
        );
    }
    function viewInvestments(uint256 id) view public returns(uint256[],address[],uint256[]){
        return(
            _funds[id].investedAmount,
            _funds[id].investedBy,
            _funds[id].investedDate
        );
    }

    function paybackToMFI(uint256 fid,uint256 value) public returns(bool){
        
        return true;
    }

    function isExists(bytes32[] _arr, bytes32 _who) pure private returns (bool) {
        for (uint i = 0; i < _arr.length; i++) {
            if (_arr[i] == _who) {
                return true;
            }
        }
        return false;
    }
} 