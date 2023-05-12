import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Result "mo:base/Result";

actor HomeworkDiary {
  type Homework = {
    title : Text;
    description : Text;
    dueDate : Time.Time;
    completed : Bool;
  };

  var homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size() - 1;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    var res = homeworkDiary.getOpt(id);
    switch (res) {
      case null #err "not found";
      case (?hw) #ok hw;
    };
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    var res = homeworkDiary.getOpt(id);
    switch (res) {
      case null #err "not found";
      case (?hw) {
        homeworkDiary.put(id, homework);
        #ok();
      };
    };
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    var res = homeworkDiary.getOpt(id);
    switch (res) {
      case null #err "not found";
      case (?hw) {
        let newHw : Homework = {
          title = hw.title;
          description = hw.description;
          dueDate = hw.dueDate;
          completed = true;
        };
        homeworkDiary.put(id, newHw);
        #ok();
      };
    };
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    var res = homeworkDiary.getOpt(id);
    switch (res) {
      case null #err "not found";
      case (?hw) {
        ignore homeworkDiary.remove(id);
        #ok();
      };
    };
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray<Homework>(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    homeworkDiary.filterEntries(func(_, x) = x.completed == false);
    return Buffer.toArray<Homework>(homeworkDiary);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework (searchTerm : Text) : async [Homework] {
    homeworkDiary.filterEntries(func(_, x) = x.title == searchTerm or x.description == searchTerm);
    return Buffer.toArray<Homework>(homeworkDiary);
  };
};
