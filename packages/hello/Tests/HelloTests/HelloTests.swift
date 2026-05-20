import Testing
import Hello

@Test
func messageReturnsSharedSwiftGreeting() {
    #expect(Hello.message() == "Hello from shared Swift")
}
