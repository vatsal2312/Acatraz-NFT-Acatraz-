// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7; 

import './Context.sol';
import './Ownable.sol';
import './ReentrancyGuard.sol';
import './MerkleProof.sol';
import './Strings.sol';
import './ERC721A.sol';
import './IERC721A.sol';

contract AcatrazNFT is ERC721A, Ownable {
    using Strings for uint256;

    string public uri_common = "https://bafybeiaxcxfipifcrbchn4nenod5qlycqh242elqjkasqq6q6wfmaj64h4.ipfs.nftstorage.link/";

    uint public price = 0.1 ether;
    uint public collectionSize = 4444;

    uint public status = 3;
    uint public mint_perTxn = 3;
    uint public mint_perAdd = 3;

    bytes32 public merkleRoot = 0x6dda27bb24289cd482fe990e245166cbe0ee289047013366bf025558e08fc9ce;
    function setMerkleRoot(bytes32 m) public onlyOwner{
        merkleRoot = m;
    }

    constructor() ERC721A("Acatraz NFT", "Acatraz")  {}

    function giveaway(address recipient, uint quantity) public onlyOwner {
        require(totalSupply() + quantity <= collectionSize, "Giveaway exceeds current batch!!!");
        _safeMint(recipient, quantity);
    }

    function mint_WL(uint quantity, bytes32[] calldata merkleproof) public payable {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify( merkleproof, merkleRoot, leaf),"Not whitelisted");
        
        require(status == 1, "Whitelist Minting not active!!");
        require(quantity <= mint_perTxn && quantity > 0, "Invalid mint quantity!!");
        require(numberMinted(msg.sender) + quantity <= mint_perAdd && quantity > 0, "Invalid mint quantity!!");
        require(quantity * price >= msg.value, "Insufficient eth sent for mint!!");
        require(totalSupply() + quantity <= collectionSize, "Mint exceeds Collection size!!");
        
        _safeMint(msg.sender, quantity);
    }

    function mint(uint quantity) public payable {
        require(status == 2, "Public Minting not active!!");
        require(quantity <= mint_perTxn && quantity > 0, "Invalid mint quantity!!");
        require(numberMinted(msg.sender) + quantity <= mint_perAdd && quantity > 0, "Invalid mint quantity!!");
        require(quantity * price >= msg.value, "Insufficient eth sent for mint!!");
        require(totalSupply() + quantity <= collectionSize, "Mint exceeds Collection size!!");
        
        _safeMint(msg.sender, quantity);
    }

    function startWL() public onlyOwner {
        price = 0.08 ether;
        mint_perAdd = 2;
        mint_perTxn = 2;
        status = 1;
    }
    function startPublic() public onlyOwner {
        price = 0.1 ether;
        mint_perAdd = 3;
        mint_perTxn = 3;
        status = 2;
    }

    function distributeRewards() public payable onlyOwner {
        for(uint i = 1 ; i <= totalSupply() ; i ++)
        payable(ownerOf(i)).transfer(msg.value/totalSupply());
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        uri_common = baseURI;
    }
    function setPrice(uint256 number) public onlyOwner() {
        price = number;
    }
    function setMaxxQtPerTx(uint256 number) public onlyOwner {
        mint_perTxn = number;
    }
    function setMaxxQtPerAdd(uint256 number) public onlyOwner {
        mint_perAdd = number;
    }
    function setStatus(uint256 number) public onlyOwner {
        status = number;
    }    
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(uri_common, (tokenId).toString(), ".json"));
    }
    function _startTokenId() pure internal override returns (uint256) {
        return 1;
    }
    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }
}
