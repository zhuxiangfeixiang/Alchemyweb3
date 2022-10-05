// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "hardhat/console.sol";
contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Track {
        uint256 id;
        uint256 level;
        uint256 hp;
        }
    mapping(uint256 => Track) public tracks;

    // Initializing the state variable
    uint randNonce = 0;
    constructor() ERC721("Chain Battles", "CBTLS") {
    }
    function generateCharacter(uint256 tokenId) public view returns (string memory) {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            "<text x='50%' y='30%' class='base' dominant-baseline='middle' text-anchor='middle'>Warrior</text>",
            "<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>Id:",getId(tokenId),"</text>",
            "<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>Levels:",getLevel(tokenId),"</text>",
            "<text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>HP:",getHP(tokenId),"</text>",
           
            "</svg>"
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )
        );
    }

    function getId(uint256 tokenId) public view returns(string memory) {
        Track memory track = tracks[tokenId];
        return track.id.toString();
    }

    function getLevel(uint256 tokenId) public view returns(string memory) {
        Track memory track = tracks[tokenId];
        return track.level.toString();
    }

    function getHP(uint256 tokenId) public view returns(string memory) {
        Track memory track = tracks[tokenId];
        return track.hp.toString();
    }

    function randMod() internal returns(uint)
    {
        // increase nonce
        randNonce++; 
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 100;
    }

    function getTokenURI(uint256 tokenId) public view returns(string memory) {
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        uint256 randId = randMod();
        tracks[newItemId] = Track(randId, 0, 0);
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing Token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to train it");
        Track memory track ;
        Track memory current = tracks[tokenId];
        track = Track(current.id, current.level+1, current.hp+5);
        tracks[tokenId] = track;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}