pragma solidity 0.4.15;

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
  mapping(bytes32 => Post) parents;


  // Map content hashes to posts
  mapping(bytes32 => Post) posts;

  // Need an event for when posts are posted
  // event NewPOst()


  // TODO: Do something with owner 
  function ClevrPosts() {
    owner = msg.sender;
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

    return true;
  }

  // Passing in the child hash
  function getParents(bytes32 _hash) 
  returns(
    uint256,
    address,
    uint256,
    uint256,
    bytes32) {

     return(parents[_hash].timePosted,
            parents[_hash].publisher,
            parents[_hash].numLikes,
            parents[_hash].numShares,
            parents[_hash].contentHash.hash);
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
