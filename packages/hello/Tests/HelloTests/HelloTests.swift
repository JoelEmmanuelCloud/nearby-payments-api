import Testing
import Hello

@Test
func messageReturnsSharedSwiftGreeting() {
    #expect(Greeting.message() == "Hello from shared Swift")
}
