// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;
import "artifacts/console/node_modules/@nomiclabs/buidler/console.sol";
import "artifacts/node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "artifacts/node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "artifacts/node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "./libraries/Base64.sol";


contract myepicgame is ERC721{
    struct characterattributes{
        uint index;
        string name;
        string imageURI;
        uint hp;
        uint level;
        uint maxhp;
        uint damage;
    }
  struct boss{
  string name;
  string imageURI;
  uint hp;
  uint maxhp;
  uint damage;
}
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds; 
    characterattributes[] defaultcharacters;
    mapping (uint => characterattributes) public nftattributes;
    mapping (address =>uint) public nftholder;
    event nftminted(address sender,uint tokenid,uint charindex);
    event attackcomplete(address sender,uint newbosshp,uint newplayerhp);
    boss public bigboss;
constructor (string[] memory names, string[] memory uris, uint[] memory damages, uint[] memory hps , string memory bossname,string memory uri,uint bosshp,uint bossattack)
 ERC721("Ninjas","NINJA"){
    for(uint i=0;i<names.length;i++){
        defaultcharacters.push(characterattributes({
            index :i ,
            name : names[i],
            imageURI:uris[i],
            hp:hps[i],
            damage:damages[i],
            level:1,
            maxhp:hps[i]
        }));
        characterattributes memory c = defaultcharacters[i];
       console.log("Done initializing %s w/ ,image %s",c.name,c.imageURI);
       console.log("Hp %s,level %s damage %s",c.hp,c.level,c.damage);
       _tokenIds.increment();
      }
      bigboss=boss({
        name:bossname,
        imageURI:uri,
        hp:bosshp,
        maxhp:bosshp,
        damage:bossattack
       });
       console.log("Done initializing boss %s w/ img %s", bigboss.name, bigboss.imageURI);
        console.log("Hp %s,damage %s",bigboss.hp,bigboss.damage);

       
    }
    function mintNFT(uint char_index)external{
        uint itemId=_tokenIds.current();
        _safeMint(msg.sender, itemId);

        nftattributes[itemId]=characterattributes({
        index: char_index,
        name: defaultcharacters[char_index].name,
        imageURI: defaultcharacters[char_index].imageURI,
        level:defaultcharacters[char_index].level,
        hp: defaultcharacters[char_index].hp,
        maxhp: defaultcharacters[char_index].maxhp,
        damage: defaultcharacters[char_index].damage
        });
      console.log("Minted NFT w/ tokenId %s and characterIndex %s", itemId, char_index); 
      nftholder[msg.sender]=itemId;
      _tokenIds.increment();
      emit nftminted(msg.sender, itemId, char_index);
    }
function tokenURI(uint _tokenId) public view override returns (string memory){
    characterattributes memory charattributes=nftattributes[_tokenId];
    string memory strhp=Strings.toString(charattributes.hp);
    string memory strmaxhp=Strings.toString(charattributes.maxhp);
    string memory strdamage=Strings.toString(charattributes.damage);

 string memory json = Base64.encode(
    abi.encodePacked(
      '{"name": "',charattributes.name,
      ' -- NFT #: ',Strings.toString(_tokenId),
      '", "description": "This is an NFT that lets people play in the game Ninjaverse !","image": "',charattributes.imageURI,
      '","attributes": [ { "trait_type": "Health Points", "value": ',strhp,', "max_value":',strmaxhp,'}, { "trait_type": "Attack Damage", "value": ',strdamage,'} ]}'
    )
  );   
  string memory output = string(
 abi.encodePacked("data:application/json;base64,", json)
  );
  return output;
}
function attackboss() public {
  uint playernfttoken=nftholder[msg.sender];
  characterattributes storage player = nftattributes[playernfttoken];
   console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.damage);
  console.log("Boss %s has %s HP and %s AD", bigboss.name, bigboss.hp, bigboss.damage);
   require (
    player.hp > 0,
    "Error: character must have HP to attack boss."
  );

  // Make sure the boss has more than 0 HP.
  require (
    bigboss.hp > 0,
    "Error: boss must have HP to attack character."
  );
  if (bigboss.hp < player.damage) {
    bigboss.hp = 0;
  } else {
    bigboss.hp = bigboss.hp - player.damage;
  }
  if (player.hp < bigboss.damage) {
    player.hp = 0;
  } else {
    player.hp = player.hp - bigboss.damage;
  }
  console.log("Player attacked boss. New boss hp: %s", bigboss.hp);
  console.log("Boss attacked player. New player hp: %s\n", player.hp);
  emit attackcomplete(msg.sender, bigboss.hp, player.hp);
}


function checkifuserhasnft()public view returns(characterattributes memory){
  uint itemid=nftholder[msg.sender];
  if(itemid>0){
    return nftattributes[itemid];
  }
  else{
    characterattributes memory emptystruct;
    return emptystruct; 
  }
}
function displaycharacters()public view returns(characterattributes[] memory){
    return defaultcharacters;
}

function showboss()public view returns(boss memory){
  return bigboss;
}



}


