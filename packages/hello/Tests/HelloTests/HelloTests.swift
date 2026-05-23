import Hello
import Testing

@Test
func messageReturnsSharedSwiftGreeting() {
  #expect(Greeting.message() == "Hello from shared Swift")
}
