import SwiftGodot

protocol WithinViewport: Node {}

extension WithinViewport {
	var viewport: Viewport { getViewport()! }
	var viewportRect: Rect2 { viewport.getVisibleRect() }
}
