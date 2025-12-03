pragma solidity ^0.4.17;

import "./DeedRepository.sol";

/**
 * @title 拍卖仓库
 * 这个合约允许为非同质化代币创建拍卖
 * 它还包括拍卖行的基本功能
 */
contract AuctionRepository {
    
    // 所有拍卖的数组
    Auction[] public auctions;

    // 从拍卖索引到用户出价的映射
    mapping(uint256 => Bid[]) public auctionBids;

    // 从所有者到拥有的拍卖列表的映射
    mapping(address => uint[]) public auctionOwner;

    // 出价结构体，包含出价人和金额
    struct Bid {
        address from;
        uint256 amount;
    }

    // 拍卖结构体，包含所有所需的信息
    struct Auction {
        string name;
        uint256 blockDeadline;
        uint256 startPrice;
        string metadata;
        uint256 deedId;
        address deedRepositoryAddress;
        address owner;
        bool active;
        bool finalized;
    }

    /**
    * @dev 确保msg.sender是给定拍卖的所有者
    * @param _auctionId uint 拍卖的ID，用于验证其所有权属于msg.sender
    */
    modifier isOwner(uint _auctionId) {
        require(auctions[_auctionId].owner == msg.sender);
        _;
    }

    /**
    * @dev 确保这个合约是给定代币的所有者
    * @param _deedRepositoryAddress 代币仓库的地址，用于验证
    * @param _deedId uint256 代币在代币仓库中注册的ID
    */
    modifier contractIsDeedOwner(address _deedRepositoryAddress, uint256 _deedId) {
        address deedOwner = DeedRepository(_deedRepositoryAddress).ownerOf(_deedId);
        require(deedOwner == address(this));
        _;
    }

    /**
    * @dev 禁止直接向这个合约支付
    */
    function() public{
        revert();
    }

    /**
    * @dev 获取拍卖的数量
    * @return uint 代表拍卖的数量
    */
    function getCount() public constant returns(uint) {
        return auctions.length;
    }

    /**
    * @dev 获取给定拍卖的出价数量
    * @param _auctionId uint 拍卖的ID
    */
    function getBidsCount(uint _auctionId) public constant returns(uint) {
        return auctionBids[_auctionId].length;
    }

    /**
    * @dev 获取拥有的拍卖数组
    * @param _owner 拍卖所有者的地址
    */
    function getAuctionsOf(address _owner) public constant returns(uint[]) {
        uint[] memory ownedAuctions = auctionOwner[_owner];
        return ownedAuctions;
    }

    /**
    * @dev 获取拥有的拍卖数组
    * @param _auctionId uint 拍卖的所有者
    * @return amount uint256, 最后出价者的地址
    */
    function getCurrentBid(uint _auctionId) public constant returns(uint256, address) {
        uint bidsLength = auctionBids[_auctionId].length;
        // 如果有出价，退还最后的出价
        if( bidsLength > 0 ) {
            Bid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            return (lastBid.amount, lastBid.from);
        }
        return (0, 0);
    }

    /**
    * @dev 获取地址拥有的拍卖总数
    * @param _owner 所有者的地址
    * @return uint 拍卖的总数
    */
    function getAuctionsCountOfOwner(address _owner) public constant returns(uint) {
        return auctionOwner[_owner].length;
    }

    /**
    * @dev 获取给定拍卖的信息，这些信息存储在结构体中
    * @param _auctionId uint 拍卖的ID
    * @return string 拍卖的名称
    * @return uint256 拍卖结束的时间戳
    * @return uint256 拍卖的起始价格
    * @return string 代表拍卖的元数据
    * @return uint256 在DeedRepository中注册的代币ID
    * @return address DeedRepository的地址
    * @return address 拍卖的所有者
    * @return bool 拍卖是否活跃
    * @return bool 拍卖是否已完成
    */
    function getAuctionById(uint _auctionId) public constant returns(
        string name,
        uint256 blockDeadline,
        uint256 startPrice,
        string metadata,
        uint256 deedId,
        address deedRepositoryAddress,
        address owner,
        bool active,
        bool finalized) {

        Auction memory auc = auctions[_auctionId];
        return (
            auc.name, 
            auc.blockDeadline, 
            auc.startPrice, 
            auc.metadata, 
            auc.deedId, 
            auc.deedRepositoryAddress, 
            auc.owner, 
            auc.active, 
            auc.finalized);
    }
    
    /**
    * @dev 使用给定的信息创建拍卖
    * @param _deedRepositoryAddress DeedRepository合约的地址
    * @param _deedId uint256 在DeedRepository中注册的代币
    * @param _auctionTitle string 包含拍卖标题的字符串
    * @param _metadata string 包含拍卖元数据的字符串
    * @param _startPrice uint256 拍卖的起始价格
    * @param _blockDeadline uint 拍卖结束的时间戳
    * @return bool 拍卖是否已创建
    */
    function createAuction(address _deedRepositoryAddress, uint256 _deedId, string _auctionTitle, string _metadata, uint256 _startPrice, uint _blockDeadline) public contractIsDeedOwner(_deedRepositoryAddress, _deedId) returns(bool) {
        uint auctionId = auctions.length;
        Auction memory newAuction;
        newAuction.name = _auctionTitle;
        newAuction.blockDeadline = _blockDeadline;
        newAuction.startPrice = _startPrice;
        newAuction.metadata = _metadata;
        newAuction.deedId = _deedId;
        newAuction.deedRepositoryAddress = _deedRepositoryAddress;
        newAuction.owner = msg.sender;
        newAuction.active = true;
        newAuction.finalized = false;
        
        auctions.push(newAuction);        
        auctionOwner[msg.sender].push(auctionId);
        
        emit AuctionCreated(msg.sender, auctionId);
        return true;
    }

    function approveAndTransfer(address _from, address _to, address _deedRepositoryAddress, uint256 _deedId) internal returns(bool) {
        DeedRepository remoteContract = DeedRepository(_deedRepositoryAddress);
        remoteContract.approve(_to, _deedId);
        remoteContract.transferFrom(_from, _to, _deedId);
        return true;
    }

    /**
    * @dev 由所有者取消正在进行的拍卖
    * @dev 代币将被转移回拍卖所有者
    * @dev 出价者将获得初始金额的退款
    * @param _auctionId uint 创建的拍卖的ID
    */
    function cancelAuction(uint _auctionId) public isOwner(_auctionId) {
        Auction memory myAuction = auctions[_auctionId];
        uint bidsLength = auctionBids[_auctionId].length;

        // 如果有出价，退还最后的出价
        if( bidsLength > 0 ) {
            Bid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            if(!lastBid.from.send(lastBid.amount)) {
                revert();
            }
        }

        // 批准并将代币从这个合约转移到拍卖所有者
        if(approveAndTransfer(address(this), myAuction.owner, myAuction.deedRepositoryAddress, myAuction.deedId)){
            auctions[_auctionId].active = false;
            emit AuctionCanceled(msg.sender, _auctionId);
        }
    }

    /**
    * @dev 完成已结束的拍卖
    * @dev 拍卖应该已结束，并且至少有一个出价
    * @dev 成功后，代币将被转移到出价者，拍卖所有者获得金额
    * @param _auctionId uint 创建的拍卖的ID
    */
    function finalizeAuction(uint _auctionId) public {
        Auction memory myAuction = auctions[_auctionId];
        uint bidsLength = auctionBids[_auctionId].length;

        // 1. 如果拍卖未结束，则回滚
        if( block.timestamp < myAuction.blockDeadline ) revert();
        
        // 如果没有出价，则取消
        if(bidsLength == 0) {
            cancelAuction(_auctionId);
        }else{

            // 2. 金额将转移到拍卖所有者
            Bid memory lastBid = auctionBids[_auctionId][bidsLength - 1];
            if(!myAuction.owner.send(lastBid.amount)) {
                revert();
            }

            // 批准并将代币从这个合约转移到出价者
            if(approveAndTransfer(address(this), lastBid.from, myAuction.deedRepositoryAddress, myAuction.deedId)){
                auctions[_auctionId].active = false;
                auctions[_auctionId].finalized = true;
                emit AuctionFinalized(msg.sender, _auctionId);
            }
        }
    }

    /**
    * @dev 出价者在拍卖上出价
    * @dev 拍卖应该是活跃的，并且未结束
    * @dev 如果有新的有效出价，退还上一个出价者
    * @param _auctionId uint 创建的拍卖的ID
    */
    function bidOnAuction(uint _auctionId) public payable {
        uint256 ethAmountSent = msg.value;

        // owner can't bid on their auctions
        Auction memory myAuction = auctions[_auctionId];
        if(myAuction.owner == msg.sender) revert();

        // if auction is expired
        if( block.timestamp > myAuction.blockDeadline ) revert();

        uint bidsLength = auctionBids[_auctionId].length;
        uint256 tempAmount = myAuction.startPrice;
        Bid memory lastBid;

        // there are previous bids
        if( bidsLength > 0 ) {
            lastBid = auctionBids[_auctionId][bidsLength - 1];
            tempAmount = lastBid.amount;
        }

        // check if amound is greater than previous amount  
        if( ethAmountSent < tempAmount ) revert(); 

        // refund the last bidder
        if( bidsLength > 0 ) {
            if(!lastBid.from.send(lastBid.amount)) {
                revert();
            }  
        }

        // insert bid 
        Bid memory newBid;
        newBid.from = msg.sender;
        newBid.amount = ethAmountSent;
        auctionBids[_auctionId].push(newBid);
        emit BidSuccess(msg.sender, _auctionId);
    }

    event BidSuccess(address _from, uint _auctionId);

    // AuctionCreated is fired when an auction is created
    event AuctionCreated(address _owner, uint _auctionId);

    // AuctionCanceled is fired when an auction is canceled
    event AuctionCanceled(address _owner, uint _auctionId);

    // AuctionFinalized is fired when an auction is finalized
    event AuctionFinalized(address _owner, uint _auctionId);
}