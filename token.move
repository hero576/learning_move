module 0xCAFE::Token {
  use 0xCAFE::MapUtil::{Self, Map};
  use 0xCAFE::StringUtil::{Self, String};
  use Std::Signer;

  struct Collection has key {
    name: String,
    description: String,
    supply: u64,
  }

  struct Token has store {
    id: u64,
    name: String,
  }

  struct TokenStore has key {
    tokens: Map<u64, Token>,
  }

  public fun create_collection(creator: &signer) {
    let addr = Signer::address_of(creator);
    
    let name = StringUtil::new(b"IMCODING NFT");
    let description = StringUtil::new(b"issued within imcoding.online");

    move_to(creator, Collection {
      name,
      description,
      supply: 0,
    });
  }

  public fun mint(creator: &signer) acquires Collection, TokenStore {
    let addr = Signer::address_of(creator);
    let collection = borrow_global_mut<Collection>(addr);
    let supply = &mut collection.supply;
    *supply = *supply + 1;
    let id = *supply;

    let name = StringUtil::new(b"IMCODING NFT #");
    StringUtil::append(&mut name, StringUtil::from_num(id));

    let token = Token {
      id,
      name,
    };
    deposit_token(creator, token);
  }

  public fun transfer(sender: &signer, receiver: &signer, id: u64) acquires TokenStore  {
    let token = withdraw_token(Signer::address_of(sender), id);
    deposit_token(receiver, token);
  }

  public fun token_ids(addr: address): vector<u64> acquires TokenStore {
    let token_store = borrow_global<TokenStore>(addr);
    let tokens = &token_store.tokens;
    MapUtil::keys(tokens)
  }

  fun deposit_token(account: &signer, token: Token) acquires TokenStore {
    let addr = Signer::address_of(account);
    if (!exists<TokenStore>(addr)) {
      move_to(account, TokenStore {
        tokens: MapUtil::new(),
      });
    };

    let token_store = borrow_global_mut<TokenStore>(addr);
    MapUtil::add(&mut token_store.tokens, token.id, token);
  }

  fun withdraw_token(addr: address, id: u64): Token acquires TokenStore {
    let token_store = borrow_global_mut<TokenStore>(addr);
    let tokens = &mut token_store.tokens;
    assert!(MapUtil::contains(tokens, &id), 100);
    let (_, value) = MapUtil::remove(tokens, &id);
    value
  }
}
