pragma solidity ^0.4.17;

contract MFI{
    uint256 mfiID = 0;
    uint256 fundID = 0;
    uint256 invID = 0;
    uint256 lnID = 0;
    uint256 bID = 0;

    address owner;
    bytes32[] _mfinames;
    address[] _borrowerArray;
    mapping(uint256 => fund) _funds;
    mapping(uint256 => mfi) _mfi;
    mapping(uint256 => borrower) _borrowers;
    mapping(address => bool) _mfiaddress;

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
        address[] borrowers;
    }
    struct borrower{
        uint256 id;
        bytes32 name;
        address baddress;
        uint256 requestedAmount;
        uint256 approvedAmount;
        uint256[] borrowedAmount;
        uint256[] paidBackAmount;
        uint256[] paidBackDate;
    }

    function MFI() public {
        //mfiSignup("MFI","j@example.com",22222);
        //addFund(1,"Fund1",15,30,20180101,20181231,1000,2000);
        owner = msg.sender;
    }
    //"MFI12","jinijose@gmail.com",8891222515
    //"0x4d464931","0x6a696e696a6f736540676d61696c2e636f6d",8891222515
    //MFI.deployed().then(function(f) {f.mfiSignup('MFI12',15,30,20180401,20180730,100,500,'jinijose@gmail.com',8891222515).then(function(f) {console.log(f)})})
    //MFI.deployed().then(function(f) {f.mfiSignup('MFI12','jinijose@gmail.com',8891222515).then(function(f) {console.log(f.toString())})})
    function mfiSignup(bytes32 name, bytes32 email, uint256 cNo) public returns(bool) {
        require(name != "");
        require(email != "");
        require(cNo > 0);
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
        _mfiaddress[msg.sender] =  true;
        mfiEvent(mfiID,msg.sender,name,0,email,cNo);

        return true;
    }
    function isMFI() view public returns(bool){
        if(_mfiaddress[msg.sender] == true){
            return true;
        }
        return false;
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
        require(_funds[fundid].details[4] <= value);
        require(_funds[fundid].details[5] >= value);
        require(_funds[fundid].active == 1);
        require(_funds[fundid].details[2] >= now);
        require(_funds[fundid].details[3] <= now);

        owner.transfer(value);

        _funds[fundid].investedAmount.push(value);
        _funds[fundid].investedBy.push(msg.sender);
        _funds[fundid].investedDate.push(now);

        
        return true;
    }

    //allowance
    //approval

    function borrow(uint256 fundid,uint256 value,uint256 bid) public returns(bool){
        
        require(value > 0);
        require(_funds[fundid].details[6] >= value);
        require(_funds[fundid].details[7] <= value);
        require(_funds[fundid].details[2] >= now);
        require(_funds[fundid].details[3] <= now);
        require(arrsum(_funds[fundid].investedAmount) - arrsum(_funds[fundid].loanAmount) - value > 0);
        require(_borrowers[bid].approvedAmount >= arrsum(_borrowers[bid].borrowedAmount) + value);
        require(!isExistsA(_funds[fundid].borrowers,msg.sender));

        _funds[fundid].loanAmount.push(value);
        _funds[fundid].takenBy.push(msg.sender);
        _funds[fundid].loanDate.push(now);
        
        _borrowers[bid].borrowedAmount.push(value);
        return true;
    }
    function addBorrower(bytes32 name, address baddress, uint256 reqAmount,uint256 fundid) public returns(bool){
        require(!borrowerExists(_borrowerArray, baddress));
        require(!isExistsA(_funds[fundid].borrowers,baddress));

        borrower memory b;
        bID += 1;
        b.id = bID;
        b.name = name;
        b.baddress = baddress;
        b.requestedAmount = reqAmount;
        b.approvedAmount = 0;
        

        _borrowers[bID] = b;
        _borrowerArray.push(baddress);
        _funds[fundid].borrowers.push(baddress);
        return true;
    }
    function approveBorrowal(uint256 bid, uint256 value) public returns(bool){
        require(_borrowers[bid].approvedAmount <= _borrowers[bid].requestedAmount);

        _borrowers[bid].approvedAmount = _borrowers[bid].approvedAmount + value;
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
    function viewFund(uint256 id) view public returns(bytes32 name,uint256[] rates,uint active,uint256 TotalInvestment, uint256 TotalBorrowings){
        return(
            _funds[id].name,
            _funds[id].details,
            _funds[id].active,
            arrsum(_funds[id].investedAmount),
            arrsum(_funds[id].loanAmount)
        );
    }
    function viewBorrowing(uint256 id) view public returns(uint256[],address[],uint256[]){
        return(
            _funds[id].loanAmount,
            _funds[id].takenBy,
            _funds[id].loanDate
        );
    }
    function viewInvestment(uint256 id) view public returns(uint256[],address[],uint256[]){
        return(
            _funds[id].investedAmount,
            _funds[id].investedBy,
            _funds[id].investedDate
        );
    }

    function paybackToFund(uint256 fid,uint256 value, uint256 bid) public returns(bool){
        //accept borrowed amount
        //calculate interest
        //transfer to fund
        uint256 intr = _funds[fid].details[1];
        uint256 ttl = value + (value * intr / 100);
        owner.transfer(ttl);
        _borrowers[bid].paidBackAmount.push(value);
        _borrowers[bid].paidBackDate.push(now);
        return true;
    }
    function paybackToInvester(uint256 fid, uint256 value, uint256 iid) public returns(bool){
        uint256 intr = _funds[fid].details[0];
        uint256 ttl = value + (value * intr / 100);
        owner.transfer(ttl);
        return true;
    }
    function isExistsA(address[] _arr, address _who) pure private returns (bool) {
        for (uint i = 0; i < _arr.length; i++) {
            if (_arr[i] == _who) {
                return true;
            }
        }
        return false;
    }
    function isExists(bytes32[] _arr, bytes32 _who) pure private returns (bool) {
        for (uint i = 0; i < _arr.length; i++) {
            if (_arr[i] == _who) {
                return true;
            }
        }
        return false;
    }

    function arrsum(uint256[] arr) internal pure returns (uint256) {
        uint256 S;
        for(uint i;i < arr.length;i++) {
            S += arr[i];
        }
        return S;
    }

    function borrowerExists(address[] barr, address b) internal view returns(bool){

        for(uint i = 1;i <= barr.length; i++){
            require(barr[i] == b);
        }
        return false;
    }

    function viewBorrower(uint256 b) view public returns(bytes32 name, address add,uint256 rAmt, uint256 aAmt, uint256[] bAmts, uint256[] pAmts){
        return(
            _borrowers[b].name,
            _borrowers[b].baddress,
            _borrowers[b].requestedAmount,
            _borrowers[b].approvedAmount,
            _borrowers[b].borrowedAmount,
            _borrowers[b].paidBackAmount
        );
    }
} 
