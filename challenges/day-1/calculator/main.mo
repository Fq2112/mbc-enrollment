import Int "mo:base/Int";
import Error "mo:base/Error";
import Float "mo:base/Float";

actor Calculator {
  // Step 1 -  Define a mutable variable called `counter`.
  stable var counter : Float = 0;

  // Step 2 - Implement add
  public shared func add(x : Float) : async Float {
    counter += x;
    counter;
  };

  // Step 3 - Implement sub
  public shared func sub(x : Float) : async Float {
    counter -= x;
    counter;
  };

  // Step 4 - Implement mul
  public shared func mul(x : Float) : async Float {
    counter *= x;
    counter;
  };

  // Step 5 - Implement div
  public shared func div(x : Float) : async Float {
    if (x > 0) {
      counter /= x;
      counter;
    } else {
      throw Error.reject("Undefined!");
    };
  };

  // Step 6 - Implement reset
  public shared func reset() : async () {
    counter := 0;
  };

  // Step 7 - Implement query
  public query func see() : async Float {
    counter;
  };

  // Step 8 - Implement power
  public shared func power(x : Float) : async Float {
    counter := Float.pow(counter, x);
    counter;
  };

  // Step 9 - Implement sqrt
  public shared func sqrt() : async Float {
    counter := Float.sqrt(counter);
    counter;
  };

  // Step 10 - Implement floor
  public shared func floor() : async Float {
    counter := Float.floor(counter);
    counter;
  };
};
