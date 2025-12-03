pragma solidity ^0.4.17;
import "./ERC721/ERC721Token.sol";

/**
 * @title ERC721 Deeds仓库
 * 这个合约包含用户注册的Deeds列表。
 * 这是一个演示，展示如何将tokens（Deeds）mint并添加到仓库中。
 */
contract DeedRepository is ERC721Token {

    /**
    * @dev 使用名称和符号创建DeedRepository
    * @param _name string 表示仓库名称
    * @param _symbol string 表示仓库符号
    */
    function DeedRepository(string _name, string _symbol) public ERC721Token(_name, _symbol) {}
    
    /**
    * @dev 公共函数用于注册新Deed
    * @dev 调用ERC721Token Minter
    * @param _tokenId uint256 表示特定Deed
    * @param _uri string 包含元数据/uri
    */
    function registerDeed(uint256 _tokenId, string _uri) public {
        _mint(msg.sender, _tokenId);
        addDeedMetadata(_tokenId, _uri);
        emit DeedRegistered(msg.sender, _tokenId);
    }

    /**
    * @dev 公共函数用于向Deed添加元数据
    * @param _tokenId 表示特定Deed
    * @param _uri 描述给定Deed特征的文本
    * @return Deed元数据是否被添加到仓库
    */
    function addDeedMetadata(uint256 _tokenId, string _uri) public returns(bool){
        _setTokenURI(_tokenId, _uri);
        return true;
    }

    /**
    * @dev 如果Deed/token被注册，则触发事件
    * @param _by 注册者的地址
    * @param _tokenId uint256 表示特定Deed
    */
    event DeedRegistered(address _by, uint256 _tokenId);
}