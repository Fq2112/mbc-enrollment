import Text "mo:base/Text";
import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Order "mo:base/Order";

actor StudentWall {
  public type Content = {
    #Text : Text;
    #Image : Blob;
    #Video : Blob;
  };

  type Message = {
    vote : Int;
    content : Content;
    creator : Principal;
  };

  var messageId : Nat = 0;

  var wall = HashMap.HashMap<Nat, Message>(0, Nat.equal, Hash.hash);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let message : Message = {
      content : Content = c;
      vote : Int = 0;
      creator : Principal = caller;
    };
    let id : Nat = messageId;
    wall.put(id, message);
    messageId += 1;
    return id;
  };

  //Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    var res = wall.get(messageId);
    switch (res) {
      case null #err "The message you're looking for was not found!";
      case (?msg) #ok msg;
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    var res = wall.get(messageId);
    switch (res) {
      case null #err "The message you're going to update was not found!";
      case (?msg) {
        if (Principal.notEqual(msg.creator, caller)) {
          return #err "The creator of this message was not you!";
        } else {
          let newMsg : Message = {
            msg with content = c;
          };
          ignore wall.replace(messageId, newMsg);
          #ok();
        };
      };
    };
  };

  //Delete a specific message by ID
  public shared func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    var res = wall.get(messageId);
    switch (res) {
      case null #err "The message you're going to delete was not found!";
      case (?msg) {
        ignore wall.remove(messageId);
        #ok();
      };
    };
  };

  // up Voting
  public shared func upVote(messageId : Nat) : async Result.Result<(), Text> {
    var res = wall.get(messageId);
    switch (res) {
      case null #err "The message you're going to vote was not found!";
      case (?msg) {
        let newMsg : Message = {
          msg with vote = msg.vote + 1;
        };
        ignore wall.replace(messageId, newMsg);
        #ok();
      };
    };
  };

  // down Voting
  public shared func downVote(messageId : Nat) : async Result.Result<(), Text> {
    var res = wall.get(messageId);
    switch (res) {
      case null #err "The message you're going to vote was not found!";
      case (?msg) {
        let newMsg : Message = {
          msg with vote = msg.vote - 1;
        };
        ignore wall.replace(messageId, newMsg);
        #ok();
      };
    };
  };

  //Get all messages
  public shared query func getAllMessages() : async [Message] {
    return Iter.toArray(wall.vals());
  };

  //Get all messages order by vote
  public shared query func getAllMessagesRanked() : async [Message] {
    var sortedArr = Array.sort(Iter.toArray(wall.vals()), _compareMessageVote);
    return Array.reverse(sortedArr);
  };

  private func _compareMessageVote(msg1 : Message, msg2 : Message) : Order.Order {
    return Int.compare(msg1.vote, msg2.vote);
  };
};
