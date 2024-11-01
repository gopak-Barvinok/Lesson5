import "@stdlib/deploy";

message Withdraw {
    amount: Int as coins;
}

contract SendTon with Deployable {
    
    const MinTonForStorage: Int = ton("0.01");
    owner: Address;
    init() {
        self.owner = sender();
    }

    receive() {
        
    }

    fun onlyOwner() {
        require(sender() == self.owner, "only owner is allowed to withdraw");
    }

    receive("withdraw all") {
        self.onlyOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: 0,
            mode: SendRemainingBalance + SendIgnoreErrors         
        });
    }

    receive("withdraw safe") {
        self.onlyOwner();
        send(SendParameters{
            to: sender(),
            bounce: true,
            //context().value - деньги в контексте, которые не учитывают те ноткоины, что придут вместе с сообщением
            value: myBalance() - context().value - self.MinTonForStorage,
            mode: SendIgnoreErrors + SendRemainingValue
        });
    }

    receive(msg: Withdraw) {
        self.onlyOwner();
        let amount: Int = min(msg.amount, myBalance() - context().value - self.MinTonForStorage);
        require(amount > 0, "insufficient balance");
        send(SendParameters{
            to: sender(),
            bounce: true,
            value: amount,
            mode: SendIgnoreErrors + SendRemainingValue
        });
    }

    get fun balance(): String {
        return myBalance().toCoinsString();
    }
}
