import Blob "mo:base/Blob";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import TrieMap "mo:base/TrieMap";
import Account "account";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";

actor MotoCoin {
  type Subaccount = Account.Subaccount;
  type Account = Account.Account;

  let ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  let token = {
    name : Text = "MotoCoin";
    symbol : Text = "MOC";
  };
  stable var totalTokens : Nat = 0;

  private let canisterId = "rww3b-zqaaa-aaaam-abioa-cai";

  // Returns the name of the token
  public shared query func name() : async Text {
    return token.name;
  };

  // Returns the symbol of the token
  public shared query func symbol() : async Text {
    return token.symbol;
  };

  // Returns the the total number of tokens on all accounts
  public shared query func totalSupply() : async Nat {
    for (val in ledger.vals()) {
      totalTokens += val;
    };
    return totalTokens;
  };

  // Returns the balance of the account
  public shared query func balanceOf(account : Account) : async (Nat) {
    switch (ledger.get(account)) {
      case (?balance) balance;
      case null 0;
    };
  };

  // Transfer tokens to another account
  public shared func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
    switch (ledger.get(from)) {
      case (?balance) {
        if (amount > balance) {
          return #err("Unable to make transaction! Your remaining token balance is " # Nat.toText(balance) # ".");
        } else {
          switch (ledger.get(to)) {
            case (?targetBalance) {
              var currSenderBalance : Nat = balance;
              var currTargetBalance : Nat = targetBalance;
              currSenderBalance -= amount;
              currTargetBalance += amount;
              ignore ledger.replace(from, currSenderBalance);
              ignore ledger.replace(to, currTargetBalance);
              return #ok();
            };
            case null {
              var currSenderBalance : Nat = balance;
              currSenderBalance -= amount;
              ignore ledger.replace(from, currSenderBalance);
              ledger.put(to, amount);
              return #ok();
            };
          };
        };
      };
      case null #err("Your token balance is 0!");
    };
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public shared func airDrop() : async Result.Result<(), Text> {
    let airDropCoin = 100;
    let studentsCanister : [Principal] = await getStudents();
    // let studentsCanister : [Principal] = await getAllStudentsPrincipalTest(); // only for testing purpose
    for (val in studentsCanister.vals()) {
      let acc : Account = {
        owner = val;
        subaccount = null;
      };
      switch (ledger.get(acc)) {
        case (?balance) {
          var currBalance : Nat = balance;
          currBalance += airDropCoin;
          ignore ledger.replace(acc, currBalance);
        };
        case null {
          ledger.put(acc, airDropCoin);
        };
      };
    };
    return #ok();
  };

  // the list of all principals of the students participating in the Bootcamp
  public func getStudents() : async [Principal] {
    let canister2 = actor (canisterId) : actor {
      getAllStudentsPrincipal : shared () -> async [Principal];
    };
    var students = await canister2.getAllStudentsPrincipal();
    return students;
  };

  /*
  * only for testing purpose, why? because
  * can't call the mainnet canister locally
  */
  // let textPrincipals : [Text] = [
  //   "un4fu-tqaaa-aaaab-qadjq-cai",
  //   "un4fu-tqaaa-aaaac-qadjr-cai",
  //   "un4fu-tqaaa-aaaad-qadjs-cai",
  //   "un4fu-tqaaa-aaaae-qadjt-cai",
  //   "un4fu-tqaaa-aaaaf-qadjv-cai",
  //   "un4fu-tqaaa-aaaag-qadjw-cai",
  //   "un4fu-tqaaa-aaaah-qadjx-cai",
  //   "un4fu-tqaaa-aaaai-qadjy-cai",
  //   "un4fu-tqaaa-aaaaj-qadjz-cai",
  //   "un4fu-tqaaa-aaaak-qadk1-cai",
  // ];
  // public shared func getAllStudentsPrincipalTest() : async [Principal] {
  //   let principalsText : Buffer.Buffer<Text> = Buffer.fromArray(textPrincipals);
  //   var index : Nat = 0;
  //   var principalsReady = Buffer.Buffer<Principal>(10);

  //   Buffer.iterate<Text>(
  //     principalsText,
  //     func(x) {
  //       let newPrincipal = Principal.fromText(principalsText.get(index));
  //       principalsReady.add(newPrincipal);
  //     },
  //   );
  //   return Buffer.toArray(principalsReady);
  // };
};
