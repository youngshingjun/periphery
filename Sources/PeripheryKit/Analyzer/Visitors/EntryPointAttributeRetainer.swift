import Foundation

final class EntryPointAttributeRetainer: SourceGraphVisitor {
    static func make(graph: SourceGraph) -> Self {
        return self.init(graph: graph)
    }

    private let graph: SourceGraph

    required init(graph: SourceGraph) {
        self.graph = graph
    }

    func visit() {
        let classes = graph.declarations(ofKinds: [.class, .struct])
        let mainClasses = classes.filter {
            $0.attributes.contains("NSApplicationMain") ||
            $0.attributes.contains("UIApplicationMain") ||
            $0.attributes.contains("main")
        }

        mainClasses.forEach {
            graph.markRetained($0)

            $0.ancestralDeclarations.forEach {
                graph.markRetained($0)
            }

            if $0.attributes.contains("main") {
                // @main requires a static main() function.
                $0.declarations
                    .filter { $0.kind == .functionMethodStatic && $0.name == "main()"}
                    .forEach { graph.markRetained($0) }
            }
        }
    }
}
