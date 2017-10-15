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
    bytes32 prevPost; // hash of the next post

    uint256 numLikes;// Think of changing to original name?
    uint256 numShares;

    uint256 costToLike;
    uint256 costToShare;

    uint256 costGrowthRate;
  }

  address public owner;

  // Map hash to parent post
  mapping(bytes32 => bytes32) parent_hashes;


  // Map content hashes to posts
  mapping(bytes32 => Post) posts;
  
  // Map content addreses to posts
  mapping(address => Post) userPosts;

  // Need an event for when posts are posted
  // event NewPOst()

  modifier validHash(bytes32 _hash) {
    require(_hash[0] != 0);
    _;
  }

  // TODO: Do something with owner 
  function ClevrPosts() {
    owner = msg.sender;
  }

  
  function cascadeLikes(bytes32 _hash) payable returns(bool){
    require(msg.value == post[_hash].costToLike);

    uint256 amtLeft = msg.value;

    address[] creatorsToPay;
    uint256[] growthRates;

    bytes32 parentHash = _hash;
    uint256 parentIncrementer = 0;

    while (parentHash != 0) {
      creatorsToPay[parentIncrementer] = posts[parentHash].publisher;
      growthRates[parentIncrementer++] = posts[parentHash].costGrowthRate;

      parentHash = incrementLikes(parentHash);
    }

    for(uint i = 0; i < creatorsToPay.length; i++) {
      assert(this.balance >= amtLeft);
      creatorsToPay[i].transfer(post[i].costToLike * growthRates[i]);
    }

    return true;
  }


  // Compute costGrowthRate for each post  
  function cascadeShares(bytes32 _hash) returns(uint){
    address[] creatorsToPay;
    bytes32 parentHash = _hash;
    uint256 parentIncrementer = 0;

    while (parentHash != 0) {
      creatorsToPay[parentIncrementer++] = posts[parentHash].publisher;
      parentHash = incrementShares(parentHash);
    }

    return parentIncrementer;
  }
   
  function incrementLikes(bytes32 _hash) validHash(_hash) internal returns(bytes32){

    posts[_hash].numLikes +=1;
    return parent_hashes[_hash];
  }

  function incrementShares(bytes32 _hash) validHash(_hash) internal returns(bytes32){
      posts[_hash].numShares +=1;
      return parent_hashes[_hash];
  }

  function createPost(bytes32 _hash, 
                   uint8 _hashFunction,
                   uint8 _size,
                   bytes32 _parentHash)
                   validHash(_hash)
                   returns (bool) {

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

    if (userPosts[msg.sender].contentHash.hash[0] != 0) {
      newPost.prevPost =  userPosts[msg.sender].contentHash.hash;
    } else {
      newPost.prevPost = '0';
    }

    userPosts[msg.sender] = newPost;

    uint256 shares; 
    if (_parentHash != 0) {
        shares = cascadeShares(_parentHash);
        newPost.costGrowthRate = 1024 / (2 ** shares);
    }

    // Pay for the shares

    return true;
  }

  // Passing in the child hash
  function getParent(bytes32 _hash)  returns
  (uint256,
    address,
    uint256,
    uint256,
    bytes32){
    return getPost(getParentHash(_hash));
    
  }
  function getParentHash(bytes32 _hash)  returns(bytes32){
    return parent_hashes[_hash];
    
  }
  // last post
  function getPostForUser(address _userAddress) returns 
  ( uint256,
    address,
    uint256,
    uint256,
    bytes32)
    {
      Post post = userPosts[_userAddress];
      return (post.timePosted,post.publisher,post.numLikes,post.numShares,post.prevPost);
  }

  function getPost(bytes32 _hash) returns(
    uint256,
    address,
    uint256,
    uint256,
    bytes32) {

     return(posts[_hash].timePosted,
            posts[_hash].publisher,
            posts[_hash].numLikes,
            posts[_hash].numShares,
            posts[_hash].prevPost);
    }
}
