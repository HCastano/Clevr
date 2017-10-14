pragma solidity 0.4.17;

contract ClevrPosts {

  struct Multihash {
    bytes32 hash;
    uint8 hashFunction;
    uint8 size;
  }

 // Need to be public, figure out why 
  struct Post {
    Multihash contentHash;
    uint256 timePosted;
    address publisher;
    uint256 numLikes;// Think of changing to original name?
    uint256 numShares;
  }

  address public owner;

  // Map hash to parent post
  mapping(bytes32 => bytes32) parent_hashes;


  // Map content hashes to posts
  mapping(bytes32 => Post) posts;

  // Need an event for when posts are posted
  // event NewPOst()


  // TODO: Do something with owner 
  function ClevrPosts() {
    owner = msg.sender;
  }
  
  function cascadeLikes(bytes32 _hash) returns(bool){
    bytes32 parentIncrementer ;
    parentIncrementer = _hash;
    
    while (parentIncrementer!=0){
            parentIncrementer = incrementLikes(parentIncrementer);
    }
    
    return true;
  }
  
  function cascadeShares(bytes32 _hash) returns(bool){
    bytes32 parentIncrementer ;
    parentIncrementer = _hash;
    
    while (parentIncrementer!=0){
            parentIncrementer = incrementShares(parentIncrementer);
    }
    
    return true;
  }
   
  function incrementLikes(bytes32 _hash) returns(bytes32){
      posts[_hash].numLikes +=1;
      return parent_hashes[_hash];
  }
  function incrementShares(bytes32 _hash) returns(bytes32){
      posts[_hash].numShares +=1;
      return parent_hashes[_hash];
  }

  function createPost(bytes32 _hash, 
                   uint8 _hashFunction,
                   uint8 _size,
                   bytes32 _parentHash)
                   returns (bool) {

    require(_hash[0] != 0);
    require(_hashFunction  != 0);
    require(_size != 0);

    Post memory newPost;
    Multihash memory newMultihash;

    newMultihash.hash = _hash;
    newMultihash.hashFunction = _hashFunction;
    newMultihash.size = _size;

    newPost.contentHash = newMultihash;
    newPost.timePosted = now;
    newPost.publisher = msg.sender;
    newPost.numLikes = 0;
    newPost.numShares = 0;

    posts[newMultihash.hash] = newPost;
    parent_hashes[_hash] = _parentHash;
    if (_parentHash != 0){
        cascadeShares(_parentHash);
        
    }

    return true;
  }

  // Passing in the child hash
  function getParent(bytes32 _hash)  returns(uint256,
    address,
    uint256,
    uint256){
    return getPosts(getParentHash(_hash));
    
  }
  function getParentHash(bytes32 _hash)  returns(bytes32){
    return parent_hashes[_hash];
    
  }

  function getPosts(bytes32 _hash) returns(
    uint256,
    address,
    uint256,
    uint256) {

     return(posts[_hash].timePosted,
            posts[_hash].publisher,
            posts[_hash].numLikes,
            posts[_hash].numShares);
    }
}
